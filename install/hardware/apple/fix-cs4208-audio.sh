# Enable speakers on 12-inch MacBooks (MacBook9,1 / 2016 and MacBook10,1 / 2017).
# Mainline snd_hda_codec_cs420x detects the CS4208 but never runs the macOS
# init that powers the speaker amplifier, so PipeWire plays to a silent analog
# path. The out-of-tree module replays that init.
# MacBook8,1 (2015) is not supported by this driver.
# https://github.com/leifliddy/macbook12-audio-driver
# https://github.com/basecamp/omarchy/issues/2101

product_name="${OMARCHY_MACBOOK12_AUDIO_MODEL:-$(cat /sys/class/dmi/id/product_name 2>/dev/null)}"
if [[ $product_name == "MacBook9,1" || $product_name == "MacBook10,1" ]]; then
  echo "Detected 12-inch MacBook with CS4208 audio"

  systemd_dir="${OMARCHY_SYSTEMD_DIR:-/etc/systemd/system}"
  service_target="$systemd_dir/omarchy-cs4208-audio.service"
  if [[ -e $service_target || -L $service_target ]]; then
    if [[ -L $service_target || ! -f $service_target ]] ||
      ! cmp -s "$OMARCHY_INSTALL/hardware/apple/omarchy-cs4208-audio.service" "$service_target"; then
      echo "Preserving customized audio service: $service_target; reconcile it manually before retrying." >&2
      return 1
    fi
  fi
  omarchy-pkg-add macbook12-audio-driver-dkms

  install -Dm644 \
    "$OMARCHY_INSTALL/hardware/apple/omarchy-cs4208-audio.service" \
    "$systemd_dir/omarchy-cs4208-audio.service"
  systemctl daemon-reload
  systemctl enable omarchy-cs4208-audio.service
fi
