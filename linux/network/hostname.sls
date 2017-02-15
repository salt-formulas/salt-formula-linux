{%- from "linux/map.jinja" import network with context %}
{%- if network.enabled %}

{%- if grains.os_family in ['Arch', 'Debian'] %}

linux_hostname_file:
  file.managed:
  - name: {{ network.hostname_file }}
  - source: salt://linux/files/hostname
  - template: jinja
  - user: root
  - group: root
  - mode: 644
  - watch_in:
    - cmd: linux_enforce_hostname

{%- endif %}

linux_enforce_hostname:
  cmd.wait:
  - name: hostname {{ network.hostname }}
  - unless: test "$(hostname)" = "{{ network.hostname }}"

{#
linux_hostname_hosts:
  host.present:
  - ip: {{ grains.ip4_interfaces[network.get('default_interface', 'eth0')][0] }}
  - names:
    - {{ network.fqdn }}
    - {{ network.hostname }}
#}

{%- endif %}
