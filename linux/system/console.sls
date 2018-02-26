{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.console is defined %}

{%- for tty_name, console in system.console.items() %}

{%- if grains.get('init', None) == 'upstart' %}
{{ tty_name }}_service_file:
  file.managed:
    - name: /etc/init/{{ tty_name }}.conf
    - source: salt://linux/files/tty.upstart
    - template: jinja
    - defaults:
        name: {{ tty_name }}
        tty: {{ console }}
{%- endif %}

{{ tty_name }}_service:
  service.running:
    - enable: true
    - name: {{ tty_name }}
    - watch:
      - file: {{ tty_name }}_service_file

{%- endfor %}

{%- endif %}

{%- endif %}
