grub_d_directory:
  file.directory:
    - name: /etc/default/grub.d
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}
grub_update:
  cmd.wait:
  - name: update-grub
{%- endif %}
