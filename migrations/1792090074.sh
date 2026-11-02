echo "Show the pointer in browser screen shares (xdph cursor mode)"

# Chromium's WebRTC portal client only requests the cursor mode it prefers,
# metadata, and sends no cursor_mode at all when the portal does not list it.
# xdg-desktop-portal-hyprland advertises only hidden and embedded, so those
# shares kept xdph's hidden default and viewers never saw the pointer.
# `screencopy:cursor_mode = 2` makes the session default embedded instead, so
# an unspecified client gets the pointer too. Apps that explicitly ask for
# hidden or embedded still get what they asked for.
#
# xdph reads its config only at startup, so existing installs with Omarchy's
# unmodified xdph.conf get the new default and a portal restart. A user who
# edited the file keeps their version; `omarchy-refresh-config hypr/xdph.conf`
# picks the default up manually.

xdph_config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/xdph.conf"
shipped="$OMARCHY_PATH/config/hypr/xdph.conf"

[[ -f $xdph_config && ! -L $xdph_config && -f $shipped ]] || exit 0
grep -q '^    cursor_mode' "$xdph_config" && exit 0

# Only replace copies that are still exactly a shipped default; both hashes
# below are historical contents of config/hypr/xdph.conf.
known_old_default_hash=(
  637899cd3926c4b8c758d3cb812cc1e7ac7643aca83a8e5030208234d064c839
  2fded88a27b89f33cbc2b64a1258117df74b591f39a84c78ec3504a7d3b09136
)
file_hash=$(sha256sum -- "$xdph_config") || exit 0
file_hash=${file_hash%% *}
is_old_default=0
for hash in "${known_old_default_hash[@]}"; do
  if [[ $file_hash == "$hash" ]]; then
    is_old_default=1
    break
  fi
done
(( is_old_default )) || exit 0

install -Dm644 -- "$shipped" "$xdph_config"

# The portal only reads xdph.conf at startup. A restart drops restore tokens,
# which remember the old hidden cursor, so a fresh share picks the new mode up.
if systemctl --user is-active --quiet xdg-desktop-portal-hyprland.service 2>/dev/null; then
  systemctl --user restart xdg-desktop-portal-hyprland.service >/dev/null 2>&1 || true
fi
