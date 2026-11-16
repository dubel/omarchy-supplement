#!/bin/bash

# Apply custom Waybar configuration surgically
# Instead of overwriting with a static file (which freezes your config in time),
# this pulls the absolute latest Omarchy default config, and surgically replaces
# the clock format string. It includes defensive rollback logic if Waybar crashes.

echo "Applying surgical custom Waybar configuration..."

# 1. Pull the absolute latest default config from Omarchy master
echo "Pulling latest Omarchy default config..."
omarchy-refresh-config waybar/config.jsonc

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"

# 2. Make a defensive backup
cp "$WAYBAR_CONFIG" "${WAYBAR_CONFIG}.safe_backup"

# 3. Apply the surgical edit using Python (safe string replace)
python3 -c '
import sys
try:
    with open(sys.argv[1], "r") as f:
        content = f.read()
    
    # We look for the exact default format string to ensure we only change what we expect
    old_str = "\"format\": \"{:L%A %H:%M}\""
    new_str = "\"format\": \"{:L%d %B (%A)  %H:%M}\""
    
    if old_str in content:
        content = content.replace(old_str, new_str)
        with open(sys.argv[1], "w") as f:
            f.write(content)
        print("Surgical edit applied successfully.")
    else:
        print("Warning: Default format string not found. Omarchy may have changed the default config structure.")
        print("Skipping edit to prevent breaking Waybar.")
except Exception as e:
    print(f"Error applying edit: {e}")
    sys.exit(1)
' "$WAYBAR_CONFIG"

# Check if Python script failed
if [ $? -ne 0 ]; then
    echo "Failed to run edit script. Reverting..."
    cp "${WAYBAR_CONFIG}.safe_backup" "$WAYBAR_CONFIG"
fi

# 4. Attempt to restart Waybar and check if it crashes
echo "Restarting Waybar to test configuration..."
if command -v omarchy-restart-waybar &>/dev/null; then
    omarchy-restart-waybar &>/dev/null || pkill -SIGUSR2 waybar
else
    pkill -SIGUSR2 waybar 2>/dev/null
fi

# Wait briefly for Waybar to initialize
sleep 2

# Check if Waybar is running
if ! pgrep -x "waybar" > /dev/null; then
    echo "CRITICAL: Waybar crashed after the edit! Reverting to safe backup..."
    cp "${WAYBAR_CONFIG}.safe_backup" "$WAYBAR_CONFIG"
    
    # Restart with the safe config
    if command -v omarchy-restart-waybar &>/dev/null; then
        omarchy-restart-waybar &>/dev/null || pkill -SIGUSR2 waybar
    else
        pkill -SIGUSR2 waybar 2>/dev/null
    fi
    echo "Restored original Omarchy master config. Your OS is safe."
else
    echo "Waybar is running stable with the new configuration!"
fi
