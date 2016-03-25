{%- from "linux/map.jinja" import system with context %}

# History across sessions for Bash
if [ -n "$BASH_VERSION" ]; then
  # Avoid duplicates
  export HISTCONTROL=ignoredups:erasedups
  # When the shell exits, append to the history file instead of overwriting it
  shopt -s histappend

  # After each command, append to the history file and reread it
  export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
fi
