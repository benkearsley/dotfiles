#!/usr/bin/env bash

# Centralized backup function for dotfiles installation
# Usage: backup_config <target_path> <dotfiles_base_path> <config_base_path> <tool_name>
#
# Example:
# backup_config "$HOME/.config/nvim" "$HOME/dotfiles" "$HOME/.config" "nvim"

backup_config() {
  local TARGET_PATH="$1"
  local DOTFILES_BASE_PATH="$2"
  local CONFIG_BASE_PATH="$3"
  local TOOL_NAME="$4"

  if [[ -z "$TARGET_PATH" || -z "$DOTFILES_BASE_PATH" || -z "$CONFIG_BASE_PATH" || -z "$TOOL_NAME" ]]; then
    echo "Error: backup_config requires 4 arguments: <target_path> <dotfiles_base_path> <config_base_path> <tool_name>" >&2
    return 1
  fi

  # Create centralized backup directory
  local BACKUP_BASE_DIR="$CONFIG_BASE_PATH/.bak"
  local BACKUP_TOOL_DIR="$BACKUP_BASE_DIR/$TOOL_NAME"
  
  if ! mkdir -p "$BACKUP_TOOL_DIR"; then
    echo "Error: Failed to create backup directory: $BACKUP_TOOL_DIR" >&2
    return 1
  fi

  # If the target exists (file, dir, or symlink)
  if [[ -e "$TARGET_PATH" || -L "$TARGET_PATH" ]]; then
    echo "⚠️  Existing config found at: $TARGET_PATH"

    # If it's a symlink
    if [[ -L "$TARGET_PATH" ]]; then
      local LINK_TARGET
      LINK_TARGET="$(readlink "$TARGET_PATH")"
      echo "🔗 Found symlink → $LINK_TARGET"

      # If it already points to our dotfiles, skip backup
      if [[ "$LINK_TARGET" == *"$DOTFILES_BASE_PATH"* ]]; then
        echo "✅ Symlink already points to dotfiles — skipping backup."
        return 0
      fi
    fi

    # Determine backup destination path preserving directory structure
    local BACKUP_DEST
    if [[ "$TARGET_PATH" == "$HOME"/* ]]; then
      # For home directory files, preserve relative path from home
      local REL_PATH="${TARGET_PATH#$HOME/}"
      BACKUP_DEST="$BACKUP_TOOL_DIR/$REL_PATH"
    elif [[ "$TARGET_PATH" == "$CONFIG_BASE_PATH"/* ]]; then
      # For config directory files, preserve relative path from config
      local REL_PATH="${TARGET_PATH#$CONFIG_BASE_PATH/}"
      BACKUP_DEST="$BACKUP_TOOL_DIR/$REL_PATH"
    else
      # For other paths, use basename
      BACKUP_DEST="$BACKUP_TOOL_DIR/$(basename "$TARGET_PATH")"
    fi

    # Create parent directory for backup destination
    if ! mkdir -p "$(dirname "$BACKUP_DEST")"; then
      echo "Error: Failed to create backup parent directory: $(dirname "$BACKUP_DEST")" >&2
      return 1
    fi

    # Remove existing backup at this specific path if it exists
    if [[ -e "$BACKUP_DEST" || -L "$BACKUP_DEST" ]]; then
      echo "🗑️  Removing existing backup at: $BACKUP_DEST"
      if ! rm -rf "$BACKUP_DEST"; then
        echo "Error: Failed to remove existing backup: $BACKUP_DEST" >&2
        return 1
      fi
    fi

    # Move the target to backup location
    echo "📦 Backing up existing config to: $BACKUP_DEST"
    if ! mv "$TARGET_PATH" "$BACKUP_DEST"; then
      echo "Error: Failed to backup config from $TARGET_PATH to $BACKUP_DEST" >&2
      return 1
    fi

  else
    echo "✅ No existing config found at: $TARGET_PATH"
  fi
}
