{%- from "linux/map.jinja" import network with context %}

{%- if network.dhclient.enabled|default(False) %}

dhclient_conf:
  file.managed:
    - name: {{ network.dhclient_config }}
    - source: salt://linux/files/dhclient.conf
    - template: jinja

{%- endif %}
