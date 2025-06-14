#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Disconnect From VPN
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔌

# Documentation:
# @raycast.description Disconnect from Azure East US2 VPN with scutils
# @raycast.author Ben Kearsley

VPN_NAME="eastus2_default_client-vpn-vwan_eastus2_default_cl"

# Disconnect
scutil --nc stop "$VPN_NAME"

# Wait until status becomes "Disconnected", up to 30 seconds
MAX_WAIT=30
WAITED=0
STATUS=""

while [[ $WAITED -lt $MAX_WAIT ]]; do
  STATUS=$(scutil --nc status "$VPN_NAME" | head -n 1)
  if [[ "$STATUS" == "Disconnected" ]]; then
    echo "VPN disconnected successfully."
    exit 0
  fi
  sleep 1
  ((WAITED++))
done

echo "Timeout: VPN did not disconnect after $MAX_WAIT seconds. Current status: $STATUS"
exit 1

