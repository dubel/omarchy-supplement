#!/bin/bash

# Install Node.js 20 LTS using mise (Omarchy's built-in runtime manager).
#
# This script is idempotent - mise use -g is a no-op if the version
# is already installed and set globally.

set -e

if ! command -v mise &>/dev/null; then
    echo "mise is not installed. Please ensure you are running Omarchy."
    exit 1
fi

echo "Installing Node.js 20 LTS via mise..."
mise use -g node@20

echo "Node.js setup complete: $(node --version)"
