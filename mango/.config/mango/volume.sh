#!/bin/bash

SINK_NAME="@DEFAULT_SINK@"

get_volume_percentage() {
    pactl get-sink-volume "$SINK_NAME" | grep -Po '\d+(?=%)' | head -n 1
}

get_mute_status() {
    if pactl get-sink-mute "$SINK_NAME" | grep -q "yes"; then
        echo "Muted"
    else
        echo "Unmuted"
    fi
}

ACTION="$1"

case "$ACTION" in
up)
    pactl set-sink-volume "$SINK_NAME" +5%
    sleep 0.05
    VOLUME=$(get_volume_percentage)
    BODY="Volume: ${VOLUME}%"
    ;;
down)
    pactl set-sink-volume "$SINK_NAME" -5%
    sleep 0.05
    VOLUME=$(get_volume_percentage)
    BODY="Volume: ${VOLUME}%"
    ;;
mute)
    pactl set-sink-mute "$SINK_NAME" toggle
    sleep 0.05
    MUTE=$(get_mute_status)
    VOLUME=$(get_volume_percentage)
    BODY="${MUTE} (${VOLUME}%)"
    ;;
*)
    echo "Usage: $0 <up|down|mute>"
    exit 1
    ;;
esac

notify-send \
    -a "volume" \
    -t 1500 \
    -h string:x-canonical-private-synchronous:audio \
    "Volume" \
    "$BODY"
