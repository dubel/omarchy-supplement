#!/bin/bash

# Install Omarchy Synthwave84 theme for Omarchy 4.x.
# Uses Omarchy's theme management system and ensures custom wallpaper is placed in backgrounds.

set -e

echo "Installing Synthwave84 theme for Omarchy..."

if [ -d "$HOME/.config/omarchy/themes/synthwave84" ]; then
    echo "Synthwave84 theme directory already exists. Applying theme..."
    omarchy theme set synthwave84 2>/dev/null || omarchy-theme-set synthwave84 2>/dev/null || true
else
    echo "Installing theme from GitHub repository..."
    omarchy-theme-install https://github.com/omacom-io/omarchy-synthwave84-theme.git
fi

echo "Synthwave84 theme setup complete!"

# Download custom wallpaper to the user backgrounds directory
WALLPAPER_DIR="$HOME/.config/omarchy/backgrounds/synthwave84"
WALLPAPER_URL="https://dubel.dev/images/milky_way_galaxy_2-wallpaper-2880x1920.jpg"
WALLPAPER_FILE="milky_way_galaxy_2-wallpaper-2880x1920.jpg"

mkdir -p "$WALLPAPER_DIR"

if [ -f "$WALLPAPER_DIR/$WALLPAPER_FILE" ]; then
    echo "Wallpaper already exists: $WALLPAPER_DIR/$WALLPAPER_FILE"
else
    echo "Downloading custom wallpaper..."
    if command -v curl &>/dev/null; then
        curl -fsSL -o "$WALLPAPER_DIR/$WALLPAPER_FILE" "$WALLPAPER_URL"
    elif command -v wget &>/dev/null; then
        wget -q -O "$WALLPAPER_DIR/$WALLPAPER_FILE" "$WALLPAPER_URL"
    fi
    echo "Wallpaper downloaded to: $WALLPAPER_DIR/$WALLPAPER_FILE"
fi

echo ""
echo "Theme setup complete! Use 'omarchy theme switcher' or 'omarchy theme bg-switcher' anytime."
