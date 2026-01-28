#!/bin/bash

# Uninstall PipeWire virtual mic combiner node

CONFIG_DIR="$HOME/.config/pipewire/pipewire.conf.d"
CONFIG_FILE="mic-combine.conf"

rm -f "$CONFIG_DIR/$CONFIG_FILE"

echo "Removed $CONFIG_DIR/$CONFIG_FILE"
echo "Restarting PipeWire..."

systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null || pkill -u "$USER" pipewire

echo "Done. Virtual mic removed."
