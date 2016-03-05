{%- from "linux/map.jinja" import network with context %}
{%- if network.enabled %}

{%- for name, host in network.host.iteritems() %}

{%- if host.names is defined %}

linux_host_{{ name }}:
  host.present:
  - ip: {{ host.address }}
  - names: {{ host.names }}

{%- if host.address in grains.ipv4 %}

{%- if host.names.0|length > host.names.1|length %}
{%- set before = host.names.1 + " " + host.names.0 %}
{%- set after = host.names.0 + " " + host.names.1 %}
{%- else %}
{%- set before = host.names.0 + " " + host.names.1 %}
{%- set after = host.names.1 + " " + host.names.0 %}
{%- endif %}

mine.send:
  module.run:
    - name: file.replace
    - path: /etc/hosts
    - pattern: {{ before }}
    - repl: {{ after }}
    - watch:
      - host: linux_host_{{ name }}

{%- endif %}

{%- endif %}

{%- endfor %}

{%- endif %}