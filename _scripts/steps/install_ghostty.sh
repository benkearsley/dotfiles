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

# --- OS-specific theme configuration ---
GHOSTTY_CONFIG_PATH="$CONFIG_BASE_PATH/ghostty/config"

if [[ ! -f "$GHOSTTY_CONFIG_PATH" ]]; then
  echo "Error: Ghostty config file not found at $GHOSTTY_CONFIG_PATH after stowing" >&2
  exit 1
fi

# Modify theme configuration based on OS
if [[ "$OPERATING_SYS" == "mac" ]]; then
  echo "Configuring Tokyo Night theme for Mac..."
  
  # If config is a symlink (from stow), break it so we can modify it independently
  if [[ -L "$GHOSTTY_CONFIG_PATH" ]]; then
    echo "Breaking symlink to create OS-specific config..."
    cp "$GHOSTTY_CONFIG_PATH" "$GHOSTTY_CONFIG_PATH.tmp"
    rm "$GHOSTTY_CONFIG_PATH"
    mv "$GHOSTTY_CONFIG_PATH.tmp" "$GHOSTTY_CONFIG_PATH"
  fi
  
  # Check if Tokyo Night theme is already set
  if grep -q "^theme.*TokyoNight" "$GHOSTTY_CONFIG_PATH"; then
    echo "Tokyo Night theme already configured"
  else
    # Create a temporary file with Mac-specific config
    TEMP_CONFIG=$(mktemp)
    
    # Process config file: remove omarchy config-file line, keep everything else
    while IFS= read -r line; do
      # Skip the "Dynamic theme colors" comment and omarchy config-file line on Mac
      if [[ "$line" =~ ^#.*Dynamic.*theme.*colors ]] || [[ "$line" =~ config-file.*omarchy ]]; then
        # Skip these lines - we'll add Tokyo Night theme instead
        continue
      elif [[ "$line" =~ ^theme.*TokyoNight ]]; then
        # Skip if Tokyo Night theme is already configured (avoid duplicates)
        continue
      else
        echo "$line" >> "$TEMP_CONFIG"
      fi
    done < "$GHOSTTY_CONFIG_PATH"
    
    # Add Tokyo Night theme at the beginning
    TEMP_CONFIG2=$(mktemp)
    {
      echo "theme = TokyoNight"
      echo ""
      cat "$TEMP_CONFIG" >> "$TEMP_CONFIG2"
      mv "$TEMP_CONFIG2" "$GHOSTTY_CONFIG_PATH"
    }
    echo "✅ Tokyo Night theme configured for Mac"
  fi
elif [[ "$OPERATING_SYS" == "arch" ]]; then
  echo "Keeping omarchy theme configuration for Arch Linux"
  # Ensure the omarchy config-file line exists
  if ! grep -q "config-file.*omarchy" "$GHOSTTY_CONFIG_PATH"; then
    # Add it if missing (shouldn't happen, but just in case)
    sed -i.bak '1i# Dynamic theme colors\nconfig-file = ?"~/.config/omarchy/current/theme/ghostty.conf"\n' "$GHOSTTY_CONFIG_PATH"
    rm -f "${GHOSTTY_CONFIG_PATH}.bak"
  fi
fi

echo "✅ Ghostty setup complete!"
