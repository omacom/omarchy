echo "Detach the Thunderbolt controller around sleep on the MacBookPro14,1"

# Existing installs predate the install-time hook, and their machines never wake
# from a lid close. Install only a missing hook so administrator changes survive.
hook_src="${OMARCHY_APPLE_TB_HOOK_SRC:-$OMARCHY_PATH/default/systemd/system-sleep/apple-thunderbolt-detach}"
hook_dst="${OMARCHY_APPLE_TB_HOOK_DST:-/usr/lib/systemd/system-sleep/apple-thunderbolt-detach}"

omarchy-hw-match "MacBookPro14,1" || exit 0
[[ -e $hook_dst ]] && exit 0

sudo install -Dm755 "$hook_src" "$hook_dst"
