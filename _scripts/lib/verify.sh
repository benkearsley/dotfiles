#!/usr/bin/env bash

# Verification functions for dotfiles installation
# Usage: verify_installation <dotfiles_base_path> <config_base_path> <operating_system>

verify_installation() {
  local DOTFILES_BASE_PATH="$1"
  local CONFIG_BASE_PATH="$2"
  local OPERATING_SYS="$3"
  
  local ERRORS=0
  local WARNINGS=0

  echo "Checking installed tools..."
  
  # Verify prerequisite tools
  local PREREQ_TOOLS=("stow" "zoxide" "eza" "fzf")
  for tool in "${PREREQ_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      echo "❌ Error: $tool is not installed or not in PATH"
      ((ERRORS++))
    else
      echo "✅ $tool is installed"
    fi
  done

  # Verify OS-specific tools
  if [[ "$OPERATING_SYS" == "mac" ]]; then
    local MAC_TOOLS=("aerospace" "borders" "sketchybar")
    for tool in "${MAC_TOOLS[@]}"; do
      if ! command -v "$tool" &>/dev/null; then
        echo "⚠️  Warning: $tool is not installed or not in PATH"
        ((WARNINGS++))
      else
        echo "✅ $tool is installed"
      fi
    done
  elif [[ "$OPERATING_SYS" == "arch" ]]; then
    if ! pacman -Q hyprland &>/dev/null 2>&1; then
      echo "⚠️  Warning: hyprland package not found (may be installed differently)"
      ((WARNINGS++))
    else
      echo "✅ hyprland is installed"
    fi
  fi

  # Verify common tools
  local COMMON_TOOLS=("nvim" "ghostty" "starship" "tmux")
  for tool in "${COMMON_TOOLS[@]}"; do
    if [[ "$OPERATING_SYS" == "mac" ]]; then
      if ! command -v "$tool" &>/dev/null; then
        echo "❌ Error: $tool is not installed or not in PATH"
        ((ERRORS++))
      else
        echo "✅ $tool is installed"
      fi
    elif [[ "$OPERATING_SYS" == "arch" ]]; then
      if ! pacman -Q "$tool" &>/dev/null 2>&1; then
        echo "❌ Error: $tool package not found"
        ((ERRORS++))
      else
        echo "✅ $tool is installed"
      fi
    fi
  done

  echo ""
  echo "Checking stow symlinks..."
  
  # Verify key symlinks exist
  local SYMLINKS_TO_CHECK=()
  
  if [[ "$OPERATING_SYS" == "mac" ]]; then
    SYMLINKS_TO_CHECK=(
      "$HOME/.zshrc"
      "$CONFIG_BASE_PATH/init"
      "$CONFIG_BASE_PATH/aerospace/aerospace.toml"
      "$CONFIG_BASE_PATH/sketchybar"
      "$CONFIG_BASE_PATH/starship/starship.toml"
    )
  elif [[ "$OPERATING_SYS" == "arch" ]]; then
    SYMLINKS_TO_CHECK=(
      "$CONFIG_BASE_PATH/bashrc/overrides"
      "$CONFIG_BASE_PATH/starship/starship.toml"
    )
  fi
  
  # Common symlinks
  SYMLINKS_TO_CHECK+=(
    "$CONFIG_BASE_PATH/nvim"
    "$CONFIG_BASE_PATH/ghostty"
    "$HOME/.tmux.conf"
  )

  for symlink in "${SYMLINKS_TO_CHECK[@]}"; do
    if [[ -L "$symlink" ]]; then
      local LINK_TARGET
      LINK_TARGET="$(readlink "$symlink")"
      if [[ "$LINK_TARGET" == *"$DOTFILES_BASE_PATH"* ]]; then
        echo "✅ Symlink correct: $symlink → $LINK_TARGET"
      else
        echo "⚠️  Warning: Symlink exists but doesn't point to dotfiles: $symlink → $LINK_TARGET"
        ((WARNINGS++))
      fi
    elif [[ -e "$symlink" ]]; then
      echo "⚠️  Warning: Path exists but is not a symlink: $symlink"
      ((WARNINGS++))
    else
      echo "⚠️  Warning: Expected symlink not found: $symlink"
      ((WARNINGS++))
    fi
  done

  echo ""
  if [[ $ERRORS -gt 0 ]]; then
    echo "❌ Verification failed with $ERRORS error(s) and $WARNINGS warning(s)"
    return 1
  elif [[ $WARNINGS -gt 0 ]]; then
    echo "⚠️  Verification completed with $WARNINGS warning(s)"
    return 0
  else
    echo "✅ All verifications passed!"
    return 0
  fi
}

