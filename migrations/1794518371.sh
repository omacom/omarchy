echo "Install xrandr so Wine tray menus open at the pointer"

# omarchy-tray-context-menu reads Xwayland's monitor layout with xrandr to
# place a Wine app's own tray menu where it was right-clicked.
omarchy-pkg-add xorg-xrandr
