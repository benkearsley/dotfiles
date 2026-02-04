#!/usr/bin/env bash
# Neovim cleanup script - run this if nvim starts acting weird

echo "🧹 Cleaning up Neovim zombies and cruft..."

# Kill any zombie nvim processes
echo "Killing zombie nvim processes..."
killall nvim 2>/dev/null
sleep 1

# Clean old swap files (older than 1 day)
echo "Cleaning old swap files..."
find ~/.local/state/nvim/swap -name "*.swp" -mtime +1 -delete 2>/dev/null

# Clean old session files (older than 7 days)
echo "Cleaning old session files..."
find ~/.local/state/nvim/sessions -name "*.vim" -mtime +7 -delete 2>/dev/null

# Count remaining files
swap_count=$(ls ~/.local/state/nvim/swap 2>/dev/null | wc -l | tr -d ' ')
session_count=$(ls ~/.local/state/nvim/sessions 2>/dev/null | wc -l | tr -d ' ')

echo "✅ Done!"
echo "   Swap files: $swap_count"
echo "   Sessions: $session_count"
echo ""
echo "Run this script anytime nvim starts crashing."
