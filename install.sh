#!/bin/bash

#Made for Arch Linux
UPDATE_COMMAND="sudo pacman -Syu"
INSTALL_COMMAND="sudo pacman -S --noconfirm"
AUR_COMMAND="makepkg -sri"
PIP3_INSTALL_COMMAND="sudo pip install"
pkgs=('base-devel' 'xbindkeys' 'xorg-xinit' 'xorg' 'openbox' 'rxvt-unicode'
'rofi' 'python' 'vim' 'feh' 'git' 'python-pip' 'gsimplecal')
aur_pkgs=('lemonbar-git' 'compton-git')
pip3_pkgs=('sh')

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
    cd ~/aur
done

cd ~

for pkg in ${pip3_pkgs[@]}; do
    $PIP3_INSTALL_COMMAND "$pkg"
done
