#!/bin/bash

# Setup GitHub CLI and Authentication
# This provides a modern, secure alternative to storing plaintext tokens in ~/.netrc

set -e

echo "Checking GitHub CLI..."

# Install github-cli if it's not installed
if ! command -v gh &>/dev/null; then
    yay -S --noconfirm --needed github-cli
fi

# Check if user is already logged in
if gh auth status &>/dev/null; then
    echo "GitHub CLI is already authenticated!"
elif [ ! -t 0 ]; then
    echo "GitHub CLI is not authenticated. Run 'gh auth login' in your terminal when convenient."
else
    echo ""
    echo "=========================================================="
    echo " GitHub CLI Authentication"
    echo "=========================================================="
    echo "You will now be prompted to log into GitHub."
    echo "Select 'HTTPS' for Git operations and choose to authenticate Git."
    echo "=========================================================="
    echo ""
    
    # Run the interactive login
    gh auth login

    # Ensure git is configured to use gh as the credential helper
    gh auth setup-git
fi
