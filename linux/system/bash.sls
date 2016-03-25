{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.bash.get('preserve_history', False) %}
/etc/profile.d/bash_history.sh:
  file.managed:
    - source: salt://linux/files/bash_history.sh
    - template: jinja
{%- endif %}

{%- endif %}
