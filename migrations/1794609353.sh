echo "Keep the Lenovo Yoga Slim 7x from waking itself in deep suspend with the lid open"

hook=/usr/lib/systemd/system-sleep/yoga-slim7x-lid-wake

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "83ED" && [[ ! -e $hook ]]; then
  sudo install -Dm755 "$OMARCHY_PATH/default/systemd/system-sleep/yoga-slim7x-lid-wake" "$hook"
fi
