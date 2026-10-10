echo "Keep ASUS ROG speakers and headphones on when switching between them"

# Only the ROG soft mixer leaves outputs off after a switch. Anyone who removed
# it has PipeWire driving the hardware mixer again and needs nothing.
if omarchy-hw-asus-rog && [[ -f $HOME/.config/wireplumber/wireplumber.conf.d/alsa-soft-mixer.conf ]]; then
  paths="$HOME/.config/alsa-card-profile/mixer/paths"
  mkdir -p "$paths"

  # A path the user already overrides is theirs; leave it alone.
  for path in analog-output-speaker.conf analog-output-headphones.conf; do
    [[ -e $paths/$path ]] || cp "$OMARCHY_PATH/default/alsa-card-profile/mixer/paths/$path" "$paths/"
  done
  if [[ ! -e $paths/analog-output.conf.common && ! -L $paths/analog-output.conf.common ]]; then
    ln -s /usr/share/alsa-card-profile/mixer/paths/analog-output.conf.common "$paths/analog-output.conf.common"
  fi

  # Installs on codecs other than ALC285 never got the install-time Master unmute,
  # and neither path turns Master on. Set it like a fresh install does, but only
  # while it is muted or at zero, so a level that already works stays put.
  card=$(aplay -l 2>/dev/null | grep -m1 -oiP 'card \K[0-9]+(?=:.*ALC[0-9]+ Analog)' || true)
  if [[ -n $card ]]; then
    master=$(amixer -c "$card" sget Master 2>/dev/null || true)
    if [[ $master == *"[off]"* || $master == *"[0%]"* ]]; then
      amixer -c "$card" set Master 80% unmute >/dev/null 2>&1 || true
    fi
  fi

  # WirePlumber loads mixer paths when it opens the card; restart it if it is running.
  systemctl --user try-restart wireplumber.service 2>/dev/null || true
fi
