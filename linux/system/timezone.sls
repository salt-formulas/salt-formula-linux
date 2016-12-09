{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.timezone is defined %}

include:
- linux.system.rsyslog

{{ system.timezone }}:
  timezone.system:
  - utc: {{ system.utc }}
  - watch_in:
    - service: rsyslog_service

{%- endif %}

{%- endif %}