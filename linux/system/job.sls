{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

include:
- linux.system.user

{%- for name, job in system.job.items() %}

linux_job_{{ job.command }}:
  {%- if job.enabled|default(True) %}
  cron.present:
    - name: >
        {{ job.command }}
    {%- if job.get('identifier', True) %}
    - identifier: {{ job.get('identifier', job.get('name', name)) }}
    {%- endif %}
    - user: {{ job.user|default("root") }}
    {%- if job.minute is defined %}
    - minute: '{{ job.minute }}'
    {%- endif %}
    {%- if job.hour is defined %}
    - hour: '{{ job.hour }}'
    {%- endif %}
    {%- if job.daymonth is defined %}
    - daymonth: '{{ job.daymonth }}'
    {%- endif %}
    {%- if job.month is defined %}
    - month: '{{ job.month }}'
    {%- endif %}
    {%- if job.dayweek is defined %}
    - dayweek: '{{ job.dayweek }}'
    {%- endif %}
    {%- if job.user|default("root") in system.get('user', {}).keys() %}
    - require:
      - user: system_user_{{ job.user|default("root") }}
    {%- endif %}
  {%- else %}
  cron.absent:
    - name: {{ job.command }}
    {%- if job.get('identifier', True) %}
    - identifier: {{ job.get('identifier', job.get('name', name)) }}
    {%- endif %}
  {%- endif %}

{%- endfor %}

{%- endif %}
