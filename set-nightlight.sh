#!/bin/bash

# Configure sunsetr (Omarchy's nightlight tool) for a warm screen
# from 21:00 to 07:00 with 5500K temperature.
#
# This script is idempotent - running it multiple times produces the same result.
# It writes the desired values directly to sunsetr's config file and restarts
# the service if it's running.

set -e

CONFIG_DIR="$HOME/.config/sunsetr"
CONFIG_FILE="$CONFIG_DIR/sunsetr.toml"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Desired settings
NIGHT_TEMP=5500
DAY_TEMP=6500
NIGHT_GAMMA=90
DAY_GAMMA=100
SUNSET="21:00:00"
SUNRISE="07:00:00"
TRANSITION_MODE="finish_by"
TRANSITION_DURATION=45

# Update config values using sunsetr set (writes to config file)
# If sunsetr is running, these take effect immediately.
# If not running, they persist in the config for next start.
sunsetr set \
  night_temp="$NIGHT_TEMP" \
  day_temp="$DAY_TEMP" \
  night_gamma="$NIGHT_GAMMA" \
  day_gamma="$DAY_GAMMA" \
  sunset="$SUNSET" \
  sunrise="$SUNRISE" \
  transition_mode="$TRANSITION_MODE" \
  transition_duration="$TRANSITION_DURATION"

echo "Nightlight configured: ${NIGHT_TEMP}K from ${SUNSET%:00} to ${SUNRISE%:00}"
echo "Current status:"
sunsetr status
