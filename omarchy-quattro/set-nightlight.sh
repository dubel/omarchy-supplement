#!/bin/bash

# Configure nightlight for Omarchy Quattro.
# Quattro uses hyprsunset instead of sunsetr for nightlight control.
# This script detects which tool is available and configures accordingly.
#
# If sunsetr is still available, it will be used (backward-compatible).
# If only hyprsunset is available, it configures via shell.toml.

set -e

echo "Configuring nightlight for Omarchy Quattro..."

# Desired settings
NIGHT_TEMP=3300
DAY_TEMP=6500
SUNSET="21:00"
SUNRISE="07:00"

# Check which nightlight tool is available
if command -v sunsetr &>/dev/null; then
    echo "Using sunsetr for nightlight configuration..."

    CONFIG_DIR="$HOME/.config/sunsetr"
    mkdir -p "$CONFIG_DIR"

    NIGHT_GAMMA=90
    DAY_GAMMA=100
    TRANSITION_MODE="finish_by"
    TRANSITION_DURATION=45

    sunsetr set \
      night_temp="$NIGHT_TEMP" \
      day_temp="$DAY_TEMP" \
      night_gamma="$NIGHT_GAMMA" \
      day_gamma="$DAY_GAMMA" \
      sunset="${SUNSET}:00" \
      sunrise="${SUNRISE}:00" \
      transition_mode="$TRANSITION_MODE" \
      transition_duration="$TRANSITION_DURATION"

    echo "Nightlight configured via sunsetr: ${NIGHT_TEMP}K from ${SUNSET} to ${SUNRISE}"
    echo "Current status:"
    sunsetr status

elif command -v hyprsunset &>/dev/null; then
    echo "Using hyprsunset for nightlight configuration..."

    # hyprsunset is Quattro's built-in nightlight, configured through shell.toml
    SHELL_TOML="$HOME/.config/omarchy/shell.toml"
    SHELL_TOML_DIR="$(dirname "$SHELL_TOML")"
    mkdir -p "$SHELL_TOML_DIR"

    # Helper function to set a value in shell.toml
    set_toml_value() {
        local key="$1"
        local value="$2"
        if [ -f "$SHELL_TOML" ] && grep -q "^${key}" "$SHELL_TOML"; then
            sed -i "s|^${key}.*|${key} = ${value}|" "$SHELL_TOML"
        else
            echo "${key} = ${value}" >> "$SHELL_TOML"
        fi
    }

    set_toml_value "nightlight_temp" "$NIGHT_TEMP"
    set_toml_value "nightlight_sunset" "\"$SUNSET\""
    set_toml_value "nightlight_sunrise" "\"$SUNRISE\""

    echo "Nightlight configured via hyprsunset/shell.toml: ${NIGHT_TEMP}K from ${SUNSET} to ${SUNRISE}"

    # Restart hyprsunset to pick up changes
    if command -v omarchy-restart-hyprsunset &>/dev/null; then
        omarchy-restart-hyprsunset
        echo "hyprsunset restarted with new settings."
    fi

    echo "Tip: You can also toggle nightlight from the bar's widget menu."

else
    echo "Error: Neither sunsetr nor hyprsunset found."
    echo "Please verify your Omarchy Quattro installation."
    exit 1
fi
