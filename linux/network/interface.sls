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

  {%- for interface_name, interface in network.interface.iteritems() %}
    {%- set interface_name = interface.get('name', interface_name) %}

    {%- if interface.get('managed', True) %}

      {%- if grains.os_family in ['RedHat', 'Debian'] %}

        {%- if interface.type == 'ovs_bridge' %}

          ovs_bridge_{{ interface_name }}_config:
            file.managed:
              - name: /etc/network/interfaces.d/ifcfg-{{ interface_name }}
              - source: salt://linux/files/ovs_bridge
              - defaults:
                bridge: {{ interface|yaml }}
                bridge_name: {{ interface_name }}
                ovs_ports: {{ interface.ovs_ports }}
              - template: jinja
 
          add_ovs_bridge_{{ interface_name }}:
            cmd.run:
              - unless: ovs-vsctl show | grep {{ interface_name }}
              - name: ovs-vsctl add-br {{ interface_name }} 

      {%- for int_name, int in network.interface.iteritems() %}

        {%- set int_name = int.get('name', int_name) %}

        {%- if int.ovs_bridge is defined %}

          add_bond_to_ovs_bridge_{{ interface_name }}: {# the rest of ovs-ports will be auto added to ovs_bridge after reboot #}
            cmd.run:
              - unless: ovs-vsctl show | grep {{ int_name }}
              - name: ovs-vsctl add-port {{ interface_name }} {{ int_name }}

        {%- endif %}

      {%- endfor %}

        {%- elif interface.type == 'ovs_port' %}
          ovs_port_{{ interface_name }}:
            file.managed:
              - name: /etc/network/interfaces.d/ifcfg-{{ interface_name }}
              - source: salt://linux/files/ovs_port
              - defaults:
                port: {{ interface|yaml }}
                port_name: {{ interface_name }}
              - template: jinja

        {%- else %}
          linux_interface_{{ interface_name }}:
            network.managed:
            - enabled: {{ interface.enabled }}
            - name: {{ interface_name }}
            - type: {{ interface.type }}
            {%- if interface.address is defined %}
            {%- if grains.os_family == 'Debian' %}
            - unless: grep -q "iface {{ interface_name }} " /etc/network/interfaces
            - proto: {{ interface.get('proto', 'static') }}
            {% endif %}
            {%- if grains.os_family == 'RedHat' %}
            {%- if interface.get('proto', 'none') == 'manual' %}
            - proto: 'none'
            {%- else %}
            - proto: {{ interface.get('proto', 'none') }}
            {%- endif %}
            {%- endif %}
            - ipaddr: {{ interface.address }}
            - netmask: {{ interface.netmask }}
            {%- else %}
            - proto: {{ interface.get('proto', 'dhcp') }}
            {%- endif %}
            {%- if interface.name_servers is defined %}
            - dns: {{ interface.name_servers }}
            {%- endif %}
            {%- if interface.master is defined %}
            - master: {{ interface.master }}
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
              - network: linux_interface_{{ network }}
              {%- endfor %}
            - ports: {% for network in interface.get('use_interfaces', []) %}{{ network }} {% endfor %}{%  for network in interface.get('use_ovs_ports', []) %}{{ network }} {% endfor %}
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



  {%- for interface_name, interface in network.interface.iteritems() %}

    {%- set interface_name = interface.get('name', interface_name) %}

    {%- if interface.type == 'ovs_port' or interface.type == 'ovs_bridge' %}

          {# erases junk ovs interfaces from the file if its defined between other interfaces  #}
          ovs_port_remove_{{ interface_name }}_z_file_interfaces:
            file.replace:
            - name: /etc/network/interfaces
            - pattern: '(auto {{ interface_name }}([\s\S]*?)auto)'
            - repl: "auto"

          {# if some junk ovs interface is at the end of the file then erase it #}
          ovs_port_remove_{{ interface_name }}_z_file_interfaces2:
            file.replace:
            - name: /etc/network/interfaces
            - pattern: '(auto {{ interface_name }}([\s\S]*?)(.|\n)*)'
            - repl: ""

          {# erases junk ovs interfaces from the file if its defined between other interfaces and starts with 'iface'  #}
          ovs_port_remove_{{ interface_name }}_z_file_interfaces3:
            file.replace:
            - name: /etc/network/interfaces
            - pattern: '(iface {{ interface_name }}([\s\S]*?)iface)'
            - repl: "iface"

          {# if some junk ovs interface is at the end of the file and starts with 'iface' then erase it #}
          ovs_port_remove_{{ interface_name }}_z_file_interfaces4:
            file.replace:
            - name: /etc/network/interfaces
            - pattern: '(iface {{ interface_name }}([\s\S]*?)(.|\n)*)'
            - repl: ""



    {%- endif %}

  {%- endfor %}

  {%- if network.bridge != 'none' %}

          linux_interfaces_final_include:
            file.prepend:
            - name: /etc/network/interfaces
            - text: 'source /etc/network/interfaces.d/*'

  {%- endif %}
{%- endif %}


{%- if network.network_manager.disable is defined and network.network_manager.disable == True %}

          NetworkManager:
            service.dead:
            - enable: false

{%- endif %}