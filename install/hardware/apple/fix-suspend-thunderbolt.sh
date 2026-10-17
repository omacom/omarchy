# The MacBookPro14,1 never wakes from lid-close sleep: its Alpine Ridge
# Thunderbolt controller hangs the platform phase of suspend. Detach the
# controller around sleep with a system-sleep hook.
hook_src="${OMARCHY_APPLE_TB_HOOK_SRC:-$OMARCHY_PATH/default/systemd/system-sleep/apple-thunderbolt-detach}"
hook_dst="${OMARCHY_APPLE_TB_HOOK_DST:-/usr/lib/systemd/system-sleep/apple-thunderbolt-detach}"

if omarchy-hw-match "MacBookPro14,1"; then
  install -Dm755 "$hook_src" "$hook_dst"
fi
