{%- from "linux/map.jinja" import system with context %}
{%- if system.selinux is defined %}

include:
- linux.system.repo

{%- if grains.os_family == 'RedHat' %}

{%- if system.selinux == 'disabled' %}

selinux_config:
  cmd.run:
  - name: "sed -i 's/SELINUX=[a-z][a-z]*$/SELINUX={{ system.selinux }}/' /etc/selinux/config"
  - unless: cat '/etc/selinux/config' | grep 'SELINUX={{ system.selinux }}'
  - require:
    - pkg: linux_repo_prereq_pkgs

permisive:
  selinux.mode

{%- else %}

selinux_config:
  cmd.run:
  - name: "sed -i 's/SELINUX=[a-z][a-z]*$/SELINUX={{ system.selinux }}/' /etc/selinux/config"
  - unless: cat '/etc/selinux/config' | grep 'SELINUX={{ system.selinux }}'
  - require:
    - pkg: linux_repo_prereq_pkgs

{{ system.selinux }}:
  selinux.mode

{%- endif %}

{%- endif %}

{%- endif %}

