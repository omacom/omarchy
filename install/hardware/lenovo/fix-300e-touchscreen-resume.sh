# Rebind the ELAN238E touchscreen after resume on the Lenovo 300e 2nd Gen.
# The device stays registered through suspend but stops sending touches.

if omarchy-hw-match "300e 2nd Gen"; then
  sudo install -Dm755 \
    "$OMARCHY_PATH/default/systemd/system-sleep/lenovo-300e-touchscreen" \
    /usr/lib/systemd/system-sleep/lenovo-300e-touchscreen
fi
