{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- for file_name, file in system.file.items() %}

linux_file_{{ file_name }}:
{%- if file.serialize is defined %}
  file.serialize:
    - formatter: {{ file.serialize }}
  {%- if file.contents is defined  %}
    - dataset: {{ file.contents|json }}
  {%- elif file.contents_pillar is defined %}
    - dataset_pillar: {{ file.contents_pillar }}
  {%- endif %}
{%- else %}
  file.managed:
    {%- if file.source is defined %}
    - source: {{ file.source }}
    {%- if file.hash is defined %}
    - source_hash: {{ file.hash }}
    {%- else %}
    - skip_verify: True
    {%- endif %}
    {%- if file.template is defined %}
    - template: {{ file.template }}
      {%- if file.defaults is defined %}
    - defaults: {{ file.defaults|json }}
      {%- endif %}
      {%- if file.context is defined %}
    - context: {{ file.context|json }}
      {%- endif %}
    {%- endif %}
    {%- elif file.contents is defined %}
    - contents: {{ file.contents|json }}
    {%- elif file.contents_pillar is defined %}
    - contents_pillar: {{ file.contents_pillar }}
    {%- elif file.contents_grains is defined %}
    - contents_grains: {{ file.contents_grains }}
    {%- endif %}

{%- endif %}
    {%- if file.name is defined %}
    - name: {{ file.name }}
    {%- else %}
    - name: {{ file_name }}
    {%- endif %}
    - makedirs: {{ file.get('makedirs', 'True') }}
    - replace: {{ file.get('replace', 'True') }}
    - user: {{ file.get('user', 'root') }}
    - group: {{ file.get('group', 'root') }}
    {%- if file.mode is defined %}
    - mode: {{ file.mode }}
    {%- endif %}
    {%- if file.dir_mode is defined %}
    - dir_mode: {{ file.dir_mode }}
    {%- endif %}
    {%- if file.encoding is defined %}
    - encoding: {{ file.encoding }}
    {%- endif %}
 
{%- endfor %}

{%- endif %}
