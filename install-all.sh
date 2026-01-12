#!/bin/bash

# Install all packages in order
./install-zsh.sh
# ./install-asdf.sh
./install-nodejs.sh
# ./install-ruby.sh
# ./install-postgresql.sh
# ./install-ghostty.sh
./install-tmux.sh
./install-stow.sh
./install-dotfiles.sh
./install-hyprland-overrides.sh

# Additional applications
./install-google-chrome.sh
./install-github-desktop.sh
./install-signal.sh
./install-antigravity.sh
./install-zed.sh
./install-slack.sh

# Omarchy theme customization
./install-synthwave84-theme.sh
./set-shell.sh
