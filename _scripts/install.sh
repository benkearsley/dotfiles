#!/bin/bash

# This script collects input before installing dotfiles.
# Inputs are passed to the orchestrator script, which calls individual
# scripts for specific programs

set -euo pipefail

echo "Beginning dotfiles installation..."

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

# Install package manager tools
if [[ "$os" == "mac" ]]; then
  if ! command -v brew &>/dev/null; then
    echo "Homebrew is not installed. Please install it manually from https://brew.sh"
    exit 1
  fi
elif [[ "$os" == "arch" ]]; then
  if ! command -v pacman &>/dev/null; then
    echo "pacman not found. This system does not appear to be Arch-based."
    exit 1
  fi
fi
elif [[ "$os" == "arch" ]]; then
  echo "Using pacman (already installed on Arch)..."
fi

# Install stow if missing
if ! command -v stow &>/dev/null; then
  echo "Installing stow..."
  if [[ "$os" == "mac" ]]; then
    brew install stow
  else
    sudo pacman -S --needed --noconfirm stow
  fi
else
  echo "stow already installed. Skipping."
fi


# Install zoxide if missing
if ! command -v zoxide &>/dev/null; then
  echo "Installing zoxide..."
  if [[ "$os" == "mac" ]]; then
    brew install zoxide
  else
    sudo pacman -S --needed --noconfirm zoxide
  fi
else
  echo "eza already installed. Skipping."
fi


# Install eza if missing
if ! command -v eza &>/dev/null; then
  echo "Installing eza..."
  if [[ "$os" == "mac" ]]; then
    brew install eza
  else
    sudo pacman -S --needed --noconfirm eza
  fi
else
  echo "eza already installed. Skipping."
fi

# Stow .zshrc if mac
if [[ "$os" == "mac" ]]; then
  echo "Linking .zshrc"
  stow -v zshrc
  source ~/.zshrc
fi

if [[ "$os" == "arch" ]]; then
  echo "bash rc already set up"
fi


# Install Ghostty if missing
if ! command -v ghostty &>/dev/null; then
  echo "Installing Ghostty..."
  if [[ "$os" == "mac" ]]; then
    brew install --cask ghostty
  else
    sudo pacman -S --needed --noconfirm ghostty
  fi
else
  echo "Ghostty already installed. Skipping."
fi


# Set TERMINAL environment variable for Omarchy (Arch)
if [[ "$os" == "arch" ]]; then
  echo "Setting TERMINAL=ghostty..."
  TERMINAL_CONFIG_PATH="$HOME/.config/uwsm/default"
  mkdir -p "$(dirname "$TERMINAL_CONFIG_PATH")"
  touch "$TERMINAL_CONFIG_PATH"

  if grep -q '^export TERMINAL=' "$TERMINAL_CONFIG_PATH" 2>/dev/null; then
      sed -i 's/^export TERMINAL=.*/export TERMINAL=ghostty/' "$TERMINAL_CONFIG_PATH"
  else
      echo 'export TERMINAL=ghostty' >> "$TERMINAL_CONFIG_PATH"
  fi
fi

echo "Dotfiles installation completed."


# TODO: symlink seed the ghostty directory with the omarchy config file (for mac)
# TODO: convert p10k prompt back to starship

# starship or p10k

# tmux

# aerospace on mac
# sketchybar on mac
# borders on mac

# .zshrc or .bashrc

# .ideamvimrc (on mac)




