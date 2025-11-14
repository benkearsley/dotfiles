#!/usr/bin/env bash

# Usage:
# ./install_aerospace.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_aerospace.sh ~/dotfiles ~/.config mac

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

echo "Setting up Aerospace for OS: $OPERATING_SYS"

# Aerospace is Mac-only
if [[ "$OPERATING_SYS" != "mac" ]]; then
  echo "Aerospace is Mac-only. Skipping."
  exit 0
fi

# --- Check and install Aerospace ---
if ! command -v aerospace >/dev/null 2>&1; then
  echo "Aerospace not found. Installing with Homebrew..."
  if ! brew install --cask aerospace; then
    echo "Error: Failed to install aerospace with Homebrew" >&2
    exit 1
  fi
else
  echo "Aerospace already installed."
fi

# --- Backup and Stow Aerospace dotfiles ---
# Backup config directory
TARGET_DIR="$CONFIG_BASE_PATH/aerospace"
backup_config "$TARGET_DIR" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "aerospace"

# Also backup ~/.aerospace.toml if it exists (legacy location)
if [[ -e "$HOME/.aerospace.toml" ]] || [[ -L "$HOME/.aerospace.toml" ]]; then
  backup_config "$HOME/.aerospace.toml" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "aerospace"
fi

# Stow aerospace config
if ! safe_stow "aerospace" "$DOTFILES_BASE_PATH"; then
  echo "Error: Failed to stow aerospace configuration" >&2
  exit 1
fi

echo "✅ Aerospace setup complete!"
