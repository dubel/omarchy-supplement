#!/bin/bash

# Configures the Omarchy screensaver for infinite Matrix rain using ttfx.
# In Omarchy 4.x, the screensaver engine uses ttfx (Rust terminal text effects)
# and is spawned inside a fullscreen terminal by `omarchy-launch-screensaver`.
#
# Customizing user binaries is safely done by placing an override in ~/.local/bin/
# (which precedes /usr/share/omarchy/bin in PATH), preserving full Hyprland integration.

set -e

LOCAL_BIN="$HOME/.local/bin"
SCREENSAVER_SCRIPT="$LOCAL_BIN/omarchy-screensaver"

echo "Configuring Omarchy screensaver for infinite Matrix rain..."

mkdir -p "$LOCAL_BIN"

cat > "$SCREENSAVER_SCRIPT" << 'EOF'
#!/bin/bash

# Custom Matrix screensaver for Omarchy 4.x
# Preserves all terminal management, cursor management, and input dismissal logic.

screensaver_in_focus() {
  hyprctl activewindow -j | jq -e '.class == "org.omarchy.screensaver"' >/dev/null 2>&1
}

exit_screensaver() {
  hyprctl eval 'hl.config({ cursor = { invisible = false } })' &>/dev/null || hyprctl keyword cursor:invisible false &>/dev/null || true
  pkill -x ttfx 2>/dev/null
  pkill -f '[o]rg.omarchy.screensaver' 2>/dev/null
  exit 0
}

# Exit the screensaver on signals and input from keyboard and mouse
trap exit_screensaver SIGINT SIGTERM SIGHUP SIGQUIT

printf '\033]11;rgb:00/00/00\007'  # Set background color to black
stty -echo 2>/dev/null             # Don't echo input

hyprctl eval 'hl.config({ cursor = { invisible = true } })' &>/dev/null || hyprctl keyword cursor:invisible true &>/dev/null

tty=$(tty 2>/dev/null)

wait_for_terminal_resize() {
  local deadline=$((SECONDS + 2))
  while ((SECONDS < deadline)) && [[ $(stty size 2>/dev/null) == "24 80" ]]; do
    sleep 0.02
  done
}

wait_for_terminal_resize

while true; do
  ttfx matrix --rain-time 0 --no-eol --no-restore-cursor &

  while pgrep -t "${tty#/dev/}" -x ttfx >/dev/null; do
    if read -n1 -t 1 || ! screensaver_in_focus; then
      exit_screensaver
    fi
  done
done
EOF

chmod +x "$SCREENSAVER_SCRIPT"
echo "Screensaver configured at $SCREENSAVER_SCRIPT (overrides system default via PATH)."
echo "Infinite Matrix rain is now active for screensaver!"
