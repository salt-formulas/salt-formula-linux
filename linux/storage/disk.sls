{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}

{%- for disk_name, disk in storage.disk.iteritems() %}

{%- if disk.type is defined %}
create_disk_label:
  module.run:
  - name: partition.mklabel
  - device: {{ disk.name|default(disk_name) }}
  - label_type: {{ disk.get('type', 'gpt') }}
  - unless: fdisk -l | grep {{ disk.get('type', 'gpt') }}
{%- endif %}

{% set end_size = 0 -%}

{%- for partition in disk.get('partitions', []) %}

{%- if not salt['partition.exists'](disk.get('name', disk_name)+'p'~loop.index) %}
create_partition_{{ disk.name|default(disk_name) }}_{{ loop.index }}:
  module.run:
  - name: partition.mkpart
  - device: {{ disk.name|default(disk_name) }}
  - part_type: primary
  - fs_type: {{ partition.type }}
  - start: {{ end_size }}MB
  - end: {{ end_size + partition.size }}MB
{%- endif %}

{% set end_size = end_size + partition.size -%}

{%- endfor %}
{%- endfor %}

{%- endif %}
