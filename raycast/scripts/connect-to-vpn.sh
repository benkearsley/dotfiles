#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Connect to VPN
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔌

# Documentation:
# @raycast.description Use scutil to connect to Azure East US2 vpn
# @raycast.author Ben Kearsley


VPN_NAME="eastus2_default_client-vpn-vwan_eastus2_default_cl"

# Connect
scutil --nc start "$VPN_NAME"

# Optional: Wait and confirm
sleep 2
STATUS=$(scutil --nc status "$VPN_NAME" | head -n 1)

if [[ "$STATUS" == "Connected" ]]; then
  echo "VPN connected successfully."
else
  echo "Failed to connect VPN: $STATUS"
fi

