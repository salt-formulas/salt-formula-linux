{%- from "linux/map.jinja" import network with context %}
{%- if network.enabled %}

{%- set dhclient = network.get('dhclient_config', False) %}

{%- if dhclient %}
dhclient_conf:
  file.managed:
    - name: {{ network.dhclient_cfg_path }}
    - source: salt://linux/files/dhclient.conf
    - template: jinja
{%- endif %}

{%- endif %}
