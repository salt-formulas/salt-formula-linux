{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}

{%- for name, mount in storage.mount.iteritems() %}

{%- if mount.enabled %}

{%- if not mount.file_system in ['nfs', 'nfs4', 'cifs', 'tmpfs'] %}

mkfs_{{ mount.device}}:
  cmd.run:
  - name: "mkfs.{{ mount.file_system }} -L {{ name }} {{ mount.device }}"
  - onlyif: "test `blkid {{ mount.device }} >/dev/null;echo $?` -eq 2"
  - require_in:
    - mount: {{ mount.path }}
  {%- if mount.file_system == 'xfs' %}
  - require:
    - pkg: xfs_packages_{{ mount.device }}

xfs_packages_{{ mount.device }}:
  pkg.installed:
    - name: xfsprogs
  {%- endif %}

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
