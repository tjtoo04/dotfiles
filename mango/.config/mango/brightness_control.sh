#!/bin/bash

# brightness_control.sh {up|down}

ACTION="$1"

# Change brightness
case "$ACTION" in
up)
    brightnessctl set +5%
    ;;
down)
    brightnessctl set 5%-
    ;;
*)
    echo "Usage: $0 {up|down}"
    exit 1
    ;;
esac

# Get updated brightness value
BRIGHTNESS=$(brightnessctl get)
MAX=$(brightnessctl max)

# Mako single-notification replacement
notify-send -e -t 1500 \
    -h string:x-canonical-private-synchronous:brightness \
    "Brightness: ${BRIGHTNESS}/${MAX}"
