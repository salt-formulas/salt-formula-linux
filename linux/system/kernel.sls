{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- if system.kernel is defined %}

Basic kernel:

  linux:
    system:
      kernel:
        hold: true
        versions:
          generic:
            headers: true


  linux:
    system:
      kernel:
        source:
          engine: pkg
          repo: from_repo
        version: 1.13.42
        hold: true
        headers: true
        generic: true

linux-headers-3.13.0-34
linux-image-3.13.0-34-generic
linux-headers-3.13.0-34-generic

{%- if system.kernel.get('source', {'engine': 'pkg'}).engine == 'pkg' %}

{%- if system.kernel.version is defined %}

linux_kernel_package:
  pkg.installed:
  - name: linux-image-{{ system.kernel.version }}
  - refresh: true

{%- else %}

linux_kernel_package:
  pkg.latest:
  - name: linux-image-generic
  - refresh: true

{%- endif %}

{%- if system.kernel.headers is defined %}
{%- if system.kernel.version is defined %}

linux_kernel_package:
  pkg.installed:
  - name: linux-image-{{ system.kernel.version }}
  - version: 
  - refresh: true

{%- else %}

linux_kernel_package:
  pkg.latest:
  - name: linux-image-generic
  - refresh: true

{%- endif %}
{%- endif %}

{%- endif %}

{%- endif %}

{%- endif %}