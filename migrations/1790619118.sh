echo "Install Intel BE200/BE211 sleep reset hook"

if lspci -nn 2>/dev/null | grep -qE '\[8086:(e440|272b)\]'; then
  hook_src="$OMARCHY_PATH/default/systemd/system-sleep/iwlwifi-reset"
  hook_dir="${OMARCHY_SYSTEM_SLEEP_DIR:-/usr/lib/systemd/system-sleep}"
  hook_dest="$hook_dir/iwlwifi-reset"

  if [[ -f $hook_src ]]; then
    if [[ ! -f $hook_dest ]] || ! cmp -s "$hook_src" "$hook_dest"; then
      # Root runs this on every suspend, so it must not keep the owner of a dev-linked checkout.
      sudo install -D -m 0755 -o root -g root "$hook_src" "$hook_dest"
    fi
  fi
fi
