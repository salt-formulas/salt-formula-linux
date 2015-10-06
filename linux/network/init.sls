{%- from "linux/map.jinja" import network with context %}
include:
- linux.network.hostname
{%- if network.host|length > 0 %}
- linux.network.host
{%- endif %}
{%- if network.interface|length > 0 %}
- linux.network.interface
{%- endif %}
- linux.network.proxy
