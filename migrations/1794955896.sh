echo "Disable dictation services that are not the selected backend"

config="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/defaults/dictation"
[[ -s $config ]] || exit 0

exec 9> "$config.lock"
flock -w 5 9
backend=$(omarchy-default-dictation 2>/dev/null) || exit 0
[[ $backend == "voxtype" || $backend == "superwhisper" || $backend == "hex" ]] || exit 0

systemctl --user show-environment 9>&- >/dev/null
for service in voxtype superwhisper hex; do
  if [[ $service != "$backend" ]] && systemctl --user cat "$service.service" 9>&- >/dev/null 2>&1; then
    systemctl --user disable --now "$service.service" 9>&- >/dev/null
  fi
done
