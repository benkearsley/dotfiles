#!/usr/bin/env bash

# Usage:
# ./install_stow.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_stow.sh ~/dotfiles ~/.config mac
# or
# ./install_stow.sh ~/dotfiles ~/.config arch

set -euo pipefail

DOTFILES_BASE_PATH="$1"
CONFIG_BASE_PATH="$2"
OPERATING_SYS="$3"

if [[ -z "$DOTFILES_BASE_PATH" || -z "$CONFIG_BASE_PATH" || -z "$OPERATING_SYS" ]]; then
  echo "Error: Usage: $0 <dotfiles_base_path> <config_base_path> <operating_system>" >&2
  exit 1
fi

if [[ "$OPERATING_SYS" == "arch" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../lib/sudo_check.sh"
fi

echo "Setting up stow for OS: $OPERATING_SYS"

# --- Check and install stow ---
if [[ "$OPERATING_SYS" == "mac" ]]; then
  if ! command -v stow &>/dev/null 2>&1; then
    echo "stow not found. Installing with Homebrew..."
    if ! brew install stow; then
      echo "Error: Failed to install stow with Homebrew" >&2
      exit 1
    fi
  else
    echo "stow already installed."
  fi
elif [[ "$OPERATING_SYS" == "arch" ]]; then
  if ! check_sudo_available; then
    echo "Error: sudo is required for installing stow" >&2
    exit 1
  fi
  
  if ! pacman -Q stow >/dev/null 2>&1; then
    echo "stow not found. Installing with pacman..."
    if ! sudo pacman -S --needed --noconfirm stow; then
      echo "Error: Failed to install stow with pacman" >&2
      exit 1
    fi
  else
    echo "stow already installed."
  fi
else
  echo "Error: Unsupported OS: $OPERATING_SYS" >&2
  echo "Please specify 'mac' or 'arch'" >&2
  exit 1
fi

echo "✅ stow setup complete!"
