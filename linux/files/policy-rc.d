{%- from "linux/map.jinja" import system with context -%}
#!/bin/sh

while true; do
case $1 in
  {%- for policy in system.policyrcd %}
  {{ policy.package }}) {{ policy.action }};;
  {%- endfor %}
esac
done
