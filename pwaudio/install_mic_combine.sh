#!/bin/bash

# Install PipeWire virtual mic combiner node

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/pipewire/pipewire.conf.d"
CONFIG_FILE="mic-combine.conf"

mkdir -p "$CONFIG_DIR"
cp "$SCRIPT_DIR/$CONFIG_FILE" "$CONFIG_DIR/$CONFIG_FILE"

echo "Installed config to $CONFIG_DIR/$CONFIG_FILE"
echo "Restarting PipeWire..."

systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null || pkill -u "$USER" pipewire

echo "Done. Virtual mic 'Combined Stereo Mic' should now be available."
echo "Use pw-link to connect microphones to combined_stereo_mic_input:playback_FL and playback_FR"
