include:
  - linux.system.grub

/etc/default/grub.d/90-iommu.cfg:
  file.managed:
    - contents: 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT intel_iommu=on iommu=pt"'
    - require:
      - file: grub_d_directory
{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}
    - watch_in:
      - cmd: grub_update
{%- endif %}
