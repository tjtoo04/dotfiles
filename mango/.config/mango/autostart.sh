# elephant &
# walker --gapplication-service &

xscreensaver --no-splash &
swayidle -w \
    timeout 240 "xscreensaver-command -activate" \
    timeout 300 "$HOME/.config/mango/screenlock.sh" \
    timeout 420 "$HOME/.config/mango/blank.sh" \
    resume "$HOME/.config/mango/unblank.sh" &

# swayidle -w \
#     timeout 300 "xscreensaver-command -activate" \
#     timeout 120 "$HOME/.config/mango/screenlock.sh" &
mako &
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots &
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css >/dev/null 2>&1 &
swaybg -i ~/Wallpapers/gameboy.png >/dev/null 2>&1 &
exec swayosd-server &
