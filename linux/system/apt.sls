{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}
{%- if grains.os_family == 'Debian' %}

{%- if system.repo|length > 0 %}
include:
- linux.system.repo
{%- endif %}

{%- for key, config in system.apt.get('config', {}).items() %}

linux_apt_conf_{{ key }}:
  file.managed:
  - name: /etc/apt/apt.conf.d/99{{ key }}-salt
  - template: jinja
  - source: salt://linux/files/apt.conf
  - defaults:
      config: {{ config|yaml }}
  {%- if system.repo|length > 0 %}
  - require_in:
    - pkg: linux_repo_prereq_pkgs
  {%- endif %}

{%- endfor %}

{%- endif %}
{%- endif %}
