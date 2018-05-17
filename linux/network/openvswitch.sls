{%- from "linux/map.jinja" import network with context %}

{%- if network.get('openvswitch', {}).get('enabled', False) %}

openvswitch_pkgs:
  pkg.installed:
    - pkgs: {{ network.ovs_pkgs }}

/etc/default/openvswitch-switch:
  file.managed:
    - source: salt://linux/files/openvswitch-switch.default
    - template: jinja
    - require:
      - pkg: openvswitch_pkgs

openvswitch_switch_service:
  service.running:
    - name: openvswitch-switch
    - enable: true
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}
    - watch:
      - file: /etc/default/openvswitch-switch

{%- endif %}
