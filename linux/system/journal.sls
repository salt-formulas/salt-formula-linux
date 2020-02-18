{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled and grains.get('init', None) == 'systemd' %}

{%- if system.systemd.journal is defined %}

linux_systemd_journal_config:
  file.managed:
    - name: /etc/systemd/journald.conf.d/90-salt.conf
    - source: salt://linux/files/journal.conf
    - template: jinja
    - makedirs: True
    - defaults:
        settings: {{ system.systemd.journal|tojson }}
    - watch_in:
      - module: linux_journal_systemd_reload

linux_journal_systemd_reload:
  module.wait:
    - name: service.restart
    - m_name: systemd-journald
    - require:
      - module: service.systemctl_reload

{%- endif %}
{%- endif %}