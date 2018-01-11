{%- from "linux/map.jinja" import system with context %}

{%- if system.cgroup.enabled|default(True) %}

cgroup_package:
  pkg.installed:
  - pkgs:
    - cgroup-bin

include:
  - linux.system.grub

/etc/default/grub.d/80-cgroup.cfg:
  file.managed:
  - contents: 'GRUB_CMDLINE_LINUX_DEFAULT="quiet cgroup_enable=memory swapaccount=1"'
  - require:
    - file: grub_d_directory
{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}
  - watch_in:
    - cmd: grub_update
{%- endif %}

/etc/cgconfig.conf:
  file.managed:
  - user: root
  - group: root
  - mode: 0644
  - template: jinja
  - source: salt://linux/files/cgconfig.conf
{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}
  - check_cmd: /usr/sbin/cgconfigparser -l
{%- endif %}

/etc/cgrules.conf:
  file.managed:
  - user: root
  - group: root
  - mode: 0644
  - template: jinja
  - source: salt://linux/files/cgrules.conf

/etc/default/cgred:
  file.managed:
  - contents: |
      OPTIONS=-v --logfile=/var/log/cgrulesengd.log

/etc/systemd/system/cgred.service:
  file.managed:
  - contents: |
      [Unit]
      Description=CGroups Rules Engine Daemon
      After=syslog.target

      [Service]
      Type=forking
      EnvironmentFile=-/etc/default/cgred
      ExecStart=/usr/sbin/cgrulesengd $OPTIONS

      [Install]
      WantedBy=multi-user.target

cgred_service_running:
  service.running:
  - enable: true
  - names: ['cgred']
  - watch:
    - file: /etc/cgconfig.conf
    - file: /etc/cgrules.conf
    - file: /etc/default/cgred
    - file: /etc/systemd/system/cgred.service
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

{%- else %}

cgred_service_dead:
  service.dead:
  - enable: false
  - names: ['cgred']
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

include:
  - linux.system.grub

remove_/etc/default/grub.d/80-cgroup.cfg:
  file.absent:
  - name: /etc/default/grub.d/80-cgroup.cfg
  - require:
    - file: grub_d_directory
{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}
  - watch_in:
    - cmd: grub_update
{%- endif %}

remove_/etc/systemd/system/cgred.service:
  file.absent:
  - name: /etc/systemd/system/cgred.service

remove_/etc/cgconfig.conf:
  file.absent:
  - name: /etc/cgconfig.conf

remove_/etc/cgrules.conf:
  file.absent:
  - name: /etc/cgrules.conf

remove_/etc/default/cgred:
  file.absent:
  - name: /etc/default/cgred

purge_cgroup_package:
  pkg.purged:
  - pkgs:
    - cgroup-tools

{%- endif %}
