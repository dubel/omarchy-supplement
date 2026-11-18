#!/bin/bash

# Install GitHub Desktop
# Skip if any variant (github-desktop-bin, github-desktop, github-desktop-git)
# is already installed: they conflict, and --noconfirm declines the removal.
if command -v github-desktop &>/dev/null; then
    echo "GitHub Desktop is already installed ($(pacman -Qqo "$(command -v github-desktop)" 2>/dev/null || echo unknown package)), skipping."
    exit 0
fi

yay -S --noconfirm --needed github-desktop-bin
