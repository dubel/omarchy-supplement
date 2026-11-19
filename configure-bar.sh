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

# Show the focused application's name in the bar, like the macOS menu bar.
# The widget lives in this repo (configs/omarchy-plugins/supplement.app-name) and
# replaces Omarchy's built-in Active window widget, whose full window titles
# crowd the bar. Files are always refreshed; enabling only happens when off, so
# reruns don't touch the widget's placement.
APP_NAME_WIDGET="supplement.app-name"
APP_NAME_SRC="$(cd "$(dirname "$0")" && pwd)/configs/omarchy-plugins/$APP_NAME_WIDGET"
APP_NAME_DEST="$HOME/.config/omarchy/plugins/$APP_NAME_WIDGET"

plugin_enabled() {
    omarchy-shell shell listPlugins | jq -e --arg id "$1" 'any(.[]; .id == $id and .enabled)' >/dev/null
}

# The shell caches loaded QML, so a changed widget only takes effect after a
# shell restart; a first install is picked up by the rescan below.
APP_NAME_RESTART=0
if [ -d "$APP_NAME_DEST" ] && ! diff -rq "$APP_NAME_SRC" "$APP_NAME_DEST" >/dev/null; then
    APP_NAME_RESTART=1
fi
mkdir -p "$APP_NAME_DEST"
cp -a "$APP_NAME_SRC/." "$APP_NAME_DEST/"
omarchy-shell shell rescanPlugins >/dev/null
for _ in $(seq 40); do
    omarchy-plugin-list --json | jq -e --arg id "$APP_NAME_WIDGET" 'any(.[]; .id == $id)' >/dev/null && break
    sleep 0.05
done

if plugin_enabled omarchy.active-window; then
    omarchy plugin disable omarchy.active-window
fi
if plugin_enabled "$APP_NAME_WIDGET"; then
    echo "Bar widget $APP_NAME_WIDGET already enabled."
else
    omarchy plugin enable "$APP_NAME_WIDGET"
fi
if [ "$APP_NAME_RESTART" = 1 ]; then
    echo "Widget $APP_NAME_WIDGET changed, restarting the Omarchy shell..."
    omarchy restart shell
fi
