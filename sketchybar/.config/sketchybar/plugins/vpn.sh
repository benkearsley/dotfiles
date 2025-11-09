#!/bin/bash

# Check for VPN connection using scutil
VPN=$(scutil --nc list | grep Connected | sed -E 's/.*"(.*)".*/\1/')

if [[ -n "$VPN" ]]; then
  # VPN is connected - show with green color and connection name
  sketchybar -m --set vpn icon="󰕥" \
                          label="" \
                          icon.color=0xff8bd5ca \
                          label.color=0xff8bd5ca \
                          drawing=on
else
  # No VPN connection - show disconnected state
  sketchybar -m --set vpn icon="󰞀" \
                          label="" \
                          icon.color=0xfff5a97f \
                          label.color=0xfff5a97f \
                          drawing=on
fi