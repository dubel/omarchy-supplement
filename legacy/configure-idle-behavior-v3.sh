#!/bin/bash
# Configures idle behavior:
# 1. Extends the lock timeout to 30 minutes when idle is enabled.
# 2. Sets the DEFAULT state on boot to be DISABLED entirely (no screensaver, no lock).

HYPRIDLE_CONF="$HOME/.config/hypr/hypridle.conf"
AUTOSTART_CONF="$HOME/.config/hypr/autostart.conf"

echo "Configuring Omarchy idle behavior..."

# --- 1. SET TIMEOUT TO 30 MINUTES ---
if [ -f "$HYPRIDLE_CONF" ]; then
    # We use sed to replace the specific 152 second timeout for the lock listener 
    # to 1800 seconds (30 mins).
    sed -i 's/timeout = 152/timeout = 1800/g' "$HYPRIDLE_CONF"
    echo "Timeout for lock updated to 1800 seconds (30 minutes)."
else
    echo "Warning: hypridle.conf not found at $HYPRIDLE_CONF"
fi

# --- 2. SET DEFAULT BOOT STATE TO DISABLED ---
# Add a kill command to the Hyprland autostart config if it's not already there
if ! grep -q "pkill -x hypridle" "$AUTOSTART_CONF"; then
    echo "" >> "$AUTOSTART_CONF"
    echo "# Disable idle lock on boot by default (Omarchy default override)" >> "$AUTOSTART_CONF"
    echo "exec-once = bash -c 'for i in {1..20}; do if pgrep -x hypridle >/dev/null; then pkill -x hypridle; pkill -RTMIN+9 waybar; break; fi; sleep 1; done'" >> "$AUTOSTART_CONF"
    echo "Added autostart override to disable idle daemon on boot."
fi

# --- 3. APPLY DEFAULT STATE IMMEDIATELY ---
if pgrep -x hypridle >/dev/null; then
    echo "Killing active hypridle daemon to apply default disabled state..."
    pkill -x hypridle
    # Tell Waybar to update its UI icon to 'disabled'
    pkill -RTMIN+9 waybar
fi

echo "Done! By default, idle lock is DISABLED. If you toggle it ON manually, it will wait 30 minutes before locking."
