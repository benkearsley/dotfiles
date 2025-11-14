#!/usr/bin/env bash

# Usage:
# ./install_starship.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_starship.sh ~/dotfiles ~/.config mac
# or
# ./install_starship.sh ~/dotfiles ~/.config arch

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

echo "Setting up Starship for OS: $OPERATING_SYS"

# --- Check and install Starship ---
if [[ "$OPERATING_SYS" == "mac" ]]; then
  if ! command -v starship >/dev/null 2>&1; then
    echo "Starship not found. Installing with Homebrew..."
    if ! brew install starship; then
      echo "Error: Failed to install starship with Homebrew" >&2
      exit 1
    fi
  else
    echo "Starship already installed."
  fi
elif [[ "$OPERATING_SYS" == "arch" ]]; then
  if ! check_sudo_available; then
    echo "Error: sudo is required for installing starship" >&2
    exit 1
  fi
  
  if ! pacman -Q starship >/dev/null 2>&1; then
    echo "Starship not found. Installing with pacman..."
    if ! sudo pacman -S --needed --noconfirm starship; then
      echo "Error: Failed to install starship with pacman" >&2
      exit 1
    fi
  else
    echo "Starship already installed."
  fi
else
  echo "Error: Unsupported OS: $OPERATING_SYS" >&2
  echo "Please specify 'mac' or 'arch'" >&2
  exit 1
fi

# --- Backup and Stow Starship dotfiles ---
# Backup starship.toml if it exists
if [[ -e "$CONFIG_BASE_PATH/starship.toml" ]] || [[ -L "$CONFIG_BASE_PATH/starship.toml" ]]; then
  backup_config "$CONFIG_BASE_PATH/starship.toml" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "starship"
fi

# Backup starship directory if it exists
if [[ -e "$CONFIG_BASE_PATH/starship" ]] || [[ -L "$CONFIG_BASE_PATH/starship" ]]; then
  backup_config "$CONFIG_BASE_PATH/starship" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "starship"
fi

# Stow starship config
if ! safe_stow "starship" "$DOTFILES_BASE_PATH"; then
  echo "Error: Failed to stow starship configuration" >&2
  exit 1
fi

echo "✅ Starship setup complete!"
