echo "Enable speaker tuning for the Flower Sakura (FRANQE0006)"

sku=$(cat /sys/class/dmi/id/product_sku 2>/dev/null || true)
if [[ ${sku,,} != "franqe0006" ]]; then
  exit 0
fi

if [[ ! -r $OMARCHY_PATH/default/audio/tunings/flower-sakura/tuning.conf ]]; then
  echo "Waiting for omarchy-settings to ship the flower-sakura speaker tuning"
  exit 75
fi

omarchy-pkg-add lsp-plugins-lv2

# An update from a TTY or SSH has no audio session yet, so keep this migration
# pending for the next graphical login without failing the update.
if ! pactl info >/dev/null 2>&1; then
  echo "Waiting for an audio session to apply speaker tuning"
  exit 75
fi

# Preserve an existing EasyEffects setup rather than failing updates when
# omarchy-audio-tuning refuses to coexist with it.
if pactl list sinks short 2>/dev/null | awk '{print $2}' | grep -qx easyeffects_sink ||
  pgrep -u "$(id -u)" -x easyeffects >/dev/null 2>&1 ||
  systemctl --user is-active --quiet easyeffects.service 2>/dev/null; then
  echo "Skipping automatic speaker tuning while EasyEffects is active. To switch later, stop EasyEffects and run: omarchy audio tuning on"
  exit 0
fi

if ! omarchy-audio-tuning on; then
  echo "Speaker tuning not applied yet. After logging in or rebooting, run: omarchy audio tuning on" >&2
  exit 1
fi
