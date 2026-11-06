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
- **Oh My Zsh & P10k:** Installs Oh My Zsh, Powerlevel10k theme (Classic style), Meslo Nerd Font, and essential plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) completely non-interactively.
- **Node.js:** Installs Node LTS (v20) using Omarchy's built-in `mise`.
- **Golang:** Installs the latest version of Go using Omarchy's built-in `mise`.
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
- **Waybar:** Restores customized upper ribbon (Waybar) configurations (e.g., custom date/time format).
- **Nightlight:** Configures `sunsetr` for a fixed schedule (21:00 to 07:00 at 5500K warmth).

## macOS Terminal Replicator

To reproduce the Omarchy terminal feel (Alacritty + Synthwave84 theme, Powerlevel10k, Dracula Tmux top bar, and modern CLI tools) on macOS:

```bash
# Option A: From this cloned repo on macOS
./install-macos-terminal.sh

# Option B: One-liner on a fresh Mac (do NOT run with sudo!)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dubel/omarchy-supplement/main/install-macos-terminal.sh)"
```

Besides the theme, the installer also adds `~/.local/bin` to `PATH` (so the Claude Code native install is found), pins Alacritty to the Dock, and gives Alacritty a standard macOS title bar. The script is safe to re-run, but it overwrites `~/.tmux.conf`, `~/.config/alacritty/alacritty.toml` and the Ghostty config, so put any custom changes into the script.

### Tmux shortcuts

The prefix is **`Ctrl+Space`** (like Omarchy); `Ctrl+b` works as a fallback. Press the prefix, release it, then press the key.

| Action | Shortcut |
|---|---|
| Switch to window 1..9 | **Left `Option` + `1`..`9`** (no prefix) or prefix, `1`..`9` |
| New window (opens in the current directory) | prefix, `c` |
| Next / previous window | prefix, `n` / `p` |
| Split side by side | prefix, `\|` (default `%` also works) |
| Split stacked (top / bottom) | prefix, `-` (default `"` also works) |
| Move between panes | prefix, arrow keys, or click with the mouse |
| Resize pane | prefix, `Ctrl` + arrow keys, or drag the border with the mouse |
| Zoom pane in / out | prefix, `z` |
| Close pane / window | `exit` or `Ctrl+d`; prefix, `x` (pane) or `&` (window) |
| New named session | prefix, `:`, then `new -s <name>` |
| List and switch sessions / windows | prefix, `s` / `w` |
| Detach (session keeps running) | prefix, `d` |
| Install / update tmux plugins | prefix, `I` |

Notes:
- Opening Alacritty attaches to the `main` tmux session. Exiting or detaching tmux closes the Alacritty window.
- Only the **left** `Option` key acts as Alt in Alacritty. Use the **right** `Option` key to type Polish characters (ą, ę, ś, ...).
- If `Ctrl+Space` does nothing, macOS is probably using it to switch input sources. Disable that in **System Settings → Keyboard → Keyboard Shortcuts → Input Sources**.

### Alacritty window shortcuts

| Action | Shortcut |
|---|---|
| Toggle full screen | `Cmd+Ctrl+F` |
| Fill the screen (macOS window tiling) | `Fn+Ctrl+F` |
| Left / right half of the screen | `Fn+Ctrl+←` / `Fn+Ctrl+→` |
| Restore previous size | `Fn+Ctrl+R` |

## Note on Configs (Dotfiles)

Instead of using `stow` and a separate dotfiles repository, this setup relies directly on **Omarchy's built-in configuration management** (`omarchy-refresh-config`). Customizations specific to this machine (like keyboard layouts, scroll speeds) are handled in `hyprland-overrides.conf`.

