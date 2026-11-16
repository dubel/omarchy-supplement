# Omarchy OS: Agent Knowledge Base

This document serves as a reference for future AI agents working on the `omarchy-supplement` repository. Omarchy is a highly customized, Hyprland-based Arch Linux environment. To ensure stability and avoid conflicts with its built-in automation, agents must adhere to the following behaviors and lessons learned.

---

## 1. Core Rule: Idempotency
All `install-*.sh` scripts in this repository **must be idempotent**. They should safely execute on a fresh machine or a machine that has run them 100 times, without duplicating configurations or breaking existing states.

## 2. Omarchy Built-in Scripts & Toggles
Omarchy ships with a vast array of helper scripts (prefixed with `omarchy-`) located in `~/.local/share/omarchy/bin/`. 
**Crucial Lesson:** Before writing custom `sed` logic to modify system configs or restart services, always check if an Omarchy helper exists!
- Example: Disabling the Idle Lock. Instead of hacking `~/.config/hypr/hypridle.conf`, simply run `omarchy-toggle-idle`. This ensures the daemon is killed correctly and the Waybar UI is instantly updated via signals.

## 3. Waybar Customizations
Omarchy aggressively manages the Waybar configuration.
- Running `omarchy-refresh-waybar` will **overwrite** any local changes by pulling down the master configuration from Omarchy's upstream repository.
- If you write a script to surgically edit `~/.config/waybar/config.jsonc` (e.g., via Python JSON manipulation), **do not** use `refresh-waybar`. Instead, use `omarchy-restart-waybar` to cleanly restart the service and preserve local edits.

## 4. Background Tasks & Sudo 
Agents run commands in the background without interactive terminals. 
- Using `yay` to install AUR packages (e.g., `ttf-meslo-nerd-font-powerlevel10k`) often prompts for a fingerprint or `sudo` password. 
- Since background tasks cannot fulfill fingerprint requests, the agent will hang. Plan the scripts, test what you can, but gracefully instruct the user to run the final script manually in their Alacritty terminal.

## 5. Tmux Persistence & Shell Updates
Tmux is extremely resilient. It spawns a background server that caches the environment state.
- If you update the default shell (e.g., from `bash` to `zsh`), any existing Tmux server will continue launching `bash` because of its cached state. 
- When updating Tmux configs (`~/.tmux.conf`), explicitly set `set-option -g default-shell /usr/bin/zsh` and remember to run `tmux kill-server` so it boots fresh on the next terminal launch.

## 6. Alacritty Shell Caching
Wayland/systemd environments often cache `$SHELL` aggressively. Even if you use `chsh -s $(which zsh)`, Alacritty might still open `bash` until a full system reboot.
- **Fix:** Bypass the environment cache by explicitly defining the shell in `~/.config/alacritty/alacritty.toml` under the `[terminal]` block using `shell.program = "/usr/bin/zsh"`.

## 7. Package Managers & Runtime Environments
- **Mise:** Omarchy uses `mise` to manage language environments (Node, Go, etc.). When installing packages via `mise` in scripts, always prefix with `MISE_HTTP_TIMEOUT=300` because default timeouts are too short and often fail during large AUR downloads.
- **CLI Tools:** Modern tools (`eza`, `zoxide`, `bat`) are installed by default on the OS but **not configured** for the user's shell. If switching to Oh My Zsh, aliases and shell integrations for these tools must be injected manually into `~/.zshrc`.
