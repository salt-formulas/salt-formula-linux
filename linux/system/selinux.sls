{%- from "linux/map.jinja" import system with context %}
{%- if system.selinux is defined %}

  {% if system.selinux.pkgs %}
linux_system_selinux_pkgs:
  pkg.installed:
  - pkgs: {{ system.selinux.pkgs }}
  {%- endif %}

  {%- if grains.os_family == 'RedHat' %}

{{ system.selinux.mode }}:
  selinux.mode:
    - require:
      - pkg: linux_system_selinux_pkgs

  {%- endif %}
{%- endif %}

