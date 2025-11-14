#!/usr/bin/env bash

# Main dotfiles installation script
# This script detects the OS, installs prerequisites, and calls individual
# step scripts for each tool based on the operating system

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_BASE_PATH="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_BASE_PATH="$HOME/.config"

echo "Beginning dotfiles installation..."
echo "Dotfiles base path: $DOTFILES_BASE_PATH"
echo "Config base path: $CONFIG_BASE_PATH"

# Detect OS
os=""
if [[ "$(uname)" == "Darwin" ]]; then
  os="mac"
elif [[ -f "/etc/arch-release" ]]; then
  os="arch"
else
  echo "Unsupported OS. Exiting."
  exit 1
fi

echo "Detected OS: $os"

# Check package manager
if [[ "$os" == "mac" ]]; then
  if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew is not installed. Please install it manually from https://brew.sh"
    exit 1
  fi
  echo "Using Homebrew..."
elif [[ "$os" == "arch" ]]; then
  if ! command -v pacman &>/dev/null; then
    echo "Error: pacman not found. This system does not appear to be Arch-based."
    exit 1
  fi
  echo "Using pacman..."
  
  # Check sudo availability for Arch
  source "$SCRIPT_DIR/lib/sudo_check.sh"
  if ! check_sudo_available; then
    echo "Error: sudo is required for Arch Linux package installation."
    exit 1
  fi
fi

# Source helper libraries
source "$SCRIPT_DIR/lib/backup.sh"
source "$SCRIPT_DIR/lib/stow_helpers.sh"

# Function to run a step script if it exists
run_step() {
  local step_script="$SCRIPT_DIR/steps/$1"
  if [[ -f "$step_script" ]]; then
    echo ""
    echo "=========================================="
    echo "Running: $1"
    echo "=========================================="
    if ! bash "$step_script" "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "$os"; then
      echo "Error: Step script failed: $1" >&2
      exit 1
    fi
  else
    echo "Error: Step script not found: $step_script" >&2
    exit 1
  fi
}

# Install prerequisite utilities
# Note: stow must be installed first as it's needed for the other installations
run_step "install_stow.sh"
run_step "install_zoxide.sh"
run_step "install_eza.sh"
run_step "install_fzf.sh"
run_step "install_bat.sh"

# Run step scripts based on OS
echo ""
echo "Installing dotfiles for tools..."

# Tools for both OS
run_step "install_neovim.sh"
run_step "install_ghostty.sh"
run_step "install_starship.sh"
run_step "install_tmux.sh"

# OS-specific tools
if [[ "$os" == "mac" ]]; then
  run_step "install_aerospace.sh"
  run_step "install_borders.sh"
  run_step "install_sketchybar.sh"
  run_step "install_zshrc.sh"
elif [[ "$os" == "arch" ]]; then
  run_step "install_hypr.sh"
  run_step "install_bashrc.sh"
fi

# Set TERMINAL environment variable for Omarchy (Arch)
if [[ "$os" == "arch" ]]; then
  echo ""
  echo "Setting TERMINAL=ghostty for Omarchy..."
  TERMINAL_CONFIG_PATH="$HOME/.config/uwsm/default"
  mkdir -p "$(dirname "$TERMINAL_CONFIG_PATH")"
  touch "$TERMINAL_CONFIG_PATH"

  if grep -q '^export TERMINAL=' "$TERMINAL_CONFIG_PATH" 2>/dev/null; then
      sed -i 's/^export TERMINAL=.*/export TERMINAL=ghostty/' "$TERMINAL_CONFIG_PATH"
  else
      echo 'export TERMINAL=ghostty' >> "$TERMINAL_CONFIG_PATH"
  fi
fi

# Verification step
echo ""
echo "=========================================="
echo "Verifying installation..."
echo "=========================================="

source "$SCRIPT_DIR/lib/verify.sh"
if verify_installation "$DOTFILES_BASE_PATH" "$CONFIG_BASE_PATH" "$os"; then
  echo ""
  echo "✅ Dotfiles installation completed successfully!"
else
  echo ""
  echo "⚠️  Installation completed with warnings. Please review the output above."
  exit 1
fi
