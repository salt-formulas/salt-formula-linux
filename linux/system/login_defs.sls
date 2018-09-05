{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}
  {%- if system.login_defs is defined %}
login_defs:
  file.managed:
    - name: /etc/login.defs
    - source: salt://linux/files/login.defs.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
  {%- endif %}
{%- endif %}
