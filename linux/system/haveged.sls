{%- from "linux/map.jinja" import system with context %}

{%- if system.haveged.enabled %}

linux_haveged_pkgs:
  pkg.installed:
  - name: haveged
  - watch_in:
    - service: linux_haveged_service

linux_haveged_service:
  service.running:
  - name: haveged
  - enable: true
  - require:
    - pkg: linux_haveged_pkgs

{%- endif %}
