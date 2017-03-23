{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.env.get('enabled', False) %}
# on /etc/environment (system wide, no variable expansion)

{%- if system.env.get('proxy', {}).get('enabled', False) %}
linux_system_environment_proxies:
  file.blockreplace:
  - name: /etc/environment
  - marker_start: '# START - SALT MANAGED PROXIES, DO NOT EDIT'
  - marker_end: '# END - SALT MANAGED PROXIES'
  - template: jinja
  - source: salt://linux/files/95proxies.profile.d
  - append_if_not_found: True
  - backup: '.bak'
  - show_changes: True
  - defaults:
      noproxy: {{ system.env.proxy.get('noproxy', None) | default(system.proxy.get('noproxy', None), True) }}
      https: {{ system.env.proxy.get('https', None) | default(system.proxy.get('https', None), True) }}
      http: {{ system.env.proxy.get('http', None) | default(system.proxy.get('http', None), True) }}
      ftp: {{ system.env.proxy.get('ftp', None) | default(system.proxy.get('ftp', None), True) }}
{%- else %}
linux_system_environment_proxies:
  file.blockreplace:
  - name: /etc/environment
  - marker_start: '# SALT MANAGED PROXIES - DO NOT EDIT - START'
  - marker_end: '# SALT MANAGED PROXIES - END'
  - content: '# proxies not configured'
  - append_if_not_found: False
  - backup: '.bak'
  - show_changes: True
{%- endif %}

{%- else %}
# if proxies not enabled

linux_system_environment_proxies:
  file.blockreplace:
  - name: /etc/environment
  - marker_start: '# SALT MANAGED PROXIES - DO NOT EDIT - START'
  - marker_end: '# SALT MANAGED PROXIES - END'
  - content: '# proxies not configured'
  - append_if_not_found: False
  - backup: '.bak'
  - show_changes: True

{%- endif %}
{%- endif %}
