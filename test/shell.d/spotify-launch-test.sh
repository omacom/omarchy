#!/bin/bash
#
# omarchy-launch-spotify must start Spotify on native Wayland and shrink it
# just enough that its layout fits a half-width tile on the focused monitor,
# leaving it alone where a half tile is already wide enough. A running window
# is focused instead of relaunched, and a spotify: link is handed to Spotify.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/usr/bin"

# The launcher only starts the packaged client, so point it at a stand-in.
sed "s|/usr/bin/spotify|$test_dir/usr/bin/spotify|g" "$ROOT/bin/omarchy-launch-spotify" >"$test_dir/launch"
printf '#!/bin/bash\n' >"$test_dir/usr/bin/spotify"
chmod +x "$test_dir/usr/bin/spotify"

cat >"$test_dir/bin/hyprctl" <<'STUB'
#!/bin/bash
case "$*" in
  "monitors -j") printf '[{"focused":false,"width":3840,"height":2160,"scale":1,"transform":0},{"focused":true,"width":%s,"height":%s,"scale":%s,"transform":%s}]\n' "$WIDTH" "$HEIGHT" "$SCALE" "${TRANSFORM:-0}" ;;
  "clients -j") printf '%s\n' "${CLIENTS:-[]}" ;;
  dispatch*) printf '%s\n' "${*:2}" >>"$DISPATCH_LOG" ;;
esac
STUB
cat >"$test_dir/bin/uwsm-app" <<'STUB'
#!/bin/bash
shift
printf '%s\n' "${@:2}"
STUB
cat >"$test_dir/bin/setsid" <<'STUB'
#!/bin/bash
exec "$@"
STUB
chmod +x "$test_dir/bin/"*

mkdir -p "$test_dir/home/.config"

launch() {
  HOME="$test_dir/home" XDG_CONFIG_HOME="${XDG_CONFIG_HOME_OVERRIDE:-}" PATH="$test_dir/bin:$PATH" DISPATCH_LOG="$test_dir/dispatch.log" bash "$test_dir/launch" "$@"
}

expect_flags() {
  local monitor="$1" expected="$2" description="$3" actual width height scale transform

  IFS=' ' read -r width height scale transform <<<"$monitor"
  actual=$(WIDTH=$width HEIGHT=$height SCALE=$scale TRANSFORM=${transform:-0} launch)
  [[ $actual == "$expected" ]] || fail "$description" "$actual"
  pass "$description"
}

wayland="--ozone-platform=wayland"

expect_flags "1920 1080 1" "$wayland"$'\n--force-device-scale-factor=0.96' "a 1080p monitor at 1x shrinks Spotify slightly"
expect_flags "3840 2160 2" "$wayland"$'\n--force-device-scale-factor=0.96' "a 4K monitor at 2x shrinks Spotify slightly"
expect_flags "1920 1080 1.25" "$wayland"$'\n--force-device-scale-factor=0.768' "a 1080p monitor at 1.25x fits Spotify in a half tile"
expect_flags "1920 1080 1.5" "$wayland"$'\n--force-device-scale-factor=0.64' "a 1080p monitor at 1.5x fits Spotify in a half tile"
expect_flags "1920 1080 2" "$wayland"$'\n--force-device-scale-factor=0.48' "a 1080p monitor at 2x fits Spotify in a half tile"
expect_flags "2560 1600 1.6" "$wayland"$'\n--force-device-scale-factor=0.8' "a 2560px monitor at 1.6x fits Spotify in a half tile"
expect_flags "2560 1440 1" "$wayland" "a 1440p monitor at 1x leaves Spotify at its own scale"
expect_flags "1920 1080 1 1" "$wayland"$'\n--force-device-scale-factor=0.54' "a portrait monitor measures its rotated width"

# A scale the user set in their own Spotify flags wins, since Spotify's
# launcher already passes it along; a commented-out one does not count.
printf -- '--force-device-scale-factor=1\n' >"$test_dir/home/.config/spotify-flags.conf"
expect_flags "1920 1080 1.25" "$wayland" "a scale in the user's Spotify flags replaces the half-tile fit"

printf -- '# --force-device-scale-factor=1\n' >"$test_dir/home/.config/spotify-flags.conf"
expect_flags "1920 1080 1.25" "$wayland"$'\n--force-device-scale-factor=0.768' "a commented-out scale in the user's Spotify flags is ignored"
rm "$test_dir/home/.config/spotify-flags.conf"

mkdir -p "$test_dir/xdg"
printf -- '--force-device-scale-factor=1\n' >"$test_dir/xdg/spotify-flags.conf"
XDG_CONFIG_HOME_OVERRIDE="$test_dir/xdg" expect_flags "1920 1080 1.25" "$wayland" "the user's Spotify flags are read from XDG_CONFIG_HOME"

actual=$(WIDTH=2560 HEIGHT=1440 SCALE=1 launch spotify:track:abc)
[[ $actual == $'--ozone-platform=wayland\n--uri=spotify:track:abc' ]] || fail "a spotify: link is handed to Spotify" "$actual"
pass "a spotify: link is handed to Spotify"

actual=$(WIDTH=1920 HEIGHT=1080 SCALE=1.25 CLIENTS='[{"class":"spotify","title":"Spotify Premium","address":"0xabc"}]' launch)
[[ -z $actual ]] && grep -q 'address:0xabc' "$test_dir/dispatch.log" || fail "a running Spotify is focused instead of relaunched" "$actual"
pass "a running Spotify is focused instead of relaunched"

actual=$(WIDTH=2560 HEIGHT=1440 SCALE=1 CLIENTS='[{"class":"org.gnome.Nautilus","title":"spotify-screenshots","address":"0xdef"}]' launch)
[[ $actual == "--ozone-platform=wayland" ]] || fail "a window merely titled after Spotify does not count as Spotify" "$actual"
pass "a window merely titled after Spotify does not count as Spotify"

# Without Spotify, a link must survive the trip through the installer's shell
# command line intact, without any part of it running as a command.
sed "s|/usr/bin/spotify|$test_dir/missing/spotify|g" "$ROOT/bin/omarchy-launch-spotify" >"$test_dir/launch-missing"
cat >"$test_dir/bin/omarchy-launch-floating-terminal-with-presentation" <<'STUB'
#!/bin/bash
bash -c "$*"
STUB
cat >"$test_dir/bin/omarchy-install-service-spotify" <<'STUB'
#!/bin/bash
printf '%s|' "$#" "$@" >"$INSTALL_LOG"
STUB
chmod +x "$test_dir/bin/omarchy-launch-floating-terminal-with-presentation" "$test_dir/bin/omarchy-install-service-spotify"

install_with() {
  rm -f "$test_dir/install.log"
  (cd "$test_dir" && HOME="$test_dir" PATH="$test_dir/bin:$PATH" INSTALL_LOG="$test_dir/install.log" CLIENTS='[]' bash "$test_dir/launch-missing" "$@")
}

link='spotify:track:abc;touch "$HOME/pwned" $(touch pwned2)'
install_with "$link"
[[ $(<"$test_dir/install.log") == "1|$link|" ]] || fail "a spotify: link is handed to the installer intact" "$(<"$test_dir/install.log")"
[[ ! -e $test_dir/pwned && ! -e $test_dir/pwned2 ]] || fail "a spotify: link is never run as a command"
pass "a spotify: link is handed to the installer intact"

install_with
[[ $(<"$test_dir/install.log") == "0|" ]] || fail "the installer starts without a link when none is given" "$(<"$test_dir/install.log")"
pass "the installer starts without a link when none is given"
