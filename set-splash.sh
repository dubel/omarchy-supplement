#!/bin/bash
# Sets the Omarchy splash screen to a deep purple Synthwave theme

echo "Configuring Omarchy splash screen..."
echo "This will require your sudo password or fingerprint to update the boot image."

# Background: Deep purple (#1e1136)
# Text/Accents: Neon cyan (#05d9e8)
omarchy-plymouth-set '#1e1136' '#05d9e8' ~/.local/share/omarchy/default/plymouth/logo.png

echo "Splash screen successfully updated to Synthwave theme!"
