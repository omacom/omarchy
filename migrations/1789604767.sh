echo "Stop logind suspending on lid close so Hyprland can debounce"

dropin=/etc/systemd/logind.conf.d/30-lid-ignore.conf
src="$OMARCHY_PATH/etc/systemd/logind.conf.d/30-lid-ignore.conf"

if [[ -f $src && ! -f $dropin ]]; then
  sudo install -Dm644 "$src" "$dropin"
fi

[[ -f $dropin ]] || exit 0

if ! grep -q '^HandleLidSwitch=ignore' "$dropin"; then
  exit 0
fi

sudo systemctl reload systemd-logind.service
