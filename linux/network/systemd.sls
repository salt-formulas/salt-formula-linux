{%- from "linux/map.jinja" import network with context %}
{%- if network.enabled and grains.get('init', None) == 'systemd' %}

{%- if network.systemd is mapping %}
{%- for config_type, configs in network.systemd.items() %}

{%- if config_type == 'link' %}
/etc/udev/rules.d/80-net-setup-link.rules:
  file.managed:
    - makedirs: True
    - content: ""
{%- endif %}

{%- for config_name, config in configs.items() %}
linux_network_systemd_networkd_{{ config_type }}_config_{{ config_name }}:
  file.managed:
    - name: /etc/systemd/network/{{ config_name }}.{{ config_type }}
    - source: salt://linux/files/systemd-network.conf
    - template: jinja
    - makedirs: True
    - defaults:
        settings: {{ config }}
    - watch_in:
      - module: linux_network_systemd_reload
      - module: linux_network_systemd_networkd
{%- endfor %}
{%- endfor %}

linux_network_systemd_reload:
  module.wait:
  - name: service.systemctl_reload

linux_network_systemd_networkd:
  service.running:
  - name: systemd-networkd
  - init_delay: 10
  - enable: True
  - reload: True
  - watch:
    - module: linux_network_systemd_reload

{%- endif %}
{%- endif %}
