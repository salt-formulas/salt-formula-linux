{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}

parted:
  pkg.installed

xfsprogs:
  pkg.installed

{%- for disk_name, disk in storage.disk.items() %}
{%- set disk_name = disk.name|default(disk_name) %}

create_disk_label_{{ disk_name }}:
  module.run:
  {%- if 'module.run' in salt['config.get']('use_superseded', default=[]) %}
  - partition.mklabel:
    - device: {{ disk_name }}
    - label_type: {{ disk.get('type', 'dos') }}
  {%- else %}
  - name: partition.mklabel
  - device: {{ disk_name }}
  - label_type: {{ disk.get('type', 'dos') }}
  {%- endif %}
  - unless: "fdisk -l {{ disk_name }} | grep -i 'Disklabel type: {{ disk.get('type', 'dos') }}'"
  - require:
    - pkg: parted

{% set end_size = 0 -%}
{% if disk.get('startsector', None) %}
{% set end_size = disk.get('startsector')|int %}
{% endif %}

{%- for partition in disk.get('partitions', []) %}

create_partition_{{ disk_name }}_{{ loop.index }}:
  module.run:
  {%- if 'module.run' in salt['config.get']('use_superseded', default=[]) %}
  - partition.mkpart:
    - device: {{ disk_name }}
    - part_type: primary
      {%- if partition.type is defined %}
    - fs_type: {{ partition.type }}
      {%- endif %}
    - start: {{ end_size }}MB
    - end: {{ end_size + partition.size }}MB
  {%- else %}
  - name: partition.mkpart
  - device: {{ disk_name }}
  - part_type: primary
    {%- if partition.type is defined %}
  - fs_type: {{ partition.type }}
    {%- endif %}
  - start: {{ end_size }}MB
  - end: {{ end_size + partition.size }}MB
  {%- endif %}
  - unless: "blkid {{ disk_name }}{{ loop.index }} {{ disk_name }}p{{ loop.index }}"
  - require:
    - module: create_disk_label_{{ disk_name }}
    - pkg: xfsprogs

{% set end_size = end_size + partition.size -%}

{%- endfor %}

probe_partions_{{ disk_name }}:
  module.run:
{%- if 'module.run' in salt['config.get']('use_superseded', default=[]) %}
  - partition.probe:
    - device: {{ disk_name }}
{%- else %}
  - name: partition.probe
  - device: {{ disk_name }}
{%- endif %}

{%- for partition in disk.get('partitions', []) %}

{%- if partition.get('mkfs') and partition.type == "xfs" %}

mkfs_partition_{{ disk_name }}_{{ loop.index }}:
  module.run:
  {%- if 'module.run' in salt['config.get']('use_superseded', default=[]) %}
  - xfs.mkfs:
    - device: {{ disk_name }}{{ loop.index }}
  {%- else %}
  - name: xfs.mkfs
  - device: {{ disk_name }}{{ loop.index }}
  {%- endif %}
  - unless: "blkid {{ disk_name }}{{ loop.index }} {{ disk_name }}p{{ loop.index }} | grep xfs"
  - require:
    - module: create_partition_{{ disk_name }}_{{ loop.index }}

{%- endif %}

{%- endfor %}

{%- endfor %}

{%- endif %}
