#!/bin/bash

# Link two physical mics to the combined stereo mic

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <left_mic> <right_mic>"
    echo ""
    echo "Example: $0 alsa_input.usb-Mic1 alsa_input.usb-Mic2"
    echo ""
    echo "Available mics:"
    pw-link -o | grep alsa_input | cut -d: -f1 | sort -u
    exit 1
fi

LEFT_MIC=$(pw-link -o  | grep "capture" | grep "$1" | head -1 | cut -d: -f1)
RIGHT_MIC=$(pw-link -o | grep "capture" | grep "$2" | head -1 | cut -d: -f1)

# Detect capture port names
LEFT_PORT=$(pw-link -o | grep "^${LEFT_MIC}:" | head -1 | cut -d: -f2)
RIGHT_PORT=$(pw-link -o | grep "^${RIGHT_MIC}:" | head -1 | cut -d: -f2)

if [[ -z "$LEFT_PORT" ]]; then
    echo "Error: Could not find left mic '$LEFT_MIC'"
    exit 1
fi

if [[ -z "$RIGHT_PORT" ]]; then
    echo "Error: Could not find right mic '$RIGHT_MIC'"
    exit 1
fi

pw-link "${LEFT_MIC}:${LEFT_PORT}" combined_stereo_mic_input:playback_FL
pw-link "${RIGHT_MIC}:${RIGHT_PORT}" combined_stereo_mic_input:playback_FR

echo "Linked:"
echo "  ${LEFT_MIC}:${LEFT_PORT} -> FL"
echo "  ${RIGHT_MIC}:${RIGHT_PORT} -> FR"
