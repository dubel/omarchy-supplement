#!/usr/bin/env bash
set -euo pipefail

# Install web apps as launchable desktop entries via Omarchy's webapp system.
# Each app becomes available through the launcher (SUPER + SPACE).
#
# This script is idempotent - omarchy-webapp-install overwrites the .desktop
# file if it already exists, and icon downloads are re-fetched to the same path.

echo "Setting up web apps..."

# WhatsApp
echo "  -> WhatsApp"
omarchy-webapp-install "WhatsApp" "https://web.whatsapp.com/" ""

# Apple Notes (iCloud)
echo "  -> Apple Notes"
omarchy-webapp-install "Notes" "https://www.icloud.com/notes" ""

# iCloud Drive
echo "  -> iCloud Drive"
omarchy-webapp-install "iCloud Drive" "https://www.icloud.com/iclouddrive" ""

echo ""
echo "Web apps installed! Available via launcher (SUPER + SPACE)."
