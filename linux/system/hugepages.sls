{%- from "linux/map.jinja" import system with context %}

{%- if "pse" in grains.cpu_flags or "pdpe1gb" in grains.cpu_flags %}

grub_d_directory:
  file.directory:
    - name: /etc/default/grub.d
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/etc/default/grub.d/90-hugepages.cfg:
  file.managed:
    - source: salt://linux/files/grub_hugepages
    - template: jinja
    - require:
      - file: grub_d_directory

hugepages_update_grub:
  cmd.run:
  - name: update-grub
  - watch:
    - file: /etc/default/grub.d/90-hugepages.cfg

{%- for hugepages_type, hugepages in system.kernel.hugepages.iteritems() %}

{%- if hugepages.get('mount', False) or hugepages.get('default', False) %}

hugepages_mount_{{ hugepages_type }}:
  mount.mounted:
    - name: {{ hugepages.mount_point }}
    - device: Hugetlbfs-kvm
    - fstype: hugetlbfs
    - mkmnt: true
    - opts: mode=775,pagesize={{ hugepages.size }}

{%- endif %}

{%- endfor %}

{%- endif %}
