{%- from "linux/map.jinja" import network with context %}
{%- from "linux/map.jinja" import system with context %}
{%- if network.enabled %}

{%- set dpdk_enabled = network.get('dpdk', {}).get('enabled', False) %}
{%- if dpdk_enabled %}
include:
- linux.network.dpdk
{%- endif %}

{%- macro set_param(param_name, param_dict) -%}
{%- if param_dict.get(param_name, False) -%}
- {{ param_name }}: {{ param_dict[param_name] }}
{%- endif -%}
{%- endmacro -%}

{%- if network.bridge != 'none' %}

linux_network_bridge_pkgs:
  pkg.installed:
  {%- if network.bridge == 'openvswitch' %}
  - pkgs: {{ network.ovs_pkgs | json }}
  {%- else %}
  - pkgs: {{ network.bridge_pkgs | json }}
  {%- endif %}

{%- endif %}

{%- for f in network.get('concat_iface_files', []) %}

{%- if salt['file.file_exists'](f.src) %}

append_{{ f.src }}_{{ f.dst }}:
  file.append:
    - name: {{ f.dst }}
    - source: {{ f.src }}

remove_appended_{{ f.src }}:
  file.absent:
    - name: {{ f.src }}

{%- endif %}

{%- endfor %}

{%- for f in network.get('remove_iface_files', []) %}

remove_iface_file_{{ f }}:
  file.absent:
    - name: {{ f }}

{%- endfor %}

{%- if network.interface is defined %}

remove_cloud_init_file:
  file.absent:
  - name: /etc/network/interfaces.d/50-cloud-init.cfg

{%- endif %}

{%- for interface_name, interface in network.interface.items() %}

{%- set interface_name = interface.get('name', interface_name) %}

