# Omarchy Quattro: Agent Knowledge Base

This document serves as a reference for future AI agents working on the `omarchy-supplement` repository when targeting **Omarchy Quattro (v4.0.0)**. Quattro is a major rewrite — many subsystems have been replaced. Agents must understand the new architecture to avoid breaking changes.

---

## 1. Core Rule: Idempotency
All `install-*.sh` and `configure-*.sh` scripts in this repository **must be idempotent**. They should safely execute on a fresh machine or a machine that has run them 100 times, without duplicating configurations or breaking existing states.

## 2. Quattro Architecture Changes (vs. v3.x)

| Subsystem | Old (v3.x) | New (Quattro) |
|-----------|-----------|---------------|
| **Config format** | `hyprland.conf` (`.conf` syntax) | `hyprland.lua` (Lua DSL with `o.*` API) |
| **Status bar** | Waybar (`config.jsonc`) | Quickshell widget (configured via `shell.toml`) |
| **Lock screen** | `hyprlock` | Shell-powered PAM lock (`omarchy-lock`) |
| **Idle management** | `hypridle` + `hypridle.conf` | Quickshell idle plugin (configured via `shell.toml`) |
| **Terminal (default)** | Alacritty | Foot (`foot.ini`) — Alacritty still available |
| **Screensaver** | `terminaltexteffects` | `ttfx` (Rust port) |
| **Nightlight** | `sunsetr` | `hyprsunset` (may coexist with sunsetr) |
| **Autostart** | `autostart.conf` | `autostart.lua` |
| **Theming** | 8-color palette | 24-color palette with auto-generated nvim/vscode/btop themes |
| **Packages** | Scripts in `~/.local/share/omarchy/bin/` | System packages via pacman |

## 3. Omarchy Built-in Scripts & Toggles
Omarchy ships helper scripts prefixed with `omarchy-`. In Quattro, these are installed as **system packages** (not user-local scripts).

**Crucial Lesson:** Before writing custom `sed` logic to modify system configs, always check if an Omarchy helper exists!
- **Idle toggle:** `omarchy-toggle-idle` (replaces `pkill -x hypridle`)
- **Lock screen:** `omarchy-lock` (replaces `hyprlock`)
- **Nightlight:** `omarchy-restart-hyprsunset` / `omarchy-refresh-hyprsunset`
- **Idle debug:** `omarchy-debug-idle` (new diagnostic tool)

## 4. Shell Configuration (`shell.toml`)
Quattro introduces `~/.config/omarchy/shell.toml` as the central configuration file for the Quickshell-based UI. This file is **live-watched** — changes take effect immediately without restarts.

Known keys:
- `clock_format` — bar clock display format
- `idle_timeout` — seconds before idle triggers
- `nightlight_temp` / `nightlight_sunset` / `nightlight_sunrise` — nightlight settings

## 5. Hyprland Lua Configuration
Quattro's Hyprland config uses a Lua DSL:
- `o.input({...})` — input device settings
- `o.bind("MOD", "KEY", o.exec("command"))` — keybindings
- `o.windowrule("match:...", "action")` — window rules
- `o.exec_once("command")` — autostart commands

User overrides can be loaded with `dofile("/path/to/overrides.lua")` appended to `hyprland.lua`.

## 6. Background Tasks & Sudo
Agents run commands in the background without interactive terminals.
- Using `yay` to install AUR packages often prompts for a fingerprint or `sudo` password.
- Since background tasks cannot fulfill fingerprint requests, the agent will hang. Plan the scripts, but instruct the user to run the final script manually in their **Foot** terminal.

## 7. Tmux Persistence & Shell Updates
Tmux is extremely resilient. It spawns a background server that caches the environment state.
- If you update the default shell (e.g., from `bash` to `zsh`), any existing Tmux server will continue launching `bash`.
- When updating Tmux configs, explicitly set `set-option -g default-shell /usr/bin/zsh` and run `tmux kill-server`.

## 8. Terminal Shell Caching
Wayland/systemd environments cache `$SHELL` aggressively. Even after `chsh`, the terminal may still open `bash` until reboot.
- **Foot fix:** Set `shell=/usr/bin/zsh` under `[main]` in `~/.config/foot/foot.ini`
- **Alacritty fix:** Set `shell.program = "/usr/bin/zsh"` under `[terminal]` in `~/.config/alacritty/alacritty.toml`

## 9. Package Managers & Runtime Environments
- **Mise:** Omarchy uses `mise` to manage language environments (Node, Go, etc.). Prefix with `MISE_HTTP_TIMEOUT=300` for large downloads.
- **CLI Tools:** Modern tools (`eza`, `zoxide`, `bat`) are installed by default but **not configured** for the user's shell. If switching to Oh My Zsh, aliases must be injected into `~/.zshrc`.

## 10. Dead References (DO NOT USE)
The following commands and files **no longer exist** in Quattro:
- `waybar`, `omarchy-refresh-waybar`, `omarchy-restart-waybar`, `pkill -SIGUSR2 waybar`
- `hyprlock`, `hypridle`, `hypridle.conf`
- `hyprland.conf` (replaced by `hyprland.lua`)
- `autostart.conf` (replaced by `autostart.lua`)
- `terminaltexteffects` (replaced by `ttfx`)
- `~/.local/share/omarchy/bin/` (scripts now installed as system packages)
