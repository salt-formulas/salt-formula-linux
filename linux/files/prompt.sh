{%- from "linux/map.jinja" import system with context %}

# Don't set special prompt when not using Bash or ZSH
[ -n "$BASH_VERSION" -o -n "$ZSH_VERSION" ] || return 0

# Don't set prompt on non-interactive shell
[[ $- == *i* ]] || return 0

{%- for user, prompt in system.prompt.items() %}
{% if user != "default" %}
if [ "$USERNAME" == "{{ user }}" ]; then
  export PS1="{{ prompt }} "
  return 0
fi
{% endif %}
{%- endfor %}

{% if system.prompt.default is defined %}
export PS1="{{ system.prompt.default }} "
{%- endif %}
