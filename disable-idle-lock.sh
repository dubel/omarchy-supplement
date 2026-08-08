#!/bin/bash

# Disables automatic idle locking by leveraging Omarchy's built-in toggle script

echo "Disabling idle screen lock using Omarchy toggle..."

# 1. Restore the original hypridle.conf if we backed it up earlier, so the toggle works properly
if [ -f "$HOME/.config/hypr/hypridle.conf.bak.idle_disabled" ]; then
    mv "$HOME/.config/hypr/hypridle.conf.bak.idle_disabled" "$HOME/.config/hypr/hypridle.conf"
fi

# 2. Add an autostart hook so it gets toggled OFF automatically on every boot
AUTOSTART_CONF="$HOME/.config/hypr/autostart.conf"
if ! grep -q "omarchy-toggle-idle" "$AUTOSTART_CONF"; then
    echo "" >> "$AUTOSTART_CONF"
    echo "# Disable idle lock on boot using Omarchy's toggle" >> "$AUTOSTART_CONF"
    echo "exec-once = sleep 2 && pgrep -x hypridle >/dev/null && omarchy-toggle-idle" >> "$AUTOSTART_CONF"
fi

# 3. Apply it immediately to the current session (if it's currently enabled)
if pgrep -x hypridle >/dev/null; then
    omarchy-toggle-idle
fi

echo "Done! The idle lock is disabled."
