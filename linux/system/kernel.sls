{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.kernel is defined %}

{%- if system.kernel.version is defined %}

linux_kernel_package:
  pkg.installed:
  - names:
    - linux-image-{{ system.kernel.version }}-{{ system.kernel.type|default('generic') }}
    {%- if system.kernel.get('headers', False) %}
    - linux-headers-{{ system.kernel.version }}-{{ system.kernel.type|default('generic') }}
    {%- endif %}
    {%- if system.kernel.get('extra', False) %}
    - linux-image-extra-{{ system.kernel.version }}-{{ system.kernel.type|default('generic') }}
    {%- endif %}
  - refresh: true

# Not very Salt-ish.. :-(
linux_kernel_old_absent:
  cmd.wait:
  - name: "apt-get purge -y $(dpkg -l '*linux-image-[0-9]*' '*linux-headers-[0-9]*' '*linux-image-extra-[0-9]*' | grep -E '^ii' | awk '{print $2}' | grep -v '{{ system.kernel.version }}')"
  - watch:
    - pkg: linux_kernel_package

{%- else %}

linux_kernel_package:
  pkg.latest:
  - names:
    - linux-image-{{ system.kernel.type|default('generic') }}{% if system.kernel.get('lts', False) %}-lts-{{ system.kernel.lts }}{% endif %}
    {%- if system.kernel.get('headers', False) %}
    - linux-headers-{{ system.kernel.type|default('generic') }}{% if system.kernel.get('lts', False) %}-lts-{{ system.kernel.lts }}{% endif %}
    {%- endif %}
    {%- if system.kernel.get('extra', False) %}
    - linux-image-extra-{{ system.kernel.type|default('generic') }}{% if system.kernel.get('lts', False) %}-lts-{{ system.kernel.lts }}{% endif %}
    {%- endif %}
  - refresh: true

{%- endif %}

{%- for sysclt_name, sysctl_value in sytem.kernel.get('sysctl', {}).iteritems() %}

linux_kernel_{{ sysclt_name }}
  sysctl.present:
  - name: {{ sysclt_name }}
  - value: {{ sysctl_value }}

{%- endfor %}

{%- endif %}

{%- endif %}
