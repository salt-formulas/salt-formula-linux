{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

# global proxy setup
{%- if system.proxy.get('pkg', {}).get('enabled', False) %}

{%- if grains.os_family == 'Debian' %}

/etc/apt/apt.conf.d/95proxies:
  file.managed:
  - template: jinja
  - source: salt://linux/files/95proxies.apt.conf
  - defaults:
      external_host: False
      https: {{ system.proxy.get('pkg', {}).get('https', None) | default(system.proxy.get('https', None), true) }}
      http: {{ system.proxy.get('pkg', {}).get('http', None) | default(system.proxy.get('http', None), true) }}
      ftp: {{ system.proxy.get('pkg', {}).get('ftp', None) | default(system.proxy.get('ftp', None), true) }}

{%- else %}
/etc/apt/apt.conf.d/95proxies:
  file.absent
{%- endif %}
{%- endif %}

{% set default_repos = {} %}

{%- for name, repo in system.repo.iteritems() %}

{%- if grains.os_family == 'Debian' %}

# per repository proxy setup
{%- if repo.get('proxy', {}).get('enabled', False) %}
{%- set external_host = repo.proxy.get('host', None) or repo.source.split('/')[2] %}
/etc/apt/apt.conf.d/95proxies_{{ name }}:
  file.managed:
  - template: jinja
  - source: salt://linux/files/95proxies.apt.conf
  - defaults:
      external_host: {{ external_host }}
      https: {{ repo.proxy.get('https', None) or system.proxy.get('pkg', {}).get('https', None) | default(system.proxy.get('https', None), True) }}
      http: {{ repo.proxy.get('http', None) or system.proxy.get('pkg', {}).get('http', None) | default(system.proxy.get('http', None), True) }}
      ftp: {{ repo.proxy.get('ftp', None) or system.proxy.get('pkg', {}).get('ftp', None) | default(system.proxy.get('ftp', None), True) }}
{%- else %}
/etc/apt/apt.conf.d/95proxies_{{ name }}:
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

{%- if repo.key_url|default(False) %}

linux_repo_{{ name }}_key:
  cmd.wait:
    - name: "curl -s {{ repo.key_url }} | apt-key add -"
    - watch:
      - file: default_repo_list

{%- endif %}

{%- else %}

linux_repo_{{ name }}:
  pkgrepo.managed:
  - human_name: {{ name }}
  - name: {{ repo.source }}
  {%- if repo.architectures is defined %}
  - architectures: {{ repo.architectures }}
  {%- endif %}
  - file: /etc/apt/sources.list.d/{{ name }}.list
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
    - pkg: linux_packages
  {%- if repo.get('proxy', {}).get('enabled', False) %}
    - file: /etc/apt/apt.conf.d/95proxies_{{ name }}
  {%- endif %}
  {%- if system.proxy.get('pkg', {}).get('enabled', False) %}
    - file: /etc/apt/apt.conf.d/95proxies
  {%- endif %}

{%- endif %}

{%- endif %}

{%- if grains.os_family == "RedHat" %}

{%- if repo.get('proxy', {}).get('enabled', False) %}
# PLACEHOLDER
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
    - pkg: linux_packages

{%- endif %}

{%- endif %}

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
    - defaults:
        default_repos: {{ default_repos }}
    - require:
      - pkg: linux_packages

{%- endif %}

{%- endif %}
