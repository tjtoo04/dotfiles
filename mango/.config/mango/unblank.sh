#!/usr/bin/env bash
for out in $(mmsg -O | awk '{print $1}'); do
    mmsg -d enable_monitor,"$out"
done
