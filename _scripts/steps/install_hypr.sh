#!/usr/bin/env bash

# Usage:
# ./install_hypr.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_hypr.sh ~/dotfiles ~/.config arch

set -euo pipefail

DOTFILES_BASE_PATH="$1"
CONFIG_BASE_PATH="$2"
OPERATING_SYS="$3"

if [[ -z "$DOTFILES_BASE_PATH" || -z "$CONFIG_BASE_PATH" || -z "$OPERATING_SYS" ]]; then
  echo "Error: Usage: $0 <dotfiles_base_path> <config_base_path> <operating_system>" >&2
  exit 1
fi

# Source helper libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/backup.sh"
source "$SCRIPT_DIR/../lib/stow_helpers.sh"

echo "Installing Hyprland dotfiles..."

# Check for Hyprland directory in dotfiles repo
if [[ ! -d "$DOTFILES_BASE_PATH/hyprland" ]]; then
  echo "Error: Directory not found: $DOTFILES_BASE_PATH/hyprland" >&2
  exit 1
fi

# Check for existing Hyprland config in ~/.config
if [[ ! -d "$CONFIG_BASE_PATH/hypr" ]]; then
  echo "Error: Hyprland config directory not found at: $CONFIG_BASE_PATH/hypr" >&2
  echo "Please ensure Hyprland is installed and configured first." >&2
  exit 1
fi

# Backup custom config files before stowing (only if they exist)
CUSTOM_CONFIG_DIR="$CONFIG_BASE_PATH/hypr"
if [[ -e "$CUSTOM_CONFIG_DIR/custom_monitors.conf" ]] || [[ -L "$CUSTOM_CONFIG_DIR/custom_monitors.conf" ]]; then
  backup_config "$CUSTOM_CONFIG_DIR/custom_monitors.conf" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "hypr"
fi

if [[ -e "$CUSTOM_CONFIG_DIR/custom_input.conf" ]] || [[ -L "$CUSTOM_CONFIG_DIR/custom_input.conf" ]]; then
  backup_config "$CUSTOM_CONFIG_DIR/custom_input.conf" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "hypr"
fi

if [[ -e "$CUSTOM_CONFIG_DIR/custom_bindings.conf" ]] || [[ -L "$CUSTOM_CONFIG_DIR/custom_bindings.conf" ]]; then
  backup_config "$CUSTOM_CONFIG_DIR/custom_bindings.conf" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "hypr"
fi

if [[ -e "$CUSTOM_CONFIG_DIR/custom_envs.conf" ]] || [[ -L "$CUSTOM_CONFIG_DIR/custom_envs.conf" ]]; then
  backup_config "$CUSTOM_CONFIG_DIR/custom_envs.conf" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "hypr"
fi

if [[ -e "$CUSTOM_CONFIG_DIR/custom_looknfeel.conf" ]] || [[ -L "$CUSTOM_CONFIG_DIR/custom_looknfeel.conf" ]]; then
  backup_config "$CUSTOM_CONFIG_DIR/custom_looknfeel.conf" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "hypr"
fi

if [[ -e "$CUSTOM_CONFIG_DIR/custom_autostart.conf" ]] || [[ -L "$CUSTOM_CONFIG_DIR/custom_autostart.conf" ]]; then
  backup_config "$CUSTOM_CONFIG_DIR/custom_autostart.conf" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "hypr"
fi

# Stow Hyprland dotfiles
if ! safe_stow "hyprland" "$DOTFILES_BASE_PATH"; then
  echo "Error: Failed to stow hyprland configuration" >&2
  exit 1
fi

# Add lines to hyprland.conf
CUSTOM_LINE_FLAG="# CUSTOM DOTFILES CONFIG:"
HYPRLAND_BASE_CONFIG_FILE="$CONFIG_BASE_PATH/hypr/hyprland.conf"

if [[ ! -f "$HYPRLAND_BASE_CONFIG_FILE" ]]; then
  echo "Error: hyprland.conf not found at: $HYPRLAND_BASE_CONFIG_FILE" >&2
  exit 1
fi

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

# Reload Hyprland configuration if hyprctl is available and Hyprland is running
if command -v hyprctl >/dev/null 2>&1; then
  # Check if Hyprland is running by checking if hyprctl can connect
  if hyprctl version >/dev/null 2>&1; then
    echo "Reloading Hyprland configuration..."
    if hyprctl reload; then
      echo "✅ Hyprland configuration reloaded successfully"
    else
      echo "Warning: Failed to reload Hyprland configuration. You may need to reload manually." >&2
    fi
  else
    echo "Hyprland is not currently running. Configuration will be loaded on next Hyprland start."
  fi
else
  echo "hyprctl not found. Skipping configuration reload."
fi

echo "✅ Hyprland dotfiles installed successfully!"
