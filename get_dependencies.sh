#!/bin/bash

if ! command -v yay &>/dev/null; then
    echo "Installing yay..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si && cd ..
    rm -rf yay
fi

# Sync and update
yay -Syu

if [ -f packages.txt ]; then
    echo "Installing packages..."
    yay -S --needed "$(cat packages.txt)"
fi

echo 'Done.'
