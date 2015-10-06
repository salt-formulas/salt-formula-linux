{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}

{%- if grains.os_family == 'Debian' %}

linux_multipath_pkgs:
  pkg.installed:
  - names: {{ storage.multipath_pkgs }}

{%- if storage.multipath.backend not in ['fujitsu'] %}

linux_multipath_boot_pkg:
  pkg.installed:
  - name: multipath-tools-boot

{%- endif %}

{%- if storage.multipath.backend == 'HDS' %}

/etc/multipath.conf:
  file.managed:
  - source: salt://linux/files/multipath.conf.hds
  - template: jinja
  - require:
    - pkg: linux_multipath_pkgs

{%- else %}

/etc/multipath.conf:
  file.managed:
  - source: salt://linux/files/multipath.conf
  - template: jinja
  - require:
    - pkg: linux_multipath_pkgs

{%- endif %}

multipath_service:
  service.running:
  - enable: True
  - name: multipath-tools
  - watch:
    - file: /etc/multipath.conf
  - sig: multipathd

{%- endif %}

{%- endif %}
