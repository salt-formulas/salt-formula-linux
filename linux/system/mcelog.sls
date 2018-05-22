{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.get('mcelog',{}).get('enabled', False) %}

mcelog_packages:
  pkg.installed:
    - name: mcelog

mcelog_conf:
  file.managed:
    - name: /etc/mcelog/mcelog.conf
    - source: salt://linux/files/mcelog.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: mcelog_packages

mce_service:
  service.running:
  - name: mcelog
  - enable: true
  - require:
    - pkg: mcelog_packages
  - watch:
    - file: mcelog_conf

{%- endif %}

{%- endif %}
