#!/bin/bash

# Configure nightlight for Omarchy Quattro.
# Quattro uses omarchy-toggle-nightlight (wrapping hyprsunset) for nightlight.
# This script enables nightlight immediately and optionally configures sunsetr
# as a fallback if hyprsunset is not available.

set -e

echo "Configuring nightlight for Omarchy Quattro..."

# Desired settings
NIGHT_TEMP=3300
DAY_TEMP=6500
SUNSET="21:00"
SUNRISE="07:00"

# Quattro's native nightlight is omarchy-toggle-nightlight, which wraps hyprsunset.
# sunsetr may be installed but is NOT what Quattro uses for the toggle widget.
if command -v omarchy-toggle-nightlight &>/dev/null; then
    echo "Using Quattro's built-in nightlight (omarchy-toggle-nightlight / hyprsunset)..."

    # Enable nightlight now
    omarchy-toggle-nightlight 2>/dev/null || true
    sleep 0.5

    # Check if it's actually on; if the toggle turned it off, toggle again
    STATUS=$(omarchy-toggle-nightlight --status 2>/dev/null || echo '{}')
    ENABLED=$(echo "$STATUS" | grep -o '"enabled":true' || true)
    if [ -z "$ENABLED" ]; then
        omarchy-toggle-nightlight 2>/dev/null || true
        sleep 0.5
    fi

    echo "Nightlight enabled via omarchy-toggle-nightlight."
    echo "Current status:"
    omarchy-toggle-nightlight --status 2>/dev/null || echo "  (could not query status)"

    # Note: hyprsunset's default ON temp is 4000K. To change it, the
    # omarchy-toggle-nightlight script would need to be overridden.
    # The temperature can also be set directly:
    #   hyprctl hyprsunset temperature 3300
    echo ""
    echo "Tip: Use SUPER+CTRL+N to toggle nightlight, or the bar widget."

elif command -v sunsetr &>/dev/null; then
    echo "Falling back to sunsetr for nightlight configuration..."

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

else
    echo "Error: Neither omarchy-toggle-nightlight nor sunsetr found."
    echo "Please verify your Omarchy Quattro installation."
    exit 1
fi
