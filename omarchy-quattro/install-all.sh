#!/bin/bash

# Master install script for Omarchy Quattro supplement.
# Runs all configuration scripts in the correct order.
#
# Scripts in the parent directory (../install-*.sh) are unchanged and safe for Quattro.
# Scripts in this directory (./configure-*.sh, ./install-*.sh) are Quattro-specific rewrites.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Omarchy Quattro Supplement Installer ==="
echo ""

# --- Development tools (unchanged, from parent directory) ---
echo "--- Installing development tools ---"
"$PARENT_DIR/install-dev-tools.sh"
"$PARENT_DIR/install-zsh.sh"
"$SCRIPT_DIR/install-oh-my-zsh.sh"        # Quattro version (adds Foot config)
"$PARENT_DIR/install-nodejs.sh"
"$PARENT_DIR/install-golang.sh"
"$PARENT_DIR/install-postgresql.sh"
"$PARENT_DIR/install-tmux.sh"

# --- Hyprland overrides (Quattro Lua version) ---
echo ""
echo "--- Configuring Hyprland ---"
"$SCRIPT_DIR/install-hyprland-overrides.sh"

# --- Additional applications (unchanged, from parent directory) ---
echo ""
echo "--- Installing applications ---"
"$PARENT_DIR/setup-chromium-google-account.sh"
"$PARENT_DIR/setup-github-auth.sh"
"$PARENT_DIR/install-github-desktop.sh"
"$PARENT_DIR/install-signal.sh"
"$PARENT_DIR/install-antigravity.sh"
"$PARENT_DIR/install-antigravity-ide.sh"
"$PARENT_DIR/install-ide-configs.sh"
"$PARENT_DIR/install-zed.sh"
"$PARENT_DIR/install-slack.sh"
"$PARENT_DIR/install-teams.sh"

# --- Web apps (unchanged, from parent directory) ---
echo ""
echo "--- Installing web apps ---"
"$PARENT_DIR/install-webapps.sh"

# --- Gaming (unchanged, from parent directory) ---
echo ""
echo "--- Installing gaming tools ---"
"$PARENT_DIR/install-gaming-related-tools.sh"

# --- Omarchy customization (Quattro versions) ---
echo ""
echo "--- Applying Omarchy Quattro customizations ---"
"$SCRIPT_DIR/install-synthwave84-theme.sh"
"$SCRIPT_DIR/configure-bar.sh"             # Replaces install-waybar-config.sh
"$PARENT_DIR/set-shell.sh"
"$SCRIPT_DIR/set-nightlight.sh"            # Quattro version (hyprsunset support)
"$SCRIPT_DIR/configure-idle-behavior.sh"   # Quattro version (Quickshell idle)
"$SCRIPT_DIR/configure-screensaver.sh"     # Quattro version (ttfx)
"$PARENT_DIR/set-splash.sh"

echo ""
echo "=== Omarchy Quattro Supplement installation complete! ==="
