# Omarchy Supplement

This repository contains baselining scripts to customize a fresh install of [Omarchy Linux](https://omacom.io/) to suit my personal workflow, development, and gaming needs.

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

The `./install-all.sh` script automates the setup of the following categories:

### 1. Development Tools
- **Dev Tools & IDEs:** Installs Goland, VS Code, Lazydocker, Lazygit, and Docker Compose.
- **IDE Configurations:** Installs JetBrains keybindings and enforces baseline JSON configurations (Solarized Dark theme + custom 'close all other editors' shortcut on `ctrl+shift+f12`) for both VS Code and Antigravity IDE.
- **Zsh:** Changes default shell to Zsh.
- **Node.js:** Installs Node LTS (v20) using Omarchy's built-in `mise`.
- **PostgreSQL:** Installs, initializes the data directory, enables the service, and creates a default DB/user.
- **Tmux:** Restores tmux configurations.
- **Hyprland Overrides:** Injects custom input configurations and keybinds (`hyprland-overrides.conf`).

### 2. Applications
- **Chromium:** Configures Chromium to allow Google Account sync using Omarchy's OAuth flags (interactive).
- **GitHub CLI:** Installs `gh`, performs interactive web login to securely configure Git (replaces `~/.netrc`).
- **Tools:** GitHub Desktop, Signal, Zed, Slack, Microsoft Teams, and Antigravity IDE.

### 3. Web Apps
Installs desktop launchers (accessible via `SUPER + SPACE`) for web applications:
- WhatsApp
- Apple Notes
- iCloud Drive
- Google Calendar

### 4. Gaming
Configures a **Framework 13 (AMD Ryzen AI 7 350 + Radeon 860M)** for gaming:
- **Vulkan & Mesa:** Explicit installation of `mesa-utils` and Vulkan tools.
- **Steam & Proton:** Uses Omarchy's hardware-detecting scripts to install Steam, Heroic, Lutris, and lib32 GPU drivers. Installs ProtonPlus.
- **GameMode:** Configures Feral GameMode (D-Bus activated) and MangoHud.

### 5. Desktop Customization
- **Theme:** Downloads a custom milky way wallpaper and installs the Synthwave84 Omarchy theme.
- **Nightlight:** Configures `sunsetr` for a fixed schedule (21:00 to 07:00 at 5500K warmth).

## Note on Configs (Dotfiles)

Instead of using `stow` and a separate dotfiles repository, this setup relies directly on **Omarchy's built-in configuration management** (`omarchy-refresh-config`). Customizations specific to this machine (like keyboard layouts, scroll speeds) are handled in `hyprland-overrides.conf`.
