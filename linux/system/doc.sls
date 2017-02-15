{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

linux_system_doc_grains_dir:
  file.directory:
  - name: /etc/salt/grains.d
  - mode: 700
  - makedirs: true
  - user: root

linux_system_doc_grain:
  file.managed:
  - name: /etc/salt/grains.d/sphinx
  - source: salt://linux/files/sphinx.grain
  - template: jinja
  - mode: 600
  - require:
    - file: linux_system_doc_grains_dir

linux_system_doc_validity_check:
  pkg.installed:
  - pkgs: {{ system.doc_validity_pkgs }}
  cmd.wait:
  - name: python -c "import yaml; stream = file('/etc/salt/grains.d/sphinx', 'r'); yaml.load(stream); stream.close()"
  - require:
    - pkg: linux_system_doc_validity_check
  - watch:
    - file: linux_system_doc_grain

{%- endif %}
