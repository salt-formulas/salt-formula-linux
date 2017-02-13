{%- from "linux/map.jinja" import system with context %}

/etc/default/grub.d:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/etc/default/grub.d/90-sriov.cfg:
  file.managed:
    - contents: 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT intel_iommu=on iommu=pt"'
    - require:
      - file: /etc/default/grub.d

/etc/modprobe.conf/sriov.conf:
  file.managed:
    - contents: |
        blacklist ixgbevf
        blacklist igbvf
        blacklist i40evf

sriov_update_grub:
  cmd.run:
  - name: update-grub
  - watch:
    - file: /etc/default/grub.d/90-sriov.cfg