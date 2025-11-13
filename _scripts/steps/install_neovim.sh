#!/usr/bin/env bash

# Usage:
# ./setup_neovim.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./setup_neovim.sh ~/dotfiles ~/.config mac
# or
# ./setup_neovim.sh ~/dotfiles ~/.config arch

set -e  # Exit on error

DOTFILES_BASE_PATH="$1"
CONFIG_BASE_PATH="$2"
OPERATING_SYS="$3"

if [[ -z "$DOTFILES_BASE_PATH" || -z "$CONFIG_BASE_PATH" || -z "$OPERATING_SYS" ]]; then
  echo "Usage: $0 <dotfiles_base_path> <config_base_path> <operating_system>"
  exit 1
fi

echo "Setting up Neovim for OS: $OPERATING_SYS"

# --- Check and install Neovim ---
if [[ "$OPERATING_SYS" == "mac" ]]; then
  if ! command -v nvim >/dev/null 2>&1; then
    echo "Neovim not found. Installing with Homebrew..."
    brew install neovim
  else
    echo "Neovim already installed."
  fi
elif [[ "$OPERATING_SYS" == "arch" ]]; then
  if ! pacman -Q neovim >/dev/null 2>&1; then
    echo "Neovim not found. Installing with pacman..."
    sudo pacman -S --needed neovim
  else
    echo "Neovim already installed."
  fi
else
  echo "Unsupported OS: $OPERATING_SYS"
  echo "Please specify 'mac' or 'arch'"
  exit 1
fi

# --- Stow Neovim dotfiles ---
echo "Stowing Neovim dotfiles..."
cd "$DOTFILES_BASE_PATH" || exit 1

TARGET_DIR="$CONFIG_BASE_PATH/nvim"
BACKUP_DIR="${TARGET_DIR}.bak"

# If the target exists (file, dir, or symlink)
if [[ -e "$TARGET_DIR" || -L "$TARGET_DIR" ]]; then
  echo "⚠️  Existing Neovim config found at: $TARGET_DIR"

  # Remove old backup if it exists
  if [[ -e "$BACKUP_DIR" || -L "$BACKUP_DIR" ]]; then
    echo "🗑️  Removing existing backup at: $BACKUP_DIR"
    rm -rf "$BACKUP_DIR"
  fi

  # If it's a symlink
  if [[ -L "$TARGET_DIR" ]]; then
    LINK_TARGET="$(readlink "$TARGET_DIR")"
    echo "🔗 Found symlink → $LINK_TARGET"

    # If it already points to our dotfiles, skip backup
    if [[ "$LINK_TARGET" == *"$DOTFILES_BASE_PATH"* ]]; then
      echo "✅ Symlink already points to dotfiles — skipping backup."
    else
      echo "📦 Backing up existing symlink to: $BACKUP_DIR"
      mv "$TARGET_DIR" "$BACKUP_DIR"
    fi

  else
    # It's a real directory or file
    echo "📦 Creating backup of existing Neovim config at: $BACKUP_DIR"
    mv "$TARGET_DIR" "$BACKUP_DIR"
  fi
fi

# Now stow cleanly
echo "🔗 Creating Neovim symlinks with stow..."
stow -Rv nvim
echo "✅ Neovim stow complete!"

# --- Move theme files if on Mac ---
if [[ "$OPERATING_SYS" == "mac" ]]; then
  echo "Copying theme files to Neovim plugin directory..."

  PLUGIN_DIR="$CONFIG_BASE_PATH/nvim/lua/plugins"
  mkdir -p "$PLUGIN_DIR"

  cp "$DOTFILES_BASE_PATH/nvim/themes/colorscheme.lua" "$PLUGIN_DIR/" 2>/dev/null || true
  cp "$DOTFILES_BASE_PATH/nvim/themes/tokyonight-custom.lua" "$PLUGIN_DIR/" 2>/dev/null || true

  echo "Themes copied to: $PLUGIN_DIR"
fi

echo "✅ Neovim setup complete!"
