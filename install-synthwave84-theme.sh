#!/bin/bash


# Download custom wallpaper
WALLPAPER_DIR="$HOME/.config/omarchy/themes/synthwave84/backgrounds"
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

# Install Omarchy Synthwave84 theme
echo "Installing Synthwave84 theme for Omarchy..."
omarchy-theme-install https://github.com/omacom-io/omarchy-synthwave84-theme.git

echo "Synthwave84 theme installation complete!"

