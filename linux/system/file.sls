{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- for file_name, file in system.file.iteritems() %}

{{ file_name }}:
  file.managed:
    {%- if file.source is defined %}
    - source: {{ file.source }}
    {%- endif %}
    {%- if file.contents is defined %}
    - contents: {{ file.contents }}
    {%- endif %}
    - makedirs: {{ file.get('makedirs', 'True') }}
    - user: {{ file.get('user', 'root') }}
    - group: {{ file.get('group', 'root') }}
    {%- if file.file_mode is defined %}
    - file_mode: {{ file.file_mode }}
    {%- endif %}
    {%- if file.dir_mode is defined %}
    - dir_mode: {{ file.dir_mode }}
    {%- endif %}
    {%- if file.encoding is defined %}
    - encoding: {{ file.encoding }}
    {%- endif %}
    {%- if file.hash is defined %}
    - source_hash: {{ file.hash }}
    {%- else %}
    - skip_verify: True
    {%- endif %}

{%- endfor %}

{%- endif %}