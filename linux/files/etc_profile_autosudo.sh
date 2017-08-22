#!/bin/bash

# USAGE: $ . autosudo.sh
#        $ sudoon
#        $ sudo: <any commands>
#        $ sudo: ...
#        $ sudo: sudooff
# LIMITATIONS:
#   - does not check your sudo policy, assumes "bash -c ..." is allowed
#   - autocompletion (tab) for files/dirs does not work in restricted folders
#   - may contain bugs
# NOTES: supports "cd ..."; allows to freely operate in restricted directories

function sudoon () {
  if [ -z "$PREEXEC_PROMPT" ]
  then
    trap - DEBUG
    ORIGINAL_PROMPT_COMMAND="$PROMPT_COMMAND"
    PREEXEC_PROMPT=1
    ORIGINAL_PS1=$PS1
    PS1=$ORIGINAL_PS1"sudo: "
    shopt -s extdebug
    PROMPT_COMMAND="_preexec_prompt"
    trap "_preexec_sudo" DEBUG
  fi
}

function sudooff () {
  trap - DEBUG
  shopt -u extdebug
  unset PREEXEC_PROMPT
  PS1=$ORIGINAL_PS1
  unset SUDO_DIR
  PROMPT_COMMAND="$ORIGINAL_PROMPT_COMMAND"
  unset ORIGINAL_PROMPT_COMMAND
}

function _preexec_prompt() {
  trap - DEBUG
  PREEXEC_PROMPT=1
  trap "_preexec_sudo" DEBUG
}


function _preexec_sudo() {
  # echo PREEXEC_PROMPT=$PREEXEC_PROMPT BASH_COMMAND=$BASH_COMMAND SUDO_DIR=$SUDO_DIR
  [ -n "$COMP_LINE" ] && return
  [ "$BASH_COMMAND" == "$PROMPT_COMMAND" ] && return
  [ -z "$BASH_COMMAND" ] && return
  [[ "$BASH_COMMAND" =~ ^exit$|^set\ |^shopt\ |^trap\ |^sudoon$|^sudooff$ ]] && return
  [ -z "$PREEXEC_PROMPT" ] && return
  if [ "$PREEXEC_PROMPT" -eq 0 ]; then
    # echo cancelling "$BASH_COMMAND"
    return 1
  fi

  # echo "trap-DEBUG"
  trap - DEBUG
  PREEXEC_PROMPT=0
  FULL_COMMAND=$(HISTTIMEFORMAT='' history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//")
  # echo "Running _preexec_sudo $FULL_COMMAND"
  ARG_0=$(cut -d' ' -f1 <<< "$BASH_COMMAND")
  TYPE=$(type "$ARG_0" 2> /dev/null | head -n 1)
  if [[ ! "$TYPE" =~ / ]]
  then
    if [ "$BASH_COMMAND" == "$FULL_COMMAND" ]
    then
      if [[ "$BASH_COMMAND" =~ ^cd\  ]]
      then
        if [ -z "$SUDO_DIR" ]
        then
          if $BASH_COMMAND 2> /dev/null
          then
            trap "_preexec_sudo" DEBUG
            return 1
          else
            DIR=$(sudo bash -c "$BASH_COMMAND; pwd")
            DIR_ERR=$?
          fi
        else
          DIR=$(sudo bash -c "cd $SUDO_DIR; $BASH_COMMAND; pwd")
          DIR_ERR=$?
        fi
        if [ "$DIR_ERR" -eq 0 ]
        then
          if cd "$DIR" 2> /dev/null
          then
            SUDO_DIR=''
            PS1=$ORIGINAL_PS1"sudo: "
          else
            SUDO_DIR=$DIR
            [ -n "$SUDO_DIR" ] && PS1_SUDO_DIR="($(echo "$SUDO_DIR" | rev | cut -d'/' -f1 | rev))" || PS1_SUDO_DIR=''
            PS1=$ORIGINAL_PS1"sudo${PS1_SUDO_DIR}: "
          fi
        fi
        trap "_preexec_sudo" DEBUG
        return 1
      elif [ -z "$SUDO_DIR" ]
      then
        trap "_preexec_sudo" DEBUG
        return # single call to function / builtin; not sudoing
      fi
    fi
  fi
  [[ "$TYPE" =~ / ]] && [ "$(which "$ARG_0")" == "$(which sudo)" ] && return 0 # execute explicit sudo as-is
  if [ -n "$SUDO_DIR" ]
  then
    CMD_DIR="cd $SUDO_DIR; "
  else
    CMD_DIR=''
  fi
  if [ ! "$BASH_COMMAND" == "$FULL_COMMAND" ] || [ -n "$CMD_DIR" ]
  then
    # echo combined or cd command: `printf '%q' "${CMD_DIR}$FULL_COMMAND"`
    eval sudo -E bash -c $(printf '%q' "${CMD_DIR}${FULL_COMMAND}")
  else
    eval sudo -E ${FULL_COMMAND}
  fi
  trap "_preexec_sudo" DEBUG
  return 1
}
