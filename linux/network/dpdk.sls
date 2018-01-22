{%- from "linux/map.jinja" import network with context %}
{%- from "linux/map.jinja" import system with context %}
{%- if network.dpdk.enabled %}

linux_dpdk_pkgs:
  pkg.installed:
  - pkgs: {{ network.dpdk_pkgs }}

linux_dpdk_kernel_module:
  kmod.present:
  - name: {{ network.dpdk.driver }}
  - require:
    - pkg: linux_dpdk_pkgs
  - require_in:
    - service: linux_network_dpdk_service

/etc/dpdk/interfaces:
  file.managed:
  - source: salt://linux/files/dpdk_interfaces
  - template: jinja
  - user: root
  - group: root
  - mode: 644
  - require:
    - pkg: linux_dpdk_pkgs

linux_network_dpdk_service:
  service.running:
  - enable: true
  - name: dpdk
  - watch:
    - file: /etc/dpdk/interfaces

{%- if network.openvswitch is defined %}

openvswitch_dpdk_pkgs:
  pkg.installed:
  - pkgs:
    - openvswitch-switch-dpdk
    - openvswitch-switch
    - bridge-utils

linux_network_dpdk_ovs_service:
  cmd.run:
  - name: "ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true"
  - require:
    - service: linux_network_dpdk_service
  - unless: 'ovs-vsctl get Open_vSwitch . other_config | grep "dpdk-init=\"true\""'

{%- set ovs_options = [
  "pmd-cpu-mask=\""+network.openvswitch.pmd_cpu_mask+"\"",
  "dpdk-socket-mem=\""+network.openvswitch.dpdk_socket_mem+"\"",
  "dpdk-lcore-mask=\""+network.openvswitch.dpdk_lcore_mask+"\"",
  "dpdk-extra=\"-n "+network.openvswitch.memory_channels+" --vhost-owner libvirt-qemu:kvm --vhost-perm 0664\""
]
%}

{%- if network.openvswitch.get('vhost_socket_dir',{}).get('path') %}
{%- do ovs_options.append("vhost-sock-dir=\""+network.openvswitch.vhost_socket_dir.path+"\"") %}
{%- endif %}

{%- for option in ovs_options %}

linux_network_dpdk_ovs_option_{{ option }}:
  cmd.run:
  - name: 'ovs-vsctl set Open_vSwitch . other_config:{{ option }}'
  - watch_in:
    - service: service_openvswitch
  - require:
    - cmd: linux_network_dpdk_ovs_service
  - unless: |
      ovs-vsctl get Open_vSwitch . other_config | grep '{{ option }}'

{%- endfor %}

service_openvswitch:
  service.running:
  - name: openvswitch-switch
  - enable: true
  - watch:
    - cmd: linux_network_dpdk_ovs_service

{%- endif %}

{%- for interface_name, interface in network.interface.iteritems() if interface.get('enabled', True) %}

  {%- if interface.type == "dpdk_ovs_bond" %}

    {%- set bond_interfaces = {} %}
    {%- for iface_name, iface in network.interface.iteritems() if iface.get('enabled', True) and iface.get('bond',"") == interface_name %}
      {#- Get list of child interfaces #}
      {%- do bond_interfaces.update({iface_name: iface}) %}
    {%- endfor %}

linux_network_dpdk_bond_interface_{{ interface_name }}:
  cmd.run:
    - name: "ovs-vsctl add-bond {{ interface.bridge }} {{ interface_name }} {{ bond_interfaces.keys()|join(' ') }} {% for iface_name, iface in bond_interfaces.iteritems() %}-- set Interface {{ iface_name }} type=dpdk options:dpdk-devargs={{ iface.pci }} {% endfor %}"
    - unless: "ovs-vsctl show | grep {{ interface_name }}"
    - require:
        - cmd: linux_network_dpdk_bridge_interface_{{ interface.bridge }}

linux_network_dpdk_bond_mode_{{ interface_name }}:
  cmd.run:
    - name: "ovs-vsctl set port {{ interface_name }} bond_mode={{ interface.mode }}"
    - unless: "ovs-appctl bond/show {{ interface_name }} | grep {{ interface.mode }}"
    - require:
        - cmd: linux_network_dpdk_bond_interface_{{ interface_name }}

  {%- elif interface.type == 'dpdk_ovs_bridge' %}

linux_network_dpdk_bridge_interface_{{ interface_name }}:
  cmd.run:
    - name: "ovs-vsctl add-br {{ interface_name }} -- set bridge {{ interface_name }} datapath_type=netdev{% if interface.tag is defined %} -- set port {{ interface_name }} tag={{ interface.tag }}{% endif %}"
    - unless: "ovs-vsctl show | grep {{ interface_name }}"

    {# OVS dpdk needs ip address for vxlan termination on bridge br-prv #}
    {%- if interface.address is defined %}

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

{# enforce ip address and mtu for ovs dpdk br-prv #}
/etc/network/interfaces.d/ifcfg-{{ interface_name }}:
  file.managed:
    - contents: |
        auto {{ interface_name }}
        iface {{ interface_name }} inet static
        address {{ interface.address }}
        netmask {{ interface.netmask }}
        {%- if interface.mtu is defined %}
        mtu {{ interface.mtu }}
        {%- endif %}
    - require:
      - file: /etc/systemd/system/ifup@{{ interface_name }}.service.d/override.conf

    {%- endif %}

  {%- elif interface.type == 'dpdk_ovs_port' and interface.bridge is defined %}

linux_network_dpdk_bridge_port_interface_{{ interface_name }}:
  cmd.run:
    - name: "ovs-vsctl add-port {{ interface.bridge }} dpdk0 -- set Interface dpdk0 type=dpdk options:dpdk-devargs={{ interface.pci }}"
    - unless: "ovs-vsctl show | grep dpdk0"
    - require:
      - cmd: linux_network_dpdk_bridge_interface_{{ interface.bridge }}

  {%- endif %}

  {# Multiqueue n_rxq, pmd_rxq_affinity and mtu setup on interfaces #}
  {%- if interface.type == 'dpdk_ovs_port' %}

  {%- if interface.n_rxq is defined %}

linux_network_dpdk_bridge_port_interface_n_rxq_{{ interface_name }}:
  cmd.run:
    - name: "ovs-vsctl set Interface {{ interface_name }} options:n_rxq={{ interface.n_rxq }} "
    - unless: |
        ovs-vsctl get Interface {{ interface_name }} options | grep 'n_rxq="{{ interface.n_rxq }}"'

  {%- endif %}

  {%- if interface.pmd_rxq_affinity is defined %}

linux_network_dpdk_bridge_port_interface_pmd_rxq_affinity_{{ interface_name }}:
  cmd.run:
    - name: "ovs-vsctl set Interface {{ interface_name }} other_config:pmd-rxq-affinity={{ interface.pmd_rxq_affinity }} "
    - unless: |
        ovs-vsctl get Interface {{ interface_name }} other_config | grep 'pmd-rxq-affinity="{{ interface.pmd_rxq_affinity }}"'

  {%- endif %}

  {%- if interface.mtu is defined %}

{# MTU ovs dpdk setup on interfaces #}
linux_network_dpdk_bridge_port_interface_mtu_{{ interface_name }}:
  cmd.run:
    - name: "ovs-vsctl set Interface {{ interface_name }} mtu_request={{ interface.mtu }} "
    - unless: "ovs-vsctl get Interface {{ interface_name }} mtu_request | grep {{ interface.mtu }}"

  {%- endif %}

  {%- endif %}

{%- endfor %}

{%- endif %}
