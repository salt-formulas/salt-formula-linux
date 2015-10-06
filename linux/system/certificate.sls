{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.ca_certificates is defined %}

{%- for certificate in system.ca_certificates %}

{{ system.ca_certs_dir }}/{{ certificate }}.crt:
  file.managed:
  - source: salt://pki/{{ certificate }}/{{ certificate }}-chain.cert.pem
  - watch_in:
    - cmd: update_certificates

{%- endfor %}

update_certificates:
  cmd.wait:
  - name: /usr/sbin/update-ca-certificates

{%- endif %}

{%- endif %}
