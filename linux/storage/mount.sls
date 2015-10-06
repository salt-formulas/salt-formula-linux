{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}

{%- for name, mount in storage.mount.iteritems() %}

{%- if mount.enabled %}

mkfs_{{ mount.device}}:
  cmd.run:
  - name: "mkfs.{{ mount.file_system }} -L {{ name }} {{ mount.device }}"
  - onlyif: "test `blkid {{ mount.device }} >/dev/null;echo $?` -eq 2"
  - require_in:
    - mount: {{ mount.path }}

{{ mount.path }}:
  mount.mounted:
  - device: {{ mount.device }}
  - fstype: {{ mount.file_system }}
  - mkmnt: True
  - opts: {{ mount.get('opts', 'defaults,noatime') }}

{%- endif %}

{%- endfor %}

{%- endif %}
