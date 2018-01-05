grub_d_directory:
  file.directory:
    - name: /etc/default/grub.d
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{%- if grains['os_family'] == 'RedHat' %}
/etc/default/grub:
  file.append:
    - text:
      - for i in $(ls /etc/default/grub.d);do source /etc/default/grub.d/$i ;done

grub_update:
  cmd.wait:
  - name: grub2-mkconfig -o /boot/grub2/grub.cfg

{%- else %}

{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}
grub_update:
  cmd.wait:
  - name: update-grub
{%- endif %}

{%- endif %}
