{%- from "linux/map.jinja" import system with context %}
{%- if system.cpu.governor is defined %}

include:
  - linux.system.sysfs

ondemand_service_disable:
  service.dead:
    - name: ondemand
    - enable: false

{%- if grains.get('virtual', None) in ['physical', None] %}
{#- Governor cannot be set in VMs, etc. #}

/etc/sysfs.d/governor.conf:
  file.managed:
    - source: salt://linux/files/governor.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - defaults:
        governor: {{ system.cpu.governor }}
    - require:
      - file: /etc/sysfs.d

{% for cpu_core in range(salt['grains.get']('num_cpus', 1)) %}

{% set core_key = 'devices/system/cpu/cpu' + cpu_core|string + '/cpufreq/scaling_governor' %}
{% if salt['file.file_exists']('/sys/'+ core_key) %}
governor_write_sysfs_cpu_core_{{ cpu_core }}:
  module.run:
  {%- if 'module.run' in salt['config.get']('use_superseded', default=[]) %}
    - sysfs.write:
      - key: {{ core_key }}
      - value: {{ system.cpu.governor }}
  {%- else %}
    - name: sysfs.write
    - key: {{ core_key }}
    - value: {{ system.cpu.governor }}
  {%- endif %}
{% endif %}

{%- endfor %}

{%- endif %}

{%- endif %}
