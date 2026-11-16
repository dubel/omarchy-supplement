# Omarchy Supplement → Quattro Migration Plan

This plan assesses every file in the `omarchy-supplement` project against the Omarchy Quattro (v4.0.0) release notes and the new repo structure, then proposes concrete migration steps. Deliverables go into `omarchy-quattro/`.

## Impact Summary

| Impact | Count | Files |
|--------|-------|-------|
| 🔴 **BROKEN — must rewrite** | 5 | `hyprland-overrides.conf`, `install-hyprland-overrides.sh`, `install-waybar-config.sh`, `configure-idle-behavior.sh`, `configure-screensaver.sh` |
| 🟡 **NEEDS UPDATE — still works but uses deprecated patterns** | 5 | `install-oh-my-zsh.sh`, `install-all.sh`, `omarchy-behaviour.md`, `set-nightlight.sh`, `install-synthwave84-theme.sh` |
| 🟢 **SAFE — no changes needed** | 16 | All others (dev tools, gaming, postgresql, golang, nodejs, tmux, webapps, IDE configs, signal, slack, teams, zed, antigravity, set-shell, set-splash, setup-github-auth, setup-chromium-google-account) |

---

## 🔴 BROKEN — Must Rewrite (5 files)

### 1. Hyprland Configuration (2 files)

> [!CAUTION]
> Quattro converts **all Hyprland configs from `.conf` to Lua** (`.lua`). The old `hyprland.conf` with `source = ...` no longer works. The new config lives at `~/.config/hypr/hyprland.lua` and uses a Lua API (`o.bind(...)`, `o.input({...})` etc.).

#### [hyprland-overrides.conf](file:///home/mike/Documents/GitHub/omarchy-supplement/hyprland-overrides.conf)
- **Problem**: `.conf` syntax is dead. Binds like `bind = SUPER, L, exec, hyprlock` and `input { ... }` blocks are invalid in Quattro's Lua config.
- **Additional**: `hyprlock` is gone — replaced by a shell-powered lock screen. The `$terminal = uwsm app -- alacritty` is outdated — Foot is the new default terminal.
- **Migration**: Rewrite as `hyprland-overrides.lua` using the new Lua DSL.

#### [install-hyprland-overrides.sh](file:///home/mike/Documents/GitHub/omarchy-supplement/install-hyprland-overrides.sh)
- **Problem**: Looks for `~/.config/hypr/hyprland.conf` and appends a `source = ...` line. The file is now `hyprland.lua` and sourcing works differently in Lua.
- **Migration**: Rewrite to inject a `dofile(...)` call into `hyprland.lua`, or use Quattro's extension mechanism if available.

---

### 2. Waybar Config (1 file)

> [!CAUTION]
> Waybar is **completely gone** in Quattro. The entire bar is now a Quickshell widget. There is no `waybar/config.jsonc`, no `omarchy-refresh-waybar`, no `omarchy-restart-waybar`, no `pkill -SIGUSR2 waybar`.

#### [install-waybar-config.sh](file:///home/mike/Documents/GitHub/omarchy-supplement/install-waybar-config.sh)
- **Problem**: Every line references Waybar — the config path, refresh commands, restart commands, crash detection. All dead.
- **Migration**: The clock format is now a bar widget. Customization goes through `~/.config/omarchy/shell.toml` (watched live) or the bar's right-click menu (12h/24h toggle). This script must be either **deleted** or rewritten to configure the Quickshell bar's clock widget.

---

### 3. Idle Behavior (1 file)

> [!CAUTION]
> `hypridle` is **gone** — replaced by the Quickshell-based idle handling. `hyprlock` is also gone — replaced by the shell's PAM lock screen. Waybar signals (`pkill -RTMIN+9 waybar`) are dead.

#### [configure-idle-behavior.sh](file:///home/mike/Documents/GitHub/omarchy-supplement/configure-idle-behavior.sh)
- **Problem**: Modifies `hypridle.conf` (doesn't exist), kills `hypridle` process (not running), sends Waybar signals (no Waybar). The `autostart.conf` is now `autostart.lua`.
- **Migration**: Investigate Quattro's idle configuration (likely via `shell.toml` or the shell's idle plugin). Rewrite accordingly, or use `omarchy-debug-idle` for diagnostics.

---

### 4. Screensaver (1 file)

> [!CAUTION]
> `terminaltexteffects` is **replaced by `ttfx`** (a Rust port). The screensaver script path and CLI flags have likely changed.

