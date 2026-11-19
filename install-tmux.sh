#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install tmux if not present
if ! command -v tmux &>/dev/null; then
    echo "Installing tmux..."
    yay -S --noconfirm --needed tmux
else
    echo "tmux is already installed."
fi

TPM_DIR="$HOME/.tmux/plugins/tpm"

# Check if TPM is already installed
if [ -d "$TPM_DIR" ]; then
    echo "TPM is already installed in $TPM_DIR"
else
    echo "Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

echo "Applying baseline Tmux configuration..."
cp "$SCRIPT_DIR/configs/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Terminal window title = program running in the active pane ("claude", "nvim",
# "zsh"), so the bar's App name widget can show e.g. "Foot: Claude".
# Omarchy's ~/.config/tmux/tmux.conf is read after ~/.tmux.conf and sets its own
# set-titles-string ('#h:#W'), so the override is appended there.
OMARCHY_TMUX_CONF="$HOME/.config/tmux/tmux.conf"
TITLE_LINE="set -g set-titles-string '#{pane_current_command}'"
if [ -f "$OMARCHY_TMUX_CONF" ]; then
    if ! grep -qxF "$TITLE_LINE" "$OMARCHY_TMUX_CONF"; then
        printf '\n# omarchy-supplement: window title = running program (for the bar App name widget)\n%s\n' "$TITLE_LINE" >> "$OMARCHY_TMUX_CONF"
        echo "Tmux window title set to the running program."
    else
        echo "Tmux window title already set to the running program."
    fi
fi

echo "Installing Tmux plugins..."
# Run TPM's headless install script to download resurrect, continuum, etc.
"$TPM_DIR/bin/install_plugins" || true

# Safe Auto-Start Logic for Zsh
ZSHRC="$HOME/.zshrc"
echo "Injecting safe Tmux auto-start logic into $ZSHRC..."

# This snippet ensures tmux only auto-starts if we are NOT already in tmux,
# AND we are in an interactive shell, AND we are not inside VS Code.
AUTOSTART_SNIPPET='
# Auto-start Tmux
if [[ -z "$TMUX" ]] && [[ -n "$PS1" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
    # Try to attach to "main", if it fails, create "main"
    tmux attach-session -t main || tmux new-session -s main
    # Exit the shell when exiting tmux so you don'\''t have to type exit twice
    exit
fi
'

if [ -f "$ZSHRC" ]; then
    if ! grep -q "Auto-start Tmux" "$ZSHRC"; then
        echo "$AUTOSTART_SNIPPET" >> "$ZSHRC"
        echo "Auto-start logic injected."
    else
        echo "Auto-start logic already exists in $ZSHRC."
    fi
fi

echo "Tmux setup complete!"
