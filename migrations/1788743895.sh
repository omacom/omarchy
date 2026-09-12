echo "Install qt5-wayland so Google Chrome can start under Wayland"

# Chrome's libqt5_shim.so needs the Qt5 Wayland platform plugin. Omarchy sets
# QT_QPA_PLATFORM=wayland;xcb globally, and without qt5-wayland Chrome aborts
# at startup (issue #10488). Only pull it in when Chrome is already present so
# machines that never installed Chrome stay free of the Qt5 stack.

if omarchy-pkg-present google-chrome || omarchy-cmd-present google-chrome-stable; then
  omarchy-pkg-add qt5-wayland
fi
