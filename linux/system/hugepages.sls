{%- from "linux/map.jinja" import system with context %}

include:
  - linux.system.grub

{%- if "pse" in grains.cpu_flags or "pdpe1gb" in grains.cpu_flags %}

/etc/default/grub.d/90-hugepages.cfg:
  file.managed:
    - source: salt://linux/files/grub_hugepages
    - template: jinja
    - require:
      - file: grub_d_directory
    - watch_in:
      - cmd: grub_update

{%- for hugepages_type, hugepages in system.kernel.hugepages.iteritems() %}

{%- if hugepages.get('mount', False) or hugepages.get('default', False) %}

hugepages_mount_{{ hugepages_type }}:
  mount.mounted:
    - name: {{ hugepages.mount_point }}
    - device: Hugetlbfs-kvm
    - fstype: hugetlbfs
    - mkmnt: true
    - opts: mode=777,pagesize={{ hugepages.size }}

{%- endif %}

{%- endfor %}

{%- endif %}
