#!/bin/bash

# Set environment variables
export XDG_CONFIG_HOME="$HOME/.config"
CONFIG_DIR="$XDG_CONFIG_HOME/sketchybar"

# Debug output
echo "DEBUG start_sketchybar.sh: Starting sketchybar with XDG_CONFIG_HOME=$XDG_CONFIG_HOME" >> /tmp/sketchybar_debug.log

# Start sketchybar with the config (theme will be sourced in sketchybarrc)
exec /opt/homebrew/bin/sketchybar --config "$CONFIG_DIR/sketchybarrc" 