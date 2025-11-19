#!/usr/bin/env bash

# Usage:
# ./install_bat.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_bat.sh ~/dotfiles ~/.config mac
# or
# ./install_bat.sh ~/dotfiles ~/.config arch

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

echo "Setting up bat for OS: $OPERATING_SYS"

# --- Check and install bat ---
if [[ "$OPERATING_SYS" == "mac" ]]; then
  if ! command -v bat >/dev/null 2>&1; then
    echo "bat not found. Installing with Homebrew..."
    if ! brew install bat; then
      echo "Error: Failed to install bat with Homebrew" >&2
      exit 1
    fi
  else
    echo "bat already installed."
  fi
elif [[ "$OPERATING_SYS" == "arch" ]]; then
  if ! check_sudo_available; then
    echo "Error: sudo is required for installing bat" >&2
    exit 1
  fi
  
  if ! pacman -Q bat >/dev/null 2>&1; then
    echo "bat not found. Installing with pacman..."
    if ! sudo pacman -S --needed --noconfirm bat; then
      echo "Error: Failed to install bat with pacman" >&2
      exit 1
    fi
  else
    echo "bat already installed."
  fi
else
  echo "Error: Unsupported OS: $OPERATING_SYS" >&2
  echo "Please specify 'mac' or 'arch'" >&2
  exit 1
fi

echo "✅ bat setup complete!"

