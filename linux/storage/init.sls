{%- from "linux/map.jinja" import storage with context %}
{%- if storage.mount|length > 0 or storage.swap|length > 0 or storage.multipath.enabled or storage.lvm|length > 0 %}
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
