{%- from "linux/map.jinja" import banner with context %}

{%- if banner.get('enabled', False) %}
/etc/issue:
  file.managed:
  - user: root
  - group: root
  - mode: 644
  - contents_pillar: linux:system:banner:contents
{%- endif %}
