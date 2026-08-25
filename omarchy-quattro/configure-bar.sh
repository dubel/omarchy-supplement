#!/bin/bash

# Configure the Quickshell bar clock format for Omarchy Quattro.
# Replaces the old install-waybar-config.sh — Waybar is completely gone in Quattro.
# The bar is now a Quickshell widget configured through ~/.config/omarchy/shell.toml.

set -e

SHELL_TOML="$HOME/.config/omarchy/shell.toml"
SHELL_TOML_DIR="$(dirname "$SHELL_TOML")"

echo "Configuring Quattro bar clock format..."

# Ensure the config directory exists
mkdir -p "$SHELL_TOML_DIR"

# Desired clock format: "25 August (Monday)  14:30"
# The shell.toml is live-watched — changes take effect immediately, no restart needed.
CLOCK_FORMAT="%d %B (%A)  %H:%M"

if [ -f "$SHELL_TOML" ]; then
    # Check if a clock_format line already exists
    if grep -q "^clock_format" "$SHELL_TOML"; then
        # Update the existing value
        sed -i "s|^clock_format.*|clock_format = \"$CLOCK_FORMAT\"|" "$SHELL_TOML"
        echo "Updated existing clock_format in $SHELL_TOML"
    else
        # Append the clock format setting
        echo "" >> "$SHELL_TOML"
        echo "# Custom clock format (day month weekday time)" >> "$SHELL_TOML"
        echo "clock_format = \"$CLOCK_FORMAT\"" >> "$SHELL_TOML"
        echo "Added clock_format to $SHELL_TOML"
    fi
else
    # Create a new shell.toml with the clock format
    cat > "$SHELL_TOML" << EOF
# Omarchy Quattro shell configuration
# This file is live-watched — changes take effect immediately.

# Custom clock format (day month weekday time)
clock_format = "$CLOCK_FORMAT"
EOF
    echo "Created $SHELL_TOML with custom clock format"
fi

echo "Bar clock configured: format = \"$CLOCK_FORMAT\""
echo "Tip: You can also right-click the clock widget to toggle between 12h/24h format."
