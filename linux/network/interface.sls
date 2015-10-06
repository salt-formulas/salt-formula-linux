{%- from "linux/map.jinja" import network with context %}
{%- from "linux/map.jinja" import system with context %}
{%- if network.enabled %}

{%- macro set_param(param_name, param_dict) -%}
{%- if param_dict.get(param_name, False) -%}
- {{ param_name }}: {{ param_dict[param_name] }}
{%- endif -%}
{%- endmacro -%}

{%- if network.bridge != 'none' %}

linux_network_bridge_pkgs:
  pkg.installed:
  {%- if network.bridge == 'openvswitch' %}
  - names: {{ network.ovs_pkgs }}
  {%- else %}
  - names: {{ network.bridge_pkgs }}
  {%- endif %}

{%- endif %}

{%- if not network.network_manager %}

{# TODO stop/disable/uninstall network manager #}

{%- for interface_name, interface in network.interface.iteritems() %}

{%- if interface.get('managed', True) %}

{%- if grains.os_family in ['RedHat', 'Debian'] %}

{%- if interface.type == 'bridge' and network.bridge == 'openvswitch' %}

linux_interface_{{ interface_name }}:
  network.managed:
  - enabled: {{ interface.enabled }}
  - name: {{ interface_name }}
  - type: eth
  {%- if interface.address is defined %}
  - proto: {{ interface.get('proto', 'static') }}
  - ipaddr: {{ interface.address }}
  - netmask: {{ interface.netmask }}
  {%- else %}
  - proto: {{ interface.get('proto', 'dhcp') }}
  {%- endif %}
  {%- if interface.name_servers is defined %}
  - dns: {{ interface.name_servers }}
  {%- endif %}
  {%- for param in network.interface_params %}
  {{ set_param(param, interface) }}
  {%- endfor %}
  {%- if interface.wireless is defined and grains.os_family == 'Debian' %}
  {%- if interface.wireless.security == "wpa" %}
  - wpa-ssid: {{ interface.wireless.essid }}
  - wpa-psk: {{ interface.wireless.key }}
  {%- else %}
  - wireless-ssid: {{ interface.wireless.essid }}
  - wireless-psk: {{ interface.wireless.key }}
  {%- endif %}
  {%- endif %}
  - require:
    - pkg: linux_network_bridge_pkgs
    {%- for network in interface.use_interfaces %}
    - network: linux_interface_{{ network }}
    {%- endfor %}

linux_ovs_bridge_{{ interface_name }}:
  cmd.run:
  - name: ovs-vsctl add-br {{ interface_name }}
  - unless: ovs-vsctl show | grep 'Bridge {{ interface_name }}'
  - require:
    - network: linux_interface_{{ interface_name }}

{%- for port in interface.use_interfaces %}

linux_ovs_bridge_{{ interface_name }}_port_{{ port }}:
  cmd.run:
  - name: ovs-vsctl add-port {{ interface_name }} {{ port }}
  - unless: ovs-vsctl show | grep 'Interface "{{ interface_name }}"'
  - require:
    - cmd: linux_ovs_bridge_{{ interface_name }}

{%- endfor %}

{%- else %}

linux_interface_{{ interface_name }}:
  network.managed:
  - enabled: {{ interface.enabled }}
  - name: {{ interface_name }}
  - type: {{ interface.type }}
  {%- if interface.address is defined %}
  - proto: {{ interface.get('proto', 'static') }}
  - ipaddr: {{ interface.address }}
  - netmask: {{ interface.netmask }}
  {%- else %}
  - proto: {{ interface.get('proto', 'dhcp') }}
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
  {%- for param in network.interface_params %}
  {{ set_param(param, interface) }}
  {%- endfor %}
  {%- if interface.type == 'bridge' %}
  - bridge: {{ interface_name }}
  - delay: 0
  - bypassfirewall: True
  - use:
    {%- for network in interface.use_interfaces %}
    - network: {{ network }}
    {%- endfor %}
  - ports: {% for network in interface.use_interfaces %}{{ network }} {% endfor %}
  - require:
    {%- for network in interface.use_interfaces %}
    - network: linux_interface_{{ network }}
    {%- endfor %}
  {%- endif %}

{%- if interface.gateway is defined %}

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
  - require_reboot: False

{%- endif %}

{%- endif %}

{%- endif %}

{%- if interface.wireless is defined %}

{%- if grains.os_family == 'Arch' %}

linux_network_packages:
  pkg.installed:
  - names: {{ network.pkgs }}

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
    {%- for route_name, route in interface.route.iteritems() %}
    - name: {{ route_name }}
      ipaddr: {{ route.address }}
      netmask: {{ route.netmask }}
      gateway: {{ route.gateway }}
    {%- endfor %}

{%- endif %}

{%- endfor %}

{%- endif %}

{%- endif %}