#### [configure-screensaver.sh](file:///home/mike/Documents/GitHub/omarchy-supplement/configure-screensaver.sh)
- **Problem**: Patches `omarchy-screensaver` with `--random-effect --no-eol --no-restore-cursor` flags that belong to `terminaltexteffects`. The new `ttfx` binary has different arguments.
- **Migration**: Rewrite the sed replacement to target `ttfx`'s matrix command syntax instead.

---

## 🟡 NEEDS UPDATE (5 files)

### 5. Oh My Zsh Setup

#### [install-oh-my-zsh.sh](file:///home/mike/Documents/GitHub/omarchy-supplement/install-oh-my-zsh.sh)
- **Problem (lines 77-88)**: Configures **Alacritty** (`alacritty.toml`) with font/shell settings. Quattro's default terminal is **Foot** (`foot.ini`). Alacritty still exists but is secondary.
- **Also**: Uses `CaskaydiaMono Nerd Font` → `MesloLGS NF` replacement. Quattro ships the lighter "basic JetBrains Mono Nerd font" — font name may have changed.
- **Migration**: Add parallel Foot configuration alongside Alacritty. Verify the font name in Quattro.

### 6. Master Install Script

#### [install-all.sh](file:///home/mike/Documents/GitHub/omarchy-supplement/install-all.sh)
- **Problem**: Calls `./install-waybar-config.sh` and `./configure-idle-behavior.sh` which are broken. Calls `./install-hyprland-overrides.sh` which needs a rewrite.
- **Migration**: Update to reference the new rewritten scripts and remove/replace broken calls.

### 7. Nightlight Configuration

#### [set-nightlight.sh](file:///home/mike/Documents/GitHub/omarchy-supplement/set-nightlight.sh)
- **Problem**: Uses `sunsetr` which may still work, but Quattro now uses `hyprsunset` for night light (`omarchy-refresh-hyprsunset`, `omarchy-restart-hyprsunset` are in the bin). The night light is also a toggle in the shell's bar.
- **Migration**: Verify if `sunsetr` still ships or if it's replaced. If replaced, rewrite to use `hyprsunset` configuration.

### 8. Theme Installation

#### [install-synthwave84-theme.sh](file:///home/mike/Documents/GitHub/omarchy-supplement/install-synthwave84-theme.sh)
- **Problem**: Uses `omarchy-theme-install` which still exists in Quattro. But Quattro expanded theming from 8 to 24 colors, added auto-generation of nvim/vscode/btop themes from the colorset. The theme itself may need updating to provide the expanded color palette.
- **Also**: Background directory structure may have changed with the new visual background switcher.
- **Migration**: Verify the Synthwave84 theme repo is Quattro-compatible. The wallpaper download path likely still works.

### 9. Behavior Documentation

#### [omarchy-behaviour.md](file:///home/mike/Documents/GitHub/omarchy-supplement/omarchy-behaviour.md)
- **Problem**: References Waybar, `omarchy-refresh-waybar`, `omarchy-restart-waybar`, `hypridle.conf`, Alacritty-specific caching behavior, and `~/.local/share/omarchy/bin/` paths (internals moved to system packages).
- **Migration**: Update to reflect Quattro's architecture (Quickshell, Foot terminal, Lua configs, `shell.toml`, system packages via pacman).

---

## 🟢 SAFE — No Changes Needed (16 files)

These scripts use stable Omarchy APIs, standard pacman/yay, or are entirely standalone:

| File | Why It's Safe |
|------|--------------|
| `install-dev-tools.sh` | Pure `yay` install — no Omarchy API dependency |
| `install-zsh.sh` | Installs `zsh` package — unchanged |
| `install-nodejs.sh` | Uses `mise` — still the runtime manager in Quattro |
| `install-golang.sh` | Uses `mise` — still the runtime manager in Quattro |
| `install-postgresql.sh` | Pure `pacman`/`systemctl` — unchanged |
| `install-tmux.sh` | Pure git/tmux — Quattro still ships tmux alongside Herdr |
| `install-gaming-related-tools.sh` | Uses `omarchy-install-gaming-*` — all still present in Quattro |
| `install-webapps.sh` | Uses `omarchy-webapp-install` → `omarchy-launch-webapp` still exists |
| `install-ide-configs.sh` | Copies JSON configs — no Omarchy API dependency |
| `install-github-desktop.sh` | AUR install — unchanged |
| `install-signal.sh` | AUR install — unchanged (Signal moved to on-demand but still installable) |
| `install-slack.sh` | AUR install — unchanged |
| `install-teams.sh` | AUR install — unchanged |
| `install-zed.sh` | AUR install — unchanged |
| `install-antigravity.sh` / `install-antigravity-ide.sh` | AUR install — unchanged |
| `setup-chromium-google-account.sh` | Uses `omarchy-install-chromium-google-account` — still exists |
| `setup-github-auth.sh` | Uses `gh` CLI — no Omarchy dependency |
| `set-shell.sh` | Pure `chsh` — unchanged |
| `set-splash.sh` | Uses `omarchy-plymouth-set` — still exists in Quattro |
| `configs/` + `3rdparty-assets/` | Static data files — no runtime dependency |

