#!/usr/bin/env bash
# File: /53-sketchybar/config/items/slack.sh
# ──────────────────────────────────────────────────────────────────────────────

## ─────────────────────────────────────────────────────────────────────────────
## Displays the current slack layout.
##
## Using `\uf198` (nf-fa-slack) icon.
## ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item slack right
sketchybar --set slack \
    icon="" \
    update_freq=60 \
    script="$HOME/.config/sketchybar/plugins/slack.sh" \
    click_script="$HOME/.config/sketchybar/plugins/slack_click.sh"
