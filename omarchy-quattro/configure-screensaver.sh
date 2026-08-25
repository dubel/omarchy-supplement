#!/bin/bash

# Replaces the default random-effect screensaver with a continuous matrix loop.
# Quattro replaces terminaltexteffects with ttfx (a Rust port).
# The screensaver script now lives in the system package, not ~/.local/share/omarchy/bin/.
#
# NOTE: The exact ttfx CLI flags may need adjustment on a live Quattro system.
#       Use 'ttfx --help' and 'ttfx matrix --help' to verify available options.

set -e

echo "Configuring Omarchy Quattro screensaver for infinite Matrix rain..."

# In Quattro, omarchy-screensaver is a system-installed script.
# Check common locations.
SCREENSAVER_SCRIPT=""
for path in \
    "/usr/share/omarchy/bin/omarchy-screensaver" \
    "/usr/local/bin/omarchy-screensaver" \
    "$HOME/.local/share/omarchy/bin/omarchy-screensaver"; do
    if [ -f "$path" ]; then
        SCREENSAVER_SCRIPT="$path"
        break
    fi
done

# Also check if it's on PATH
if [ -z "$SCREENSAVER_SCRIPT" ] && command -v omarchy-screensaver &>/dev/null; then
    SCREENSAVER_SCRIPT="$(command -v omarchy-screensaver)"
fi

if [ -z "$SCREENSAVER_SCRIPT" ]; then
    echo "Warning: omarchy-screensaver not found."
    echo "The screensaver script may have moved in Quattro."
    echo "Try: 'which omarchy-screensaver' or 'pacman -Ql omarchy | grep screensaver'"
    exit 1
fi

echo "Found screensaver script at: $SCREENSAVER_SCRIPT"

# Check if the script is writable (system packages may be read-only)
if [ ! -w "$SCREENSAVER_SCRIPT" ]; then
    echo "Warning: $SCREENSAVER_SCRIPT is not writable."
    echo "Creating a local override instead..."

    # Create a local wrapper that overrides the system screensaver
    LOCAL_BIN="$HOME/.local/bin"
    mkdir -p "$LOCAL_BIN"

    cat > "$LOCAL_BIN/omarchy-screensaver" << 'WRAPPER'
#!/bin/bash
# Local override: infinite matrix rain screensaver using ttfx
exec ttfx matrix --rain-time 0
WRAPPER
    chmod +x "$LOCAL_BIN/omarchy-screensaver"
    echo "Created local override at $LOCAL_BIN/omarchy-screensaver"
    echo "Make sure $LOCAL_BIN is in your PATH (it should be by default on Omarchy)."
else
    # Patch the existing script: replace terminaltexteffects syntax with ttfx
    # Old: terminaltexteffects --random-effect --no-eol --no-restore-cursor
    # New: ttfx matrix --rain-time 0  (infinite matrix rain)
    if grep -q "terminaltexteffects" "$SCREENSAVER_SCRIPT"; then
        sed -i 's|terminaltexteffects --random-effect --no-eol --no-restore-cursor|ttfx matrix --rain-time 0|g' "$SCREENSAVER_SCRIPT"
        echo "Patched terminaltexteffects → ttfx in $SCREENSAVER_SCRIPT"
    elif grep -q "ttfx.*--random" "$SCREENSAVER_SCRIPT"; then
        # ttfx is already in use but with random effect
        sed -i 's|ttfx.*--random[^ ]*|ttfx matrix --rain-time 0|g' "$SCREENSAVER_SCRIPT"
        echo "Patched ttfx random effect → matrix in $SCREENSAVER_SCRIPT"
    else
        echo "Warning: Could not find expected pattern in $SCREENSAVER_SCRIPT"
        echo "The script may already be customized or use a different format."
        echo "Please check manually: cat $SCREENSAVER_SCRIPT"
    fi
fi

echo "Screensaver configured for infinite Matrix rain!"
