#!/bin/bash

# Install latest Golang using mise (Omarchy's built-in runtime manager).
#
# This script is idempotent - mise use -g is a no-op if the version
# is already installed and set globally.

set -e

if ! command -v mise &>/dev/null; then
    echo "mise is not installed. Please ensure you are running Omarchy."
    exit 1
fi

echo "Installing latest Golang via mise..."
MISE_HTTP_TIMEOUT=300 mise use -g go@latest

echo "Golang setup complete: $(go version 2>/dev/null || echo 'Requires new shell session to be available in PATH')"
