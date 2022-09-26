{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}

{%- for name, mount in storage.mount|dictsort %}

{%- if mount.enabled %}

{%- if not mount.file_system in ['nfs', 'nfs4', 'cifs', 'tmpfs'] %}

{%- if mount.make_fs is defined and mount.make_fs %}
mkfs_{{ mount.device}}:
  cmd.run:
  - name: "mkfs.{{ mount.file_system }} -L {{ name }} {{ mount.device }}"
  - onlyif: "test `blkid {{ mount.device }} | grep -q TYPE;echo $?` -eq 1"
  - require_in:
    - mount: {{ mount.path }}
  {%- if mount.file_system == 'xfs' %}
  - require:
    - pkg: xfs_packages_{{ mount.device }}
  {%- endif %}
{%- endif %}

{%- if mount.file_system == 'xfs' %}
xfs_packages_{{ mount.device }}:
  pkg.installed:
    - name: xfsprogs
{% endif %}

{%- endif %}

{%- if mount.file_system == 'nfs' %}
linux_storage_nfs_packages_{{ mount.path }}:
  pkg.installed:
  - pkgs: {{ storage.nfs.pkgs | json }}
{%- endif %}

{{ mount.path }}:
  mount.mounted:
  - order: 1
  - device: {{ mount.device }}
  - fstype: {{ mount.file_system }}
  - mkmnt: True
  - opts: {{ mount.get('opts', 'defaults,noatime') }}
  - mount: {{ mount.get('mount', 'True') }}
  - persist: {{ mount.get('save_to_fstab', 'False') }}
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
