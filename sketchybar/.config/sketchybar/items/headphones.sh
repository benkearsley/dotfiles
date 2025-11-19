#!/usr/bin/env bash
# File: /53-sketchybar/config/items/headphones.sh
# ──────────────────────────────────────────────────────────────────────────────

## ─────────────────────────────────────────────────────────────────────────────
## Displays if headphones are currently connected over bluetooth.
##
## Using `󰋋` (nf-md-headphones_bluetooth) icon with same color as active VPN.
## ─────────────────────────────────────────────────────────────────────────────
sketchybar --add item headphones right
sketchybar --set headphones icon="󰋋" \
                             icon.color=0xff8bd5ca \
                             label.color=0xff8bd5ca \
                             update_freq=10 \
                             drawing=off \
                             script="$HOME/.config/sketchybar/plugins/bluetooth_headphones.sh"