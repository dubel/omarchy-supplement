#!/bin/bash

# Install Omarchy Synthwave84 theme for Quattro.
# omarchy-theme-install still exists in Quattro but the theming system has expanded
# from 8 to 24 colors, with auto-generation of nvim/vscode/btop themes.
#
# NOTE: If the Synthwave84 theme repo doesn't provide the expanded 24-color palette,
# Omarchy will auto-generate the missing colors from the base colorset.

echo "Installing Synthwave84 theme for Omarchy Quattro..."
omarchy-theme-install https://github.com/omacom-io/omarchy-synthwave84-theme.git

echo "Synthwave84 theme installation complete!"

# Download custom wallpaper to the user backgrounds directory
WALLPAPER_DIR="$HOME/.config/omarchy/backgrounds/synthwave84"
WALLPAPER_URL="https://dubel.dev/images/milky_way_galaxy_2-wallpaper-2880x1920.jpg"
WALLPAPER_FILE="milky_way_galaxy_2-wallpaper-2880x1920.jpg"

# Ensure the backgrounds directory exists
mkdir -p "$WALLPAPER_DIR"

# Download the wallpaper if not already present
if [ -f "$WALLPAPER_DIR/$WALLPAPER_FILE" ]; then
    echo "Wallpaper already exists, skipping download."
else
    echo "Downloading custom wallpaper..."
    if command -v curl &>/dev/null; then
        curl -L -o "$WALLPAPER_DIR/$WALLPAPER_FILE" "$WALLPAPER_URL"
    elif command -v wget &>/dev/null; then
        wget -O "$WALLPAPER_DIR/$WALLPAPER_FILE" "$WALLPAPER_URL"
    else
        echo "Error: Neither curl nor wget is available."
        exit 1
    fi
    echo "Wallpaper downloaded to: $WALLPAPER_DIR/$WALLPAPER_FILE"
fi

echo ""
echo "Theme setup complete! Use the visual background switcher to select your wallpaper."
