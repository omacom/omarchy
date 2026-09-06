# Late 2015 21.5-inch iMacs (iMac16,1 / iMac16,2) drive the built-in speakers
# as four digital CS4208 channels. Analog Stereo is the headphone DAC and is
# silent on those speakers, and Master hardware volume does not affect them.

if omarchy-hw-imac-cs4208; then
  mkdir -p ~/.config/wireplumber/wireplumber.conf.d/
  cp "$OMARCHY_PATH/default/wireplumber/wireplumber.conf.d/imac-cs4208-speakers.conf" \
    ~/.config/wireplumber/wireplumber.conf.d/
  rm -rf ~/.local/state/wireplumber/default-routes

  # Leave the hardware mixer wide open so software volume is the only attenuation.
  card=$(aplay -l 2>/dev/null | grep -i "CS4208 Analog" | head -1 | sed 's/card \([0-9]*\).*/\1/')
  if [[ -n $card ]]; then
    amixer -c "$card" set Master 100% unmute 2>/dev/null || true
    amixer -c "$card" set PCM 100% 2>/dev/null || true
  fi
fi
