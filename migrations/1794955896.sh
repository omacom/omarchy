echo "Disable dictation services that are not the selected backend"

config="$HOME/.config/omarchy/defaults/dictation"
[[ -f $config ]] || exit 0

backend=$(< "$config")
[[ $backend == "voxtype" || $backend == "superwhisper" || $backend == "hex" ]] || exit 0

for service in voxtype superwhisper hex; do
  if [[ $service != "$backend" ]]; then
    systemctl --user disable --now "$service.service" >/dev/null 2>&1 || true
  fi
done
