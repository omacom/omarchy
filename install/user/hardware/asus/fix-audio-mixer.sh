# Fix audio volume on Asus ROG laptops by using a soft mixer.

if omarchy-hw-asus-rog; then
  mkdir -p ~/.config/wireplumber/wireplumber.conf.d/
  cp "$OMARCHY_PATH/default/wireplumber/wireplumber.conf.d/alsa-soft-mixer.conf" ~/.config/wireplumber/wireplumber.conf.d/
  rm -rf ~/.local/state/wireplumber/default-routes

  # With the soft mixer, PipeWire no longer turns the active output's hardware
  # controls on, but switching outputs still turns the other one off. These
  # mixer paths turn the active output on whenever it is selected.
  paths=~/.config/alsa-card-profile/mixer/paths
  mkdir -p "$paths"
  cp "$OMARCHY_PATH"/default/alsa-card-profile/mixer/paths/analog-output-{speaker,headphones}.conf "$paths/"
  # Both paths include this file relative to their own directory.
  ln -sfn /usr/share/alsa-card-profile/mixer/paths/analog-output.conf.common "$paths/analog-output.conf.common"

  # Unmute the Master control on the Realtek card (often muted by default)
  card=$(aplay -l 2>/dev/null | grep -iE "ALC[0-9]+ Analog" | head -1 | sed 's/card \([0-9]*\).*/\1/')
  if [[ -n $card ]]; then
    amixer -c "$card" set Master 80% unmute >/dev/null 2>&1 || true
  fi
fi
