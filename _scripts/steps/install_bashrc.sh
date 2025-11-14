#!/usr/bin/env bash

# Usage:
# ./install_bashrc.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_bashrc.sh ~/dotfiles ~/.config arch

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

echo "Setting up bashrc overrides for OS: $OPERATING_SYS"

# bashrc is Arch-only
if [[ "$OPERATING_SYS" != "arch" ]]; then
  echo "bashrc overrides are Arch-only. Skipping."
  exit 0
fi

# --- Backup and Stow bashrc dotfiles ---
TARGET_DIR="$CONFIG_BASE_PATH/bashrc"
backup_config "$TARGET_DIR" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "bashrc"

# Stow bashrc config
if ! safe_stow "bashrc" "$DOTFILES_BASE_PATH"; then
  echo "Error: Failed to stow bashrc configuration" >&2
  exit 1
fi

echo ""
echo "⚠️  TODO: Ensure ~/.config/bashrc/overrides is sourced in the omarchy bashrc configuration"
echo "✅ bashrc setup complete!"
