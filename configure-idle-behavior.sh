#!/bin/bash

# Configures idle behavior for Omarchy 4.x (Quattro).
# Replaces legacy hypridle/hyprlock configs — idle detection and lock screen
# are now handled natively by Omarchy Shell (Quickshell).
#
# Goals:
# 1. Extend the idle lock timeout to 30 minutes (when idle IS enabled).
# 2. Set the default boot state to DISABLED (stay-awake mode, no automatic lock/screensaver).

set -e

SHELL_JSON="$HOME/.config/omarchy/shell.json"
AUTOSTART_LUA="$HOME/.config/hypr/autostart.lua"

echo "Configuring Omarchy idle behavior..."

# --- 1. SET IDLE TIMEOUT IN SHELL.JSON ---
# idle.lock: seconds before screen locks (1800s = 30m)
# idle.screensaver: seconds before screensaver activates (900s = 15m)
if [ -f "$SHELL_JSON" ] && command -v jq &>/dev/null; then
    tmp=$(mktemp)
    jq '.idle.lock = 1800 | .idle.screensaver = 900' "$SHELL_JSON" > "$tmp" && mv "$tmp" "$SHELL_JSON"
    echo "Configured idle timeouts in $SHELL_JSON (lock: 1800s, screensaver: 900s)"
fi

# --- 2. SET DEFAULT BOOT STATE TO STAY-AWAKE ---
# Omarchy 4.x uses 'omarchy toggle idle stay-awake' to prevent automatic sleep/lock.
if [ -f "$AUTOSTART_LUA" ]; then
    MARKER="-- Disable idle on boot (omarchy-supplement)"
    if ! grep -qF -- "$MARKER" "$AUTOSTART_LUA"; then
        echo "" >> "$AUTOSTART_LUA"
        echo "$MARKER" >> "$AUTOSTART_LUA"
        echo 'o.launch_on_start("omarchy toggle idle stay-awake")' >> "$AUTOSTART_LUA"
        echo "Added stay-awake autostart entry to $AUTOSTART_LUA"
    else
        echo "Stay-awake autostart entry already present in $AUTOSTART_LUA"
    fi
else
    echo "Note: $AUTOSTART_LUA not found. Creating it..."
    mkdir -p "$(dirname "$AUTOSTART_LUA")"
    cat > "$AUTOSTART_LUA" << 'EOF'
-- Extra autostart processes.
o.launch_on_start("omarchy toggle idle stay-awake")
EOF
fi

# --- 3. APPLY STAY-AWAKE STATE IMMEDIATELY ---
if command -v omarchy-toggle-idle &>/dev/null || command -v omarchy &>/dev/null; then
    omarchy toggle idle stay-awake 2>/dev/null || omarchy-toggle-idle stay-awake 2>/dev/null || true
    echo "Applied stay-awake state immediately."
fi

echo ""
echo "Done! Idle behavior configured:"
echo "  - Idle timeout: 30 minutes (lock), 15 minutes (screensaver)"
echo "  - Default state: STAY AWAKE (no auto-lock on boot)"
echo "  - Manual toggle: use the bar indicator or 'omarchy toggle idle'"
