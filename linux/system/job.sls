{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

include:
- linux.system.user
- linux.system.cron

  {%- for name, job in system.job.items() %}
    {%- set job_user = job.get('user', 'root') %}

linux_job_{{ job.command }}:
    {%- if job.get('enabled', True) %}
  cron.present:
    - name: >
        {{ job.command }}
      {%- if job.get('identifier', True) %}
    - identifier: {{ job.get('identifier', job.get('name', name)) }}
      {%- endif %}
    - user: {{ job_user }}
      {%- if job.special is defined %}
    - special: '{{ job.special }}'
      {%- else %}
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
      {%- endif %}
    - require:
      - sls: linux.system.cron
      {%- if job_user in system.get('user', {}).keys() %}
      - user: system_user_{{ job_user }}
      {%- endif %}
    {%- else %}
  cron.absent:
    - name: {{ job.command }}
      {%- if job.get('identifier', True) %}
    - identifier: {{ job.get('identifier', job.get('name', name)) }}
      {%- endif %}
    - user: {{ job_user }}
    {%- endif %}
  {%- endfor %}
{%- endif %}
