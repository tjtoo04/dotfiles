#!/usr/bin/env bash
for out in $(mmsg -O | awk '{print $1}'); do
    mmsg -d disable_monitor,"$out"
done
