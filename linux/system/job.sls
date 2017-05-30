{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- for name, job in system.job.iteritems() %}

linux_job_{{ job.command }}:
  {%- if job.enabled %}
  cron.present:
    - name: {{ job.command }}
    - user: {{ job.user }}
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
    {%- if job.user in system.get('user', {}).keys() %}
    - require:
      - user: system_user_{{ job.user }}
    {%- endif %}
  {%- else %}
  cron.absent:
    - name: {{ job.command }}
  {%- endif %}

{%- endfor %}

{%- endif %}
