#!/usr/bin/env bash

# Helper functions for stow operations with error handling

# Safely stow a package with error handling
# Usage: safe_stow <package_name> <dotfiles_base_path>
safe_stow() {
  local PACKAGE_NAME="$1"
  local DOTFILES_BASE_PATH="$2"

  if [[ -z "$PACKAGE_NAME" || -z "$DOTFILES_BASE_PATH" ]]; then
    echo "Error: safe_stow requires 2 arguments: <package_name> <dotfiles_base_path>" >&2
    return 1
  fi

  # Check if stow directory exists
  if [[ ! -d "$DOTFILES_BASE_PATH/$PACKAGE_NAME" ]]; then
    echo "Error: Stow directory not found: $DOTFILES_BASE_PATH/$PACKAGE_NAME" >&2
    return 1
  fi

  # Check if stow is available
  if ! command -v stow &>/dev/null; then
    echo "Error: stow command not found. Please install stow first." >&2
    return 1
  fi

  # Change to dotfiles directory
  if ! cd "$DOTFILES_BASE_PATH"; then
    echo "Error: Failed to change to dotfiles directory: $DOTFILES_BASE_PATH" >&2
    return 1
  fi

  # Run stow with error checking
  echo "🔗 Creating $PACKAGE_NAME symlinks with stow..."
  if ! stow -Rv "$PACKAGE_NAME"; then
    echo "Error: stow failed for package: $PACKAGE_NAME" >&2
    return 1
  fi

  echo "✅ $PACKAGE_NAME stow complete!"
  return 0
}

