#!/bin/bash

# NOTE: This script has been modified to use the simple commands available in 'mmsg' (Mango IPC).
# It NO LONGER supports the 'windows' mode because 'mmsg' does not provide geometry for all open windows.
# We have added a 'focused' mode instead, using the '-x' option.

# Configuration
[[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
OUTPUT_DIR="$HOME/Pictures"

if [[ ! -d "$OUTPUT_DIR" ]]; then
    notify-send "Screenshot directory does not exist: $OUTPUT_DIR" -u critical -t 3000
    exit 1
fi

# Kill previous slurp selection if running (toggle)
pkill slurp && exit 0

MODE="${1:-smart}"
PROCESSING="${2:-slurp}"

get_focused_rectangle() {
    # Capture the multi-line output from mmsg
    local mmsg_output=$(mmsg -g -x 2>/dev/null)

    # Check if the output is empty or contains an error
    if [ -z "$mmsg_output" ]; then
        return 1 # No focused client or mmsg failed
    fi

    # 1. Dynamically extract the monitor name (e.g., eDP-2, HDMI-A-1)
    # The name is the first word on the line containing 'x'
    local monitor_name=$(echo "$mmsg_output" | awk '/ x / {print $1}')

    # Check if a monitor name was found
    if [ -z "$monitor_name" ]; then
        return 1
    fi

    # 2. Extract values using awk, referencing the dynamically found monitor name
    local x=$(echo "$mmsg_output" | awk -v name="$monitor_name" '$1 == name && $2 == "x" {print $3}')
    local y=$(echo "$mmsg_output" | awk -v name="$monitor_name" '$1 == name && $2 == "y" {print $3}')
    local width=$(echo "$mmsg_output" | awk -v name="$monitor_name" '$1 == name && $2 == "width" {print $3}')
    local height=$(echo "$mmsg_output" | awk -v name="$monitor_name" '$1 == name && $2 == "height" {print $3}')

    # 3. Format into the single string required by grim/slurp
    if [ -n "$x" ] && [ -n "$y" ] && [ -n "$width" ] && [ -n "$height" ]; then
        echo "${x},${y} ${width}x${height}"
    else
        return 1 # Parsing failed
    fi
}

# Select based on mode
case "$MODE" in
region)
    wayfreeze &
    PID=$!
    sleep .1
    SELECTION=$(slurp 2>/dev/null)
    kill $PID 2>/dev/null
    ;;

# The 'windows' mode is no longer possible as mmsg cannot list all window geometries.
# We use the focused client geometry instead.
focused)
    SELECTION=$(get_focused_rectangle)
    ;;

fullscreen)
    # grim captures the focused output automatically without needing mmsg or geometry coordinates.
    # The SELECTION variable is intentionally left empty so 'grim' captures the focused monitor.
    ;;

smart | *)
    # Default to focused client in smart mode, as getting all windows is not possible.
    SELECTION=$(get_focused_rectangle)
    # If selection fails (no focused client), fall back to slurp region selection
    if [ -z "$SELECTION" ]; then
        wayfreeze &
        PID=$!
        sleep .1
        SELECTION=$(slurp 2>/dev/null)
        kill $PID 2>/dev/null
    fi
    ;;

*)
    # For any unknown mode, default to region selection
    wayfreeze &
    PID=$!
    sleep .1
    SELECTION=$(slurp 2>/dev/null)
    kill $PID 2>/dev/null
    ;;
esac

# Exit if no selection was made (or if slurp was killed)
[ -z "$SELECTION" ] && exit 0

if [[ $PROCESSING == "slurp" ]]; then
    FILE_NAME="screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"
    grim -g "$SELECTION" - |
        satty --filename - \
            --output-filename "$OUTPUT_DIR/$FILE_NAME" \
            --early-exit \
            --actions-on-enter save-to-clipboard \
            --save-after-copy \
            --copy-command 'wl-copy'

    notify-send "Screenshot Saved & Copied" "File Name: $FILE_NAME"
else
    # Simple copy to clipboard (original logic)
    grim ${SELECTION:+-g "$SELECTION"} - | wl-copy
fi
