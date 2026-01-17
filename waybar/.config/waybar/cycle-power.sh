#!/bin/bash

# Cycle through power profiles using powerprofilesctl.
# The standard profiles are: power-saver, balanced, performance.

PROFILES=("power-saver" "balanced" "performance")

get_current_profile() {
    powerprofilesctl get | awk -F ': ' '{print $1}'
}

cycle_profile() {
    local current_profile=$(get_current_profile)
    local next_profile=""
    local found=0
    local i=0

    # Find the current profile's index
    for i in "${!PROFILES[@]}"; do
        if [[ "${PROFILES[$i]}" == "$current_profile" ]]; then
            found=1
            break
        fi
    done

    if [[ $found -eq 1 ]]; then
        local next_index=$(((i + 1) % ${#PROFILES[@]}))
        next_profile="${PROFILES[$next_index]}"
    else
        next_profile="${PROFILES[0]}"
    fi

    # Set the new profile
    if [[ -n "$next_profile" ]]; then
        powerprofilesctl set "$next_profile"

        notify-send "⚡ Power Profile Set" "Current mode: $(echo "$next_profile" | awk '{print toupper(substr($0,1,1))substr($0,2)}')" -t 3000
    else
        notify-send "Power Error" "Could not determine the next power profile." -u critical
    fi
}

cycle_profile

exit 0
