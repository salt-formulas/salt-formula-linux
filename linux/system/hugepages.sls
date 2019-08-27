{%- from "linux/map.jinja" import system with context %}

include:
  - linux.system.grub

{%- if "pse" in grains.cpu_flags or "pdpe1gb" in grains.cpu_flags or "aarch64" in grains.cpuarch %}

/etc/default/grub.d/90-hugepages.cfg:
  file.managed:
    - source: salt://linux/files/grub_hugepages
    - template: jinja
    - require:
      - file: grub_d_directory
{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}
    - watch_in:
      - cmd: grub_update

{%- endif %}

{%- for hugepages_type, hugepages in system.kernel.hugepages.items() %}

hugepages_mount_{{ hugepages_type }}:
  mount.mounted:
    - name: {{ hugepages.mount_point }}
    - device: Hugetlbfs-kvm-{{ hugepages.size|lower }}
    - fstype: hugetlbfs
    - mkmnt: true
    - opts: mode=775,pagesize={{ hugepages.size }}
    - mount: {{ hugepages.mount|default('true') }}

# Make hugepages available right away with a temporary systctl write
# This will be handled via krn args after reboot, so don't use `sysctl.present`
{%- if hugepages.get('default', False) %}
hugepages_sysctl_vm_nr_hugepages:
  cmd.run:
    - name: "sysctl vm.nr_hugepages={{ hugepages.count }}"
    - unless: "sysctl vm.nr_hugepages | grep -qE '{{ hugepages.count }}'"
{%- endif %}

{%- endfor %}

{%- endif %}

# systemd always creates default mount point at /dev/hugepages
# we have to disable it, as we configure our own mount point for DPDK.
mask_dev_hugepages:
  cmd.run:
    - name: "systemctl mask dev-hugepages.mount"
