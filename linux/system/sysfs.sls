{%- from "linux/map.jinja" import system with context %}

linux_sysfs_package:
  pkg.installed:
    - pkgs:
      - sysfsutils
    - refresh: true

/etc/sysfs.d:
  file.directory:
    - require:
      - pkg: linux_sysfs_package

{% set apply = system.get('sysfs', {}).pop('enable_apply', True) %}

{%- for name, sysfs in system.get('sysfs', {}).items() %}

/etc/sysfs.d/{{ name }}.conf:
  file.managed:
    - source: salt://linux/files/sysfs.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - defaults:
        name: {{ name }}
        sysfs: {{ sysfs|yaml }}
    - require:
      - file: /etc/sysfs.d

{%- if sysfs is mapping %}
{%- set sysfs_list = [sysfs] %}
{%- else %}
{%- set sysfs_list = sysfs %}
{%- endif %}

{%- if apply %}

{%- for item in sysfs_list %}
{%- set list_idx = loop.index %}
{%- for key, value in item.items() %}
    {%- if key not in ["mode", "owner"] %}
      {%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}
      {#- Sysfs cannot be set in docker, LXC, etc. #}
linux_sysfs_write_{{ list_idx }}_{{ name }}_{{ key }}:
  module.run:
        {%- if 'module.run' in salt['config.get']('use_superseded', default=[]) %}
    - sysfs.write:
      - key: {{ key }}
      - value: {{ value }}
        {%- else %}
    - name: sysfs.write
    - key: {{ key }}
    - value: {{ value }}
        {%- endif %}
      {%- endif %}
    {%- endif %}
  {%- endfor %}

{%- endfor %}

{%- endif %}

{%- endfor %}
