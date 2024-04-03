#!/bin/bash

# jump to bookmark from anywhere in bash.

export GOTO_BOOKMARK_SRC="$HOME/goto"

function goto() {
  linkname="$1"

  if [[ (-z ${1+x}) || ("$linkname" == "-h") || ("$linkname" == "." && -z ${2+x})  ]]; then
    echo "cd to a bookmarked directory from anywhere"
    echo "Usage:"
    echo -e "\tgoto . NAME\tAdd a link to the current directory, called NAME"
    echo -e "\tgoto NAME\tcd to directory bookmarked as NAME"
    return
  fi

  if [[ "$linkname" == "." ]]; then
    tgt=$( pwd )
    name="$2"
    echo "Symlinking $tgt as $GOTO_BOOKMARK_SRC/$name"
    ln -s "$tgt" "$GOTO_BOOKMARK_SRC/$name"
    return
  fi

  linkpath="$GOTO_BOOKMARK_SRC/$linkname"
  if [[ ! -L "$linkpath" ]]; then
    echo >&2 "error $0 $linkname: $linkpath doesn't exist or is not a symlink"
    return
  fi

  path=$( readlink -f "$linkpath" )
  cd "$path"
}

if [[ ! -d "$GOTO_BOOKMARK_SRC" ]]; then
  mkdir -p "$GOTO_BOOKMARK_SRC"
fi

_goto_cwd_completion() {
  cur="${COMP_WORDS[COMP_CWORD]}";
  links=$( ls "$GOTO_BOOKMARK_SRC" )
  COMPREPLY=($(compgen -W "${links}" -- ${cur}));
}

complete -F _goto_cwd_completion goto
