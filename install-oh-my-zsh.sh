#!/bin/bash

# Automate Oh My Zsh, Powerlevel10k, and Plugins installation
# This script sets up a modern terminal experience entirely non-interactively.

set -e

echo "Installing required font (Meslo Nerd Font for Powerlevel10k)..."
yay -S --noconfirm --needed ttf-meslo-nerd-font-powerlevel10k

# 1. Install Oh My Zsh non-interactively
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    # The --unattended flag prevents the installer from automatically dropping into a new shell
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# 2. Clone Powerlevel10k Theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "Cloning Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo "Powerlevel10k theme is already installed."
fi

# 3. Clone Plugins
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Cloning zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "zsh-autosuggestions plugin is already installed."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Cloning zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting plugin is already installed."
fi

# 4. Configure ~/.zshrc
ZSHRC="$HOME/.zshrc"
echo "Configuring ~/.zshrc..."

# Backup .zshrc before modifying
cp "$ZSHRC" "${ZSHRC}.backup_pre_p10k"

# Update ZSH_THEME
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"

# Update plugins list
sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)/' "$ZSHRC"

# Ensure Powerlevel10k configuration is sourced at the top or bottom
# According to P10k, it's highly recommended to put this at the very top of .zshrc
if ! grep -q "source ~/.p10k.zsh" "$ZSHRC"; then
    echo "Injecting .p10k.zsh source command into ~/.zshrc..."
    # Add it to the end of the file to guarantee it loads
    echo "" >> "$ZSHRC"
    echo "# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh." >> "$ZSHRC"
    echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> "$ZSHRC"
fi

# 5. Copy pre-configured Powerlevel10k classic style config (Bypass wizard)
REPO_P10K="$(pwd)/3rdparty-assets/.p10k.zsh"
if [ -f "$REPO_P10K" ]; then
    echo "Applying classic Powerlevel10k configuration from repository..."
    cp "$REPO_P10K" "$HOME/.p10k.zsh"
else
    echo "Warning: 3rdparty-assets/.p10k.zsh not found in the repository."
fi

# 6. Configure Alacritty explicitly for Zsh and Meslo font
ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"
if [ -f "$ALACRITTY_CONF" ]; then
    echo "Configuring Alacritty terminal..."
    # Update fonts
    sed -i 's/family = "CaskaydiaMono Nerd Font"/family = "MesloLGS NF"/g' "$ALACRITTY_CONF"
    
    # Ensure Zsh is the default shell
    if ! grep -q "shell.program" "$ALACRITTY_CONF"; then
        sed -i '/\[terminal\]/a shell.program = "/usr/bin/zsh"' "$ALACRITTY_CONF"
    fi
fi

echo "Oh My Zsh and Powerlevel10k setup complete!"
echo "Note: The changes will take effect when you open a new terminal session."
