#!/bin/bash

#README: You need to update FIFO in this script, and in ./vol_up.sh and ./vol_down.sh

#TODO: Volume action doesn't work, weird output on second activation, crash on third
#Volnoti?

FIFO="/tmp/bar_fifo"

get_time() {
    echo $(date +'%d/%m/%y %R')
} 

get_volume() {
    echo $(amixer sget Master | head  -n 6 | tail -n 1 | sed 's/.*\[\([0-9]\{1,3\}%\)\].*/\1/' | tr -d "\n")
}

get_bat_level() {
    echo "100 * $(cat /sys/class/power_supply/BAT0/energy_now) / $(cat /sys/class/power_supply/BAT0/energy_full)" | bc | tr "\n" "%"
}

get_bat_status() {
    echo $(cat /sys/class/power_supply/BAT0/status)
}

[ -e "$FIFO" ] || mkfifo "$FIFO"

#Open the fifo for writing, so it doesn't close early
exec 3<>"$FIFO"
#Close fd 3 on exit
trap "exec 3>&-" EXIT INT TERM

~/scripts/bar_window_titles.py "$FIFO" &

while true; do
    echo "UPDATE_TIME" > "$FIFO"
    echo "UPDATE_BAT" > "$FIFO"
    #Just in case it wasn't updated by the volume script
    echo "UPDATE_VOL" > "$FIFO"
    sleep 60
done &

WINDOW_TITLES=""
BAR_TIME=""
BAR_VOL=""
BAR_BAT_LEVEL=""
BAR_BAT_STATUS=""

while read LINE; do
    if [ "$LINE" = "UPDATE_WINDOW_TITLES" ]; then
        read WINDOW_TITLES
    elif [ "$LINE" = "UPDATE_VOL" ]; then
        BAR_VOL="$(get_volume)"
    elif [ "$LINE" = "UPDATE_TIME" ]; then
        BAR_TIME="$(get_time)"
    elif [ "$LINE" = "UPDATE_BAT" ]; then
        BAR_BAT_LEVEL="$(get_bat_level)"
        BAR_BAT_STATUS="$(get_bat_status)"
    fi

    echo -n "%{l}$WINDOW_TITLES"
    echo -n "%{r} %{A:urxvt -e alsamixer &>/dev/null &: \n}VOL: $BAR_VOL%{A}   "
    echo -n "BAT: $BAR_BAT_LEVEL ($BAR_BAT_STATUS)   "
    echo "%{A:gsimplecal &:}$BAR_TIME %{A}"
done < "$FIFO" | lemonbar -b -u 2 -B#2d2d2d | sh
