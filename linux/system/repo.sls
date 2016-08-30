{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{% set default_repos = {} %}

{%- for name, repo in system.repo.iteritems() %}

{%- if grains.os_family == 'Debian' %}

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

{%- endif %}

{%- endif %}

{%- if grains.os_family == "RedHat" %}

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

{%- endif %}

{%- endif %}
