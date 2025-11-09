#!/bin/sh

front_app=(
  label.font="JetBrainsMono Nerd Font:Bold:12.0"
  icon.background.drawing=on
  display=active
  script="/Users/ben.kearsley/.config/sketchybar/plugins/front_app.sh"
  click_script="open -a 'Mission Control'"
)
sketchybar --add item front_app left         \
           --set front_app "${front_app[@]}" \
           --subscribe front_app front_app_switched