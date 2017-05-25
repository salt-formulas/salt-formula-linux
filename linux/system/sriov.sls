{%- from "linux/map.jinja" import system with context %}

include:
  - linux.system.iommu

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
