echo "Share cameras between apps through PipeWire and warn when one is locked over V4L2"

# A V4L2 camera streams to one process at a time, so a call in Slack leaves
# Chrome reporting no camera at all, with nothing to say why. Chromium-based
# browsers can take cameras through PipeWire instead, where any number of apps
# share one stream. The shipped flags file now asks for that; every browser
# flags file already copied from it gets the same feature, on its existing
# --enable-features line because Chromium keeps only the last one it is given.

feature="WebRtcPipeWireCamera"

flag_files=(
  "$HOME/.config/chromium-flags.conf"
  "$HOME/.config/chrome-flags.conf"
  "$HOME/.config/google-chrome-flags.conf"
  "$HOME/.config/google-chrome-stable-flags.conf"
  "$HOME/.config/brave-flags.conf"
  "$HOME/.config/brave-browser-flags.conf"
  "$HOME/.config/brave-origin-flags.conf"
  "$HOME/.config/brave-origin-beta-flags.conf"
  "$HOME/.config/microsoft-edge-flags.conf"
  "$HOME/.config/microsoft-edge-stable-flags.conf"
  "$HOME/.config/opera-flags.conf"
  "$HOME/.config/vivaldi-flags.conf"
  "$HOME/.config/helium-flags.conf"
)

for file in "${flag_files[@]}"; do
  [[ -f $file ]] || continue
  grep -qF "$feature" "$file" && continue

  if grep -q '^--enable-features=' "$file"; then
    sed -i -E \
      -e "s/^--enable-features=(.*[^,])$/--enable-features=\1,$feature/" \
      -e "s/^--enable-features=,?$/--enable-features=$feature/" \
      "$file"
  else
    [[ -z $(tail -c1 "$file") ]] || echo >> "$file"
    echo "--enable-features=$feature" >> "$file"
  fi
done
