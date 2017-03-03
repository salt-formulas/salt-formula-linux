{%- from "linux/map.jinja" import system with context %}
include:
{%- if system.repo|length > 0 %}
- linux.system.repo
{%- endif %}
{%- if system.pkgs|length > 0 %}
- linux.system.package
{%- endif %}
{%- if pillar.linux.system.autoupdates is defined %}
- linux.system.autoupdates
{%- endif %}
{%- if system.timezone is defined %}
- linux.system.timezone
{%- endif %}
{%- if system.kernel is defined %}
- linux.system.kernel
{%- if system.kernel.hugepages is defined %}
- linux.system.hugepages
{%- endif %}
{%- if system.kernel.sriov is defined %}
- linux.system.sriov
{%- endif %}
{%- endif %}
{%- if system.cpu is defined %}
- linux.system.cpu
{%- endif %}
{%- if system.locale|length > 0 %}
- linux.system.locale
{%- endif %}
{%- if system.prompt is defined %}
- linux.system.prompt
{%- endif %}
{%- if system.bash is defined %}
- linux.system.bash
{%- endif %}
{%- if system.user|length > 0 %}
- linux.system.user
{%- endif %}
{%- if system.group|length > 0 %}
- linux.system.group
{%- endif %}
{%- if system.rc is defined %}
- linux.system.rc
{%- endif %}
{%- if system.job|length > 0 %}
- linux.system.job
{%- endif %}
{%- if grains.os_family == 'RedHat' %}
- linux.system.selinux
{%- endif %}
{%- if system.ca_certificates is defined %}
- linux.system.certificate
{%- endif %}
{%- if system.apparmor is defined %}
- linux.system.apparmor
{%- endif %}
{%- if system.console is defined %}
- linux.system.console
{%- endif %}
{%- if system.doc is defined %}
- linux.system.doc
{%- endif %}
{%- if system.limit|length > 0 %}
- linux.system.limit
{%- endif %}
{%- if system.motd|length > 0 %}
- linux.system.motd
{%- endif %}
{%- if system.get('policyrcd', [])|length > 0 %}
- linux.system.policyrcd
{%- endif %}
{%- if system.haveged is defined %}
- linux.system.haveged
{%- endif %}
{%- if system.config is defined %}
- linux.system.config
{%- endif %}
{%- if system.sudo is defined %}
- linux.system.sudo
{%- endif %}
