{%- from "linux/map.jinja" import system with context %}
{%- if system.cpu.governor is defined %}

ondemand_service_disable:
  service.dead:
  - name: ondemand
  - enable: false

{%- endif %}