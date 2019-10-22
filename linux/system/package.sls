{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- set pkgs_groups = {
  'latest': [],
  'purged': [],
  'removed': [],
  'installed': [],
  } %}
{%- for name, package in system.package.items() %}

  {%- if package.repo is defined or package.hold is defined or package.verify is defined %}
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
  - skip_verify: {{ "False" if package.verify else "True" }}
    {%- endif %}
  {%- else %}
    {%- if package.version is not defined %}
      {%- do pkgs_groups['installed'].append(name) %}
    {%- elif package.version in ('latest', 'purged', 'removed') %}
      {%- do pkgs_groups[package.version].append(name) %}
    {%- else %}
      {%- do pkgs_groups['installed'].append({name: package.version}) %}
    {%- endif %}
  {%- endif %}

{%- endfor %}

{%- for pkgs_group, pkgs in pkgs_groups.items() %}
  {%- if pkgs %}
linux_extra_packages_{{ pkgs_group }}:
  pkg.{{ pkgs_group }}:
    - pkgs: {{ pkgs | json }}
  {%- endif %}
{%- endfor %}

{%- endif %}
