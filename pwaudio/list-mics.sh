#!/bin/bash

# List physical microphones with their PipeWire names

# Get sources from pactl that have ALSA card properties (indicates physical device)
pactl list sources | awk '
    /^Source #/ {
        source_num = $2
        name = ""
        desc = ""
        is_physical = 0
    }
    /Name:/ {
        name = $2
    }
    /Description:/ {
        sub(/Description: /, "")
        desc = $0
    }
    /alsa.card_name/ || /device.bus/ {
        is_physical = 1
    }
    /^$/ {
        if (is_physical && name != "") {
            print name
        }
    }
' | while read -r pactl_name; do
    # Find matching pw-link output ports
    pw_ports=$(pw-link -o 2>/dev/null | grep -F "$pactl_name" | head -1 | cut -d: -f1)

    if [[ -n "$pw_ports" ]]; then
        # Get description from pactl for display
        desc=$(pactl list sources | grep -A 5 "Name: $pactl_name" | grep "Description:" | sed 's/.*Description: //')
        echo "$pw_ports"
        echo "    Description: $desc"
        echo "    Ports: $(pw-link -o | grep -F "$pactl_name" | tr '\n' ' ')"
        echo ""
    fi
done
