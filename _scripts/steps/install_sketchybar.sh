#!/usr/bin/env bash

# Usage:
# ./install_sketchybar.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_sketchybar.sh ~/dotfiles ~/.config mac

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

echo "Setting up Sketchybar for OS: $OPERATING_SYS"

# Sketchybar is Mac-only
if [[ "$OPERATING_SYS" != "mac" ]]; then
  echo "Sketchybar is Mac-only. Skipping."
  exit 0
fi

# --- Check and install Sketchybar ---
if ! command -v sketchybar >/dev/null 2>&1; then
  echo "Sketchybar not found. Installing with Homebrew..."
  if ! brew install sketchybar; then
    echo "Error: Failed to install sketchybar with Homebrew" >&2
    exit 1
  fi
else
  echo "Sketchybar already installed."
fi

# --- Backup and Stow Sketchybar dotfiles ---
TARGET_DIR="$CONFIG_BASE_PATH/sketchybar"
backup_config "$TARGET_DIR" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "sketchybar"

# Stow sketchybar config
if ! safe_stow "sketchybar" "$DOTFILES_BASE_PATH"; then
  echo "Error: Failed to stow sketchybar configuration" >&2
  exit 1
fi

# --- Restart Sketchybar to load new config ---
echo "Restarting Sketchybar to load new configuration..."
if pgrep -x sketchybar >/dev/null; then
  echo "Stopping existing Sketchybar instance..."
  killall sketchybar 2>/dev/null || true
  sleep 1
fi

# Start sketchybar with the new config
if [[ -f "$CONFIG_BASE_PATH/sketchybar/start_sketchybar.sh" ]]; then
  echo "Starting Sketchybar..."
  bash "$CONFIG_BASE_PATH/sketchybar/start_sketchybar.sh" &
else
  echo "Warning: start_sketchybar.sh not found. You may need to start Sketchybar manually." >&2
fi

echo "✅ Sketchybar setup complete!"