---

## Open Questions

> [!IMPORTANT]
> These need investigation on a live Quattro system before we can finalize the migration:

1. **Hyprland Lua override mechanism**: Does Quattro's `hyprland.lua` support `dofile()` for user overrides, or is there a dedicated `~/.config/hypr/overrides.lua` pattern? We need to check the actual `hyprland.lua` template.

2. **Idle/Lock configuration**: How does Quattro configure idle timeouts and the lock screen? Is it through `shell.toml`, a Quickshell plugin config, or something else?

3. **sunsetr vs hyprsunset**: Did `sunsetr` get fully replaced? Is `hyprsunset` a different tool or a rename?

4. **ttfx CLI flags**: What are the exact flags for `ttfx matrix` to replicate the infinite matrix rain effect?

5. **Synthwave84 theme Quattro compatibility**: Does the theme provide the expanded 24-color palette, or does it need updating at the theme-repo level?

6. **omarchy-webapp-install**: Does this command still exist in Quattro, or was it renamed to `omarchy-launch-webapp`?

---

## Proposed Changes

All deliverables go into `omarchy-quattro/`. The structure will mirror the original project.

### Component 1: Hyprland Overrides

#### [NEW] `omarchy-quattro/hyprland-overrides.lua`
Rewrite the overrides in Lua using Quattro's Hyprland DSL. Covers:
- Keyboard layout (`pl`, compose on caps)
- Repeat rate/delay
- Touchpad settings (natural scroll, clickfinger, scroll factor)
- Terminal scroll speed windowrule
- Lock screen binding (using Quattro's shell lock instead of hyprlock)

#### [NEW] `omarchy-quattro/install-hyprland-overrides.sh`
Rewrite to inject `dofile("/path/to/hyprland-overrides.lua")` into `~/.config/hypr/hyprland.lua`.

---

### Component 2: Bar/Clock Configuration (Replaces Waybar)

#### [NEW] `omarchy-quattro/configure-bar.sh`
Replace the Waybar clock format customization. Options:
- Write clock format preferences to `~/.config/omarchy/shell.toml`
- Or document that users should right-click the clock widget for format switching

---

### Component 3: Idle Behavior

#### [NEW] `omarchy-quattro/configure-idle-behavior.sh`
Rewrite for Quattro's idle management system. Will need live-system research.

---

### Component 4: Screensaver

#### [NEW] `omarchy-quattro/configure-screensaver.sh`
Rewrite to patch the `ttfx`-based screensaver command.

---

### Component 5: Oh My Zsh

#### [NEW] `omarchy-quattro/install-oh-my-zsh.sh`
Copy of the original with added Foot terminal configuration alongside Alacritty.

---

### Component 6: Nightlight

#### [NEW] `omarchy-quattro/set-nightlight.sh`
Verify sunsetr/hyprsunset and rewrite if needed.

---

### Component 7: Master Script + Documentation

#### [NEW] `omarchy-quattro/install-all.sh`
Updated master script referencing the new Quattro-compatible scripts.

#### [NEW] `omarchy-quattro/omarchy-behaviour.md`
Updated knowledge base reflecting Quattro architecture.

---

## Verification Plan

### Manual Verification (requires live Quattro system)
1. Run `omarchy update` then `Update > Omarchy to Quattro` on a test machine
2. Check that `~/.config/hypr/hyprland.lua` exists and supports `dofile()`
3. Verify `omarchy-webapp-install` vs `omarchy-launch-webapp` naming
4. Verify `sunsetr` vs `hyprsunset` for nightlight
5. Test `ttfx` matrix flags
6. Run each migrated script individually and confirm no errors
7. Run the full `install-all.sh` end-to-end

### Automated Checks (can run now)
- Shellcheck all new `.sh` scripts
- Lua syntax check on the new `.lua` file
- Verify no references to dead commands: `waybar`, `hyprlock`, `hypridle`, `terminaltexteffects`, `omarchy-refresh-waybar`, `omarchy-restart-waybar`
