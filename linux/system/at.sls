{%- from "linux/map.jinja" import system with context %}

{%- if system.at.enabled is defined and system.at.enabled %}

at_packages:
  pkg.installed:
    - names: {{ system.at.pkgs }}

at_services:
  service.running:
    - enable: true
    - names: {{ system.at.services }}
    - require:
      - pkg: at_packages
  {%- if grains.get('noservices') %}
    - onlyif: /bin/false
  {%- endif %}

  {%- set allow_users = [] %}
  {%- for user_name, user_params in system.at.get('user', {}).items() %}
    {%- set user_enabled = user_params.get('enabled', false) and
        system.get('user', {}).get(
          user_name, {'enabled': true}).get('enabled', true) %}
    {%- if user_enabled %}
      {%- do allow_users.append(user_name) %}
    {%- endif %}
  {%- endfor %}

etc_at_allow:
  {%- if allow_users %}
  file.managed:
    - name: /etc/at.allow
    - template: jinja
    - source: salt://linux/files/cron_users.jinja
    - user: root
    - group: daemon
    - mode: 0640
    - defaults:
        users: {{ allow_users | yaml }}
    - require:
      - cron_packages
  {%- else %}
  file.absent:
    - name: /etc/at.allow
  {%- endif %}


{#
    /etc/at.deny should be absent to comply with
    CIS 5.1.8 Ensure at/cron is restricted to authorized users
#}
etc_at_deny:
  file.absent:
    - name: /etc/at.deny

{%- else %}

fake_linux_system_at:
  test.nop:
    - comment: Fake state to satisfy 'require sls:linux.system.at'

{%- endif %}
