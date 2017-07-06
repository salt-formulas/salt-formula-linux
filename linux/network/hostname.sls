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

{# Change state to proper one, after releasing patch:
   https://github.com/saltstack/salt/pull/45748/files/74599bbdfcf99f45d3a31296887097fade31cbf1
linux_enforce_hostname:
  network.system:
    - enabled: True
    - hostname: {{ network.hostname }}
    - apply_hostname: True
    - retain_settings: True
#}
linux_enforce_hostname:
  cmd.run:
  - name: hostname {{ network.hostname }}
  - unless: test "$(hostname)" = "{{ network.hostname }}"
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

{%- endif %}
