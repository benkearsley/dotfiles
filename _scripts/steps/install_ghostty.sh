#!/usr/bin/env bash

# Usage:
# ./install_ghostty.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_ghostty.sh ~/dotfiles ~/.config mac
# or
# ./install_ghostty.sh ~/dotfiles ~/.config arch

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

if [[ "$OPERATING_SYS" == "arch" ]]; then
  source "$SCRIPT_DIR/../lib/sudo_check.sh"
fi

echo "Setting up Ghostty for OS: $OPERATING_SYS"

# --- Check and install Ghostty ---
if [[ "$OPERATING_SYS" == "mac" ]]; then
  if ! command -v ghostty &>/dev/null 2>&1; then
    echo "Ghostty not found. Installing with Homebrew..."
    if ! brew install --cask ghostty; then
      echo "Error: Failed to install ghostty with Homebrew" >&2
      exit 1
    fi
  else
    echo "Ghostty already installed."
  fi
elif [[ "$OPERATING_SYS" == "arch" ]]; then
  if ! check_sudo_available; then
    echo "Error: sudo is required for installing ghostty" >&2
    exit 1
  fi
  
  if ! pacman -Q ghostty >/dev/null 2>&1; then
    echo "Ghostty not found. Installing with pacman..."
    if ! sudo pacman -S --needed --noconfirm ghostty; then
      echo "Error: Failed to install ghostty with pacman" >&2
      exit 1
    fi
  else
    echo "Ghostty already installed."
  fi
else
  echo "Error: Unsupported OS: $OPERATING_SYS" >&2
  echo "Please specify 'mac' or 'arch'" >&2
  exit 1
fi

# --- Backup and Stow Ghostty dotfiles ---
TARGET_DIR="$CONFIG_BASE_PATH/ghostty"
backup_config "$TARGET_DIR" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "ghostty"

# Stow ghostty config
if ! safe_stow "ghostty" "$DOTFILES_BASE_PATH"; then
  echo "Error: Failed to stow ghostty configuration" >&2
  exit 1
fi

echo "✅ Ghostty setup complete!"
