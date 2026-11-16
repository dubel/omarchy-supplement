# Omarchy Supplement

This repository contains baselining scripts to customize an installation of [Omarchy Linux 4.x (Quattro)](https://omarchy.org/) to suit personal workflow, development, and gaming needs.

**The Major Rule:** All scripts in this repository are written to be **idempotent**. You can safely run them multiple times without breaking the OS or creating duplicate configurations.

## Quick Start (Fresh Install)

Git automatically tracks file execution permissions (`chmod +x`), so you **do not** need to recursively `chmod` the scripts yourself after cloning. Just run the master script:

```bash
# 1. Clone the repository
git clone https://github.com/dubel/omarchy-supplement.git ~/Documents/GitHub/omarchy-supplement

# 2. Enter the directory
cd ~/Documents/GitHub/omarchy-supplement

# 3. Run the master setup script
./install-all.sh
```

## What it does

The `./install-all.sh` script automates setup across the following categories:

### 1. Development Tools
- **Dev Tools & IDEs:** Installs Goland, VS Code, Lazydocker, Lazygit, and Docker Compose.
- **IDE Configurations:** Installs JetBrains keybindings and enforces baseline JSON configurations (Solarized Dark theme + custom 'close all other editors' shortcut on `ctrl+shift+f12`) for both VS Code and Antigravity IDE.
- **Zsh:** Changes default shell to Zsh.
- **Oh My Zsh & P10k:** Installs Oh My Zsh, Powerlevel10k theme (Classic style), Meslo Nerd Font, and essential plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) completely non-interactively for both Foot and Alacritty.
- **Node.js:** Installs Node LTS (v20) using Omarchy's built-in `mise`.
- **Golang:** Installs the latest version of Go using Omarchy's built-in `mise`.
- **PostgreSQL:** Installs, initializes the data directory, enables the service, and creates a default DB/user non-interactively.
- **Tmux:** Restores tmux configurations with TPM and auto-start logic for Zsh.
- **Hyprland Overrides:** Injects custom input configurations and keybinds using the Omarchy 4.x Lua API (`hyprland-overrides.lua`).

### 2. Applications
- **Chromium:** Configures Chromium to allow Google Account sync using Omarchy's OAuth flags.
- **GitHub CLI:** Installs `gh` and configures Git credential helper.
- **Tools:** GitHub Desktop, Signal, Zed, Slack, Microsoft Teams, and Antigravity IDE.

### 3. Web Apps
Installs desktop launchers (accessible via `SUPER + SPACE`) for web applications:
- WhatsApp
- Apple Notes
- iCloud Drive
- Google Calendar

### 4. Gaming
Configures a **Framework 13 (AMD Ryzen AI 7 350 + Radeon 860M)** for gaming:
- **Vulkan & Mesa:** Installation of `mesa-utils` and Vulkan tools.
- **Steam & Proton:** Uses Omarchy's hardware-detecting scripts to install Steam, Heroic, Lutris, and lib32 GPU drivers. Installs ProtonPlus.
- **GameMode:** Configures Feral GameMode (D-Bus activated) and MangoHud.

### 5. Desktop Customization (Omarchy 4.x)
- **Theme:** Downloads a custom milky way wallpaper and applies the Synthwave84 Omarchy theme.
- **Omarchy Shell Bar:** Configures top bar clock format (`d MMMM (dddd)  HH:mm`) via `omarchy bar`.
- **Nightlight:** Configures `hyprsunset` for a fixed schedule (21:00 to 07:00 at 3300K warmth).
- **Screensaver:** Configures infinite Matrix rain via `ttfx` while retaining full Omarchy cursor and dismissal handling.
- **Idle Behavior:** Sets 30-minute lock timeout and boots into stay-awake mode.

## macOS Terminal Replicator

To reproduce the Omarchy terminal feel (Alacritty + Synthwave84 theme, Powerlevel10k, Dracula Tmux top bar, and modern CLI tools) on macOS:

```bash
# Option A: From this cloned repo on macOS
./install-macos-terminal.sh

# Option B: One-liner on a fresh Mac (do NOT run with sudo!)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dubel/omarchy-supplement/main/install-macos-terminal.sh)"
```

## Legacy Scripts

Scripts targeting older Omarchy v3 (e.g. Waybar and `.conf` based setups) are archived in the `legacy/` directory.
