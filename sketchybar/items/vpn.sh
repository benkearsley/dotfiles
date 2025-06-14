#!/usr/bin/env bash
# File: /53-sketchybar/config/items/vpn.sh
# ──────────────────────────────────────────────────────────────────────────────

## ─────────────────────────────────────────────────────────────────────────────
## Displays if vpn is currently connected.
##
## Using `\\uf11c` (nf-fa-keyboard) icon.
## ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item vpn right
sketchybar --set vpn icon="󰞀" \
                        label="Checking..." \
                        update_freq=5 \
                        script="~/.config/sketchybar/plugins/vpn.sh"