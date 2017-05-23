{%- from "linux/map.jinja" import system with context %}
{%- if system.cpu.governor is defined %}

linux_sysfs_package:
  pkg.installed:
    - pkgs:
      - sysfsutils
    - refresh: true

/etc/sysfs.d:
  file.directory:
    - require:
      - pkg: linux_sysfs_package

ondemand_service_disable:
  service.dead:
    - name: ondemand
    - enable: false

/etc/sysfs.d/governor.conf:
  file.managed:
    - source: salt://linux/files/governor.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
    - defaults:
        governor: {{ system.cpu.governor }}

{% for cpu_core in range(salt['grains.get']('num_cpus', 1)) %}

governor_write_sysfs_cpu_core_{{ cpu_core }}:
  module.run:
    - name: sysfs.write
    - key: devices/system/cpu/cpu{{ cpu_core }}/cpufreq/scaling_governor
    - value: {{ system.cpu.governor }}

{%- endfor %}

{%- endif %}
