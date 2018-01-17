{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

linux_repo_prereq_pkgs:
  pkg.installed:
  - pkgs: {{ system.pkgs }}

# global proxy setup
{%- if system.proxy.get('pkg', {}).get('enabled', False) %}
{%- if grains.os_family == 'Debian' %}

/etc/apt/apt.conf.d/99proxies-salt:
  file.managed:
  - template: jinja
  - source: salt://linux/files/apt.conf.d_proxies
  - defaults:
      external_host: False
      https: {{ system.proxy.get('pkg', {}).get('https', None) | default(system.proxy.get('https', None), true) }}
      http: {{ system.proxy.get('pkg', {}).get('http', None) | default(system.proxy.get('http', None), true) }}
      ftp: {{ system.proxy.get('pkg', {}).get('ftp', None) | default(system.proxy.get('ftp', None), true) }}

{%- else %}

/etc/apt/apt.conf.d/99proxies-salt:
  file.absent

{%- endif %}
{%- endif %}

{% set default_repos = {} %}

{%- if system.purge_repos|default(False) %}

purge_sources_list_d_repos:
   file.directory:
   - name: /etc/apt/sources.list.d/           
   - clean: True

{%- endif %}

{%- for name, repo in system.repo.iteritems() %}
{%- set name=repo.get('name', name) %}
{%- if grains.os_family == 'Debian' %}

# per repository proxy setup
{%- if repo.get('proxy', {}).get('enabled', False) %}
{%- set external_host = repo.proxy.get('host', None) or repo.source.split('/')[2] %}
/etc/apt/apt.conf.d/99proxies-salt-{{ name }}:
  file.managed:
  - template: jinja
  - source: salt://linux/files/apt.conf.d_proxies
  - defaults:
      external_host: {{ external_host }}
      https: {{ repo.proxy.get('https', None) or system.proxy.get('pkg', {}).get('https', None) | default(system.proxy.get('https', None), True) }}
      http: {{ repo.proxy.get('http', None) or system.proxy.get('pkg', {}).get('http', None) | default(system.proxy.get('http', None), True) }}
      ftp: {{ repo.proxy.get('ftp', None) or system.proxy.get('pkg', {}).get('ftp', None) | default(system.proxy.get('ftp', None), True) }}
{%- else %}
/etc/apt/apt.conf.d/99proxies-salt-{{ name }}:
  file.absent
{%- endif %}

{%- if repo.pin is defined %}

linux_repo_{{ name }}_pin:
  file.managed:
    - name: /etc/apt/preferences.d/{{ name }}
    - source: salt://linux/files/preferences_repo
    - template: jinja
    - defaults:
        repo_name: {{ name }}

{%- else %}

linux_repo_{{ name }}_pin:
  file.absent:
    - name: /etc/apt/preferences.d/{{ name }}

{%- endif %}

{%- if repo.get('default', False) %}

{%- do default_repos.update({name: repo}) %}

{%- if repo.get('key') %}

linux_repo_{{ name }}_key:
  cmd.wait:
    - name: "echo '{{ repo.key }}' | apt-key add -"
    - watch:
      - file: default_repo_list

{%- elif repo.key_url|default(False) %}

linux_repo_{{ name }}_key:
  cmd.wait:
    - name: "curl -s {{ repo.key_url }} | apt-key add -"
    - watch:
      - file: default_repo_list

{%- endif %}

{%- else %}

{%- if repo.get('enabled', True) %}

linux_repo_{{ name }}:
  pkgrepo.managed:
  {%- if repo.ppa is defined %}
  - ppa: {{ repo.ppa }}
  {%- else %}
  - humanname: {{ name }}
  - name: {{ repo.source }}
  {%- if repo.architectures is defined %}
  - architectures: {{ repo.architectures }}
  {%- endif %}
  - file: /etc/apt/sources.list.d/{{ name }}.list
  - clean_file: {{ repo.clean|default(True) }}
  {%- if repo.key_id is defined %}
  - keyid: {{ repo.key_id }}
  {%- endif %}
  {%- if repo.key_server is defined %}
  - keyserver: {{ repo.key_server }}
  {%- endif %}
  {%- if repo.key_url is defined %}
  - key_url: {{ repo.key_url }}
  {%- endif %}
  - consolidate: {{ repo.get('consolidate', False) }}
  - clean_file: {{ repo.get('clean_file', False) }}
  - refresh_db: {{ repo.get('refresh_db', True) }}
  - require:
    - pkg: linux_repo_prereq_pkgs
  {%- if repo.get('proxy', {}).get('enabled', False) %}
    - file: /etc/apt/apt.conf.d/99proxies-salt-{{ name }}
  {%- endif %}
  {%- if system.proxy.get('pkg', {}).get('enabled', False) %}
    - file: /etc/apt/apt.conf.d/99proxies-salt
  {%- endif %}
  {%- if system.purge_repos|default(False) %}
    - file: purge_sources_list_d_repos
  {%- endif %}
  {%- endif %}

{%- else %}

linux_repo_{{ name }}_absent:
  pkgrepo.absent:
    {%- if repo.ppa is defined %}
    - ppa: {{ repo.ppa }}
    {%- if repo.key_id is defined %}
    - keyid_ppa: {{ repo.keyid_ppa }}
    {%- endif %}
    {%- else %}
    - file: /etc/apt/sources.list.d/{{ name }}.list
    {%- if repo.key_id is defined %}
    - keyid: {{ repo.key_id }}
    {%- endif %}
    {%- endif %}
  file.absent:
    - name: /etc/apt/sources.list.d/{{ name }}.list

{%- endif %}

{%- endif %}

{#- os_family Debian #}
{%- endif %}

{%- if grains.os_family == "RedHat" %}

{%- if repo.get('enabled', True) %}

{%- if repo.get('proxy', {}).get('enabled', False) %}
# PLACEHOLDER
# TODO, implement per proxy configuration for Yum
{%- endif %}

{%- if not repo.get('default', False) %}
linux_repo_{{ name }}:
  pkgrepo.managed:
  - name: {{ name }}
  - humanname: {{ repo.get('humanname', name) }}
  {%- if repo.mirrorlist is defined %}
  - mirrorlist: {{ repo.mirrorlist }}
  {%- else %}
  - baseurl: {{ repo.source }}
  {%- endif %}
  - gpgcheck: {% if repo.get('gpgcheck', False) %}1{% else %}0{% endif %}
  {%- if repo.gpgkey is defined %}
  - gpgkey: {{ repo.gpgkey }}
  {%- endif %}
  - require:
    - pkg: linux_repo_prereq_pkgs
{%- endif %}

{#- repo.enabled is false #}
{%- else %}
  pkgrepo.absent:
    - name: {{ repo.source }}
{%- endif %}

{#- os_family Redhat #}
{%- endif %}

{#- repo.iteritems() loop #}
{%- endfor %}

{%- if default_repos|length > 0 and grains.os_family == 'Debian' %}

default_repo_list:
  file.managed:
    - name: /etc/apt/sources.list
    - source: salt://linux/files/sources.list
    - template: jinja
    - user: root
    - group: root
    - mode: 0644
{%- if system.purge_repos|default(False) %}
    - replace: True
{%- endif %}
    - defaults:
        default_repos: {{ default_repos }}
    - require:
      - pkg: linux_repo_prereq_pkgs

refresh_default_repo:
  module.wait:
    - name: pkg.refresh_db
    - watch:
      - file: default_repo_list

{%- endif %}

{%- endif %}
