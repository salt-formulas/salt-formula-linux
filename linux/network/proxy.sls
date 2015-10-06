{%- from "linux/map.jinja" import network with context %}
{%- if network.enabled %}

{%- if grains.os_family == 'Debian' %}

{%- if network.proxy.host == 'none' %}

/etc/profile.d/proxy.sh:
  file.absent

/etc/apt/apt.conf.d/95proxies:
  file.absent

{%- else %}

/etc/apt/apt.conf.d/95proxies:
  file.managed:
  - template: jinja
  - source: salt://linux/files/95proxies

{%- endif %}

{%- endif %}

{%- endif %}
