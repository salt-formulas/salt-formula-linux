{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.ca_certificates is defined %}

linux_system_ca_certificates:
  pkg.installed:
    - name: ca-certificates
{%- if system.ca_certificates is mapping %}

{%- for name, cert in system.ca_certificates.iteritems() %}
{{ system.ca_certs_dir }}/{{ name }}.crt:
  file.managed:
  - contents_pillar: "linux:system:ca_certificates:{{ name }}"
  - watch_in:
    - cmd: update_certificates
  - require:
    - pkg: linux_system_ca_certificates
{%- endfor %}

{%- else %}
{#- salt-pki way #}

{%- for certificate in system.ca_certificates %}
{{ system.ca_certs_dir }}/{{ certificate }}.crt:
  file.managed:
  - source: salt://pki/{{ certificate }}/{{ certificate }}-chain.cert.pem
  - watch_in:
    - cmd: update_certificates
  - require:
    - pkg: linux_system_ca_certificates
{%- endfor %}

{%- endif %}

update_certificates:
  cmd.wait:
  - name: update-ca-certificates

{%- endif %}

{%- endif %}
