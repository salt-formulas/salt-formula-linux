{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

linux_packages:
  pkg.installed:
  - pkgs: {{ system.pkgs }}

{%- for name, package in system.package.iteritems() %}

linux_extra_package_{{ name }}:
  {%- if package.version is defined %}
    {%- if package.version == 'latest' %}
  pkg.latest:
    {%- elif package.version == 'purged' %}
  pkg.purged:
    {%- elif package.version == 'removed' %}
  pkg.removed:
    {%- else %}
  pkg.installed:
  - version: {{ package.version }}
    {%- endif %}
  {%- else %}
  pkg.installed:
  {%- endif %}
  - name: {{ name }}
  {%- if package.repo is defined %}
  - fromrepo: {{ package.repo }}
  {%- endif %}
  {%- if package.hold is defined %}
  - hold: {{ package.hold }}
  {%- endif %}
  {%- if package.verify is defined %}
  - skip_verify: {{ true if package.verify else false }}
  {%- endif %}
{%- endfor %}

{%- endif %}
