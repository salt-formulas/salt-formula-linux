{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

linux_packages:
  pkg.installed:
  - names: {{ system.pkgs }}

{%- for name, package in system.package.iteritems() %}

linux_extra_package_{{ name }}:
  {%- if package.version == 'latest' %}
  pkg.latest:
  {%- else %}
  pkg.installed:
  - version: {{ package.version }}
  {%- endif %}
  - name: {{ name }}
  {%- if package.repo is defined %}
  - fromrepo: {{ package.repo }}
  {%- endif %}
  {%- if package.hold is defined %}
  - hold: {{ package.hold }}
  {%- endif %}
  {%- if package.verify is defined %}
  - skip_verify: {% if package.verify %}false{% else %}true{% endif %}
  {%- endif %}
{%- endfor %}

{%- endif %}