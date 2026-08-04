#!/bin/bash

# Setup GitHub CLI and Authentication
# This provides a modern, secure alternative to storing plaintext tokens in ~/.netrc

echo "Setting up GitHub CLI..."

# Install github-cli if it's not installed
yay -S --noconfirm --needed github-cli

# Check if user is already logged in
if gh auth status &>/dev/null; then
    echo "GitHub CLI is already authenticated!"
else
    echo ""
    echo "=========================================================="
    echo " GitHub CLI Authentication"
    echo "=========================================================="
    echo "You will now be prompted to log into GitHub."
    echo "This replaces the need for a ~/.netrc file."
    echo "Select 'HTTPS' for Git operations and choose to authenticate Git."
    echo "=========================================================="
    echo ""
    
    # Run the interactive login
    gh auth login

    # Ensure git is configured to use gh as the credential helper
    gh auth setup-git
fi
