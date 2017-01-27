{%- from "linux/map.jinja" import network with context %}
{%- if network.enabled %}

{%- if network.get('purge_hosts', false) %}

linux_hosts:
  file.managed:
    - name: /etc/hosts
    - source: salt://linux/files/hosts
    - template: jinja

{%- else %}

{%- for name, host in network.host.iteritems() %}

{%- if host.names is defined %}

{%- set clearers = [] %}
{%- for etc_addr, etc_names in salt.hosts.list_hosts().iteritems() %}
{%- set names_to_clear = [] %}
{%- for host_name in host.names %}
{%- if (host.address != etc_addr) and host_name in etc_names %}
{%- do names_to_clear.append(host_name) %}
{%- endif %}
{%- endfor %}
{%- if names_to_clear != [] %}
{%- set clearer = "linux_host_" + name + "_" +  etc_addr + "_clear" %}
{%- do clearers.append(clearer) %}

{{ clearer }}:
  host.absent:
  - ip: {{ etc_addr }}
  - names: {{ names_to_clear }}

{%- endif %}
{%- endfor %}

linux_host_{{ name }}:
  host.present:
  - ip: {{ host.address }}
  - names: {{ host.names }}
  - require: {{ clearers }}

{%- if host.address in grains.ipv4 and host.names|length > 1 %}

{%- if host.names.1 in host.names.0 %}
{%- set before = host.names.1 + " " + host.names.0 %}
{%- set after = host.names.0 + " " + host.names.1 %}
{%- elif host.names.0 in host.names.1 %}
{%- set before = host.names.0 + " " + host.names.1 %}
{%- set after = host.names.1 + " " + host.names.0 %}
{%- endif %}

linux_host_{{ name }}_order_fix:
  module.run:
    - name: file.replace
    - path: /etc/hosts
    - pattern: {{ before }}
    - repl: {{ after }}
    - watch:
      - host: linux_host_{{ name }}
    - onlyif:
      - grep -q "{{ before }}" /etc/hosts

{%- endif %}

{%- endif %}

{%- endfor %}

{%- endif %}

{%- endif %}
