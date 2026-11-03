#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A theme switch snapshots the portrait twin next to its plain snapshot, and
# removes both together.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
source <(awk '/^(is_video_path|snapshot_background_path|remove_background_snapshots)\(\) \{/ { c=1 } c { print } c && /^}$/ { c=0 }' "$ROOT/bin/omarchy-theme-set")
BACKGROUND_TRANSITION_CACHE="$test_tmp/cache/background-transitions"
mkdir -p "$test_tmp/theme/backgrounds/portrait"
printf 'plain\n' >"$test_tmp/theme/backgrounds/1-moonrise.png"
printf 'twin\n' >"$test_tmp/theme/backgrounds/portrait/1-moonrise.png"
printf 'lonely\n' >"$test_tmp/theme/backgrounds/2-lonely.png"
mkdir -p "$test_tmp/config/omarchy/backgrounds/tokyo/portrait" "$test_tmp/Pictures/portrait"
printf 'user\n' >"$test_tmp/config/omarchy/backgrounds/tokyo/3-user.png"
printf 'user twin\n' >"$test_tmp/config/omarchy/backgrounds/tokyo/portrait/3-user.png"
printf 'photo\n' >"$test_tmp/Pictures/beach.png"
printf 'other photo\n' >"$test_tmp/Pictures/portrait/beach.png"
twin_snapshot=$(snapshot_background_path "$test_tmp/theme/backgrounds/1-moonrise.png" next)
lonely_snapshot=$(snapshot_background_path "$test_tmp/theme/backgrounds/2-lonely.png" previous)
[[ $(cat "$BACKGROUND_TRANSITION_CACHE/portrait/${twin_snapshot##*/}" 2>/dev/null) == twin ]] || fail "a theme switch snapshots the portrait twin next to its plain snapshot"
[[ ! -e $BACKGROUND_TRANSITION_CACHE/portrait/${lonely_snapshot##*/} ]] || fail "a background without a twin snapshots no twin"
user_snapshot=$(snapshot_background_path "$test_tmp/config/omarchy/backgrounds/tokyo/3-user.png" user)
[[ $(cat "$BACKGROUND_TRANSITION_CACHE/portrait/${user_snapshot##*/}" 2>/dev/null) == "user twin" ]] || fail "a user background snapshots its portrait twin"
photo_snapshot=$(snapshot_background_path "$test_tmp/Pictures/beach.png" photo)
[[ ! -e $BACKGROUND_TRANSITION_CACHE/portrait/${photo_snapshot##*/} ]] || fail "a picture outside a backgrounds folder snapshots no twin"
remove_background_snapshots "$twin_snapshot" "$lonely_snapshot" "$user_snapshot" "$photo_snapshot"
[[ -z $(find "$BACKGROUND_TRANSITION_CACHE" -type f) ]] || fail "removing snapshots removes their twins"
pass "theme switch snapshots and removes portrait twins with their backgrounds"

# The plugin itself, on the running compositor: the first screen is made
# portrait and shows the twin, the others keep the plain file.
require_compositor "background portrait twins"
require_command quickshell
require_command magick

stage=$(mktemp -d)
trap 'rm -rf "$test_tmp" "$stage"' EXIT
mkdir -p "$stage/home/.local/state/omarchy/current" "$stage/home/theme/backgrounds/portrait"
ln -s "$ROOT/shell/plugins/background" "$stage/background"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
magick -size 256x128 xc:red "$stage/home/theme/backgrounds/1-red.png"
magick -size 128x256 xc:blue "$stage/home/theme/backgrounds/portrait/1-red.png"
magick -size 256x128 xc:green "$stage/home/theme/backgrounds/2-green.png"
magick -size 128x256 xc:yellow "$stage/home/theme/backgrounds/portrait/2-green.png"
magick -size 256x128 xc:magenta "$stage/home/theme/backgrounds/3-lonely.png"
ln -s "$stage/home/theme" "$stage/home/.local/state/omarchy/current/theme"
ln -s "$stage/home/theme/backgrounds/1-red.png" "$stage/home/.local/state/omarchy/current/background"
cp "$SHELL_TEST_DIR/fixtures/background-portrait-twins/shell.qml" "$stage/shell.qml"
output=$(HOME="$stage/home" timeout 20 quickshell -p "$stage" --no-color 2>&1) || fail "portrait twin fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* && $output != *"RESULT fail"* ]] || fail "portrait screens show the twin and landscape screens the plain file" "$output"
if rg -q 'ReferenceError|TypeError|Unable to assign|Binding loop' <<<"$output"; then
  fail "portrait twin fixture has no QML errors" "$output"
fi
pass "a portrait screen shows the twin the probe found, through boot and reveals"
pass "a background without a twin shows the plain file on every screen"
pass "a forced reload of the same path probes the twin again"
