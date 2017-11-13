{%- from "linux/map.jinja" import system with context %}
{%- if system.selinux is defined %}

include:
- linux.system.repo

{%- if grains.os_family == 'RedHat' %}
  {%- set mode = system.selinux %}

{{ mode }}:
  selinux.mode

{%- endif %}

{%- endif %}

