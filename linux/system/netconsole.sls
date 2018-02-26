{% from "linux/map.jinja" import system with context %}
{% if system.enabled and system.netconsole is mapping and system.netconsole.enabled %}

/etc/dhcp/dhclient-exit-hooks.d/netconsole:
  file.managed:
    - source: salt://linux/files/netconsole
    - makedirs: True

/etc/network/if-up.d/netconsole:
  file.managed:
    - source: salt://linux/files/netconsole
    - mode: 755
    - makedirs: True

/etc/network/if-down.d/netconsole:
  file.managed:
    - source: salt://linux/files/netconsole
    - mode: 755
    - makedirs: True

/etc/default/netconsole.conf:
  file.managed:
    - source: salt://linux/files/netconsole.conf
    - template: jinja

{% if system.netconsole is mapping and system.netconsole.target is mapping %}
{% for target, data in system.netconsole.target.items() %}
{% if data is mapping and data.interface is defined %}
/etc/network/if-up.d/netconsole {{ target }} {{ data.interface }}:
  cmd.run:
    - name: /etc/network/if-up.d/netconsole
    - env:
      - IFACE: {{ data.interface }}
      - METHOD: static
      - ADDRFAM: inet
      - MODE: start
    - onchanges:
      - file: /etc/default/netconsole.conf
    - require:
      - file: /etc/network/if-up.d/netconsole
{% endif %}
{% endfor %}
{% endif %}

{% endif %}
