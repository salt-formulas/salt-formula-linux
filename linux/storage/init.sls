{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}
include:
{%- if storage.mount|length > 0 %}
- linux.storage.mount
{%- endif %}
{%- if storage.swap|length > 0 %}
- linux.storage.swap
{%- endif %}
{%- if storage.lvm|length > 0 %}
- linux.storage.lvm
{%- endif %}
{%- if storage.multipath.enabled %}
- linux.storage.multipath
{%- endif %}

{%- endif %}
