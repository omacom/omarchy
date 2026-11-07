# Publish the sleep hook that pauses WirePlumber across a Bluetooth adapter
# reset. omarchy-settings does not install it: the hook only execs the command
# shipped by the omarchy package. See omarchy-system-sleep-wireplumber.

hook_src="${OMARCHY_WIREPLUMBER_SLEEP_HOOK_SRC:-$OMARCHY_PATH/default/systemd/system-sleep/wireplumber-bluetooth}"
hook_dst="${OMARCHY_WIREPLUMBER_SLEEP_HOOK_DST:-/usr/lib/systemd/system-sleep/wireplumber-bluetooth}"

if [[ ! -f $hook_src ]]; then
  echo "Missing WirePlumber sleep hook source: $hook_src" >&2
  return 1
fi

if [[ -f $hook_dst && -x $hook_dst ]] && cmp -s "$hook_src" "$hook_dst"; then
  return 0
fi

install -Dm755 "$hook_src" "$hook_dst"
