{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.autoupdates.get('enabled', True) %}

{%- if system.autoupdates.pkgs %}
linux_autoupdates_packages:
  pkg.installed:
  - pkgs: {{ system.autoupdates.pkgs }}
{%- endif %}

{%- if grains.os_family == 'Debian' %}
/etc/apt/apt.conf.d/90autoupdates:
  file.managed:
  - source: salt://linux/files/90autoupdates
  - template: jinja
  - user: root
  - group: root
  - mode: 644
{%- endif %}

{%- endif %}

{%- endif %}
