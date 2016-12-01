{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}


linux_lvm_pkgs:
  pkg.installed:
  - names: {{ storage.lvm_pkgs }}

{%- for vgname, vg in storage.lvm.iteritems() %}

{%- if vg.get('enabled', True) %}

{%- for dev in vg.devices %}
lvm_{{ vg.get('name', vgname) }}_pv_{{ dev }}:
  lvm.pv_present:
    - name: {{ dev }}
    - require:
      - pkg: linux_lvm_pkgs
    - require_in:
      - lvm: lvm_vg_{{ vg.get('name', vgname) }}
{%- endfor %}

lvm_vg_{{ vg.get('name', vgname) }}:
  lvm.vg_present:
    - name: {{ vg.get('name', vgname) }}
    - devices: {{ vg.devices|join(',') }}

{%- for lvname, volume in vg.get('volume', {}).iteritems() %}

lvm_{{ vg.get('name', vgname) }}_lv_{{ volume.get('name', lvname) }}:
  lvm.lv_present:
    - name: {{ volume.get('name', lvname) }}
    - vgname: {{ vg.get('name', vgname) }}
    - size: {{ volume.size }}
    - require:
      - lvm: lvm_vg_{{ vg.get('name', vgname) }}
    {%- if volume.mount is defined %}
    - require_in:
      - mount: {{ volume.mount.path }}
    {%- endif %}

{%- endfor %}

{%- endif %}

{%- endfor %}

{%- endif %}
