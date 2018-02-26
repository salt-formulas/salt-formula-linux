{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

profile.d_clean:
  file.directory:
  - name: /etc/profile.d
  - clean: true
  - exclude_pat: 'E@^((?!salt_profile*).)*$'

{%- if system.profile|length > 0 %}

{%- for name, script in system.profile.items() %}
profile.d_script_{{ name  }}:
    file.managed:
    - name: /etc/profile.d/salt_profile_{{ name }}{%if name.split('.')|length == 1 %}.sh{% endif %}
    - source:
      - salt://linux/files/etc_profile_{{ name }}
      - salt://linux/files/etc_profile
    - template: jinja
    - defaults:
          script: {{ script|yaml }}
    - require_in:
      - service: profile.d_clean
{% endfor %}

{%- endif %}
{%- endif %}

