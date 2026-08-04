#!/usr/bin/env bash
set -euo pipefail

# Gaming setup for Framework 13 (AMD Ryzen AI 7 350 + Radeon 860M)
# Leverages Omarchy's built-in gaming install scripts where available.
#
# This script is idempotent - all package installs use --needed,
# and service/group changes are guarded with checks.

echo "======================================"
echo " Omarchy Gaming Setup"
echo " AMD Ryzen AI 7 350 + Radeon 860M"
echo "======================================"

echo
echo "[1/7] Installing Vulkan + Mesa stack..."
# Omarchy's gpu-lib32 auto-detects AMD/Intel/NVIDIA and installs the right
# lib32 Vulkan driver. We add the base mesa packages and tools on top.
sudo pacman -S --noconfirm --needed \
    mesa \
    mesa-utils \
    vulkan-radeon \
    vulkan-tools \
    lib32-mesa
omarchy-install-gaming-gpu-lib32

echo
echo "[2/7] Installing Steam..."
# Omarchy's script installs steam + auto-detected lib32 GPU drivers.
# steam already depends on steam-devices, lib32-alsa-plugins, etc.
omarchy-install-gaming-steam

echo
echo "[3/7] Installing Proton manager..."
yay -S --noconfirm --needed protonplus

echo
echo "[4/7] Installing gaming tools..."
sudo pacman -S --noconfirm --needed \
    gamemode \
    lib32-gamemode \
    mangohud \
    lib32-mangohud

echo
echo "[5/7] Installing Windows game launchers..."
# Omarchy's scripts handle heroic + lutris with proper lib32 drivers
# and lutris dependencies (wine-staging, umu-launcher, etc.)
omarchy-install-gaming-heroic
omarchy-install-gaming-lutris

echo
echo "[6/7] Installing audio/controller compatibility..."
sudo pacman -S --noconfirm --needed \
    lib32-libpulse \
    lib32-openal

echo
echo "[7/7] Configuring GameMode..."
# GameMode uses D-Bus activation — it starts automatically when gamemoderun
# is called, no systemd enable needed. Just ensure user is in gamemode group.
if ! groups "$USER" | grep -qw gamemode; then
    sudo usermod -aG gamemode "$USER"
    echo "Added $USER to gamemode group (re-login required to take effect)"
else
    echo "User already in gamemode group"
fi

echo
echo "---- Diagnostics ----"

echo
echo "GPU:"
lspci | grep -Ei "vga|display" || true

echo
echo "OpenGL:"
glxinfo | grep "OpenGL renderer" || true

echo
echo "Vulkan:"
vulkaninfo --summary 2>/dev/null | head -20 || true

echo
echo "GameMode:"
gamemoded -t || true

echo
echo "======================================"
echo " DONE"
echo
echo "Steam:"
echo "  Settings -> Compatibility -> Enable Proton"
echo
echo "Recommended launch options:"
echo "  gamemoderun mangohud %command%"
echo
echo "For Wayland-native Proton:"
echo "  gamemoderun mangohud PROTON_ENABLE_WAYLAND=1 %command%"
echo "======================================"