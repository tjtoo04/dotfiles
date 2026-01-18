#!/usr/bin/env bash

# Use absolute paths to avoid environment issues
WALL_DIR="$HOME/Wallpapers"
WALLUST_BIN=$(which wallust)
SWAY_BIN=$(which swaybg)

# 1. List wallpapers for Rofi to display
# This part runs when you first open the 'wallpapers' tab
if [ -z "$@" ]; then
    find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) -printf "%f\n"
else
    # 2. This part runs when you select an item
    # $@ is the filename you clicked
    SELECTED_WALL="$WALL_DIR/$@"

    if [ -f "$SELECTED_WALL" ]; then
        # Run wallust
        $SWAY_BIN -i "$SELECTED_WALL" >/dev/null 2>&1 &
        $WALLUST_BIN run "$SELECTED_WALL" >/dev/null 2>&1
        if [ "$DESKTOP_SESSION" == "mango" ]; then
            mmsg -d reload_config
        fi
        swayosd-client --config="$HOME/.config/swayosd/config.toml"

        # IMPORTANT: To make Rofi close after selection, we exit here
        exit 0
    fi
fi
