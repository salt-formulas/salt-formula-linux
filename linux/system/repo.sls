{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

  {% if system.pkgs %}
linux_repo_prereq_pkgs:
  pkg.installed:
  - pkgs: {{ system.pkgs | json }}
  {%- endif %}

  # global proxy setup
  {%- if grains.os_family == 'Debian' %}
    {%- if system.proxy.get('pkg', {}).get('enabled', False) %}
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
  {%- else %}
  # Implement grobal proxy configiration for non-debian OS.
  {%- endif %}

  {% set default_repos = {} %}

  {%- if system.purge_repos|default(False) %}
purge_sources_list_d_repos:
  file.directory:
  - name: /etc/apt/sources.list.d/
  - clean: True
  {%- endif %}

  {%- for name, repo in system.repo.items() | sort %}
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

      {%- if repo.pin is defined or repo.pinning is defined %}
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

      {%- if repo.get('key') %}
linux_repo_{{ name }}_key:
        {% set repo_key = salt['hashutil.base64_b64encode'](repo.key) %}
  cmd.run:
    - name: "echo '{{ repo_key }}' | base64 -d | apt-key add -"
    - require_in:
        {%- if repo.get('default', False) %}
      - file: default_repo_list
        {% else %}
      - pkgrepo: linux_repo_{{ name }}
        {% endif %}

{# key_url fetch by curl when salt <2017.7, higher version of salt has
   fixed bug for using a proxy_host/port specified at minion.conf

   NOTE: curl/cmd.run usage to fetch gpg key has limited functionality behind proxy.
         Environments with salt >= 2017.7 should use key_url specified at
         pkgrepo.manage state (which uses properly configured http_host at
         minion.conf). Older versions of salt require to have proxy set at
         ENV and curl way to fetch gpg key here can have a sense for backward
         compatibility. Be aware that as of salt 2018.3 no_proxy option is
         not implemented at all.
#}
      {%- elif repo.key_url|default(False) and grains['saltversioninfo'] < [2017, 7] and not repo.key_url.startswith('salt://') %}
linux_repo_{{ name }}_key:
  cmd.run:
    - name: "curl -sL {{ repo.key_url }} | apt-key add -"
    - require_in:
        {%- if repo.get('default', False) %}
      - file: default_repo_list
        {% else %}
      - pkgrepo: linux_repo_{{ name }}
        {% endif %}
      {%- endif %}

      {%- if repo.get('default', False) %}
        {%- do default_repos.update({name: repo}) %}
      {%- else %}

        {%- if repo.get('enabled', True) %}
linux_repo_{{ name }}:
  pkgrepo.managed:
  - refresh_db: False
  - require_in:
    - refresh_db
          {%- if repo.ppa is defined %}
  - ppa: {{ repo.ppa }}
          {%- else %}
  - humanname: {{ name }}
  - name: {{ repo.source }}
            {%- if repo.architectures is defined %}
  - architectures: {{ repo.architectures }}
            {%- endif %}
  - file: /etc/apt/sources.list.d/{{ name }}.list
  - clean_file: {{ repo.get('clean_file', True) }}
            {%- if repo.key_id is defined %}
  - keyid: {{ repo.key_id }}
            {%- endif %}
            {%- if repo.key_server is defined %}
  - keyserver: {{ repo.key_server }}
            {%- endif %}
            {%- if repo.key_url is defined and (grains['saltversioninfo'] >= [2017, 7] or repo.key_url.startswith('salt://')) %}
  - key_url: {{ repo.key_url }}
            {%- endif %}
{#
    Disable apt-key usage when salt version is at least 3005, and the user provides
    'signed-by=' in their source, and we're on a newer version of Debian or Ubuntu.
    apt-key is deprecated, see the following for more context:
    https://docs.saltproject.io/en/latest/ref/states/all/salt.states.pkgrepo.html#apt-key-deprecated
#}
            {%- if grains['saltversioninfo'] >= [3005, 0] and
              'signed-by=' in repo.source and
              (
                (grains['os'] == 'Debian' and grains['osrelease_info'] >= (11,)) or
                (grains['os'] == 'Ubuntu' and grains['osrelease_info'] >= (22, 4))
              )
            %}
  - aptkey: False
            {%- endif %}
  - consolidate: {{ repo.get('consolidate', False) }}
  - require:
    - file: /etc/apt/apt.conf.d/99proxies-salt-{{ name }}
    - file: /etc/apt/apt.conf.d/99proxies-salt
            {%- if system.purge_repos|default(False) %}
    - file: purge_sources_list_d_repos
            {%- endif %}
          {%- endif %}
        {%- else %}
linux_repo_{{ name }}:
  pkgrepo.absent:
    - refresh_db: False
    - require:
      - file: /etc/apt/apt.conf.d/99proxies-salt-{{ name }}
    - require_in:
      - refresh_db
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
        {%- endif %}
      {%- endif %}
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
  - refresh_db: False
  - require_in:
    - refresh_db
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
      {%- else %}
  pkgrepo.absent:
    - refresh_db: False
    - require_in:
      - refresh_db
    - name: {{ repo.source }}
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
    {%- if system.purge_repos|default(False) %}
    - replace: True
    {%- endif %}
    - defaults:
        default_repos: {{ default_repos }}

  {%- endif %}

refresh_db:
  {%- if system.get('refresh_repos_meta', True) %}
  module.run:
    {%- if 'module.run' in salt['config.get']('use_superseded', default=[]) %}
    - pkg.refresh_db: []
    {%- else %}
    - name: pkg.refresh_db
    {% endif %}
  {%- else %}
  test.succeed_without_changes
  {%- endif %}

{%- endif %}
