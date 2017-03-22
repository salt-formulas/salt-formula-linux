{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.profile.get('enabled', False) %}
# on /etc/profile (system wide, no variable expansion)

{%- if system.profile.get('proxy', {}).get('enabled', False) %}
# on shared profiles (affect any .sh execution), keep this for backward compatibility
/etc/profile.d/95proxies:
  file.managed:
  - template: jinja
  - source: salt://linux/files/95proxies.profile.d
  - defaults:
      noproxy: {{ system.profile.proxy.get('noproxy', None) | default(system.proxy.get('noproxy', None), True) }}
      https: {{ system.profile.proxy.get('https', None) | default(system.proxy.get('https', None), True) }}
      http: {{ system.profile.proxy.get('http', None) | default(system.proxy.get('http', None), True) }}
      ftp: {{ system.profile.proxy.get('ftp', None) | default(system.proxy.get('ftp', None), True) }}
{%- else %}
/etc/profile.d/95proxies:
  file.absent
{%- endif %}

{%- else %}
# if proxies not enabled

/etc/profile.d/95proxies:
  file.absent

{%- endif %}
{%- endif %}
