echo "Rebind the Lenovo 300e touchscreen after resume"

if ! omarchy-hw-match "300e 2nd G"; then
  exit 0
fi

source="$OMARCHY_PATH/default/systemd/system-sleep/lenovo-300e-touchscreen"
target=/usr/lib/systemd/system-sleep/lenovo-300e-touchscreen

if cmp -s "$source" "$target" && [[ -x $target ]]; then
  exit 0
fi

sudo install -Dm755 "$source" "$target"
