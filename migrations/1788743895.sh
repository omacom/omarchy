echo "Install qt5-wayland so Google Chrome can start under Wayland"

# Chrome's Qt mode picks Qt5 whenever qt5-base is installed, and without qt5-wayland it aborts
# under QT_QPA_PLATFORM=wayland;xcb (issue #10488). Without qt5-base it uses Qt6, so leave those alone.

if omarchy-pkg-present qt5-base && { omarchy-pkg-present google-chrome || omarchy-cmd-present google-chrome-stable; }; then
  omarchy-pkg-add qt5-wayland
fi
