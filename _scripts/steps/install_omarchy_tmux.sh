#!/usr/bin/env bash

# Usage:
# ./install_omarchy_tmux.sh <dotfiles_base_path> <config_base_path> <operating_system>
#
# Example:
# ./install_omarchy_tmux.sh ~/dotfiles ~/.config arch

set -euo pipefail

DOTFILES_BASE_PATH="$1"
CONFIG_BASE_PATH="$2"
OPERATING_SYS="$3"

if [[ -z "$DOTFILES_BASE_PATH" || -z "$CONFIG_BASE_PATH" || -z "$OPERATING_SYS" ]]; then
  echo "Error: Usage: $0 <dotfiles_base_path> <config_base_path> <operating_system>" >&2
  exit 1
fi

echo "Installing omarchy tmux switcher..."

# Only install on Arch Linux (omarchy)
if [[ "$OPERATING_SYS" != "arch" ]]; then
  echo "Skipping omarchy tmux switcher installation (only available on Arch Linux)"
  exit 0
fi

# Check if curl is available
if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required to install omarchy tmux switcher" >&2
  exit 1
fi

# Check if tmux is installed (required for TPM plugin)
if ! command -v tmux >/dev/null 2>&1; then
  echo "Warning: tmux is not installed. Please install tmux first." >&2
  exit 1
fi

# Check if TPM is installed (required for omarchy tmux switcher)
TPM_PATH="$CONFIG_BASE_PATH/tmux/plugins/tpm"
if [[ ! -d "$TPM_PATH" ]] || [[ ! -f "$TPM_PATH/tpm" ]]; then
  echo "Warning: TPM (Tmux Plugin Manager) is not installed. Please install TPM first." >&2
  exit 1
fi

echo "Installing omarchy tmux switcher via official installer..."
if curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-install.sh | bash; then
  echo "✅ omarchy tmux switcher installed successfully"
else
  echo "Error: Failed to install omarchy tmux switcher" >&2
  exit 1
fi

