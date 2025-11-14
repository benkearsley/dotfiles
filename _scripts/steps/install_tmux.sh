#!/usr/bin/env bash

# Usage:
# ./install_tmux.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_tmux.sh ~/dotfiles ~/.config mac
# or
# ./install_tmux.sh ~/dotfiles ~/.config arch

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

echo "Setting up tmux for OS: $OPERATING_SYS"

# --- Check and install tmux ---
if [[ "$OPERATING_SYS" == "mac" ]]; then
  if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux not found. Installing with Homebrew..."
    if ! brew install tmux; then
      echo "Error: Failed to install tmux with Homebrew" >&2
      exit 1
    fi
  else
    echo "tmux already installed."
  fi
elif [[ "$OPERATING_SYS" == "arch" ]]; then
  if ! check_sudo_available; then
    echo "Error: sudo is required for installing tmux" >&2
    exit 1
  fi
  
  if ! pacman -Q tmux >/dev/null 2>&1; then
    echo "tmux not found. Installing with pacman..."
    if ! sudo pacman -S --needed --noconfirm tmux; then
      echo "Error: Failed to install tmux with pacman" >&2
      exit 1
    fi
  else
    echo "tmux already installed."
  fi
else
  echo "Error: Unsupported OS: $OPERATING_SYS" >&2
  echo "Please specify 'mac' or 'arch'" >&2
  exit 1
fi

# --- Backup and Stow tmux dotfiles ---
# Backup ~/.tmux.conf if it exists (old location)
backup_config "$HOME/.tmux.conf" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "tmux"

# Backup ~/.tmux directory if it exists (old location)
if [[ -e "$HOME/.tmux" ]] || [[ -L "$HOME/.tmux" ]]; then
  backup_config "$HOME/.tmux" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "tmux"
fi

# Backup ~/.config/tmux if it exists (new location)
if [[ -e "$CONFIG_BASE_PATH/tmux" ]] || [[ -L "$CONFIG_BASE_PATH/tmux" ]]; then
  backup_config "$CONFIG_BASE_PATH/tmux" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "tmux"
fi

# Stow tmux config (this will create ~/.config/tmux/)
if ! safe_stow "tmux" "$DOTFILES_BASE_PATH"; then
  echo "Error: Failed to stow tmux configuration" >&2
  exit 1
fi

# Create symlink from ~/.tmux.conf to ~/.config/tmux/tmux.conf
# tmux looks for ~/.tmux.conf by default, so we need this symlink
TMUX_CONFIG_PATH="$CONFIG_BASE_PATH/tmux/tmux.conf"
TMUX_SYMLINK="$HOME/.tmux.conf"

if [[ -f "$TMUX_CONFIG_PATH" ]]; then
  # Remove existing symlink or file if it exists
  if [[ -e "$TMUX_SYMLINK" ]] || [[ -L "$TMUX_SYMLINK" ]]; then
    if [[ -L "$TMUX_SYMLINK" ]]; then
      rm "$TMUX_SYMLINK" || { echo "Error: Failed to remove existing symlink $TMUX_SYMLINK" >&2; exit 1; }
    else
      # It's a file, backup it first
      backup_config "$TMUX_SYMLINK" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "tmux"
      rm "$TMUX_SYMLINK" || { echo "Error: Failed to remove existing file $TMUX_SYMLINK" >&2; exit 1; }
    fi
  fi
  
  # Create the symlink
  if ! ln -s "$TMUX_CONFIG_PATH" "$TMUX_SYMLINK"; then
    echo "Error: Failed to create symlink from $TMUX_SYMLINK to $TMUX_CONFIG_PATH" >&2
    exit 1
  fi
  echo "Created symlink: $TMUX_SYMLINK -> $TMUX_CONFIG_PATH"
else
  echo "Error: tmux config file not found at $TMUX_CONFIG_PATH after stowing" >&2
  exit 1
fi

echo "✅ tmux setup complete!"
