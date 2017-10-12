{%- from "linux/map.jinja" import system with context %}
{%- if system.selinux is defined %}

include:
- linux.system.repo

{%- if grains.os_family == 'RedHat' %}

{%- if system.selinux == 'disabled' %}
	{%- set mode = 'permissive' %}
{%- else %}
	{%- set mode = {{ system.selinux }} %}
{%- endif %}

selinux_config:
  cmd.run:
  - name: "sed -i 's/SELINUX=[a-z][a-z]*$/SELINUX={{ system.selinux }}/' /etc/selinux/config"
  - unless: grep 'SELINUX={{ system.selinux }}' /etc/selinux/config
  - require:
    - pkg: linux_repo_prereq_pkgs

{{ mode }}:
	selinux.mode

{%- endif %}

{%- endif %}

