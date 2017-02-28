{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- for group_name, group in system.group.iteritems() %}

{%- if group.enabled %}

system_group_{{ group_name }}:
  group.present:
  - name: {{ group.name }}
  {%- if group.system is defined and group.system %}
  - system: True
  {%- endif %}
  {%- if group.gid is defined and group.gid %}
  - gid: {{ group.gid }}
  {%- endif %}
  - require_in:
    - file: /etc/sudoers.d/91-salt-group-{{ group_name }}

{%- if group.get('sudo', {}).get('enabled', False) %}
/etc/sudoers.d/91-salt-group-{{ group_name }}:
  file.managed:
  - source: salt://linux/files/sudoerg
  - template: jinja
  - user: root
  - group: root
  - mode: 440
  - defaults:
      group: {{ group|yaml }}
{%- else %}
/etc/sudoers.d/91-salt-group-{{ group_name }}:
  file.absent:
  - name: /etc/sudoers.d/91-salt-group-{{ group_name }}
{%- endif %}

{%- else %}

system_group_{{ group_name }}:
  group.absent:
  - name: {{ group.name }}
  file.absent:
  - name: /etc/sudoers.d/91-salt-group-{{ group_name }}

{%- endif %}

{%- endfor %}

{%- endif %}

