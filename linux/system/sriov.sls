{%- from "linux/map.jinja" import system with context %}

include:
  - linux.system.grub

/etc/default/grub.d/90-sriov.cfg:
  file.managed:
    - contents: 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT intel_iommu=on iommu=pt"'
    - require:
      - file: grub_d_directory
    - watch_in:
      - cmd: grub_update

/etc/modprobe.d/sriov.conf:
  file.managed:
    - contents: |
        blacklist ixgbevf
        blacklist igbvf
        blacklist i40evf

{%- if system.kernel.get('unsafe_interrupts', false) %}

/etc/modprobe.d/iommu_unsafe_interrupts.conf:
  file.managed:
    - contents: options vfio_iommu_type1 allow_unsafe_interrupts=1

{%- endif %}
