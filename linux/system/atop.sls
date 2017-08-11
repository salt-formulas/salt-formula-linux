{%- from "linux/map.jinja" import system with context %}

{%- if system.atop.enabled %}

atop_packages:
  pkg.installed:
    - name: atop

atop_defaults:
  file.managed:
    - name: /etc/default/atop
    - source: salt://linux/files/atop.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644

atop_logpath:
  file.directory:
  - name: {{ system.atop.logpath }}
  - user: root
  - group: root
  - mode: 750
  - makedirs: true

{%- if grains.get('init', None) == 'systemd' %}
atop_systemd_file:
  file.managed:
  - name: /etc/systemd/system/atop.service
  - source: salt://linux/files/atop.service
  - user: root
  - mode: 644
  - defaults:
    service_name: atop
    config_file: /etc/default/atop
    autostart: {{ system.atop.autostart }}
  - template: jinja
  - require_in:
    - service: atop_service
{%- endif %}

atop_service:
  service.running:
    - name: atop
    - enable: {{ system.atop.autostart }}
    - watch:
      - file: atop_defaults
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

{%- else %}

atop_service_stop:
  service.dead:
    - name: atop
    - enable: false
    - require_in:
      - pkg: atop_pkg_purge
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

atop_defaults_purge:
  file.absent:
    - names:
      - /etc/default/atop
      - /etc/systemd/system/atop.service
    - require:
      - pkg: atop_pkg_purge

atop_pkg_purge:
  pkg.purged:
    - name: atop

{%- endif %}
