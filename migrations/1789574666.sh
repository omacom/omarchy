echo "Enable Wayland input methods in Chromium-based browsers"

# Chromium ignores the Wayland text-input protocol unless --enable-wayland-ime is
# set, so fcitx5 never reaches Brave and friends: no candidate window, no CJK
# input, while every GTK/Qt app on the same session works. New installs get the
# flag from config/chromium-flags.conf; existing ones are patched here.
for flags_file in ~/.config/chromium-flags.conf ~/.config/chrome-flags.conf \
  ~/.config/brave-flags.conf ~/.config/brave-origin-flags.conf \
  ~/.config/microsoft-edge-stable-flags.conf; do
  if [[ -f $flags_file ]] && ! grep -qx -- "--enable-wayland-ime" "$flags_file"; then
    printf '%s\n' "--enable-wayland-ime" >>"$flags_file"
  fi
done
