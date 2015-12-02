#!/bin/bash

#Made for Arch Linux
UPDATE_COMMAND="sudo pacman -Syu"
INSTALL_COMMAND="sudo pacman -S --noconfirm"
AUR_COMMAND="makepkg -sri"
pkgs=('xbindkeys' 'xorg-xinit' 'xorg' 'openbox' 'rxvt-unicode' 'rofi'
        'feh' 'git')
aur_pkgs=('lemonbar-git' 'compton-git')

cd "$(dirname "$(readlink -f "$0")")"

#Move files to correct places
cp -rf . $HOME
#Leftovers from copying all git repo files
rm ~/README.md
rm -rf ~/.git

$UPDATE_COMMAND

for pkg in ${pkgs[@]}; do
    $INSTALL_COMMAND "$pkg"
done

mkdir ~/aur
cd ~/aur

for pkg in ${aur_pkgs[@]}; do
    git clone "https://aur.archlinux.org/${pkg}.git" 
    cd $pkg
    $AUR_COMMAND
done
