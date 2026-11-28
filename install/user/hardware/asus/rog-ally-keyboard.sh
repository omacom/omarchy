if [[ ${OMARCHY_SETUP_CONTEXT:-} == "iso-chroot" || ${OMARCHY_SETUP_CONTEXT:-} == "provision-owner" ]] &&
  omarchy-hw-rog-ally && omarchy-cmd-present wvkbd-mobintl; then
  apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  launcher="$apps/omarchy-desktop-keyboard.desktop"
  if [[ ! -e $launcher && ! -L $launcher ]] &&
    renderer_options=$(wvkbd-mobintl --help 2>&1) &&
    [[ $renderer_options == *--non-exclusive* && $renderer_options == *--wayland-layer* && $renderer_options == *--output* ]]; then
    mkdir -p "$apps"
    ln -sT "$OMARCHY_PATH/default/omarchy/applications/Desktop Keyboard.desktop" "$launcher"
  fi
fi
