{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.syslog_service is defined %}

include:
- linux.system.timezone

{{ system.syslog_service }}_service:
  service.running:
  - enable: true
  - name: {{ system.syslog_service }}
{%- if system.timezone is defined %}
  - watch:
    - timezone: {{ system.timezone }}
{%- endif %}

{%- endif %}

{%- endif %}
