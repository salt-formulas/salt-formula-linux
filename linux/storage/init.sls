{%- from "linux/map.jinja" import storage with context %}
{%- if storage.mount|length > 0 or storage.swap|length > 0 or storage.multipath %}
include:
{%- if storage.mount|length > 0 %}
- linux.storage.mount
{%- endif %}
{%- if storage.swap|length > 0 %}
- linux.storage.swap
{%- endif %}
{%- if storage.multipath %}
- linux.storage.multipath
{%- endif %}
{%- endif %}
