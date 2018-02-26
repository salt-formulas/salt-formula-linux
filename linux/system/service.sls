{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- for name, service in system.service.items() %}

linux_service_{{ name }}:
  service.{{ service.status }}:
  {%- if service.status == 'dead' %}
  - enable: {{ service.get('enabled', False) }}
  {%- elif service.status == 'running' %}
  - enable: {{ service.get('enabled', True) }}
  {%- endif %}
  - name: {{ name }}

{%- endfor %}
{%- endif %}
