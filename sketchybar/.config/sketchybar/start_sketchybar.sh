#!/bin/bash

# Set environment variables
export XDG_CONFIG_HOME="$HOME/.config"
CONFIG_DIR="$XDG_CONFIG_HOME/sketchybar"

# Start sketchybar with the config (theme will be sourced in sketchybarrc)
exec /opt/homebrew/bin/sketchybar --config "$CONFIG_DIR/sketchybarrc" 