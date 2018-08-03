{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

include:
  - linux.system.group

{%- for name, user in system.user.items() %}

{%- if user.enabled %}

{%- set requires = [] %}
{%- for group in user.get('groups', []) %}
  {%- if group in system.get('group', {}).keys() %}
    {%- do requires.append({'group': 'system_group_'+group}) %}
  {%- endif %}
{%- endfor %}

{%- if user.gid is not defined %}
system_group_{{ user.name }}:
  group.present:
  - name: {{ user.name }}
  - require_in:
    - user: system_user_{{ user.name }}
{%- endif %}

system_user_{{ user.name }}:
  user.present:
  - name: {{ user.name }}
  - home: {{ user.home }}
  {% if user.get('password') == False %}
  - enforce_password: false
  {% elif user.get('password') == None %}
  - enforce_password: true
  - password: '*'
  {% elif user.get('password') %}
  - enforce_password: true
  - password: {{ user.password }}
  - hash_password: {{ user.get('hash_password', False) }}
  {% endif %}
  {%- if user.gid is defined and user.gid %}
  - gid: {{ user.gid }}
  {%- else %}
  - gid_from_name: true
  {%- endif %}
  {%- if user.groups is defined %}
  - groups: {{ user.groups }}
  {%- endif %}
  {%- if user.system is defined and user.system %}
  - system: True
  - shell: {{ user.get('shell', '/bin/false') }}
  {%- else %}
  - shell: {{ user.get('shell', '/bin/bash') }}
  {%- endif %}
  {%- if user.uid is defined %}
  - uid: {{ user.uid }}
  {%- endif %}
  {%- if user.unique is defined %}
  - unique: {{ user.unique }}
  {%- endif %}
  {%- if user.maxdays is defined %}
  - maxdays: {{ user.maxdays }}
  {%- endif %}
  {%- if user.mindays is defined %}
  - mindays: {{ user.mindays }}
  {%- endif %}
  {%- if user.warndays is defined %}
  - warndays: {{ user.warndays }}
  {%- endif %}
  {%- if user.inactdays is defined %}
  - inactdays: {{ user.inactdays }}
  {%- endif %}
  - require: {{ requires|yaml }}

system_user_home_{{ user.home }}:
  file.directory:
  - name: {{ user.home }}
  {%- if user.uid is defined and user.uid == 0 %}
  - user: root
  {%- else %}
  - user: {{ user.name }}
  {%- endif %}
  - mode: {{ user.get('home_dir_mode', 700) }}
  - makedirs: true
  - require:
    - user: system_user_{{ user.name }}

{%- if user.get('sudo', False) %}

/etc/sudoers.d/90-salt-user-{{ user.name|replace('.', '-') }}:
  file.managed:
  - source: salt://linux/files/sudoer
  - template: jinja
  - user: root
  - group: root
  - mode: 440
  - defaults:
    user_name: {{ user.name }}
  - require:
    - user: system_user_{{ user.name }}
  - check_cmd: /usr/sbin/visudo -c -f

{%- else %}

/etc/sudoers.d/90-salt-user-{{ user.name|replace('.', '-') }}:
  file.absent

{%- endif %}

{%- else %}

system_user_{{ user.name }}:
  user.absent:
  - name: {{ user.name }}

system_user_home_{{ user.home }}:
  file.absent:
  - name: {{ user.home }}

/etc/sudoers.d/90-salt-user-{{ user.name|replace('.', '-') }}:
  file.absent

{%- endif %}

{%- endfor %}

{%- endif %}
