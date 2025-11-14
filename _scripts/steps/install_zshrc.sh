#!/usr/bin/env bash

# Usage:
# ./install_zshrc.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_zshrc.sh ~/dotfiles ~/.config mac

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

echo "Setting up zshrc for OS: $OPERATING_SYS"

# zshrc is Mac-only
if [[ "$OPERATING_SYS" != "mac" ]]; then
  echo "zshrc is Mac-only. Skipping."
  exit 0
fi

# --- Backup existing zshrc files ---
echo "Backing up existing zshrc configuration..."

# Backup ~/.zshrc
backup_config "$HOME/.zshrc" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "zshrc"

# Backup config files that zshrc uses (only if they exist)
if [[ -e "$CONFIG_BASE_PATH/init" ]] || [[ -L "$CONFIG_BASE_PATH/init" ]]; then
  backup_config "$CONFIG_BASE_PATH/init" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "zshrc"
fi

if [[ -e "$CONFIG_BASE_PATH/shell" ]] || [[ -L "$CONFIG_BASE_PATH/shell" ]]; then
  backup_config "$CONFIG_BASE_PATH/shell" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "zshrc"
fi

if [[ -e "$CONFIG_BASE_PATH/aliases" ]] || [[ -L "$CONFIG_BASE_PATH/aliases" ]]; then
  backup_config "$CONFIG_BASE_PATH/aliases" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "zshrc"
fi

if [[ -e "$CONFIG_BASE_PATH/functions" ]] || [[ -L "$CONFIG_BASE_PATH/functions" ]]; then
  backup_config "$CONFIG_BASE_PATH/functions" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "zshrc"
fi

if [[ -e "$CONFIG_BASE_PATH/prompt" ]] || [[ -L "$CONFIG_BASE_PATH/prompt" ]]; then
  backup_config "$CONFIG_BASE_PATH/prompt" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "zshrc"
fi

if [[ -e "$CONFIG_BASE_PATH/inputrc" ]] || [[ -L "$CONFIG_BASE_PATH/inputrc" ]]; then
  backup_config "$CONFIG_BASE_PATH/inputrc" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "zshrc"
fi

# --- Stow zshrc dotfiles ---
if ! safe_stow "zshrc" "$DOTFILES_BASE_PATH"; then
  echo "Error: Failed to stow zshrc configuration" >&2
  exit 1
fi

echo "✅ zshrc setup complete!"
