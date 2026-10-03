echo "Rebind the Lenovo 300e touchscreen after resume"

if ! omarchy-hw-match "300e 2nd Gen"; then
  exit 0
fi

sudo install -Dm755 \
  "$OMARCHY_PATH/default/systemd/system-sleep/lenovo-300e-touchscreen" \
  /usr/lib/systemd/system-sleep/lenovo-300e-touchscreen
