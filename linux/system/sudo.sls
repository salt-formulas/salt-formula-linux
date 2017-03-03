{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.get('sudo', {}).get('enabled', False) %}

{%- if system.get('sudo', {}).get('aliases', False) is mapping %}
/etc/sudoers.d/90-salt-sudo-aliases:
  file.managed:
  - source: salt://linux/files/sudoer-aliases
  - template: jinja
  - user: root
  - group: root
  - mode: 440
  - defaults:
      aliases: {{ system.sudo.aliases|yaml }}
  - check_cmd: /usr/sbin/visudo -c -f
{%- else %}
/etc/sudoers.d/90-salt-sudo-aliases:
  file.absent:
  - name: /etc/sudoers.d/90-salt-sudo-aliases
{%- endif %}


{%- if system.get('sudo', {}).get('users', False) is mapping %}
/etc/sudoers.d/91-salt-sudo-users:
  file.managed:
  - source: salt://linux/files/sudoer-users
  - template: jinja
  - user: root
  - group: root
  - mode: 440
  - defaults:
      users: {{ system.sudo.users|yaml }}
  - check_cmd: /usr/sbin/visudo -c -f
{%- else %}
/etc/sudoers.d/91-salt-sudo-users:
  file.absent:
  - name: /etc/sudoers.d/91-salt-sudo-users
{%- endif %}

{%- if system.get('sudo', {}).get('groups', False) is mapping %}
/etc/sudoers.d/91-salt-sudo-groups:
  file.managed:
  - source: salt://linux/files/sudoer-groups
  - template: jinja
  - user: root
  - group: root
  - mode: 440
  - defaults:
      groups: {{ system.sudo.groups|yaml }}
  - check_cmd: /usr/sbin/visudo -c -f
{%- else %}
/etc/sudoers.d/91-salt-sudo-groups:
  file.absent:
  - name: /etc/sudoers.d/91-salt-sudo-groups
{%- endif %}

{%- else %}

/etc/sudoers.d/90-salt-sudo-aliases:
  file.absent:
  - name: /etc/sudoers.d/90-salt-sudo-aliases

/etc/sudoers.d/91-salt-sudo-users:
  file.absent:
  - name: /etc/sudoers.d/91-salt-sudo-users

/etc/sudoers.d/91-salt-sudo-groups:
  file.absent:
  - name: /etc/sudoers.d/91-salt-sudo-groups

{%- endif %}
{%- endif %}
