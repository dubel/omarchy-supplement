#!/bin/bash

set -e

# Install tmux
yay -S --noconfirm --needed tmux

# Check if tmux is installed
if ! command -v tmux &>/dev/null; then
  echo "tmux installation failed."
  exit 1
fi

TPM_DIR="$HOME/.tmux/plugins/tpm"

# Check if TPM is already installed
if [ -d "$TPM_DIR" ]; then
  echo "TPM is already installed in $TPM_DIR"
else
  echo "Installing Tmux Plugin Manager (TPM)..."
  git clone https://github.com/tmux-plugins/tpm $TPM_DIR
fi

echo "TPM installed successfully!"

echo "Applying baseline Tmux configuration..."
cp "$(pwd)/configs/tmux/.tmux.conf" "$HOME/.tmux.conf"

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

if ! grep -q "Auto-start Tmux" "$ZSHRC"; then
    echo "$AUTOSTART_SNIPPET" >> "$ZSHRC"
    echo "Auto-start logic injected."
else
    echo "Auto-start logic already exists in $ZSHRC."
fi

echo "Tmux setup complete!"