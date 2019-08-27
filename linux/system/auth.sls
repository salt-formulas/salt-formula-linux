{%- from "linux/map.jinja" import auth with context %}

{%- if auth.enabled %}
  {%- if auth.duo.enabled %}
include:
  - linux.system.auth.duo
  {%- else %}
    {%- set pam_modules_enable = "" %}
    {%- set pam_modules_disable = "" %}
    {%- if grains.os_family == 'Debian' %}
linux_auth_pam_packages:
  pkg.installed:
  - pkgs: [ 'libpam-runtime' ]

linux_auth_pam_add_profile:
  file.managed:
    - name: /usr/local/bin/pam-add-profile
    - source: salt://linux/files/pam-add-profile
    - mode: 755
    - require:
      - pkg: linux_auth_pam_packages
    {%- endif %}

    {%- if auth.get('mkhomedir', {}).get('enabled', False) %}
      {%- if grains.os_family == 'Debian' %}
        {%- set pam_modules_enable = pam_modules_enable + ' mkhomedir' %}
linux_auth_mkhomedir_debconf_package:
  pkg.installed:
  - pkgs: [ 'debconf-utils' ]

linux_auth_mkhomedir_config:
  file.managed:
    - name: /usr/share/pam-configs/mkhomedir
    - source: salt://linux/files/mkhomedir
    - template: jinja

      {%- endif %}
    {%- else %}
      {%- if grains.os_family == 'Debian' %}
        {%- set pam_modules_disable = pam_modules_disable + ' mkhomedir' %}
      {%- endif %}
    {%- endif %}

    {%- if auth.get('ldap', {}).get('enabled', False) %}
      {%- from "linux/map.jinja" import ldap with context %}

      {%- if grains.os_family == 'Debian' %}
        {%- set pam_modules_enable = pam_modules_enable + ' ldap' %}

linux_auth_ldap_debconf_package:
  pkg.installed:
  - pkgs: [ 'debconf-utils' ]

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
    - require:
      - pkg: linux_auth_ldap_debconf_package

linux_auth_debconf_libpam-ldapd:
  debconf.set:
    - name: libpam-ldapd
    - data:
        libpam-ldapd/enable_shadow:
          type: 'boolean'
          value: 'true'
      {%- endif %}
    {%- else %}
      {%- if grains.os_family == 'Debian' %}
        {%- set pam_modules_disable = pam_modules_disable + ' ldap' %}
      {%- endif %}
    {%- endif %}

  {#- Setup PAM profiles #}
    {%- if grains.os_family == 'Debian' %}
      {%- if auth.get('mkhomedir', {}).get('enabled', False) %}
linux_auth_pam_add_profiles_mkhomedir_enable:
  cmd.run:
    - name: /usr/local/bin/pam-add-profile {{ pam_modules_enable }}
    - unless: "[[ `grep -c pam_mkhomedir.so /etc/pam.d/common-session` -ne 0 ]]"
    - require:
      - file: linux_auth_pam_add_profile
linux_auth_pam_add_profiles_mkhomedir_update:
  cmd.wait:
    - name: /usr/local/bin/pam-add-profile {{ pam_modules_enable }}
    - watch:
      - file: linux_auth_mkhomedir_config
    - require:
      - file: linux_auth_pam_add_profile
        {%- if auth.get('ldap', {}).get('enabled', False) %}
      - pkg: linux_auth_ldap_packages
        {%- endif %}
      {%- else %}
linux_auth_pam_remove_profiles_mkhomedir:
  cmd.run:
    - name: /usr/sbin/pam-auth-update --remove {{ pam_modules_disable }}
    - onlyif: "[[ `grep -c pam_mkhomedir.so /etc/pam.d/common-session` -ne 0 ]]"
    - require:
      - pkg: linux_auth_pam_packages
      {%- endif %}

      {%- if auth.get('ldap', {}).get('enabled', False) %}
linux_auth_pam_add_profiles_ldap:
  cmd.run:
    - name: /usr/local/bin/pam-add-profile {{ pam_modules_enable }}
    - unless: "[[ `debconf-get-selections | grep libpam-runtime/profiles | grep -c ldap` -ne 0 ]]"
    - require:
      - file: linux_auth_pam_add_profile
      - pkg: linux_auth_ldap_packages
      {%- else %}
linux_auth_pam_remove_profiles_ldap:
  cmd.run:
    - name: /usr/sbin/pam-auth-update --remove {{ pam_modules_disable }}
    - onlyif: "[[ `debconf-get-selections | grep libpam-runtime/profiles | grep -c ldap` -ne 0 ]]"
    - require:
      - pkg: linux_auth_pam_packages
      {%- endif %}

    {%- elif grains.os_family == 'RedHat' %}
      {%- if auth.get('mkhomedir', {}).get('enabled', False) %}
linux_auth_config_enable_mkhomedir:
  cmd.run:
    - name: "authconfig --enablemkhomedir --update"
    - require:
        {%- if auth.get('ldap', {}).get('enabled', False) %}
      - pkg: linux_auth_ldap_packages
        {%- endif %}
      {%- else %}
linux_auth_config_disable_mkhomedir:
  cmd.run:
    - name: "authconfig --disablemkhomedir --update"
    - require:
      - pkg: linux_auth_ldap_packages
      {%- endif %}
      {%- if auth.get('ldap', {}).get('enabled', False) %}
linux_auth_config_enable_ldap:
  cmd.run:
    - name: "authconfig --enableldap --enableldapauth --update"
    - require:
        {%- if auth.get('ldap', {}).get('enabled', False) %}
      - pkg: linux_auth_ldap_packages
        {%- endif %}
      {%- else %}
linux_auth_config_disable_ldap:
  cmd.run:
    - name: "authconfig --disableldap --disableldapauth --update"
    - require:
      - pkg: linux_auth_ldap_packages
      {%- endif %}
    {%- endif %}

    {%- if auth.get('ldap', {}).get('enabled', False) %}

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

linux_auth_ldap_packages:
  pkg.installed:
  - pkgs: {{ ldap.pkgs | json }}

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
{%- endif %}
