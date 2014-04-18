## Add this script to .bashrc like this:
#
# if [ -f ~/Nico.rc/bash_aliases ]; then
#     . ~/Nico.rc/bash_aliases
# fi
#
#

# Disable annoying ubuntu global menu
## This takes care of the annoying "menu timeout" in gvim when using KDE
## If using gnome or unity it's probably a good idea to comment this out
export UBUNTU_MENUPROXY=0

# Access to my fastgrep script from everywhere without adding a new $PATH entry
alias fastgrep='~/Nico.rc/fastgrep.sh'

# Create a folder-usage alias based on disk-usage
alias fu='du -h --max-depth=1'
alias folderusage='du -h --max-depth=1'

