# Colors prompt + makes info shown dependent on size of window

# Safe PS1
export PS1='\A \h:\w \$ '

# Color PS1
# Pick an annoying default color, to remind myself to change it
if [ -z "$THIS_HOST_COLOR" ]; then export THIS_HOST_COLOR=103; fi

export COLOR_RESET='\[\e[0m\]'
export COLOR_SET='\[\e['$THIS_HOST_COLOR'm\]'
export PS1_NL_SEP=''
export LONG_PS1='\A '$COLOR_SET'\h'$COLOR_RESET':\w$PS1_NL_SEP\$ ';
export SHORT_PS1='\A \w$PS1_NL_SEP\$ ';

if [ -n "$(LC_ALL=C type -t _scm_prompt)" ] && [ "$(LC_ALL=C type -t _scm_prompt)" = function ]; then
  export PS1='\A '$COLOR_SET'\h'$COLOR_RESET':\w$( _scm_prompt " (%s)") $PS1_NL_SEP\$ ';
fi
export PS1=$LONG_PS1

function on_bash_resize() {
  local min_blank_cols=50
  local long_ps1_len=$(echo "${#LONG_PS1}")
  local short_ps1_len=$(echo "${#SHORT_PS1}")
  local term_cols=$(tput cols)
  local cols_after_long_ps1=$(( $term_cols - $long_ps1_len ))
  local cols_after_short_ps1=$(( $term_cols - $short_ps1_len ))
  if [[ $cols_after_long_ps1 -gt $min_blank_cols  ]]; then
    export PS1="$LONG_PS1"
    export PS1_NL_SEP=''
  elif [[ $cols_after_short_ps1 -gt $min_blank_cols ]]; then
    export PS1="$SHORT_PS1"
    export PS1_NL_SEP=''
  else
    export PS1="$SHORT_PS1"
    export PS1_NL_SEP=$'\n'
  fi
}

on_bash_resize
trap on_bash_resize SIGWINCH
