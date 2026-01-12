#!/bin/bash

# Install Google Chrome browser
yay -S --noconfirm --needed google-chrome

echo ""
echo "=============================================="
echo "  Google Chrome Login Required"
echo "=============================================="
echo ""
echo "Google Chrome will now open."
echo "Please log in to your Google account and wait for sync to complete."
echo ""

# Launch Chrome in the background
google-chrome-stable &
CHROME_PID=$!

echo "Chrome is now running (PID: $CHROME_PID)"
echo ""

# Wait for user confirmation
while true; do
    read -p "Have you finished logging in and syncing? (y/n): " response
    case $response in
        [Yy]* )
            echo "Proceeding with configuration sync..."
            break
            ;;
        [Nn]* )
            echo "Please complete the login and sync, then try again."
            ;;
        * )
            echo "Please answer y (yes) or n (no)."
            ;;
    esac
done

# Close Chrome gracefully if still running
if kill -0 $CHROME_PID 2>/dev/null; then
    echo "Closing Chrome..."
    kill $CHROME_PID 2>/dev/null
    sleep 2
fi

# Sync Chrome config to Chromium
echo ""
echo "Syncing Google Chrome config to Chromium..."

# Backup existing Chromium config if it exists
if [ -d "$HOME/.config/chromium" ]; then
    echo "Backing up existing Chromium config to ~/.config/chromium.backup"
    rm -rf "$HOME/.config/chromium.backup"
    mv "$HOME/.config/chromium" "$HOME/.config/chromium.backup"
fi

# Copy Chrome config to Chromium
cp -aT "$HOME/.config/google-chrome" "$HOME/.config/chromium"

echo "Done! Chrome configuration has been synced to Chromium."
echo ""
