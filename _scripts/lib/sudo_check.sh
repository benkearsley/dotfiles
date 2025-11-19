#!/usr/bin/env bash

# Check if sudo is available and user has permissions
# Usage: check_sudo_available
# Returns 0 if sudo is available, 1 otherwise

check_sudo_available() {
  if ! command -v sudo &>/dev/null; then
    echo "Error: sudo command not found. Please install sudo or run as root." >&2
    return 1
  fi

  # Test sudo access (non-interactive)
  if ! sudo -n true 2>/dev/null; then
    # If non-interactive sudo fails, check if we can prompt
    if ! sudo -v; then
      echo "Error: Cannot obtain sudo privileges. Please ensure you have sudo access." >&2
      return 1
    fi
  fi

  return 0
}

