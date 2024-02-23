function beepPlay() {
  MELODY="$1"
  PS_CMD=$( echo $MELODY | awk -F';' '{ for(x=1;x<=NF;x++) printf "[console]::beep("$x"); "}' )
  powershell.exe "$PS_CMD"
}

alias yay='beepPlay "440,200;220,100;260,200"'
alias nope='beepPlay "260,350;260,350;200,300"'

function beepWhenDone() {
  if [[ $? -eq 0 ]]; then
    yay
  else
    nope
  fi
}

# Bring Windows binaries into Linux path
function removeExeFromWinbins() {
  winbinpath="$1"
  for winbin in "$winbinpath"/*.bat; do
    local binname_split
    local binname
    binname_split=${winbin%.bat}
    binname=${binname_split##*/}
    eval "alias $binname=$winbin"
  done
  for winbin in "$winbinpath"/*.exe; do
    local binname_split
    local binname
    binname_split=${winbin%.exe}
    binname=${binname_split##*/}
    eval "alias $binname=$winbin"
  done
}
