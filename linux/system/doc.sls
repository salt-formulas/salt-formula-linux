{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

# This state is obsolete, grains are now managed from salt.minion.grains so we
# will just include it

include:
  - salt.minion.grains

{%- endif %}
