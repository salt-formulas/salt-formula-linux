{%- if pillar.linux is defined %}
include:
{%- if pillar.linux.system is defined %}
- linux.system
{%- endif %}
{%- if pillar.linux.network is defined %}
- linux.network
{%- endif %}
{%- if pillar.linux.storage is defined %}
- linux.storage
{%- endif %}
{%- endif %}