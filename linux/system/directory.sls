{%- from "linux/map.jinja" import system with context %}

{%- for name, dir in system.directory.items() %}

{{ dir.name|default(name) }}:
  file.directory:
    {%- if dir %}
      {%- for key, value in dir.items() %}
    - {{ key }}: {{ value }}
      {%- endfor %}
    {%- else %}
    - name: {{ name }}
    {%- endif %}

{%- endfor %}
