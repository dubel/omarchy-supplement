#!/bin/bash

# Installs Hyprland Lua overrides for Omarchy 4.x.
# Injects a dofile() call into ~/.config/hypr/hyprland.lua to load the overrides,
# then validates the configuration with hyprctl reload.

set -e

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.lua"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERRIDES_FILE="$SCRIPT_DIR/hyprland-overrides.lua"

# Check if Omarchy's Lua config exists
if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo "Error: Hyprland Lua config not found at $HYPRLAND_CONFIG"
    echo "Are you running Omarchy 4.x? The old .conf format is no longer supported."
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

# Validate and reload configuration
if command -v hyprctl &>/dev/null; then
    hyprctl reload >/dev/null 2>&1 || true
    ERRORS=$(hyprctl configerrors 2>/dev/null || true)
    if [ -n "$ERRORS" ]; then
        echo "Warning: Hyprland reported config errors:"
        echo "$ERRORS"
    else
        echo "Hyprland configuration reloaded and validated clean."
    fi
fi

echo "Hyprland Lua overrides setup complete!"
