#!/usr/bin/env bash

# Bluetooth headphones detection script for SketchyBar

# Function to check if Bluetooth headphones are connected using faster method
check_bluetooth_headphones() {
    # First try using blueutil if available (faster)
    if command -v blueutil &> /dev/null; then
        # Check for connected devices with audio capabilities
        connected_devices=$(blueutil --connected --format json 2>/dev/null | grep -E "\"name\".*\"(AirPods|Headphone|Headset|Beats|Sony|Bose|Audio)")
        if [ -n "$connected_devices" ]; then
            return 0
        fi
    fi
    
    # Fallback to system_profiler (slower but more comprehensive)
    bluetooth_info=$(system_profiler SPBluetoothDataType 2>/dev/null)
    
    # Check for connected audio devices
    connected_audio=$(echo "$bluetooth_info" | grep -A 20 "Connected: Yes" | grep -E "(Headphone|Headset|AirPods|Beats|Sony|Bose|Audio|A2DP)" | head -1)
    
    if [ -n "$connected_audio" ]; then
        return 0  # Headphones connected
    else
        return 1  # No headphones connected
    fi
}

# Main logic
if check_bluetooth_headphones; then
    # Headphones are connected
    sketchybar --set headphones \
        icon="󰋋" \
        icon.color=0xff8bd5ca \
        label.color=0xff8bd5ca \
        label="" \
        drawing=on
else
    # No headphones connected - hide the widget
    sketchybar --set headphones \
        drawing=off
fi 