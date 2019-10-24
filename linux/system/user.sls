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
system_group_{{ name }}:
  group.present:
  - name: {{ name }}
  - require_in:
    - user: system_user_{{ name }}
{%- endif %}

{%- if user.get('makedirs') %}
system_user_home_parentdir_{{ user.home }}:
  file.directory:
  - name: {{ user.home | path_join("..") }}
  - makedirs: true
  - require_in:
    - user: system_user_{{ name }}
{%- endif %}

system_user_{{ name }}:
  user.present:
  - name: {{ name }}
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
  {%- if user.uid is defined and user.uid %}
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
  - user: {{ name }}
  - mode: {{ user.get('home_dir_mode', 700) }}
  - makedirs: true
  - require:
    - user: system_user_{{ name }}

{%- if user.get('sudo', False) %}

/etc/sudoers.d/90-salt-user-{{ name|replace('.', '-') }}:
  file.managed:
  - source: salt://linux/files/sudoer
  - template: jinja
  - user: root
  - group: root
  - mode: 440
  - defaults:
    user_name: {{ name }}
  - require:
    - user: system_user_{{ name }}
  - check_cmd: /usr/sbin/visudo -c -f

{%- else %}

{%- if user.authorized_keys is defined %}
  {%- if user.authorized_keys.present is defined %}
system_user_{{ name }}_authorized_keys_add:
  ssh_auth.present:
    - names:
    {%- for ssh_key_value in user.authorized_keys.present.ssh_key_values %}
      - {{ ssh_key_value }}
    {%- endfor %}
    - user: {{ name }}
    {%- if user.authorized_keys.present.enc is defined %}
    - enc: {{ user.authorized_keys.present.enc }}
    {%- endif %}
    {%- if user.authorized_keys.present.comment is defined %}
    - comment: {{ user.authorized_keys.present.comment }}
    {%- endif %}
    {%- if user.authorized_keys.present.options is defined %}
    - options:
      {%- for option_name, option_value in user.authorized_keys.present.options.items() %}
      - {{ option_name }}="{{ option_value }}"
      {%- endfor %}
    {%- endif %}
  {%- endif %}
  {%- if user.authorized_keys.absent is defined %}
system_user_{{ name }}_authorized_keys_del:
  ssh_auth.absent:
    - names:
    {%- for ssh_key_value in user.authorized_keys.absent_key_values %}
      - {{ ssh_key_value }}"
    {%- endfor %}
    - user: {{ name }}
    {%- if user.authorized_keys.absent.enc is defined %}
    - enc: {{ user.authorized_keys.absent.enc }}
    {%- endif %}
    {%- if user.authorized_keys.absent.comment is defined %}
    - comment: {{ user.authorized_keys.absent.comment }}
    {%- endif %}
    {%- if user.authorized_keys.absent.options is defined %}
    - options:
      {%- for option_name, option_value in user.authorized_keys.absent.options.items() %}
      - {{ option_name }}="{{ option_value }}"
      {%- endfor %}
    {%- endif %}
 {%- endif %}
{%- endif %}

/etc/sudoers.d/90-salt-user-{{ name|replace('.', '-') }}:
  file.absent

{%- endif %}

{%- else %}

system_user_{{ name }}:
  user.absent:
  - name: {{ name }}

system_user_home_{{ user.home }}:
  file.absent:
  - name: {{ user.home }}

/etc/sudoers.d/90-salt-user-{{ name|replace('.', '-') }}:
  file.absent

{%- endif %}

{%- endfor %}

{%- endif %}
