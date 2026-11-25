echo "Enable speaker tuning for the Dell XPS 16 (DX16263, N1x)"

sku=$(cat /sys/class/dmi/id/product_sku 2>/dev/null || true)
if [[ ${sku,,} != "0d8e" ]]; then
  exit 0
fi

if [[ ! -r $OMARCHY_PATH/default/audio/tunings/dell-xps-16-n1x/tuning.conf ]]; then
  echo "Waiting for omarchy-settings to ship the dell-xps-16-n1x speaker tuning"
  exit 75
fi

omarchy-pkg-add lsp-plugins-lv2
if ! omarchy-audio-tuning on; then
  echo "Speaker tuning not applied yet. After logging in or rebooting, run: omarchy audio tuning on" >&2
  exit 1
fi
