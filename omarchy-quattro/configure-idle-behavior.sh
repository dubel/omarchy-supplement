#!/bin/bash

# Configures idle behavior for Omarchy Quattro.
# Replaces the old configure-idle-behavior.sh — hypridle is gone, replaced by
# Quickshell-based idle handling. hyprlock is gone too, replaced by a PAM lock screen.
#
# Goals:
# 1. Extend the idle lock timeout to 30 minutes (when idle IS enabled).
# 2. Set the default boot state to DISABLED (no screensaver, no lock).

set -e

SHELL_TOML="$HOME/.config/omarchy/shell.toml"
SHELL_TOML_DIR="$(dirname "$SHELL_TOML")"
AUTOSTART_LUA="$HOME/.config/hypr/autostart.lua"

echo "Configuring Omarchy Quattro idle behavior..."

# Ensure the config directory exists
mkdir -p "$SHELL_TOML_DIR"

# --- 1. SET IDLE TIMEOUT TO 30 MINUTES ---
# In Quattro, idle timeouts are configured via shell.toml (watched live by Quickshell)
IDLE_TIMEOUT=1800  # 30 minutes in seconds

if [ -f "$SHELL_TOML" ]; then
    if grep -q "^idle_timeout" "$SHELL_TOML"; then
        sed -i "s|^idle_timeout.*|idle_timeout = $IDLE_TIMEOUT|" "$SHELL_TOML"
        echo "Updated idle_timeout to $IDLE_TIMEOUT seconds in $SHELL_TOML"
    else
        echo "" >> "$SHELL_TOML"
        echo "# Custom idle timeout (30 minutes)" >> "$SHELL_TOML"
        echo "idle_timeout = $IDLE_TIMEOUT" >> "$SHELL_TOML"
        echo "Added idle_timeout = $IDLE_TIMEOUT to $SHELL_TOML"
    fi
else
    cat > "$SHELL_TOML" << EOF
# Omarchy Quattro shell configuration

# Custom idle timeout (30 minutes)
idle_timeout = $IDLE_TIMEOUT
EOF
    echo "Created $SHELL_TOML with idle_timeout = $IDLE_TIMEOUT"
fi

# --- 2. SET DEFAULT BOOT STATE TO DISABLED ---
# In Quattro, idle can be toggled with omarchy-toggle-idle (if available).
# We inject a call into autostart.lua to disable idle on boot.
if [ -f "$AUTOSTART_LUA" ]; then
    DISABLE_MARKER="-- Disable idle on boot (omarchy-supplement)"
    if ! grep -qF -- "$DISABLE_MARKER" "$AUTOSTART_LUA"; then
        echo "" >> "$AUTOSTART_LUA"
        echo "$DISABLE_MARKER" >> "$AUTOSTART_LUA"
        # Use os.execute to run the toggle-idle command after a delay
        # This gives the shell time to start before we try to disable idle
        echo 'o.launch_on_start("bash -c '\''sleep 3 && omarchy-toggle-idle off 2>/dev/null || true'\''")' >> "$AUTOSTART_LUA"
        echo "Added idle-disable autostart entry to $AUTOSTART_LUA"
    else
        echo "Idle-disable autostart entry already exists in $AUTOSTART_LUA"
    fi
else
    echo "Warning: autostart.lua not found at $AUTOSTART_LUA"
    echo "You may need to manually disable idle on boot."
fi

# --- 3. APPLY DEFAULT STATE IMMEDIATELY ---
# Try to disable idle right now if the toggle command exists
if command -v omarchy-toggle-idle &>/dev/null; then
    echo "Disabling idle daemon now..."
    omarchy-toggle-idle off 2>/dev/null || true
elif command -v omarchy-debug-idle &>/dev/null; then
    echo "Note: Use 'omarchy-debug-idle' to check idle state and diagnostics."
fi

echo ""
echo "Done! Idle behavior configured for Quattro:"
echo "  - Idle timeout: 30 minutes (when enabled)"
echo "  - Default boot state: DISABLED"
echo "  - Use 'omarchy-toggle-idle' to toggle idle on/off manually."
