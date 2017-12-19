{%- from "linux/map.jinja" import network with context %}

{%- if network.dhclient.enabled|default(False) %}

dhclient_conf:
  file.managed:
    - name: {{ network.dhclient_config }}
    - source: salt://linux/files/dhclient.conf
    - template: jinja

{%- elif network.dhclient.enabled is defined and network.dhclient.enabled == False %}

kill_dhcp_client:
  cmd.run:
  - name: "pkill dhclient"
  - onlyif: "pgrep dhclient"

{%- endif %}
