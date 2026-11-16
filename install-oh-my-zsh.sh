#!/bin/bash

# Automate Oh My Zsh, Powerlevel10k, and Plugins installation
# This script sets up a modern terminal experience entirely non-interactively.
# Configures both Foot terminal (Omarchy default) and Alacritty.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 0. Meslo Nerd Font for Powerlevel10k
if ! pacman -Qi ttf-meslo-nerd-font-powerlevel10k &>/dev/null; then
    echo "Installing required font (Meslo Nerd Font for Powerlevel10k)..."
    yay -S --noconfirm --needed ttf-meslo-nerd-font-powerlevel10k
else
    echo "Meslo Nerd Font is already installed."
fi

# 1. Install Oh My Zsh non-interactively
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
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

# Ensure Powerlevel10k configuration is sourced
if ! grep -q "source ~/.p10k.zsh" "$ZSHRC"; then
    echo "Injecting .p10k.zsh source command into ~/.zshrc..."
    echo "" >> "$ZSHRC"
    echo "# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh." >> "$ZSHRC"
    echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> "$ZSHRC"
fi

# Ensure ~/.local/bin is prepended in ~/.zshrc for custom overrides
if ! grep -q 'PATH="$HOME/.local/bin:$PATH"' "$ZSHRC"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ZSHRC"
fi

# 5. Copy pre-configured Powerlevel10k classic style config (Bypass wizard)
REPO_P10K="$SCRIPT_DIR/3rdparty-assets/.p10k.zsh"
if [ -f "$REPO_P10K" ]; then
    echo "Applying classic Powerlevel10k configuration from repository..."
    cp "$REPO_P10K" "$HOME/.p10k.zsh"
else
    echo "Warning: 3rdparty-assets/.p10k.zsh not found in the repository."
fi

# 6. Configure Foot terminal (Omarchy default) for Zsh and Meslo font
FOOT_CONF="$HOME/.config/foot/foot.ini"
if [ -f "$FOOT_CONF" ]; then
    echo "Configuring Foot terminal..."

    if grep -q "^font=" "$FOOT_CONF"; then
        sed -i 's/^font=.*/font=MesloLGS NF:size=11/' "$FOOT_CONF"
    elif grep -q "^\[main\]" "$FOOT_CONF"; then
        sed -i '/^\[main\]/a font=MesloLGS NF:size=11' "$FOOT_CONF"
    else
        echo "" >> "$FOOT_CONF"
        echo "[main]" >> "$FOOT_CONF"
        echo "font=MesloLGS NF:size=11" >> "$FOOT_CONF"
    fi

    if grep -q "^shell=" "$FOOT_CONF"; then
        sed -i 's|^shell=.*|shell=/usr/bin/zsh|' "$FOOT_CONF"
    elif grep -q "^\[main\]" "$FOOT_CONF"; then
        if ! grep -q "^shell=" "$FOOT_CONF"; then
            sed -i '/^\[main\]/a shell=/usr/bin/zsh' "$FOOT_CONF"
        fi
    fi
    echo "Foot terminal configured with MesloLGS NF font and Zsh."
fi

# 7. Configure Alacritty (secondary terminal)
ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"
if [ -f "$ALACRITTY_CONF" ]; then
    echo "Configuring Alacritty terminal..."
    sed -i 's/family = "CaskaydiaMono Nerd Font"/family = "MesloLGS NF"/g' "$ALACRITTY_CONF"
    sed -i 's/family = "JetBrainsMono Nerd Font"/family = "MesloLGS NF"/g' "$ALACRITTY_CONF"

    if ! grep -q "shell.program" "$ALACRITTY_CONF"; then
        sed -i '/\[terminal\]/a shell.program = "/usr/bin/zsh"' "$ALACRITTY_CONF"
    fi
fi

echo ""
echo "Oh My Zsh and Powerlevel10k setup complete!"
