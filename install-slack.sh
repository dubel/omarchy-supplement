#!/bin/bash

# Install Slack messaging app
# Skip if slack-desktop or a package providing it (e.g. slack-desktop-wayland)
# is installed: they conflict, and --noconfirm declines the removal.
if pacman -T slack-desktop &>/dev/null; then
    echo "Slack is already installed, skipping."
    exit 0
fi

yay -S --noconfirm --needed slack-desktop
