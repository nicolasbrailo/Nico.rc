# OSX ships with ancient bash. Install new one and run it.
if [ "${BASH_VERSINFO[0]}" -lt 5 ] && [ -x "$HOME/src/brew/bin/bash" ]; then
    exec "$HOME/src/brew/bin/bash" --login
fi

# Access to my fastgrep script from everywhere without adding a new $PATH entry
alias fastgrep="/home/$USER/src/Nico.rc/fastgrep.sh"
alias gf="/home/$USER/src/Nico.rc/fastgrep.sh"

# Add custom scripts to path
if [ -d "$HOME/src/bin" ]; then
    PATH="$HOME/src/bin:$PATH"
fi

function kittytitle() {
  if [ -n "$TMUX" ]; then
    printf '\ePtmux;\e\e]2;%s\a\e\\' "$1"
  else
    printf '\e]2;%s\a' "$1"
  fi
}

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

function cdtofile() {
    if [ $# -eq 0 ]; then
        builtin cd ~;
        return $?;
    else
        if [ -f "$1" ]; then
            builtin cd "$(dirname "$1")" > /dev/null;
            return $?;
        else
            builtin cd "$1" > /dev/null;
            return $?;
        fi;
    fi
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
    if binexists _completion_loader; then
      _completion_loader "$preferred_bin"
      $(complete -p "$preferred_bin" | sed -E 's/[[:space:]]+'"$preferred_bin"'/ '"$default"'/g')
    fi
  fi
}

# Some fancy aliases from https://github.com/ibraheemdev/modern-unix
tryAlias cat bat
#tryAlias du duf
tryAlias grep rg
tryAlias ls "exa -l"
#tryAlias vim vimx
tryAlias cd cdtofile

# fzf: Ctrl-R fuzzy history, Ctrl-T file picker, Alt-C fuzzy cd
if command -v fzf >/dev/null; then
  # Default walkers include 'hidden'; drop it to skip dotfiles/dotdirs
  _fzf_skip="--walker-skip node_modules,__pycache__,build,dist,target,venv"
  export FZF_CTRL_T_OPTS="--walker file,dir,follow $_fzf_skip"
  export FZF_ALT_C_OPTS="--walker dir,follow $_fzf_skip"
  unset _fzf_skip
  eval "$(fzf --bash)"

  # When in ~, only let Ctrl-T walk these dirs instead of all of $HOME
  FZF_HOME_ROOTS=(src Downloads Desktop Screenshots)
  eval "$(declare -f __fzf_select__ | sed '1s/__fzf_select__/__fzf_select_all__/')"
  __fzf_select__() {
    local FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS-}" d roots=""
    if [[ $PWD == "$HOME" ]]; then
      for d in "${FZF_HOME_ROOTS[@]}"; do
        [[ -d $d ]] && roots+=" $d"
      done
      # One flag with a list; repeating --walker-root keeps only the last
      [[ -n $roots ]] && FZF_CTRL_T_OPTS+=" --walker-root$roots"
    fi
    __fzf_select_all__ "$@"
  }

  # Ctrl-T: Enter inserts the pick and runs the line, Tab only inserts it.
  # bind -x can't call accept-line, so Ctrl-T is a macro: run the widget,
  # then press \C-x\C-b, which the widget rebinds to accept-line or a no-op.
  __fzf_file_widget_run__() {
    local out key
    out="$(FZF_CTRL_T_OPTS="${FZF_CTRL_T_OPTS-} --expect=tab" __fzf_select__)"
    # First word is the --expect key: "tab", or '' for Enter
    key=${out%% *}
    out=${out#* }
    READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}$out${READLINE_LINE:READLINE_POINT}"
    READLINE_POINT=$((READLINE_POINT + ${#out}))
    if [[ -n $out && $key != tab ]]; then
      bind '"\C-x\C-b": accept-line'
    else
      bind '"\C-x\C-b": redraw-current-line'
    fi
  }
  bind -m emacs-standard -x '"\C-x\C-a": __fzf_file_widget_run__'
  bind -m emacs-standard '"\C-t": "\C-x\C-a\C-x\C-b"'
fi

