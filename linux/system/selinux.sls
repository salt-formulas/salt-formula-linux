{%- from "linux/map.jinja" import system with context %}
{%- if system.selinux is defined %}
{%- if system.enabled %}

include:
- linux.system.repo

{%- if grains.os_family == 'RedHat' %}
  {%- set mode = system.selinux %}
{%- if system.selinux == 'disabled' %}

selinux_config:
  cmd.run:
  - names:
    - "sed -i 's/enforcing/disabled/g' /etc/selinux/config"
    - "sed -i 's/permissive/disabled/g' /etc/selinux/config"
  - unless: cat '/etc/selinux/config' | grep 'SELINUX=disabled'

selinux_setenforce:
  cmd.run:
    - name: "setenforce 0"
    - unless: getenforce | grep 'Disabled'

{%- else %}

selinux_config:
  selinux.mode:
    - name: {{ system.get('selinux', 'permissive') }}
    - require:
      - pkg: linux_repo_prereq_pkgs


{%- endif %}

{%- endif %}

{%- endif %}
{%- endif %}
