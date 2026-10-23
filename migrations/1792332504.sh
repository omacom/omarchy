echo "Install the speaker tuning for the Framework Laptop 13 Pro (Intel Core Ultra Series 3)"

# Speaker tunings are PipeWire filter-chain drop-ins gated on a hardware
# predicate, so this is a no-op everywhere else. The limiter is an LV2 plugin and
# the graph will not instantiate without it.
if [[ $(omarchy-audio-tuning match 2>/dev/null) != */framework-13-pro-intel ]]; then
  exit 0
fi

omarchy-pkg-add lsp-plugins-lv2

# Owners of this laptop are likely to run EasyEffects for the same job, and
# `omarchy-audio-tuning on` refuses while it runs, since EasyEffects would grab
# the audio back. Leave the choice to them rather than fail and hold up every
# migration behind this one.
if pgrep -u "$(id -u)" -x easyeffects >/dev/null; then
  echo "EasyEffects is running, so the speaker tuning was not switched on."
  echo "To use it instead, stop EasyEffects and run: omarchy audio tuning on"
else
  omarchy-audio-tuning on
fi
