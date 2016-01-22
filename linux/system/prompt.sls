{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

/etc/profile.d/prompt.sh:
  file.managed:
    - source: salt://linux/files/prompt.sh
    - template: jinja

/etc/bash.bashrc:
  file.replace:
    - pattern: ".*PS1=.*"
    - repl: "# Prompt is set by /etc/profile.d/prompt.sh"

/etc/skel/.bashrc:
  file.replace:
    - pattern: ".*PS1=.*"
    - repl: "# Prompt is set by /etc/profile.d/prompt.sh"

{%- endif %}
