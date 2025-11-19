#!/usr/bin/env bash

# Usage:
# ./install_borders.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_borders.sh ~/dotfiles ~/.config mac

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

echo "Setting up Borders for OS: $OPERATING_SYS"

# Borders is Mac-only
if [[ "$OPERATING_SYS" != "mac" ]]; then
  echo "Borders is Mac-only. Skipping."
  exit 0
fi

# --- Check and install Borders ---
if ! command -v borders >/dev/null 2>&1; then
  echo "Borders not found. Installing with Homebrew..."
  if ! brew install borders; then
    echo "Error: Failed to install borders with Homebrew" >&2
    exit 1
  fi
else
  echo "Borders already installed."
fi

# --- Backup and Stow Borders dotfiles ---
TARGET_DIR="$CONFIG_BASE_PATH/borders"
backup_config "$TARGET_DIR" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "borders"

# Stow borders config
if ! safe_stow "borders" "$DOTFILES_BASE_PATH"; then
  echo "Error: Failed to stow borders configuration" >&2
  exit 1
fi

echo "✅ Borders setup complete!"
