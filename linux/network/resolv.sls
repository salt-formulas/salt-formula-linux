{%- from "linux/map.jinja" import network with context %}
{%- if network.enabled %}

/etc/resolv.conf:
  file.managed:
  - source: salt://linux/files/resolv.conf
  - mode: 644
  - template: jinja

linux_resolvconf_disable:
  cmd.run:
    - name: resolvconf --disable-updates
    - onlyif: resolvconf --updates-are-enabled

{%- endif %}
