{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.rc.local is defined %}

/etc/rc.local:
  file.managed:
  - user: root
  - group: root
  - mode: 755
  - contents_pillar: linux:system:rc:local

{%- endif %}

{%- endif %}