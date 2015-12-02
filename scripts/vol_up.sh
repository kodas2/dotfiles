#!/bin/sh
get_volume() {
    echo $(amixer sget Master | head  -n 6 | tail -n 1 | sed 's/.*Playback \([0-9]\{1,3\}\).*/\1/' | tr -d "\n")
}

amixer set Master "$(echo "$(get_volume) + $1" | bc)"
echo "UPDATE_VOL" > "/tmp/bar_fifo"
