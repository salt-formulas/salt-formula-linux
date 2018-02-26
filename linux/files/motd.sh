{%- from "linux/map.jinja" import system with context -%}
{%- for motd in system.motd -%}
{%- if loop.index == index -%}
{%- for name, value in motd.items() -%}
{%- if name == motd_name -%}{{ value }}{%- endif %}
{%- endfor -%}
{%- endif -%}
{%- endfor -%}
