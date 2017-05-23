{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.kernel is defined %}

{%- if system.kernel.isolcpu is defined %}

include:
  - linux.system.grub

/etc/default/grub.d/90-isolcpu.cfg:
  file.managed:
    - contents: 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT isolcpus={{ system.kernel.isolcpu }}"'
    - require:
      - file: grub_d_directory
{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %} 
    - watch_in:
      - cmd: grub_update

{%- endif %}
{%- endif %}

{%- if system.kernel.version is defined %}

linux_kernel_package:
  pkg.installed:
  - pkgs:
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

{%- endif %}


{%- for module in system.kernel.get('modules', []) %}

linux_kernel_module_{{ module }}:
  kmod.present:
    - name: {{ module }}
    - persist: true

{%- endfor %}

{%- for module_name, module_content in system.kernel.get('module', {}).iteritems() %}

/etc/modprobe.d/{{ module_name }}.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - source: salt://linux/files/modprobe.conf.jinja
    - defaults:
       module_content: {{ module_content }}
       module_name: {{ module_name }}

{%- endfor %}

{%- for sysctl_name, sysctl_value in system.kernel.get('sysctl', {}).iteritems() %}

linux_kernel_{{ sysctl_name }}:
  sysctl.present:
  - name: {{ sysctl_name }}
  - value: {{ sysctl_value }}

{%- endfor %}

{%- endif %}

{%- endif %}
