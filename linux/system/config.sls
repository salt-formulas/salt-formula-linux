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
    - source: {{ service_config.source }}
    - user: {{ config.get('user', service_config.get('user', 'root')) }}
    - group: {{ config.get('group', service_config.get('group', 'root')) }}
    - mode: {{ config.get('mode', service_config.get('mode', '644')) }}
    {%- if service_config.template is defined %}
    - template: {{ service_config.template }}
    {%- endif %}
    - makedirs: true
    - defaults:
        pillar: {{ config.pillar|yaml }}
        grains: {{ config.get('grains', {}) }}
        {%- for key, value in service_config.get('defaults', {}).iteritems() %}
        {{ key }}: {{ value }}
        {%- endfor %}

          {%- endfor %}
        {%- endif %}
      {%- endfor %}
    {%- else %}
      {# TODO: configmap not using support between formulas #}
    {%- endif %}
  {%- endfor %}

{%- endif %}
