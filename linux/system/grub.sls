grub_d_directory:
  file.directory:
    - name: /etc/default/grub.d
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{%- if grains['os_family'] == 'RedHat' %}
  {%- set boot_grub_cfg = '/boot/grub2/grub.cfg' %}
/etc/default/grub:
  file.append:
    - text:
      - for i in $(ls /etc/default/grub.d);do source /etc/default/grub.d/$i ;done

grub_update:
  cmd.wait:
  - name: grub2-mkconfig -o {{ boot_grub_cfg }}

{%- else %}
  {%- set boot_grub_cfg = '/boot/grub/grub.cfg' %}

grub_update:
  cmd.wait:
  - name: update-grub
  {%- if grains.get('virtual_subtype') in ['Docker', 'LXC'] %}
  - onlyif: /bin/false
  {%- endif %}

{%- endif %}

grub_cfg_permissions:
  file.managed:
    - name: {{ boot_grub_cfg }}
    - user: 'root'
    - owner: 'root'
    - mode: '400'
    - replace: false
    - onlyif: test -f {{ boot_grub_cfg }}
    - require:
      - cmd: grub_update
