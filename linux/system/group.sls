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

{%- else %}

system_group_{{ group_name }}:
  group.absent:
  - name: {{ group.name }}

{%- endif %}

{%- endfor %}

{%- endif %}

