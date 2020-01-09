{%- if grains['os'] == 'Ubuntu' %}

package_duo:
  pkg.installed:
    - name: duo-unix
    - skip_verify: True


login_duo:
  file.managed:
    - name: /etc/duo/login_duo.conf
    - source: salt://linux/files/login_duo.conf
    - template: jinja
    - user: 'root'
    - group: 'root'
    - mode: '0600'


pam_duo:
  file.managed:
    - name: /etc/duo/pam_duo.conf
    - source: salt://linux/files/login_duo.conf
    - template: jinja
    - user: 'root'
    - group: 'root'
    - mode: '0600'

pam-sshd_config:
  file.managed:
  - name: /etc/pam.d/sshd
  - user: root
  - group: root
  - source: salt://linux/files/pam-sshd
  - mode: 600
  - template: jinja

{%- endif %}

