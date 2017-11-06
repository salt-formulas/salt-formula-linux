{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if grains.os_family == 'RedHat' %}

{#- update-motd is not available in RedHat, so support only static motd #}
/etc/motd:
  file.managed:
    - contents_pillar: linux:system:motd

{%- else %}

{%- if grains.os == 'Ubuntu' %}
package_update_motd:
  pkg.installed:
    - name: update-motd
    - require_in:
      - file: /etc/update-motd.d
{%- endif %}

/etc/update-motd.d:
  file.directory:
    - clean: true

{%- if grains.oscodename == "jessie" %}
motd_fix_pam_sshd:
  file.replace:
    - name: /etc/pam.d/sshd
    - pattern: "/run/motd.dynamic"
    - repl: "/run/motd"
{%- endif %}

{%- for motd in system.motd %}
{%- set motd_index = loop.index %}

{%- for name, value in motd.iteritems() %}
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
