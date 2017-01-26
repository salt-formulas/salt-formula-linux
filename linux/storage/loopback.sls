{%- from "linux/map.jinja" import storage with context %}

{%- if storage.get('enabled', False) %}

{%- for device, loopback in storage.loopback|dictsort %}

{%- if loopback.get('enabled', True) %}

{{ salt['file.dirname'](loopback.file) }}:
  file.directory:
  - makedirs: true
  - require_in:
    - file: {{ loopback.file }}

{{ loopback.file }}:
  cmd.run:
  - name: "truncate --size {{ loopback.size|default('1G') }} {{ loopback.file }}"
  - creates: {{ loopback.file }}

loopback_{{ device }}_init_script:
  file.managed:
{%- if grains.get('init', None) == 'upstart' %}
  - name: /etc/init/setup-loopback-{{ device }}.conf
  - source: salt://linux/files/setup-loopback-device.upstart
{%- else %}
  - name: /etc/systemd/system/setup-loopback-{{ device }}.service
  - source: salt://linux/files/setup-loopback-device.systemd
{%- endif %}
  - template: jinja
  - defaults:
    file: {{ loopback.file }}
    device_name: "/dev/loop{{ loop.index0 }}"

setup-loopback-{{ device }}:
  service.running:
  - enable: true
  - require:
    - cmd: {{ loopback.file }}
    - file: loopback_{{ device }}_init_script
{%- endif %}

{%- endfor %}

{%- endif %}
