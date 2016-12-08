{%- from "linux/map.jinja" import system with context %}
{%- if system.get('enabled', False) %}

include:
- linux.system.package

rsyslog_service:
  service.running:
  - name: rsyslog
  - enable: true
  - require:
    - pkg: rsyslog

{%- if system.rsyslog.template is defined %}

/etc/rsyslog.conf:
  file.replace:
  - pattern: |
      ^#$
      ^# Use traditional timestamp format.$
      ^#.*$
      ^#$
      ^\$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat$
  - repl: |
      #
      # Template (Edited by Salt)
      #
      $Template {{ system.rsyslog.template.name }}, "{{ system.rsyslog.template.string|replace('\\n', '\\\\n') }}"
      $ActionFileDefaultTemplate {{ system.rsyslog.template.name }}
  - require:
    - pkg: rsyslog
  - watch_in:
    - service: rsyslog_service

{%- endif %}

{%- endif %}
