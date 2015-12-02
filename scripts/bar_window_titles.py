#!/usr/bin/python3

#This script will only work with  EWMH compliant WMs

import sh, sys

if len(sys.argv) != 2:
    print("ERROR, incorrect arguments!")
    print("First and only argument should be the bar's fifo name.")
    exit(1)

fifo = open(sys.argv[1], "w")
excluded = ["bar", "gsimplecal"]
curr_windows = []
focused = ""
window_titles = dict()
focused_window_colour = "#6d6d6d"
max_title_len = 20

def get_window_ids(line):
    line = line.rstrip("\n")
    try:
        ind = line.find("#")
    except ValueError:
        return [""]

    #+2, because there's a space after the #
    window_ids_str = line[ind + 2:]
    window_ids = window_ids_str.split(", ")

    return window_ids

def get_window_title(id):
    for line in sh.xprop("-id", id).split("\n"):
        if line.startswith("WM_NAME") or line.startswith("_NET_WM_NAME"):
            try:
                ind = line.find("=")
            except ValueError:
                return "ERROR"
            
            #+3 and -1, instead of +2 because there's quotes on either side
            title = line[ind+3:-1]
            if len(title) >= max_title_len:
                title = title[:max_title_len] + "..."
            return title

def update_fifo():
    output = ""
    for id in curr_windows:
        if id not in window_titles:
            window_titles[id] = get_window_title(id)
        window_title = window_titles[id]

        if window_title in excluded:
            continue

        output += "%{A:xdotool windowactivate " + id + ":}"
        if id == focused:
            output += "%{+u}%{B" + focused_window_colour + "}"
        output += " " + window_title + " "
        if id == focused:
            output += "%{B-}%{-u}"
        output += " %{A}"

    fifo.write("UPDATE_WINDOW_TITLES\n" + output + "\n")
    try:
        fifo.flush()
    except BrokenPipeError:
        exit(0)
        

def handle_update(line, stdin):
    if line.startswith("_NET_ACTIVE_WINDOW(WINDOW)"):
        #There should only be one id, but get_window_ids returns a list
        global focused
        focused = get_window_ids(line)[0]
        update_fifo()

    elif line.startswith("_NET_CLIENT_LIST(WINDOW)"):
        window_ids = get_window_ids(line)
        #New windows created
        for id in window_ids:
            if id not in curr_windows:
                curr_windows.append(id)
        #Windows removed
        for id in curr_windows:
            if id not in window_ids:
                curr_windows.remove(id)
        
        update_fifo()

        

sh.xprop("-spy", "-root", _out=handle_update)
fifo.close()
