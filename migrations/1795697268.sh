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
if ! omarchy-audio-tuning on; then
  echo "Speaker tuning not applied yet. After logging in or rebooting, run: omarchy audio tuning on" >&2
  exit 1
fi
