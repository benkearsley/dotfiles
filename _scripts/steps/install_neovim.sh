#!/usr/bin/env bash

# Usage:
# ./install_neovim.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_neovim.sh ~/dotfiles ~/.config mac
# or
# ./install_neovim.sh ~/dotfiles ~/.config arch

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

echo "Setting up Neovim for OS: $OPERATING_SYS"

# --- Check and install Neovim ---
if [[ "$OPERATING_SYS" == "mac" ]]; then
  if ! command -v nvim >/dev/null 2>&1; then
    echo "Neovim not found. Installing with Homebrew..."
    if ! brew install neovim; then
      echo "Error: Failed to install neovim with Homebrew" >&2
      exit 1
    fi
  else
    echo "Neovim already installed."
  fi
elif [[ "$OPERATING_SYS" == "arch" ]]; then
  if ! check_sudo_available; then
    echo "Error: sudo is required for installing neovim" >&2
    exit 1
  fi
  
  if ! pacman -Q neovim >/dev/null 2>&1; then
    echo "Neovim not found. Installing with pacman..."
    if ! sudo pacman -S --needed --noconfirm neovim; then
      echo "Error: Failed to install neovim with pacman" >&2
      exit 1
    fi
  else
    echo "Neovim already installed."
  fi
else
  echo "Error: Unsupported OS: $OPERATING_SYS" >&2
  echo "Please specify 'mac' or 'arch'" >&2
  exit 1
fi

# --- Backup and Stow Neovim dotfiles ---
echo "Stowing Neovim dotfiles..."
TARGET_DIR="$CONFIG_BASE_PATH/nvim"
backup_config "$TARGET_DIR" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "nvim"

# Stow neovim config (this will create the symlinks)
if ! safe_stow "nvim" "$DOTFILES_BASE_PATH"; then
  echo "Error: Failed to stow neovim configuration" >&2
  exit 1
fi

# --- Copy theme files (not stowed) ---
# Themes are copied (not symlinked) because they're in a separate directory
# and we don't want them in the root of the dotfiles repo
if [[ "$OPERATING_SYS" == "mac" ]]; then
  echo "Copying theme files to Neovim plugin directory..."
  
  THEMES_SOURCE_DIR="$DOTFILES_BASE_PATH/nvim/themes"
  PLUGIN_DIR="$CONFIG_BASE_PATH/nvim/lua/plugins"
  
  if [[ ! -d "$THEMES_SOURCE_DIR" ]]; then
    echo "Warning: Themes directory not found: $THEMES_SOURCE_DIR" >&2
  else
    if ! mkdir -p "$PLUGIN_DIR"; then
      echo "Error: Failed to create plugin directory: $PLUGIN_DIR" >&2
      exit 1
    fi
    
    if [[ -f "$THEMES_SOURCE_DIR/colorscheme.lua" ]]; then
      if ! cp "$THEMES_SOURCE_DIR/colorscheme.lua" "$PLUGIN_DIR/"; then
        echo "Error: Failed to copy colorscheme.lua" >&2
        exit 1
      fi
      echo "✅ Copied colorscheme.lua"
    fi
    
    if [[ -f "$THEMES_SOURCE_DIR/tokyonight-custom.lua" ]]; then
      if ! cp "$THEMES_SOURCE_DIR/tokyonight-custom.lua" "$PLUGIN_DIR/"; then
        echo "Error: Failed to copy tokyonight-custom.lua" >&2
        exit 1
      fi
      echo "✅ Copied tokyonight-custom.lua"
    fi
    
    echo "Themes copied to: $PLUGIN_DIR"
  fi
fi

echo "✅ Neovim setup complete!"
