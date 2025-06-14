#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Work Focus Mode
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 💼

# Documentation:
# @raycast.description Toggle Work Focus Mode on/off
# @raycast.author Ben Kearsley

# Function to toggle Work focus mode using direct shortcuts
# TODO: WORK IN PROGRESS
toggle_work_focus() {
    # Try to get current focus status using a simple approach
    # First try to turn OFF focus (if it's currently on)
    shortcuts run "Turn Off Work Focus" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "🟢 Work Focus Mode: OFF"
    else
        # If turning off failed, it means no focus was on, so turn on Work focus
        shortcuts run "Turn On Work Focus" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "🔴 Work Focus Mode: ON"
        fi
    fi
}


toggle_work_focus

