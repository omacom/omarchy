echo "Give the XPS 16 its own speaker tuning"

# The XPS 16 was covered by the XPS 14's tuning. Re-apply only where that shared
# tuning is what is installed: a user who switched the tuning off, or replaced it
# with their own (the Speaker Calibrator writes the same file), keeps their choice.

fragment="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/omarchy-speaker-tuning.conf.d/90-tuning.conf"
tuning="$(omarchy-audio-tuning match 2>/dev/null || true)"

if [[ ${tuning##*/} == "dell-xps-16-2026" && -r $fragment ]] &&
  [[ "$(head -1 "$fragment")" == "# Dell XPS 14 / XPS 16 (2026) speaker tuning." ]]; then
  shared="$(mktemp)"
  trap 'rm -f "$shared"' EXIT
  cp "$fragment" "$shared"
  output="$(pactl get-default-sink 2>/dev/null || true)"
  sinks="$(pactl list sinks short 2>/dev/null | cut -f1,2 || true)"
  routes="$(pactl list sink-inputs short 2>/dev/null | cut -f1,2 || true)"

  # A tuning that fails to come up is removed, and the retry would then find
  # nothing to replace.
  if ! omarchy-audio-tuning on; then
    [[ -e $fragment ]] || install -Dm644 "$shared" "$fragment"
    exit 1
  fi

  # on makes the tuning the default output and moves every stream onto it, and a
  # stream moved to the default follows the default from then on. An update must
  # leave headphone and HDMI playback where it was, so put the default and each
  # stream back by name, sending what played on the speakers to the new tuning.
  speakers="$(omarchy-audio-tuning fronted-sink 2>/dev/null || true)"
  if [[ -n $output && $output != "omarchy_speaker_tuning" && $output != "$speakers" ]]; then
    pactl set-default-sink "$output" 2>/dev/null || true
  fi
  while read -r stream sink; do
    sink="$(awk -v i="$sink" '$1 == i {print $2; exit}' <<<"$sinks")"
    if [[ -n $speakers && $sink == "$speakers" ]]; then
      sink=omarchy_speaker_tuning
    fi
    if [[ -n $stream && -n $sink ]]; then
      pactl move-sink-input "$stream" "$sink" 2>/dev/null || true
    fi
  done <<<"$routes"
fi
