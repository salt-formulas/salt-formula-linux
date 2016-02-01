{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

policyrcd_file:
  file.managed:
    - name: /usr/local/sbin/policy-rc.d
    - source: salt://linux/files/policy-rc.d
    - mode: 655
    - template: jinja

policyrcd_alternatives:
  alternatives.install:
    - name: policy-rc.d
    - link: /usr/sbin/policy-rc.d
    - path: /usr/local/sbin/policy-rc.d
    - require:
      - file: policyrcd_file

{%- endif %}
