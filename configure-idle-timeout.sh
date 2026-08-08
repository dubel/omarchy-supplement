#!/bin/bash
# Extends the idle lock timeout to 30 minutes in the hypridle configuration

HYPRIDLE_CONF="$HOME/.config/hypr/hypridle.conf"

echo "Extending idle lock timeout to 30 minutes..."

if [ -f "$HYPRIDLE_CONF" ]; then
    # Create a backup
    cp "$HYPRIDLE_CONF" "${HYPRIDLE_CONF}.bak.timeout_extended"
    
    # We use sed to replace the specific 152 second timeout for the lock listener 
    # (which sits under the "Lock system after 5 minutes" comment) to 1800 seconds (30 mins).
    sed -i 's/timeout = 152/timeout = 1800/g' "$HYPRIDLE_CONF"
    
    echo "Timeout updated to 1800 seconds (30 minutes)."
    
    # Make sure the daemon is running so the new config applies, and update Waybar UI
    if ! pgrep -x hypridle >/dev/null; then
        echo "Starting hypridle daemon..."
        uwsm-app -- hypridle >/dev/null 2>&1 &
        pkill -RTMIN+9 waybar
    else
        echo "Restarting active hypridle daemon..."
        killall hypridle
        uwsm-app -- hypridle >/dev/null 2>&1 &
        pkill -RTMIN+9 waybar
    fi
    
    echo "Done!"
else
    echo "Error: hypridle.conf not found at $HYPRIDLE_CONF"
fi
