{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}

{%- set install_xfs = False %}

{%- for name, mount in storage.mount.iteritems() %}
  {%- if mount.enabled and mount.file_system == 'xfs' %}
    {%- set install_xfs = True %}
  {%- endif %}
{%- endfor %}

{%- if install_xfs == True %}
xfs_packages:
  package.installed:
    - name: xfsprogs
{%- endif %}


{%- for name, mount in storage.mount.iteritems() %}

{%- if mount.enabled %}

{%- if not mount.file_system in ['nfs', 'nfs4'] %}

mkfs_{{ mount.device}}:
  cmd.run:
  - name: "mkfs.{{ mount.file_system }} -L {{ name }} {{ mount.device }}"
  - onlyif: "test `blkid {{ mount.device }} >/dev/null;echo $?` -eq 2"
  - require_in:
    - mount: {{ mount.path }}

{%- endif %}

{{ mount.path }}:
  mount.mounted:
  - device: {{ mount.device }}
  - fstype: {{ mount.file_system }}
  - mkmnt: True
  - opts: {{ mount.get('opts', 'defaults,noatime') }}
  {%- if mount.file_system == 'xfs' %}
  require:
    - pkg: xfs_packages
  {%- endif %}

{%- endif %}

{%- endfor %}

{%- endif %}
