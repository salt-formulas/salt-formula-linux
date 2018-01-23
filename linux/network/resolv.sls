{%- from "linux/map.jinja" import network with context %}
{%- if network.enabled %}

/etc/resolv.conf:
  file.managed:
  - source: salt://linux/files/resolv.conf
  - mode: 644
  - template: jinja
  - follow_symlinks: false
  - require:
    - service: resolvconf_service

resolvconf_service:
  service.dead:
    - name: resolvconf
    - enable: false

{%- endif %}
