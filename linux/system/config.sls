{%- from "linux/map.jinja" import system with context %}
{%- macro load_support_file(file, pillar, grains) %}{% include file %}{% endmacro %}

{%- if system.enabled %}

  {%- for config_name, config in system.get('config', {}).iteritems() %}
    {%- if config.enabled|default(True) %}
      {%- for service_name in config.pillar.keys() %}
        {%- if pillar.get(service_name, {}).get('_support', {}).get('config', {}).get('enabled', False) %}
          {%- set support_fragment_file = service_name+'/meta/config.yml' %}
          {%- set service_config_files = load_support_file(support_fragment_file, config.pillar, config.get('grains', {}))|load_yaml %}
          {%- for service_config_name, service_config in service_config_files.config.iteritems() %}

{{ service_config.path }}:
  file.managed:
    - source: {{ service.config.source }}
    {%- if service.config.template is defined %}
    - template: {{ service.config.template }}
    {%- endif %}
    - makedirs: true
    - defaults:
        pillar: {{ config.pillar|yaml }}
        grains: {{ config.get('grains', {}) }}

          {%- endfor %}
        {%- endif %}
      {%- endfor %}
    {%- else %}
      {# TODO: configmap not using support between formulas #}
    {%- endif %}
  {%- endfor %}

{%- endif %}
