{%- from "linux/map.jinja" import system with context %}

include:
- linux.system.package

{%- if system.apparmor.enabled %}

apparmor_service:
  service.running:
  - name: apparmor
  - enable: true
  - require:
    - pkg: linux_packages

{%- else %}

apparmor_service_disable:
  service.dead:
  - name: apparmor
  - enable: false

apparmor_teardown:
  cmd.wait:
  - name: /etc/init.d/apparmor teardown
  - watch:
    - service: apparmor_service_disable

{%- endif %}
