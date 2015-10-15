{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.console is defined %}

{%- for tty_name, console in system.console.iteritems() %}

{%- if console.autologin %}
autologin_{{ tty_name }}_enable:
  cmd.run:
  - name: "sed -i 's|/sbin/getty|/sbin/getty --autologin {{ console.autologin }}|g' /etc/init/{{ tty_name }}.conf"
  - unless: |
    "grep '\-\-autologin' /etc/init/{{ tty_name }}.conf"
{%- else %}
autologin_{{ tty_name }}_disable:
  cmd.run:
  - name: "sed -i 's| \-\-autologin [a-zA-Z0-9]*||g' /etc/init/{{ tty_name }}.conf"
  - onlyif: |
    "grep '\-\-autologin' /etc/init/{{ tty_name }}.conf"
{%- endif %}

{%- endfor %}

{%- endif %}

{%- endif %}
