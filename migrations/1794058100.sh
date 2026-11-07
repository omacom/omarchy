echo "Install the WirePlumber hook that keeps Bluetooth audio alive across resume"

# Fresh installs publish this from install/config/wireplumber-sleep.sh and then
# mark migrations complete. Existing installs never rerun that script.

hook_src="${OMARCHY_WIREPLUMBER_SLEEP_HOOK_SRC:-$OMARCHY_PATH/default/systemd/system-sleep/wireplumber-bluetooth}"
hook_dst="${OMARCHY_WIREPLUMBER_SLEEP_HOOK_DST:-/usr/lib/systemd/system-sleep/wireplumber-bluetooth}"

if [[ ! -f $hook_src ]]; then
  echo "Missing WirePlumber sleep hook source: $hook_src" >&2
  exit 1
fi

if [[ -f $hook_dst && -x $hook_dst ]] && cmp -s "$hook_src" "$hook_dst"; then
  exit 0
fi

sudo install -Dm755 "$hook_src" "$hook_dst"
