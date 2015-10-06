{%- from "linux/map.jinja" import network with context %}
{%- if network.enabled %}

{%- for name, host in network.host.iteritems() %}

{%- if host.names is defined %}

linux_host_{{ name }}:
  host.present:
  - ip: {{ host.address }}
  - names: {{ host.names }}

{%- endif %}

{%- endfor %}

{%- endif %}