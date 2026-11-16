#!/bin/bash

# Configure the Omarchy Shell (Quickshell) bar clock format.
# Replaces legacy Waybar config — Waybar is replaced by Quickshell in Omarchy 4.x.
# Native configuration lives in ~/.config/omarchy/shell.json and is managed by `omarchy bar`.

set -e

# Desired clock format in Qt format: "25 August (Monday)  14:30"
CLOCK_FORMAT="d MMMM (dddd)  HH:mm"

echo "Configuring Omarchy bar clock format..."

# 1. Prefer native Omarchy CLI if available
if command -v omarchy-bar &>/dev/null || command -v omarchy &>/dev/null; then
    omarchy bar set omarchy.clock format "$CLOCK_FORMAT" 2>/dev/null || omarchy-bar set omarchy.clock format "$CLOCK_FORMAT"
    echo "Clock format updated via omarchy bar CLI."
else
    # 2. Fallback: Directly update ~/.config/omarchy/shell.json using jq
    SHELL_JSON="$HOME/.config/omarchy/shell.json"
    if [ -f "$SHELL_JSON" ] && command -v jq &>/dev/null; then
        tmp=$(mktemp)
        jq --arg fmt "$CLOCK_FORMAT" '
          walk(if type == "object" and .id == "omarchy.clock" then .format = $fmt else . end)
        ' "$SHELL_JSON" > "$tmp" && mv "$tmp" "$SHELL_JSON"
        echo "Updated clock format directly in $SHELL_JSON"
    fi
fi

echo "Bar clock configured: format = \"$CLOCK_FORMAT\""
echo "Tip: Left click opens calendar, right click cycles format."
