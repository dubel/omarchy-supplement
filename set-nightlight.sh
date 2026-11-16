#!/bin/bash

# Configure scheduled nightlight for Omarchy 4.x (Quattro).
# Omarchy 4.x natively uses hyprsunset for blue light filtering and screen warmth.
# Schedules are defined declaratively in ~/.config/hypr/hyprsunset.conf.

set -e

HYPRSUNSET_CONF="$HOME/.config/hypr/hyprsunset.conf"
AUTOSTART_LUA="$HOME/.config/hypr/autostart.lua"

NIGHT_TEMP=3300
SUNSET="21:00"
SUNRISE="07:00"

echo "Configuring Omarchy nightlight (${NIGHT_TEMP}K from ${SUNSET} to ${SUNRISE})..."

mkdir -p "$(dirname "$HYPRSUNSET_CONF")"

# 1. Write the hyprsunset profile schedule
cat > "$HYPRSUNSET_CONF" << EOF
# Configured by omarchy-supplement
# Reset to neutral/daylight at sunrise
profile {
    time = ${SUNRISE}
    identity = true
}

# Apply warm color temperature at sunset
profile {
    time = ${SUNSET}
    temperature = ${NIGHT_TEMP}
}
EOF

echo "Wrote schedule to $HYPRSUNSET_CONF"

# 2. Ensure hyprsunset autostarts with Hyprland
if [ -f "$AUTOSTART_LUA" ]; then
    MARKER='o.launch_on_start("hyprsunset")'
    if ! grep -qF -- "$MARKER" "$AUTOSTART_LUA"; then
        echo "" >> "$AUTOSTART_LUA"
        echo "-- Start hyprsunset daemon for scheduled nightlight" >> "$AUTOSTART_LUA"
        echo "$MARKER" >> "$AUTOSTART_LUA"
        echo "Added hyprsunset to $AUTOSTART_LUA"
    else
        echo "hyprsunset already configured in $AUTOSTART_LUA"
    fi
fi

# 3. Restart hyprsunset daemon to reload profiles
if command -v omarchy &>/dev/null; then
    omarchy restart hyprsunset 2>/dev/null || true
fi

echo "Nightlight configured: ${NIGHT_TEMP}K at ${SUNSET}, neutral at ${SUNRISE}."
echo "Tip: You can manually toggle nightlight on/off anytime with 'omarchy toggle nightlight'."
