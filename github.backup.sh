#!/usr/bin/bash

set -euo pipefail

RED='\033[0;31m'
NC='\033[0m' # No Color

if [[ -z "${1+x}" ]]; then
  echo -e "Back up all ${RED}PUBLIC${NC} repos of a github user. Usage: $0 <GH USER>"
  exit 0
fi

USER="$1"
echo "Run back up for github.com/$USER"

BCK_DIR="gitbackup.$USER"
mkdir "$BCK_DIR"

touch "$BCK_DIR/run.sh"
chmod +x "$BCK_DIR/run.sh"

wget -q "https://api.github.com/users/$USER/repos" -O- > "$BCK_DIR/idx.json"
for repo in $( cat "$BCK_DIR/idx.json" | jq '.[].ssh_url' ); do
  echo "echo 'Cloning $repo'" >> "$BCK_DIR/run.sh"
  echo git clone --recurse-submodules "$repo" >> "$BCK_DIR/run.sh"
done

echo "Generated backup script at $BCK_DIR/run.sh"
echo "Please review before running"
echo $RED "Please review and ./run.sh when ready"
echo -e "Warning ${RED}private scripts won't be backed up automatically${NC}, but you can add them to run.sh"

