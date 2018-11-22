{%- from "linux/map.jinja" import system with context %}
{%- if system.selinux is defined %}
{%- if grains.os_family == 'RedHat' %}

{% if system.selinux is mapping %}

  {% if system.selinux.pkgs %}
linux_system_selinux_pkgs:
  pkg.installed:
  - pkgs: {{ system.selinux.pkgs }}
  {%- endif %}

  {%- if system.selinux.mode %}
{{ system.selinux.mode }}:
  selinux.mode:
    - require:
      - pkg: linux_system_selinux_pkgs
  {%- endif %}

  {%- else %}

{{ system.selinux }}:
  selinux.mode

  {%- endif %}

{%- endif %}
{%- endif %}

