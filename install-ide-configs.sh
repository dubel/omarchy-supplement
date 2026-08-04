#!/bin/bash

# Install IDE Extensions and Apply Baseline Configurations

echo "Installing IDE Extensions and Configurations..."

# 1. Install JetBrains keybindings extension
# The extension ID is k--kato.intellij-idea-keybindings
echo "Installing JetBrains keybindings for VS Code and Antigravity IDE..."
for cmd in code antigravity-ide; do
    if command -v "$cmd" &>/dev/null; then
        "$cmd" --install-extension k--kato.intellij-idea-keybindings --force
    fi
done

# 2. Copy baseline configuration files
# This copies the JSON files tracked in this git repo (configs/IDE/User/)
# to the respective IDE config directories, overwriting them to enforce the baseline.

REPO_CONFIG_DIR="$(pwd)/configs/IDE/User"

apply_configs() {
    local target_dir="$1"
    
    echo "Applying configs to $target_dir..."
    mkdir -p "$target_dir"
    
    cp "$REPO_CONFIG_DIR/settings.json" "$target_dir/settings.json"
    cp "$REPO_CONFIG_DIR/keybindings.json" "$target_dir/keybindings.json"
}

# Apply to VS Code
apply_configs "$HOME/.config/Code/User"

# Apply to Antigravity IDE (and fallback Antigravity dir just in case)
apply_configs "$HOME/.config/Antigravity/User"
apply_configs "$HOME/.config/Antigravity IDE/User"

echo "IDE configuration complete!"
