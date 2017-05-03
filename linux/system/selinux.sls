{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

include:
- linux.system.repo

{%- if grains.os_family == 'RedHat' %}

{%- if system.selinux == 'disabled' %}

selinux_config:
  cmd.run:
  - names:
    - "sed -i 's/enforcing/disabled/g' /etc/selinux/config; setenforce 0"
    - "sed -i 's/permissive/disabled/g' /etc/selinux/config; setenforce 0"
  - unless: cat '/etc/selinux/config' | grep 'SELINUX=disabled'

{%- else %}

selinux_config:
  selinux.mode:
  - name: {{ system.get('selinux', 'permissive') }}
  - require:
    - pkg: linux_repo_prereq_pkgs

{%- endif %}

{%- endif %}

{%- endif %}
