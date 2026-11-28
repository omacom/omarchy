echo "Show the mouse cursor in Chromium and Electron screen shares"

# Chromium and Electron's WebRTC portal client only requests metadata cursor
# mode, which xdg-desktop-portal-hyprland does not advertise, so those apps
# omit cursor_mode in SelectSources and fall back to xdph's hidden default.
# Setting screencopy:cursor_mode = 2 defaults unspecified clients to an
# embedded cursor while still honoring any cursor_mode a client asks for.
#
# Only replace copies that still match one of Omarchy's shipped defaults so
# user-modified or symlink-managed configs stay untouched. Users with custom
# configs can add `cursor_mode = 2` under `screencopy { ... }` or run
# `omarchy-refresh-config hypr/xdph.conf`.

xdph_config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/xdph.conf"
xdph_dir=$(dirname "$xdph_config")
shipped="$OMARCHY_PATH/config/hypr/xdph.conf"

[[ -f $xdph_config && ! -L $xdph_config && ! -L $xdph_dir ]] || exit 0

# Historical sha256 hashes of config/hypr/xdph.conf (commits c1fca69de and
# abffb0abf; matches the hypr/xdph.conf rows in bin/omarchy-upgrade-to-quattro).
case $(sha256sum <"$xdph_config") in
  637899cd3926c4b8c758d3cb812cc1e7ac7643aca83a8e5030208234d064c839* | \
    2fded88a27b89f33cbc2b64a1258117df74b591f39a84c78ec3504a7d3b09136*) ;;
  *)
    exit 0
    ;;
esac

# config/** ships in omarchy-settings while migrations/** ships in omarchy.
# Wait until omarchy-settings delivers the updated hypr/xdph.conf.
if [[ ! -f $shipped ]] || ! grep -qE '^[[:space:]]*(screencopy:)?cursor_mode[[:space:]]*=[[:space:]]*2([[:space:]]|#|$)' "$shipped"; then
  echo "Waiting for the omarchy-settings package that ships the updated hypr/xdph.conf" >&2
  exit 75
fi

# Stage beside the target and move into place atomically so a failed write
# never leaves a partial config behind.
staged=$(mktemp "$xdph_dir/xdph.conf.new.XXXXXX")
trap 'rm -f -- "$staged"' EXIT
install -m 0644 -- "$shipped" "$staged"
mv -fT -- "$staged" "$xdph_config"

# xdph reads xdph.conf only at startup; restart it when running in a live
# desktop session so new screen shares pick up the embedded cursor default.
# Note: xdg-desktop-portal itself persists restore tokens across xdph restarts,
# so a share that skips the picker via an older token keeps its saved cursor
# choice until the source is picked again.
if systemctl --user is-active --quiet xdg-desktop-portal-hyprland.service 2>/dev/null; then
  if ! systemctl --user restart xdg-desktop-portal-hyprland.service; then
    echo "Failed to restart xdg-desktop-portal-hyprland; restart it or log out to apply the new cursor mode." >&2
  fi
fi
