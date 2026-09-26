echo "Give the XPS 16 its own speaker tuning"

# The XPS 16 was covered by the XPS 14's tuning. Re-apply only where that shared
# tuning is what is installed: a user who switched the tuning off, or replaced it
# with their own (the Speaker Calibrator writes the same file), keeps their choice.

fragment="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/omarchy-speaker-tuning.conf.d/90-tuning.conf"
tuning="$(omarchy-audio-tuning match 2>/dev/null || true)"

if [[ ${tuning##*/} == "dell-xps-16-2026" && -r $fragment ]] &&
  [[ "$(head -1 "$fragment")" == "# Dell XPS 14 / XPS 16 (2026) speaker tuning." ]]; then
  omarchy-audio-tuning on
fi
