{%- from "linux/map.jinja" import auth with context %}

{%- if auth.enabled %}

{%- if auth.get('ldap', {}).get('enabled', False) %}
{%- from "linux/map.jinja" import ldap with context %}

{%- if grains.os_family == 'Debian' %}

linux_auth_debconf_libnss-ldapd:
  debconf.set:
    - name: libnss-ldapd
    - data:
        libnss-ldapd/nsswitch:
          type: 'multiselect'
          value: 'group, passwd, shadow'
        libnss-ldapd/clean_nsswitch:
          type: 'boolean'
          value: 'false'
    - require_in:
      - pkg: linux_auth_ldap_packages

linux_auth_debconf_libpam-ldapd:
  debconf.set:
    - name: libpam-ldapd
    - data:
        libpam-ldapd/enable_shadow:
          type: 'boolean'
          value: 'true'

{#- Setup mkhomedir and ldap PAM profiles #}
linux_auth_mkhomedir_config:
  file.managed:
    - name: /usr/share/pam-configs/mkhomedir
    - source: salt://linux/files/mkhomedir
    - require:
      - pkg: linux_auth_ldap_packages

linux_auth_pam_add_profile:
  file.managed:
    - name: /usr/local/bin/pam-add-profile
    - source: salt://linux/files/pam-add-profile
    - mode: 755

linux_auth_pam_add_profiles:
  cmd.run:
    - name: /usr/local/bin/pam-add-profile ldap mkhomedir
    - unless: "debconf-get-selections | grep libpam-runtime/profiles | grep mkhomedir | grep ldap"
    - watch:
      - file: linux_auth_mkhomedir_config
    - require:
      - file: linux_auth_pam_add_profile
      - pkg: linux_auth_ldap_packages

{%- elif grains.os_family == 'RedHat' %}

linux_auth_config:
  cmd.run:
    - name: "authconfig --enableldap --enableldapauth --enablemkhomedir --update"
    - require:
      - pkg: linux_auth_ldap_packages

{%- else %}

linux_auth_nsswitch_config_file:
  file.managed:
- name: /etc/nsswitch.conf
  - source: salt://linux/files/nsswitch.conf
  - template: jinja
  - mode: 644
  - require:
    - pkg: linux_auth_ldap_packages
  - watch_in:
    - service: linux_auth_nslcd_service

{%- endif %}

linux_auth_ldap_packages:
  pkg.installed:
  - pkgs: {{ ldap.pkgs }}

linux_auth_nslcd_config_file:
  file.managed:
  - name: /etc/nslcd.conf
  - source: salt://linux/files/nslcd.conf
  - template: jinja
  - mode: 600
  - require:
    - pkg: linux_auth_ldap_packages
  - watch_in:
    - service: linux_auth_nslcd_service

linux_auth_nslcd_service:
  service.running:
  - enable: true
  - name: nslcd

{%- endif %}

{%- endif %}
