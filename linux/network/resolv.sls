{%- from "linux/map.jinja" import network with context %}
{%- if network.enabled %}

/etc/resolv.conf:
  file.managed:
  - source: salt://linux/files/resolv.conf
  - mode: 644
  - template: jinja

{%- endif %}
