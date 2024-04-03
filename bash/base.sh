# Access to my fastgrep script from everywhere without adding a new $PATH entry
alias fastgrep="/home/$USER/src/Nico.rc/fastgrep.sh"
alias gf="/home/$USER/src/Nico.rc/fastgrep.sh"

# Add custom scripts to path
if [ -d "$HOME/src/bin" ]; then
    PATH="$HOME/src/bin:$PATH"
fi

# GPG shouldn't use GUI
GPG_TTY=`tty`
export GPG_TTY

# Configure history
export HISTFILESIZE=1000000
export HISTSIZE=1000000
export HISTIGNORE='ls:bg:fg:history:cd:man:exa:'
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
#export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
export PROMPT_COMMAND="history -a"
export EDITOR=vim

# Make C-w stop on slashes and spaces (instead of space only)
stty werase undef
bind '\C-w:unix-filename-rubout'

function ,s-bati.casa() {
  ssh batman@10.0.0.10
}

function ,beep() {
  aplay --quiet "/home/$USER/src/Nico.rc/beam.wav"
}

function binexists() {
  local cmd="$1"
  return $(command -v "$cmd" &>/dev/null)
}

function tryAlias() {
  local default="$1"
  local preferred="$2"

  # in case of an alias with params (eg `alias foo='ls -l'`) we want to check
  # if binexists `ls`, not 'ls -l'
  local preferred_bin=$(echo "$preferred" | awk '{print $1;}')

  if binexists "$preferred_bin"; then
    #echo "alias $default=\"$preferred\""
    eval "alias $default=\"$preferred\""

    # Try adding compgens for the alias
    _completion_loader "$preferred_bin"
    $(complete -p "$preferred_bin" | sed -E 's/[[:space:]]+'"$preferred_bin"'/ '"$default"'/g')
  fi
}

# Some fancy aliases from https://github.com/ibraheemdev/modern-unix
tryAlias cat bat
tryAlias du duf
tryAlias grep rg
tryAlias ls "exa -l"
#tryAlias vim vimx

