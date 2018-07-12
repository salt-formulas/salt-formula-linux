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

{%- for item in sysfs_list %}
{%- for key, value in item.items() %}
    {%- if key not in ["mode", "owner"] %}
      {%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}
      {#- Sysfs cannot be set in docker, LXC, etc. #}
linux_sysfs_write_{{ name }}_{{ key }}:
  module.run:
    - name: sysfs.write
    - key: {{ key }}
    - value: {{ value }}
      {%- endif %}
    {%- endif %}
  {%- endfor %}

{%- endfor %}
{%- endfor %}
