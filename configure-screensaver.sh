#!/bin/bash
# Replaces the default random effect screensaver with a continuous matrix loop

SCREENSAVER_SCRIPT="$HOME/.local/share/omarchy/bin/omarchy-screensaver"

echo "Configuring Omarchy screensaver for infinite Matrix rain..."

if [ -f "$SCREENSAVER_SCRIPT" ]; then
    # Replace --random-effect with global options first, THEN the matrix subcommand
    sed -i 's/--random-effect --no-eol --no-restore-cursor/--no-eol --no-restore-cursor matrix --rain-time 99999999/g' "$SCREENSAVER_SCRIPT"
    echo "Screensaver updated successfully!"
else
    echo "Error: $SCREENSAVER_SCRIPT not found."
fi
