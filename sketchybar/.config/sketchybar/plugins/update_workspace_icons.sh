#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"

update_space_icons() {
    local sid=$1
    # Get windows with PID and app name, filter out windows where PID doesn't exist
    local apps=$(aerospace list-windows --workspace "$sid" --format "%{app-pid}|%{app-name}" | \
        while IFS='|' read -r pid app; do
            # Check if process still exists
            if ps -p "$pid" > /dev/null 2>&1; then
                echo "$app"
            fi
        done | sort -u)

    sketchybar --set space.$sid drawing=on

    if [ "${apps}" != "" ]; then
        icon_strip=" "
        while read -r app; do
            [ -n "$app" ] && icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
        done <<<"${apps}"
    else
        icon_strip=""
    fi
    sketchybar --set space.$sid label="$icon_strip"
}

# Update all workspaces to ensure clean state
for monitor in $(aerospace list-monitors --format "%{monitor-appkit-nsscreen-screens-id}"); do
    for sid in $(aerospace list-workspaces --monitor "$monitor"); do
        update_space_icons "$sid"
    done
done
