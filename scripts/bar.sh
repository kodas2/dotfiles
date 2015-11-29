#!/bin/bash

WINDOW_NAME_SEP="   "

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

get_window_titles() {
    WINDOW_IDS=$(xprop -root | grep "_NET_CLIENT_LIST(WINDOW):" | sed 's/.*# \(.*\)/\1/' | sed 's/,//g')
    for w in $WINDOW_IDS; do
        WINDOW_NAME="$(xprop -id $w 2>/dev/null | grep 'WM_NAME(STRING)' | sed 's/.*\"\(.*\)\"/\1/')"
        [ "$WINDOW_NAME" != 'bar' ] && echo -n "${WINDOW_NAME}${WINDOW_NAME_SEP}"
    done 
}

while true; do
    echo -n "%{l}$(get_window_titles \"   \")"
    echo -n "%{r}VOL: $(get_volume)   "
    echo -n "BAT: $(get_bat_level) ($(get_bat_status))   "
    echo $(get_time)
    sleep 0.5
done | lemonbar -pb -B#992d2d2d
