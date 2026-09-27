# Keep the Dell XPS 14 (DA14260) microphone from suspending, since waking it
# clips the start of recordings. Leave an existing user copy alone.
if omarchy-hw-match "DA14260"; then
  target=~/.config/wireplumber/wireplumber.conf.d/xps14-mic-keep-ready.conf

  if [[ ! -e $target ]]; then
    mkdir -p "$(dirname "$target")"
    cp "$OMARCHY_PATH/default/wireplumber/wireplumber.conf.d/xps14-mic-keep-ready.conf" "$target"
  fi
fi
