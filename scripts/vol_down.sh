#!/bin/sh
get_volume() {
    echo $(amixer sget Master | head  -n 6 | tail -n 1 | sed 's/.*Playback \([0-9]\{1,3\}\).*/\1/' | tr -d "\n")
}

NEW_VOLUME="$(echo "$(get_volume) - $1" | bc)"
if [ $NEW_VOLUME -lt 0 ]; then
    NEW_VOLUME=0
fi
amixer set Master $NEW_VOLUME
unset NEW_VOLUME
echo "UPDATE_VOL" > "/tmp/bar_fifo"
