{%- from "linux/map.jinja" import system with context %}

{%- if system.enabled %}

{%- for key in system.ld.library %}
/etc/ld.so.conf.d/{{ key }}.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - contents: |
          {% for val in system.ld.library[key] -%}
          {{ val }}
          {% endfor %}
    - watch_in:
      - cmd: ldconfig_update
{% endfor %}

ldconfig_update:
  cmd.wait:
  - name: ldconfig

{% endif %}
