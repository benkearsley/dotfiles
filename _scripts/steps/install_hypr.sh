#!/usr/bin/env bash

echo "Installing Hyprland dotfiles..."

DOTFILES_BASE_PATH="$1"
CONFIG_BASE_PATH="$2"

# Check that both arguments were provided
if [ -z "$DOTFILES_BASE_PATH" ] || [ -z "$CONFIG_BASE_PATH" ]; then
  echo "Usage: $0 <dotfiles_base_path> <config_base_path>"
  exit 1
fi

# Check for Hyprland directory in dotfiles repo
if [ ! -d "$DOTFILES_BASE_PATH/hyprland" ]; then
  echo "Failed to install Hyprland dotfiles..."
  echo "❌ Directory not found: $DOTFILES_BASE_PATH/hyprland"
  exit 1
fi

# Check for existing Hyprland config in ~/.config
if [ ! -d "$CONFIG_BASE_PATH/hypr" ]; then
  echo "Failed to find Hyprland config directory at: $CONFIG_BASE_PATH/hypr"
  exit 1
fi

# Stow Hyprland dotfiles
cd "$DOTFILES_BASE_PATH" || exit 1
echo "Stowing Hyprland dotfiles..."
stow -Rv hyprland

# Add lines to hyprland.conf
CUSTOM_LINE_FLAG="# CUSTOM DOTFILES CONFIG:"
HYPRLAND_BASE_CONFIG_FILE="$CONFIG_BASE_PATH/hypr/hyprland.conf"

if ! grep -Fxq "$CUSTOM_LINE_FLAG" "$HYPRLAND_BASE_CONFIG_FILE"; then
  echo "Appending custom includes to $HYPRLAND_BASE_CONFIG_FILE"

  {
    echo ""
    echo "$CUSTOM_LINE_FLAG"
    echo "source = ~/.config/hypr/custom_monitors.conf"
    echo "source = ~/.config/hypr/custom_input.conf"
    echo "source = ~/.config/hypr/custom_bindings.conf"
    echo "source = ~/.config/hypr/custom_envs.conf"
    echo "source = ~/.config/hypr/custom_looknfeel.conf"
    echo "source = ~/.config/hypr/custom_autostart.conf"
    echo ""
  } >> "$HYPRLAND_BASE_CONFIG_FILE"
else
  echo "Custom config already included — skipping append."
fi

echo "✅ Hyprland dotfiles installed successfully!"
