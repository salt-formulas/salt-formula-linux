{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled and system.motd|length > 0 %}

/etc/update-motd.d:
  file.directory:
    - clean: true

{%- if system.motd is string %}

{#- Set static motd only #}
/etc/motd:
  file.managed:
    - contents_pillar: linux:system:motd

{%- else %}

{%- if grains.oscodename == "jessie" %}
motd_fix_pam_sshd:
  file.replace:
    - name: /etc/pam.d/sshd
    - pattern: "/run/motd.dynamic"
    - repl: "/run/motd"
{%- endif %}

/etc/motd:
  file.absent

{%- for motd in system.motd %}
{%- set motd_index = loop.index %}

{%- for name, value in motd.items() %}
motd_{{ motd_index }}_{{ name }}:
  file.managed:
    - name: /etc/update-motd.d/5{{ motd_index }}-{{ name }}
    - source: salt://linux/files/motd.sh
    - template: jinja
    - mode: 755
    - require:
      - file: /etc/update-motd.d
    - defaults:
        index: {{ motd_index }}
        motd_name: {{ name }}
{%- endfor %}

{%- endfor %}

{%- endif %}

{%- endif %}
