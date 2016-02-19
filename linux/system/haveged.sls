{%- from "linux/map.jinja" import system with context %}

{%- if system.haveged.enabled %}

haveged_pkgs:
  pkg.installed:
  - name: haveged
  - watch_in:
    - service: haveged_service

haveged_service:
  service.running:
  - name: haveged
  - enable: true
  - require:
    - pkg: haveged_packages

{%- endif %}
