{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.timezone is defined %}

{{ system.timezone }}:
  timezone.system:
  - utc: {{ system.utc }}

{%- endif %}

{%- endif %}