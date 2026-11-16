#!/bin/bash

# Enable Google account login in Chromium using Omarchy's built-in support,
# then optionally open Chromium for the user to sign in.
#
# This script is idempotent - running it multiple times produces the same result.
# It delegates to omarchy-install-chromium-google-account which uses grep guards
# before appending OAuth flags.

set -e

# Step 1: Add OAuth credentials to Chromium flags (idempotent)
if command -v omarchy-install-chromium-google-account &>/dev/null; then
    omarchy-install-chromium-google-account
elif command -v omarchy &>/dev/null; then
    omarchy setup browser google-account 2>/dev/null || true
else
    echo "omarchy-install-chromium-google-account not found."
    echo "Please ensure you are running Omarchy."
    exit 1
fi

# Step 2: Offer to open Chromium for login if interactive
if [ -t 0 ] && [ -z "$NON_INTERACTIVE" ] && [ "$1" != "--no-launch" ]; then
    echo ""
    echo "=============================================="
    echo "  Chromium Google Account Login"
    echo "=============================================="
    echo ""
    echo "Chromium is now configured to allow Google account sign-in."
    echo ""

    # Timeout after 15 seconds to avoid blocking unattended runs
    read -t 15 -p "Would you like to open Chromium now to sign in? (y/N - auto-skip in 15s): " response || response="n"
    echo ""
    case $response in
        [Yy]* )
            echo "Opening Chromium... Please sign in to your Google account."
            echo "Close Chromium or press Enter here when done."
            chromium &>/dev/null &
            CHROMIUM_PID=$!
            read -p "Press Enter when you're done signing in..."

            # Close Chromium gracefully if still running
            if kill -0 "$CHROMIUM_PID" 2>/dev/null; then
                echo "Closing Chromium..."
                kill "$CHROMIUM_PID" 2>/dev/null || true
                sleep 2
            fi
            ;;
        * )
            echo "Skipping. You can sign in later by opening Chromium normally."
            ;;
    esac
else
    echo "Skipping interactive browser launch. You can sign in later by opening Chromium normally."
fi
