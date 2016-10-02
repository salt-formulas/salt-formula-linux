{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled and storage.multipath.enabled %}

linux_storage_multipath_packages:
  pkg.installed:
  - names: {{ storage.multipath.pkgs }}

linux_storage_multipath_config:
  file.managed:
  - name: /etc/multipath.conf
  - source: salt://linux/files/multipath.conf
  - template: jinja
  - require:
    - pkg: linux_storage_multipath_packages

linux_storage_multipath_service:
  service.running:
  - enable: true
  - name: {{ storage.multipath.service }}
  - watch:
    - file: linux_storage_multipath_config
  - sig: multipathd

{%- endif %}
