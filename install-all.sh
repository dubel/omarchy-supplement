#!/bin/bash

# Master setup script for Omarchy Supplement
# Targets Omarchy 4.x (Quattro). All scripts are designed to be idempotent.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "         Omarchy Supplement Setup (Omarchy 4.x)          "
echo "=========================================================="
echo ""

# --- 1. Development Tools ---
echo "--- [1/6] Installing development tools ---"
"$SCRIPT_DIR/install-dev-tools.sh"
"$SCRIPT_DIR/install-zsh.sh"
"$SCRIPT_DIR/install-oh-my-zsh.sh"
"$SCRIPT_DIR/install-nodejs.sh"
"$SCRIPT_DIR/install-golang.sh"
"$SCRIPT_DIR/install-postgresql.sh"
"$SCRIPT_DIR/install-tmux.sh"

# --- 2. Hyprland Configuration ---
echo ""
echo "--- [2/6] Configuring Hyprland ---"
"$SCRIPT_DIR/install-hyprland-overrides.sh"

# --- 3. Applications ---
echo ""
echo "--- [3/6] Installing applications ---"
"$SCRIPT_DIR/setup-chromium-google-account.sh"
"$SCRIPT_DIR/setup-github-auth.sh"
"$SCRIPT_DIR/install-github-desktop.sh"
"$SCRIPT_DIR/install-signal.sh"
"$SCRIPT_DIR/install-antigravity.sh"
"$SCRIPT_DIR/install-antigravity-ide.sh"
"$SCRIPT_DIR/install-ide-configs.sh"
"$SCRIPT_DIR/install-zed.sh"
"$SCRIPT_DIR/install-slack.sh"
"$SCRIPT_DIR/install-teams.sh"

# --- 4. Web Apps ---
echo ""
echo "--- [4/6] Installing web apps ---"
"$SCRIPT_DIR/install-webapps.sh"

# --- 5. Gaming Tools ---
echo ""
echo "--- [5/6] Installing gaming tools ---"
"$SCRIPT_DIR/install-gaming-related-tools.sh"

# --- 6. Omarchy Desktop & System Customization ---
echo ""
echo "--- [6/6] Applying Omarchy desktop customizations ---"
"$SCRIPT_DIR/install-synthwave84-theme.sh"
"$SCRIPT_DIR/configure-bar.sh"
"$SCRIPT_DIR/set-shell.sh"
"$SCRIPT_DIR/set-nightlight.sh"
"$SCRIPT_DIR/configure-idle-behavior.sh"
"$SCRIPT_DIR/configure-screensaver.sh"
"$SCRIPT_DIR/set-splash.sh"

echo ""
echo "=========================================================="
echo "    Omarchy Supplement installation complete! 🎉        "
echo "=========================================================="