{# add linux network interface into OVS dpdk bridge #}

{%- if interface.type == 'dpdk_ovs_bridge' %}

{%- for int_name, int in network.interface.items() %}

{%- set int_name = int.get('name', int_name) %}

{%- if int.ovs_bridge is defined and interface_name == int.ovs_bridge %}

add_int_{{ int_name }}_to_ovs_dpdk_bridge_{{ interface_name }}:
  cmd.run:
    - unless: ovs-vsctl show | grep -w {{ int_name }}
    - name: ovs-vsctl{%- if network.ovs_nowait %} --no-wait{%- endif %} add-port {{ interface_name }} {{ int_name }}
{%- endif %}
{%- endfor %}

linux_interfaces_include_{{ interface_name }}:
  file.prepend:
  - name: /etc/network/interfaces
  - text: |
      source /etc/network/interfaces.d/*
      # Workaround for Upstream-Bug: https://github.com/saltstack/salt/issues/40262
      source /etc/network/interfaces.u/*

{# create override for openvswitch dependency for dpdk br-prv #}
/etc/systemd/system/ifup@{{ interface_name }}.service.d/override.conf:
  file.managed:
    - makedirs: true
    - require:
      - cmd: linux_network_dpdk_bridge_interface_{{ interface_name }}
    - contents: |
        [Unit]
        Requires=openvswitch-switch.service
        After=openvswitch-switch.service

dpdk_ovs_bridge_{{ interface_name }}:
  file.managed:
  - name: /etc/network/interfaces.u/ifcfg-{{ interface_name }}
  - makedirs: True
  - source: salt://linux/files/ovs_bridge
  - defaults:
      bridge: {{ interface|yaml }}
      bridge_name: {{ interface_name }}
  - template: jinja

dpdk_ovs_bridge_up_{{ interface_name }}:
  cmd.run:
  - name: ifup {{ interface_name }}
  - require:
    - file: dpdk_ovs_bridge_{{ interface_name }}
    - file: linux_interfaces_final_include

{%- endif %}

{# it is not used for any interface with type preffix dpdk,eg. dpdk_ovs_port #}
{%- if interface.get('managed', True) and not 'dpdk' in interface.type %}

{%- if grains.os_family in ['RedHat', 'Debian'] %}

{%- if interface.type == 'ovs_bridge' %}

ovs_bridge_{{ interface_name }}_present:
  openvswitch_bridge.present:
  - name: {{ interface_name }}

{# add linux network interface into OVS bridge #}
{%- for int_name, int in network.interface.items() %}

{%- set int_name = int.get('name', int_name) %}

{%- if int.ovs_bridge is defined and interface_name == int.ovs_bridge %}

add_int_{{ int_name }}_to_ovs_bridge_{{ interface_name }}:
  cmd.run:
    - unless: ovs-vsctl show | grep {{ int_name }}
    - name: ovs-vsctl{%- if network.ovs_nowait %} --no-wait{%- endif %} add-port {{ interface_name }} {{ int_name }}
{%- endif %}
{%- endfor %}

linux_interfaces_include_{{ interface_name }}:
  file.prepend:
  - name: /etc/network/interfaces
  - text: |
      source /etc/network/interfaces.d/*
      # Workaround for Upstream-Bug: https://github.com/saltstack/salt/issues/40262
      source /etc/network/interfaces.u/*

ovs_bridge_{{ interface_name }}:
  file.managed:
  - name: /etc/network/interfaces.u/ifcfg-{{ interface_name }}
  - makedirs: True
  - source: salt://linux/files/ovs_bridge
  - defaults:
      bridge: {{ interface|yaml }}
      bridge_name: {{ interface_name }}
  - template: jinja

ovs_bridge_up_{{ interface_name }}:
  cmd.run:
  - name: ifup {{ interface_name }}
  - require:
    - file: ovs_bridge_{{ interface_name }}
    - file: linux_interfaces_final_include

{%- elif interface.type == 'ovs_bond' %}
ovs_bond_{{ interface_name }}:
  cmd.run:
    - name: ovs-vsctl add-bond {{ interface.bridge }} {{ interface_name }} {{ interface.slaves }} bond_mode={{ interface.mode }}
    - unless: ovs-vsctl show | grep -A 2 'Port.*{{ interface_name }}.'
    - require:
      - ovs_bridge_{{ interface.bridge }}_present

{%- elif interface.type == 'ovs_port' %}

{%- if interface.get('port_type','internal') == 'patch' %}

ovs_port_{{ interface_name }}_present:
  openvswitch_port.present:
  - name: {{ interface_name }}
  - bridge: {{ interface.bridge }}
  - require:
    {%- if dpdk_enabled and network.interface.get(interface.bridge, {}).get('type', 'ovs_bridge') == 'dpdk_ovs_bridge' %}
    - cmd: linux_network_dpdk_bridge_interface_{{ interface.bridge }}
    {%- else %}
    - openvswitch_bridge: ovs_bridge_{{ interface.bridge }}_present
    {%- endif %}

ovs_port_set_type_{{ interface_name }}:
  cmd.run:
  - name: ovs-vsctl{%- if network.ovs_nowait %} --no-wait{%- endif %} set interface {{ interface_name }} type=patch
  - unless: ovs-vsctl show | grep -A 1 'Interface {{ interface_name }}' | grep patch

ovs_port_set_peer_{{ interface_name }}:
  cmd.run:
  - name: ovs-vsctl{%- if network.ovs_nowait %} --no-wait{%- endif %} set interface {{ interface_name }} options:peer={{ interface.peer }}
  - unless: ovs-vsctl show | grep -A 2 'Interface {{ interface_name }}' | grep {{ interface.peer }}

{% if interface.tag is defined %}
ovs_port_set_tag_{{ interface_name }}:
  cmd.run:
  - name: ovs-vsctl{%- if network.ovs_nowait %} --no-wait{%- endif %} set port {{ interface_name }} tag={{ interface.tag }}
  - unless: ovs-vsctl get Port {{ interface_name }} tag | grep -Fx {{ interface.tag }}
{%- endif %}

{%- else %}

linux_interfaces_include_{{ interface_name }}:
  file.prepend:
  - name: /etc/network/interfaces
  - text: |
      source /etc/network/interfaces.d/*
      # Workaround for Upstream-Bug: https://github.com/saltstack/salt/issues/40262
      source /etc/network/interfaces.u/*

ovs_port_{{ interface_name }}:
  file.managed:
  - name: /etc/network/interfaces.u/ifcfg-{{ interface_name }}
  - makedirs: True
  - source: salt://linux/files/ovs_port
  - defaults:
      port: {{ interface|yaml }}
      port_name: {{ interface_name }}
      auto: ""
      iface_inet: ""
  - template: jinja

ovs_port_up_{{ interface_name }}:
  cmd.run:
  - name: ifup {{ interface_name }}
  - require:
    - file: ovs_port_{{ interface_name }}
    - openvswitch_bridge: ovs_bridge_{{ interface.bridge }}_present
    - file: linux_interfaces_final_include

{%- endif %}

{%- else %}

linux_interface_{{ interface_name }}:
  network.managed:
  - enabled: {{ interface.enabled }}
  - name: {{ interface_name }}
  - type: {{ interface.type }}
  {%- if interface.address is defined %}
  {%- if grains.os_family == 'Debian' %}
  - proto: {{ interface.get('proto', 'static') }}
  {% endif %}
  {%- if grains.os_family == 'RedHat' %}
  {%- if interface.get('proto', 'none') == 'manual' %}
  - proto: 'none'
  {%- else %}
  - proto: {{ interface.get('proto', 'none') }}
  {%- endif %}
  {% endif %}
  - ipaddr: {{ interface.address }}
  - netmask: {{ interface.netmask }}
  {%- else %}
  - proto: {{ interface.get('proto', 'dhcp') }}
  {%- endif %}
  {%- if interface.type == 'slave' %}
  - master: {{ interface.master }}
  {%- endif %}
  {%- if interface.name_servers is defined %}
  - dns: {{ interface.name_servers }}
  {%- endif %}
  {%- if interface.wireless is defined and grains.os_family == 'Debian' %}
  {%- if interface.wireless.security == "wpa" %}
  - wpa-ssid: {{ interface.wireless.essid }}
  - wpa-psk: {{ interface.wireless.key }}
  {%- else %}
  - wireless-ssid: {{ interface.wireless.essid }}
  - wireless-psk: {{ interface.wireless.key }}
  {%- endif %}
  {%- endif %}
  {%- if pillar.linux.network.noifupdown is defined %}
  - noifupdown: {{ pillar.linux.network.noifupdown }}
  {%- endif %}
  {%- for param in network.interface_params %}
  {{ set_param(param, interface) }}
  {%- endfor %}
  {%- if interface.require_interfaces is defined %}
  - require:
    {%- for netif in interface.get('require_interfaces', []) %}
    - network: linux_interface_{{ netif }}
    {%- endfor %}
    {%- for network in interface.get('use_ovs_ports', []) %}
    - cmd: ovs_port_up_{{ network }}
    {%- endfor %}
  {%- endif %}
  {%- if interface.type == 'bridge' %}
  - bridge: {{ interface_name }}
  - delay: 0
  - bypassfirewall: True
  - use:
    {%- for network in interface.use_interfaces %}
    - network: linux_interface_{{ network }}
    {%- endfor %}
  - ports: {% for network in interface.get('use_interfaces', []) %}{{ network }} {% endfor %}{% for network in interface.get('use_ovs_ports', []) %}{{ network }} {% endfor %}
  - require:
    {%- for network in interface.get('use_interfaces', []) %}
    - network: linux_interface_{{ network }}
    {%- endfor %}
    {%- for network in interface.get('use_ovs_ports', []) %}
    - cmd: ovs_port_up_{{ network }}
    {%- endfor %}
  {%- endif %}
  {%- if interface.type == 'bond' %}
  - slaves: {{ interface.slaves }}
  - mode: {{ interface.mode }}
  {%- endif %}


{%- if salt['grains.get']('saltversion') < '2017.7' %}
# TODO(ddmitriev): Remove this 'if .. endif' block completely when
# switched to salt version 2017.7 that has the same functionality.
{%- if interface.type == 'bond' and interface.enabled == True %}
linux_bond_interface_{{ interface_name }}:
  cmd.run:
  - name: ifenslave {{ interface_name }} {{ interface.slaves }}
  - require:
    - network: linux_interface_{{ interface_name }}
  - onchanges:
    - network: linux_interface_{{ interface_name }}
    {%- for network in  interface.slaves.split() %}
    - network: linux_interface_{{ network }}
    {%- endfor %}
{%- endif %}
{%- endif %}

{%- for network in interface.get('use_ovs_ports', []) %}

remove_interface_{{ network }}_line1:
  file.replace:
  - name: /etc/network/interfaces
  - pattern: auto {{ network }}$
  - repl: ""

remove_interface_{{ network }}_line2:
  file.replace:
  - name: /etc/network/interfaces
  - pattern: iface {{ network }} inet manual
  - repl: ""

{%- endfor %}

{%- if interface.gateway is defined and network.resolv is not defined %}

linux_system_network:
  network.system:
  - enabled: {{ interface.enabled }}
  - hostname: {{ network.fqdn }}
  {%- if interface.gateway is defined %}
  - gateway: {{ interface.gateway }}
  - gatewaydev: {{ interface_name }}
  {%- endif %}
  - nozeroconf: True
  - nisdomain: {{ system.domain }}
  - require_reboot: True

{%- endif %}

{%- endif %}

{%- endif %}

{%- if interface.wireless is defined %}

{%- if grains.os_family == 'Arch' %}

linux_network_packages:
  pkg.installed:
  - pkgs: {{ network.pkgs | json }}

/etc/netctl/network_{{ interface.wireless.essid }}:
  file.managed:
  - source: salt://linux/files/wireless
  - mode: 755
  - template: jinja
  - require:
    - pkg: linux_network_packages
  - defaults:
      interface_name: {{ interface_name }}

switch_profile_{{ interface.wireless.essid }}:
  cmd.run:
    - name: netctl switch-to network_{{ interface.wireless.essid }}
    - cwd: /root
    - unless: "iwconfig {{ interface_name }} | grep -e 'ESSID:\"{{ interface.wireless.essid }}\"'"
    - require:
      - file: /etc/netctl/network_{{ interface.wireless.essid }}

enable_profile_{{ interface.wireless.essid }}:
  cmd.run:
    - name: netctl enable network_{{ interface.wireless.essid }}
    - cwd: /root
    - unless: test -e /etc/systemd/system/multi-user.target.wants/netctl@network_{{ interface.wireless.essid }}.service
    - require:
      - file: /etc/netctl/network_{{ interface.wireless.essid }}

{%- endif %}

{%- endif %}

{%- endif %}

{%- if interface.route is defined %}

linux_network_{{ interface_name }}_routes:
  network.routes:
  - name: {{ interface_name }}
  - routes:
    {%- for route_name, route in interface.route.items() %}
    - name: {{ route_name }}
      ipaddr: {{ route.address }}
      netmask: {{ route.netmask }}
      {%- if route.gateway is defined %}
      gateway: {{ route.gateway }}
      {%- endif %}
    {%- endfor %}
  {%- if interface.noifupdown is defined %}
  - require_reboot: {{ interface.noifupdown }}
  {%- endif %}

{%- endif %}

{%- if interface.type in ('eth','ovs_port') %}
{%- if interface.get('ipflush_onchange', False) %}

linux_interface_ipflush_onchange_{{ interface_name }}:
  cmd.run:
  - name: "/sbin/ip address flush dev {{ interface_name }}"
{%- if interface.type == 'eth' %}
  - onchanges:
    - network: linux_interface_{{ interface_name }}
{%- elif interface.type == 'ovs_port' %}
  - onchanges:
    - file: ovs_port_{{ interface_name }}
{%- endif %}

{%- if interface.get('restart_on_ipflush', False) %}

linux_interface_restart_on_ipflush_{{ interface_name }}:
  cmd.run:
  - name: "ifdown {{ interface_name }}; ifup {{ interface_name }};"
  - onchanges:
    - cmd: linux_interface_ipflush_onchange_{{ interface_name }}

{%- endif %}

{%- endif %}

{%- endif %}

{%- endfor %}

{%- if network.bridge != 'none' %}

linux_interfaces_final_include:
  file.prepend:
  - name: /etc/network/interfaces
  - text: |
      source /etc/network/interfaces.d/*
      # Workaround for Upstream-Bug: https://github.com/saltstack/salt/issues/40262
      source /etc/network/interfaces.u/*

linux_interfaces_final_include_no_requisite:
  file.prepend:
  - name: /etc/network/interfaces
  - text: |
      source /etc/network/interfaces.d/*
      # Workaround for Upstream-Bug: https://github.com/saltstack/salt/issues/40262
      source /etc/network/interfaces.u/*

{%- endif %}

{%- endif %}

{%- if network.network_manager.disable is defined and network.network_manager.disable == True %}

NetworkManager:
  service.dead:
  - enable: false

{%- endif %}

{%- if network.tap_custom_txqueuelen is defined %}

/etc/udev/rules.d/60-net-txqueue.rules:
  file.managed:
  - source: salt://linux/files/60-net-txqueue.rules
  - mode: 755
  - template: jinja
  - defaults:
    tap_custom_txqueuelen: {{ network.tap_custom_txqueuelen }}

udev_reload_rules:
  cmd.run:
  - name: "/bin/udevadm control --reload-rules"
  - onchanges:
    - file: /etc/udev/rules.d/60-net-txqueue.rules

udev_retrigger:
  cmd.run:
  - name: "/bin/udevadm trigger --attr-match=subsystem=net"
  - onchanges:
    - udev_reload_rules

{%- endif %}
