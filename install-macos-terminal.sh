#!/usr/bin/env bash

# ==============================================================================
# Omarchy Terminal Experience for macOS
# Replicates Alacritty (Synthwave84), Tmux (Dracula Top Bar), and Oh My Zsh
# (Powerlevel10k + plugins) as configured in Omarchy.
# ==============================================================================

set -e

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 1. OS & User Check
if [[ "$(uname -s)" != "Darwin" ]]; then
    error "This script is intended exclusively for macOS."
fi

if [[ $EUID -eq 0 ]]; then
    error "Please do NOT run this script with sudo. Run it as your regular user: bash -c \"\$(curl -fsSL ...)\""
fi

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}   Omarchy Terminal Environment Installer for macOS ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo ""

# 2. Check / Install Homebrew
if ! command -v brew &>/dev/null; then
    info "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configure brew in PATH for Apple Silicon or Intel
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    info "Homebrew is already installed."
fi

# Ensure brew is in current session
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. Install Core CLI Packages
info "Installing Tmux and modern CLI tools..."
brew install tmux git curl eza bat zoxide fzf dockutil

# 3b. Install Alacritty via Official GitHub Release DMG
# Note: Homebrew disabled the 'alacritty' cask due to Gatekeeper notarization rules.
# We download the official DMG directly and strip quarantine flags so it opens cleanly.
if [[ ! -d "/Applications/Alacritty.app" ]]; then
    info "Installing Alacritty directly from official GitHub release..."
    DMG_URL=$(curl -s https://api.github.com/repos/alacritty/alacritty/releases/latest | grep -o 'https://[^"]*Alacritty-[^"]*\.dmg' | head -n 1)
    if [[ -z "$DMG_URL" ]]; then
        DMG_URL="https://github.com/alacritty/alacritty/releases/download/v0.17.0/Alacritty-v0.17.0.dmg"
    fi
    TMP_DMG="/tmp/Alacritty.dmg"
    MOUNT_DIR="/tmp/Alacritty_Mount"

    echo "  -> Downloading $DMG_URL..."
    curl -fLo "$TMP_DMG" "$DMG_URL"
    mkdir -p "$MOUNT_DIR"
    hdiutil attach -nobrowse -mountpoint "$MOUNT_DIR" "$TMP_DMG"
    cp -R "$MOUNT_DIR/Alacritty.app" /Applications/
    hdiutil detach "$MOUNT_DIR" 2>/dev/null || hdiutil detach -force "$MOUNT_DIR" || true
    rm -f "$TMP_DMG"
    rmdir "$MOUNT_DIR" 2>/dev/null || true

    # Strip quarantine attribute to allow flawless launch without Gatekeeper blocking
    xattr -cr /Applications/Alacritty.app 2>/dev/null || true
    success "Alacritty.app installed to /Applications/Alacritty.app."
else
    info "Alacritty.app is already present in /Applications/."
fi

# 4. Install MesloLGS NF Fonts (Required by Powerlevel10k)
info "Installing MesloLGS NF fonts for Powerlevel10k into ~/Library/Fonts/..."
FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"

FONTS=(
    "MesloLGS NF Regular.ttf|https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
    "MesloLGS NF Bold.ttf|https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
    "MesloLGS NF Italic.ttf|https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
    "MesloLGS NF Bold Italic.ttf|https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
)

for item in "${FONTS[@]}"; do
    FILE_NAME="${item%%|*}"
    URL="${item##*|}"
    if [[ ! -f "$FONT_DIR/$FILE_NAME" ]]; then
        echo "  -> Downloading $FILE_NAME..."
        curl -fLo "$FONT_DIR/$FILE_NAME" "$URL"
    fi
done
success "MesloLGS NF fonts ready."

# 5. Install Oh My Zsh (non-interactively)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    info "Oh My Zsh is already installed."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# 6. Install Powerlevel10k Theme
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    info "Cloning Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    info "Powerlevel10k already present."
fi

# 7. Install Zsh Plugins
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    info "Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    info "Cloning zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 8. Copy or Download .p10k.zsh configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_P10K="$SCRIPT_DIR/3rdparty-assets/.p10k.zsh"
TARGET_P10K="$HOME/.p10k.zsh"

if [[ -f "$LOCAL_P10K" ]]; then
    info "Copying local Omarchy .p10k.zsh..."
    cp "$LOCAL_P10K" "$TARGET_P10K"
else
    info "Fetching Omarchy .p10k.zsh from repository..."
    curl -fsSL "https://raw.githubusercontent.com/dubel/omarchy-supplement/main/3rdparty-assets/.p10k.zsh" -o "$TARGET_P10K"
fi

# 9. Configure ~/.zshrc
ZSHRC="$HOME/.zshrc"
info "Configuring $ZSHRC..."

# Back up existing .zshrc
if [[ -f "$ZSHRC" ]] && [[ ! -f "${ZSHRC}.backup_omarchy" ]]; then
    cp "$ZSHRC" "${ZSHRC}.backup_omarchy"
fi

# Use perl for clean in-place regex without BSD vs GNU sed discrepancies
perl -i -pe 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
perl -i -pe 's/^plugins=\(.*\)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)/' "$ZSHRC"

# Add Homebrew shellenv if not already present
BREW_INIT='
# Homebrew path initialization
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi'

if ! grep -q "Homebrew path initialization" "$ZSHRC"; then
    echo "$BREW_INIT" >> "$ZSHRC"
fi

# Source .p10k.zsh
if ! grep -q "source ~/.p10k.zsh" "$ZSHRC"; then
    cat << 'EOF' >> "$ZSHRC"

# Powerlevel10k Configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
fi

# Modern CLI tools aliases (eza, bat, zoxide)
CLI_ALIASES='
# Omarchy CLI Aliases & Integrations
if command -v eza &>/dev/null; then
    alias ls="eza --icons"
    alias ll="eza -la --icons"
fi
if command -v bat &>/dev/null; then
    alias cat="bat --paging=never"
fi
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi
'

if ! grep -q "Omarchy CLI Aliases" "$ZSHRC"; then
    echo "$CLI_ALIASES" >> "$ZSHRC"
fi

# ~/.local/bin on PATH (Claude Code native installer and other user-level CLIs live there).
# Without it `claude` is not found in Alacritty / tmux once this script rewrites .zshrc.
LOCAL_BIN_PATH='
# User-level binaries (Claude Code native installer -> ~/.local/bin)
export PATH="$HOME/.local/bin:$PATH"
'

if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$ZSHRC"; then
    echo "$LOCAL_BIN_PATH" >> "$ZSHRC"
fi

# Safe Auto-start Tmux
AUTOSTART_SNIPPET='
# Auto-start Tmux (Omarchy style)
if [[ -z "$TMUX" ]] && [[ -n "$PS1" ]] && [[ "$TERM_PROGRAM" != "vscode" ]] && [[ "$TERM_PROGRAM" != "Apple_Terminal" ]]; then
    # Try to attach to "main", if it fails, create "main"
    tmux attach-session -t main 2>/dev/null || tmux new-session -s main
    exit
fi
'

if ! grep -q "Auto-start Tmux (Omarchy style)" "$ZSHRC"; then
    echo "$AUTOSTART_SNIPPET" >> "$ZSHRC"
fi

# 10. Configure Tmux (~/.tmux.conf)
info "Configuring Tmux..."
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
    info "Cloning Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Detect current zsh path on macOS
CURRENT_ZSH="$(which zsh 2>/dev/null || echo "/bin/zsh")"

cat << EOF > "$HOME/.tmux.conf"
# Tmux Baseline Configuration (Omarchy feeling on macOS)

# 1. Base settings
set-option -g default-shell "$CURRENT_ZSH"
set -g mouse on               # Enable mouse support
set -g base-index 1           # Start windows and panes at 1, not 0
setw -g pane-base-index 1
set -g renumber-windows on    # Renumber windows when one is closed

# Modern colors
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

# Prefix: Ctrl+Space (like Omarchy), Ctrl+b kept as a fallback
# Note: if macOS uses Ctrl+Space to switch input sources, disable that in
# System Settings > Keyboard > Keyboard Shortcuts > Input Sources.
set -g prefix C-Space
set -g prefix2 C-b
bind C-Space send-prefix

# Alt+1..9 -> switch to window N (like Omarchy, no prefix needed)
bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3
bind -n M-4 select-window -t 4
bind -n M-5 select-window -t 5
bind -n M-6 select-window -t 6
bind -n M-7 select-window -t 7
bind -n M-8 select-window -t 8
bind -n M-9 select-window -t 9

# Splits: prefix + | (side by side), prefix + - (stacked), open in current dir
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# 2. Tmux Plugin Manager (TPM)
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Persistence Plugins
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Continuum settings
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'

# Theme / Aesthetics (Dracula on top)
set -g @plugin 'dracula/tmux'
set -g @dracula-show-powerline true
set -g @dracula-plugins "cpu-usage ram-usage time"
set -g @dracula-show-flags true
set -g @dracula-show-left-icon session
set -g status-position top

# Initialize TMUX plugin manager
run '~/.tmux/plugins/tpm/tpm'
EOF

# Install Tmux plugins headlessly
info "Installing Tmux plugins via TPM..."
"$TPM_DIR/bin/install_plugins" || true

# 11. Configure Alacritty with Synthwave84 Theme
info "Configuring Alacritty terminal with Synthwave84 theme..."
ALACRITTY_DIR="$HOME/.config/alacritty"
mkdir -p "$ALACRITTY_DIR"

cat << EOF > "$ALACRITTY_DIR/alacritty.toml"
# Alacritty Configuration - Omarchy Synthwave84 Theme (macOS)

[env]
TERM = "xterm-256color"

[font]
normal = { family = "MesloLGS NF", style = "Regular" }
bold = { family = "MesloLGS NF", style = "Bold" }
italic = { family = "MesloLGS NF", style = "Italic" }
size = 14

[window]
padding.x = 14
padding.y = 14
decorations = "Full"
opacity = 0.95
blur = true
# Left Option = Alt (for tmux Alt+1..9); right Option still types Polish letters
option_as_alt = "OnlyLeft"

[terminal]
shell.program = "$CURRENT_ZSH"
osc52 = "CopyPaste"

# Synthwave84 Color Palette (Omarchy exact match)
[colors.primary]
background = "#240037"
foreground = "#ffffff"

[colors.cursor]
text = "#240037"
cursor = "#ffffff"

[colors.vi_mode_cursor]
text = "#240037"
cursor = "#ffffff"

[colors.search.matches]
foreground = "#240037"
background = "#f3e70f"

[colors.search.focused_match]
foreground = "#240037"
background = "#ff0040"

[colors.footer_bar]
foreground = "#240037"
background = "#ffffff"

[colors.selection]
text = "#ffffff"
background = "#ffffff"

[colors.normal]
black = "#240037"
red = "#ff0040"
green = "#8f00ff"
yellow = "#f3e70f"
blue = "#0080ff"
magenta = "#ff00ff"
cyan = "#03edf9"
white = "#ffffff"

[colors.bright]
black = "#614d85"
red = "#fe5442"
green = "#fe5442"
yellow = "#ffff66"
blue = "#0080ff"
magenta = "#ff7edb"
cyan = "#03edf9"
white = "#ffffff"
EOF

success "Alacritty configuration saved to $ALACRITTY_DIR/alacritty.toml."

# 12. Also configure Ghostty (if installed or used in the future)
GHOSTTY_DIR="$HOME/.config/ghostty"
mkdir -p "$GHOSTTY_DIR"
cat << EOF > "$GHOSTTY_DIR/config"
# Ghostty Configuration - Omarchy Synthwave84 Theme (macOS)
font-family = "MesloLGS NF"
font-size = 14
window-padding-x = 14
window-padding-y = 14
background = #240037
foreground = #ffffff
cursor-color = #ffffff
cursor-text = #240037
palette = 0=#240037
palette = 1=#ff0040
palette = 2=#8f00ff
palette = 3=#f3e70f
palette = 4=#0080ff
palette = 5=#ff00ff
palette = 6=#03edf9
palette = 7=#ffffff
palette = 8=#614d85
palette = 9=#fe5442
palette = 10=#fe5442
palette = 11=#ffff66
palette = 12=#0080ff
palette = 13=#ff7edb
palette = 14=#03edf9
palette = 15=#ffffff
EOF
success "Ghostty configuration saved to $GHOSTTY_DIR/config."

# 13. Pin Alacritty to the Dock (macOS has no "default terminal" setting,
# so keeping it in the Dock is the practical equivalent)
if defaults read com.apple.dock persistent-apps 2>/dev/null | grep -q 'Alacritty.app'; then
    info "Alacritty is already pinned to the Dock."
elif command -v dockutil &>/dev/null; then
    info "Pinning Alacritty to the Dock..."
    dockutil --add /Applications/Alacritty.app --section apps || warn "Could not pin Alacritty to the Dock."
else
    warn "dockutil not found, skipping Dock pinning."
fi

echo ""
echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}             Installation Completed!                ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo ""
echo "To experience the Omarchy terminal on macOS:"
echo " 1. Launch 'Alacritty' from Spotlight (Cmd + Space) or Applications."
echo " 2. Tmux will automatically start with the Dracula status bar at the top."
echo " 3. Powerlevel10k prompt and autosuggestions / syntax-highlighting are active."
echo ""
echo "Tmux shortcuts (prefix = Ctrl+Space, Ctrl+b also works):"
echo "  Left Option + 1..9   switch to window N"
echo "  prefix, c            new window"
echo "  prefix, | / -        split side by side / stacked"
echo "  prefix, z            zoom pane;  prefix, & / x   close window / pane"
echo "  prefix, I            install/update tmux plugins"
