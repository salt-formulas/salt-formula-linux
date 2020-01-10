{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled and grains.get('init', None) == 'systemd' %}
{%- if system.systemd.journal is defined %}
include: 
  - linux.system.journal
{%- endif %}

{%- if system.systemd.system is defined %}
linux_systemd_system_config:
  file.managed:
    - name: /etc/systemd/system.conf.d/90-salt.conf
    - source: salt://linux/files/systemd.conf
    - template: jinja
    - makedirs: True
    - defaults:
        settings: {{ system.systemd.system }}
    - watch_in:
      - module: linux_systemd_reload
{%- endif %}

{%- if system.systemd.user is defined %}
linux_systemd_user_config:
  file.managed:
    - name: /etc/systemd/user.conf.d/90-salt.conf
    - source: salt://linux/files/systemd.conf
    - template: jinja
    - makedirs: True
    - defaults:
        settings: {{ system.systemd.user }}
    - watch_in:
      - module: linux_systemd_reload
{%- endif %}

linux_systemd_reload:
  module.wait:
  - name: service.systemctl_reload

{%- endif %}