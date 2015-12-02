xrdb -merge ~/.Xresources

feh --bg-fill ~/.config/wallpaper/wallpaper.png
setxkbmap us dvorak
compton -b
~/scripts/bar.sh &
rofi -key-run control+space &
xbindkeys &
exec openbox
