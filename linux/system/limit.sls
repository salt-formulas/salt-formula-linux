{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- for name, limit in system.limit.items() %}

linux_limit_{{ name }}:
  {%- if limit.get('enabled', True) %}
  file.managed:
    - name: /etc/security/limits.d/90-salt-{{ name }}.conf
    - source: salt://linux/files/limits.conf
    - template: jinja
    - defaults:
        limit_name: {{ name }}
  {%- else %}
  file.absent:
    - name: /etc/security/limits.d/90-salt-{{ name }}.conf
  {%- endif %}

{%- endfor %}

{%- endif %}
