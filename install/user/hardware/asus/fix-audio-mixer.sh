# Fix audio volume on Asus ROG laptops by using a soft mixer.

# RC71L is a handheld; do not apply the ROG laptop setup.
if omarchy-hw-asus-rog && ! omarchy-hw-rog-ally; then
  mkdir -p ~/.config/wireplumber/wireplumber.conf.d/
  cp "$OMARCHY_PATH/default/wireplumber/wireplumber.conf.d/alsa-soft-mixer.conf" ~/.config/wireplumber/wireplumber.conf.d/
  rm -rf ~/.local/state/wireplumber/default-routes

  # Unmute the Master control on the ALC285 card (often muted by default)
  card=$(aplay -l 2>/dev/null | grep -i "ALC285" | head -1 | sed 's/card \([0-9]*\).*/\1/')
  if [[ -n $card ]]; then
    amixer -c "$card" set Master 80% unmute 2>/dev/null
  fi
fi
