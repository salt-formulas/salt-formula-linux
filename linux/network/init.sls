{%- from "linux/map.jinja" import network with context %}
include:
- linux.network.hostname
{%- if network.host|length > 0 or network.get('purge_hosts', True) %}
- linux.network.host
{%- endif %}
{%- if network.resolv is defined %}
- linux.network.resolv
{%- endif %}
{%- if network.dpdk is defined %}
- linux.network.dpdk
{%- endif %}
{%- if network.interface|length > 0 %}
- linux.network.interface
{%- endif %}
- linux.network.proxy
