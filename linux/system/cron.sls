{%- from "linux/map.jinja" import system with context %}

{%- if system.cron.enabled is defined and system.cron.enabled %}

cron_packages:
  pkg.installed:
    - names: {{ system.cron.pkgs }}

cron_services:
  service.running:
    - enable: true
    - names: {{ system.cron.services }}
    - require:
      - pkg: cron_packages
  {%- if grains.get('noservices') %}
    - onlyif: /bin/false
  {%- endif %}

  {%- set allow_users = [] %}
  {%- for user_name, user_params in system.cron.get('user', {}).items() %}
    {%- set user_enabled = user_params.get('enabled', false) and
        system.get('user', {}).get(
          user_name, {'enabled': true}).get('enabled', true) %}
    {%- if user_enabled %}
      {%- do allow_users.append(user_name) %}
    {%- endif %}
  {%- endfor %}

etc_cron_allow:
  {%- if allow_users %}
  file.managed:
    - name: /etc/cron.allow
    - template: jinja
    - source: salt://linux/files/cron_users.jinja
    - user: root
    - group: crontab
    - mode: 0640
    - defaults:
        users: {{ allow_users | yaml }}
    - require:
      - cron_packages
  {%- else %}
  file.absent:
    - name: /etc/cron.allow
  {%- endif %}

{#
    /etc/cron.deny should be absent to comply with
    CIS 5.1.8 Ensure at/cron is restricted to authorized users
#}
etc_cron_deny:
  file.absent:
    - name: /etc/cron.deny

etc_crontab:
  file.managed:
    - name: /etc/crontab
    - user: root
    - group: root
    - mode: 0600
    - replace: False
    - require:
      - cron_packages

etc_cron_dirs:
  file.directory:
    - names:
      - /etc/cron.d
      - /etc/cron.daily
      - /etc/cron.hourly
      - /etc/cron.monthly
      - /etc/cron.weekly
    - user: root
    - group: root
    - dir_mode: 0600
    - recurse:
      - ignore_files
    - require:
      - cron_packages

{%- else %}

fake_linux_system_cron:
  test.nop:
    - comment: Fake state to satisfy 'require sls:linux.system.cron'

{%- endif %}
