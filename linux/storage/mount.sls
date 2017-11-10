{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}

{%- for name, mount in storage.mount|dictsort %}

{%- if mount.enabled %}

{%- if not mount.file_system in ['nfs', 'nfs4', 'cifs', 'tmpfs', 'none'] %}

{%- if mount.file_system == 'xfs' %}
create_xfs_{{ mount.device }}:
  module.run:
    - name: xfs.mkfs
    - device: {{ mount.device }}
    - label: {{ name }}
{%- if mount.block_size is defined %}
    - bso: {{ mount.block_size }}
{%- endif %}
    - onlyif: "test `blkid {{ mount.device }} >/dev/null;echo $?` -eq 2"
    - require:
      - pkg: xfs_packages_{{ mount.device }}
    - require_in:
      - mount: {{ mount.path }}

xfs_packages_{{ mount.device }}:
  pkg.installed:
    - name: xfsprogs

{%- elif mount.file_system in ['ext2', 'ext3', 'ext4'] %}
create_extfs_{{ mount.device }}:
  module.run:
    - name: extfs.mkfs
    - device: {{ mount.device }}
    - kwargs: {
{%- if mount.block_size is defined %}
        block_size: {{ mount.block_size }},
{%- endif %}
        label: {{ name }}
    }
    - fs_type: {{ mount.file_system }}
    - onlyif: "test `blkid {{ mount.device }} >/dev/null;echo $?` -eq 2"
    - require_in:
      - mount: {{ mount.path }}

{%- else %}
mkfs_{{ mount.device}}:
  cmd.run:
  - name: "mkfs.{{ mount.file_system }} -L {{ name }} {{ mount.device }}"
  - onlyif: "test `blkid {{ mount.device }} >/dev/null;echo $?` -eq 2"
  - require_in:
    - mount: {{ mount.path }}
{%- endif %}

{%- endif %}

{%- if mount.file_system == 'nfs' %}
linux_storage_nfs_packages:
  pkg.installed:
  - pkgs: {{ storage.nfs.pkgs }}
{%- endif %}

{{ mount.path }}:
  mount.mounted:
  - device: {{ mount.device }}
  - fstype: {{ mount.file_system }}
  - mkmnt: True
  - opts: {{ mount.get('opts', 'defaults,noatime') }}
  {%- if mount.file_system == 'xfs' %}
  - require:
    - pkg: xfs_packages_{{ mount.device }}
  {%- endif %}

{%- if mount.user is defined %}
{{ mount.path }}_permissions:
  file.directory:
    - name: {{ mount.path }}
    - user: {{ mount.user }}
    - group: {{ mount.get('group', 'root') }}
    - mode: {{ mount.get('mode', 755) }}
    - require:
      - mount: {{ mount.path }}
{%- endif %}

{%- endif %}

{%- endfor %}

{%- endif %}
