#!/usr/bin/bash

set -euo pipefail

echo "This script may be dangerous, it will overwrite Firefox configs"
exit 0

THIS_SCRIPT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RED='\033[0;31m'
NC='\033[0m' # No Color

FFX_PROFILE_APT="/home/$USER/.mozilla/firefox"
FFX_PROFILE_SNAP="/home/$USER/snap/firefox/common/.mozilla/firefox"

FFX_PROFILES=""
[ -d "$FFX_PROFILE_APT" ] && FFX_PROFILES="$FFX_PROFILES $FFX_PROFILE_APT"
[ -d "$FFX_PROFILE_SNAP" ] && FFX_PROFILES="$FFX_PROFILES $FFX_PROFILE_SNAP"
echo $FFX_PROFILES

for profile in $( find $FFX_PROFILES -maxdepth 1 -type d -name '*default*' ); do
  echo "Found Firefox profile @ $profile"

  mkdir -p "$profile/chrome"
  cp "$THIS_SCRIPT/userChrome.css" "$profile/chrome"
  cp "$THIS_SCRIPT/user.js" "$profile"
  echo -e "Remember to ${RED} set 'toolkit.legacyUserProfileCustomizations' = true in about:config ${NC}"
done

FFX_INSTALL_DIR=$( { 
  IFS=:; for d in $PATH; do
    for f in $d/*; do 
      [ -f $f ] && [ -x $f ] && echo "$d/${f##*/}";
    done;
  done; } | grep firefox | sort | xargs -I% sh -c "readlink -f %" | uniq | xargs -I% sh -c "dirname %" )

for install_path in $FFX_INSTALL_DIR; do
  echo "Provision Nico config @ $install_path"

  sudo mkdir -p "$install_path/defaults/pref/"
  sudo cp "$THIS_SCRIPT/autoconfig.js" "$install_path/defaults/pref/"
  sudo cp "$THIS_SCRIPT/firefox.nico.cfg" "$install_path"
done

