if [[ ${OMARCHY_SETUP_CONTEXT:-} == "iso-chroot" || ${OMARCHY_SETUP_CONTEXT:-} == "provision-owner" ]] &&
  omarchy-hw-rog-ally && omarchy-cmd-present wvkbd-mobintl; then
  apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  launcher="$apps/omarchy-desktop-keyboard.desktop"
  if [[ ! -e $launcher && ! -L $launcher ]]; then
    mkdir -p "$apps"
    ln -s "$OMARCHY_PATH/default/omarchy/applications/Desktop Keyboard.desktop" "$launcher"
    update-desktop-database "$apps"
  fi
fi
