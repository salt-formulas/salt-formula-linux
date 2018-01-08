{%- from "linux/map.jinja" import system with context %}

{%- if system.enabled %}

{%- for key in system.ld.libraries %}
/etc/ld.so.conf.d/{{ key }}.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - contents: |
          {% for val in system.ld.libraries[key] -%}
          {{ val }}
          {% endfor %}
    - watch_in:
      - cmd: ldconfig_update
{% endfor %}

ldconfig_update:
  cmd.wait:
  - name: ldconfig

{% endif %}
