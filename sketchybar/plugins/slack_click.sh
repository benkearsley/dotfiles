#!/bin/bash

# Find which workspace has Slack running
slack_workspace=$(aerospace list-windows --all | grep -i slack | head -1 | awk -F'|' '{print $1}' | tr -d ' ')

if [ -n "$slack_workspace" ]; then
    # Switch to the workspace with Slack
    aerospace workspace "$slack_workspace"
    
    # Activate Slack after workspace switch
    osascript -e 'tell application "Slack" to activate'
else
    # If Slack is not running, open it in the current visible workspace
    open -a "Slack"
fi 