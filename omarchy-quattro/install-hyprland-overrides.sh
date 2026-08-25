#!/bin/bash

# Installs Hyprland Lua overrides for Omarchy Quattro.
# Injects a dofile() call into ~/.config/hypr/hyprland.lua to load the overrides.

set -e

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.lua"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERRIDES_FILE="$SCRIPT_DIR/hyprland-overrides.lua"

# Check if Quattro's Lua config exists
if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo "Error: Hyprland Lua config not found at $HYPRLAND_CONFIG"
    echo "Are you running Omarchy Quattro? The old .conf format is no longer supported."
    exit 1
fi

# Check if overrides file exists
if [ ! -f "$OVERRIDES_FILE" ]; then
    echo "Error: Overrides file not found at $OVERRIDES_FILE"
    exit 1
fi

# The dofile() line to inject
DOFILE_LINE="dofile(\"$OVERRIDES_FILE\")"

# Check if already injected (idempotent)
if grep -Fq "$DOFILE_LINE" "$HYPRLAND_CONFIG"; then
    echo "Hyprland Lua overrides already loaded in $HYPRLAND_CONFIG"
else
    echo "Injecting dofile() into $HYPRLAND_CONFIG..."

    # Backup the config before modifying
    cp "$HYPRLAND_CONFIG" "${HYPRLAND_CONFIG}.backup_pre_overrides"

    # Append the dofile call at the end of the config
    echo "" >> "$HYPRLAND_CONFIG"
    echo "-- User overrides (omarchy-supplement)" >> "$HYPRLAND_CONFIG"
    echo "$DOFILE_LINE" >> "$HYPRLAND_CONFIG"

    echo "dofile() injected successfully."
fi

echo "Hyprland Lua overrides setup complete!"
echo "Restart Hyprland (SUPER+SHIFT+E > Reload) to apply changes."
