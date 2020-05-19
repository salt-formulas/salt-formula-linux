{%- from "linux/map.jinja" import network with context %}

{%- if network.get('openvswitch', {}).get('enabled', False) %}

openvswitch_pkgs:
  pkg.installed:
    - pkgs: {{ network.ovs_pkgs | json }}

/etc/default/openvswitch-switch:
  file.managed:
    - source: salt://linux/files/openvswitch-switch.default
    - template: jinja
    - require:
      - pkg: openvswitch_pkgs

/etc/systemd/system/openvswitch-switch.service:
  file.managed:
    - source: salt://linux/files/openvswitch-switch.systemd
    - template: jinja
    - require:
      - pkg: openvswitch_pkgs

openvswitch_sytemctl_reload:
  module.run:
{%- if 'module.run' in salt['config.get']('use_superseded', default=[]) %}
    - service.systemctl_reload: []
{%- else %}
    - name: service.systemctl_reload
{%- endif %}
    - onchanges:
      - file: /etc/systemd/system/openvswitch-switch.service

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
