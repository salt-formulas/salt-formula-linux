{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}


linux_lvm_pkgs:
  pkg.installed:
  - names: {{ storage.lvm_pkgs }}

{%- for vgname, vg in storage.lvm.iteritems() %}

{%- if vg.get('enabled', True) %}

{%- for dev in vg.devices %}
lvm_{{ vgname }}_pv_{{ dev }}:
  lvm.pv_present:
    - name: dev
    - require:
      - pkg: linux_lvm_pkgs
    - require_in:
      - lvm: lvm_vg_{{ vgname }}
{%- endfor %}

lvm_vg_{{ vgname }}:
  lvm.vg_present:
    - name: {{ vgname }}
    - devices: {{ vg.devices }}

{%- for lvname, volume in vg.volume.iteritems() %}

lvm_{{ vgname }}_lv_{{ lvname }}:
  lvm.lv_present:
    - name: {{ lvname }}
    - vgname: {{ vgname }}
    - size: {{ volume.size }}
    - require:
      - lvm: lvm_vg_{{ vgname }}
    {%- if volume.mount is defined %}
    - require_in:
      - mount: {{ volume.mount.path }}
    {%- endif %}

{%- endfor %}

{%- endif %}

{%- endfor %}

{%- endif %}
