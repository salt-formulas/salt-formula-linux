{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}

{%- if storage.swap.enabled is not defined or storage.swap.enabled %}

{%- for swap_name, swap in storage.swap.items() %}

{%- if swap.enabled %}

{%- if swap.engine == 'partition' %}

linux_create_swap_partition_{{ swap.device }}:
  cmd.run:
  - name: 'mkswap {{ swap.device }}'
  - unless: file -L -s {{ swap.device }} | grep -q 'swap file'

linux_set_swap_partition_{{ swap.device }}:
  cmd.run:
  - name: 'swapon {{ swap.device }}'
  - unless: grep $(readlink -f {{ swap.device }}) /proc/swaps
  - require:
    - cmd: linux_create_swap_partition_{{ swap.device }}

{{ swap.device }}:
  mount.swap:
  - persist: True
  - require:
    - cmd: linux_set_swap_partition_{{ swap.device }}

{%- elif swap.engine == 'file' %}

linux_create_swap_file_{{ swap.device }}:
  cmd.run:
  - name: 'dd if=/dev/zero of={{ swap.device }} bs=1048576 count={{ swap.size }} && chmod 0600 {{ swap.device }}'
  - creates: {{ swap.device }}

linux_set_swap_file_{{ swap.device }}:
  cmd.wait:
  - name: 'mkswap {{ swap.device }}'
  - watch:
    - cmd: linux_create_swap_file_{{ swap.device }}

linux_set_swap_file_status_{{ swap.device }}:
  cmd.run:
  - name: 'swapon {{ swap.device }}'
  - unless: grep {{ swap.device }} /proc/swaps
  - require:
    - cmd: linux_set_swap_file_{{ swap.device }}

{{ swap.device }}:
  mount.swap:
  - persist: True
  - require:
    - cmd: linux_set_swap_file_{{ swap.device }}

{%- endif %}

{%- else %}

{{ swap.device }}:
  module.run:
  {%- if 'module.run' in salt['config.get']('use_superseded', default=[]) %}
    - mount.rm_fstab:
      - m_name: none
      - device: {{ swap.device }}
  {%- else %}
    - name: mount.rm_fstab
    - m_name: none
    - device: {{ swap.device }}
  {%- endif %}
    - onlyif: grep -q {{ swap.device }} /etc/fstab

linux_disable_swap_{{ swap.engine }}_{{ swap.device }}:
  cmd.run:
  {%- if swap.engine == 'partition' %}
    - name: 'swapoff {{ swap.device }}'
  {%- elif swap.engine == 'file' %}
    - name: 'swapoff {{ swap.device }} && rm -f {{ swap.device }}'
  {%- endif %}
    - onlyif: file -L -s {{ swap.device }} | grep -q 'swap file'

{%- endif %}

{%- endfor %}

{%- elif storage.swap.enabled is defined and not storage.swap.enabled %}

linux_disable_swap:
  cmd.run:
    - name: 'swapoff -a'

{%- endif %}

{%- endif %}
