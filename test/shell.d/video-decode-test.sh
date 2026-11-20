#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-install-video-decode"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# The Snapdragon check answers from a file, so each case picks the platform.
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/omarchy-hw-aarch64-qualcomm" <<'STUB'
#!/bin/bash
[[ -e $OMARCHY_TEST_QUALCOMM ]]
STUB
chmod +x "$test_tmp/bin/omarchy-hw-aarch64-qualcomm"
export OMARCHY_TEST_QUALCOMM="$test_tmp/qualcomm"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

new_home() {
  local home="$test_tmp/home-$1"
  mkdir -p "$home/.config"
  echo "$home"
}

run_helper() {
  HOME="$1" bash "$helper"
}

shipped="$ROOT/config/chromium-flags.conf"
features=$(grep -- '^--enable-features=' "$shipped")

touch "$OMARCHY_TEST_QUALCOMM"
home=$(new_home shipped)
cp "$shipped" "$home/.config/chromium-flags.conf"
cp "$shipped" "$home/.config/chrome-flags.conf"
run_helper "$home"
run_helper "$home"
# Chrome, the default, reads its own flags file beside Chromium's.
for conf in "$home/.config/chromium-flags.conf" "$home/.config/chrome-flags.conf"; do
  (( $(grep -c -- '^--use-angle=gles-egl$' "$conf") == 1 )) || fail "Snapdragon ${conf##*/} gets ANGLE on GLES once" "$(cat "$conf")"
  grep -Fxq -- "$features,AcceleratedVideoDecoder" "$conf" || fail "Snapdragon ${conf##*/} keeps its features and adds AcceleratedVideoDecoder once" "$(cat "$conf")"
  (( $(grep -c -- '^--enable-features=' "$conf") == 1 )) || fail "Snapdragon ${conf##*/} keeps one feature list" "$(cat "$conf")"
done
pass "a Snapdragon laptop gets the Chrome and Chromium settings once, even when the helper runs twice"

rm "$OMARCHY_TEST_QUALCOMM"
home=$(new_home other)
cp "$shipped" "$home/.config/chromium-flags.conf"
run_helper "$home"
cmp -s "$shipped" "$home/.config/chromium-flags.conf" || fail "other machines keep Chromium's flags" "$(cat "$home/.config/chromium-flags.conf")"
pass "other machines keep Chromium's flags"

touch "$OMARCHY_TEST_QUALCOMM"
home=$(new_home user-choices)
printf '%s\n' '--use-angle=vulkan' '--enable-features=AcceleratedVideoDecoder' >"$home/.config/chromium-flags.conf"
run_helper "$home"
[[ $(cat "$home/.config/chromium-flags.conf") == $'--use-angle=vulkan\n--enable-features=AcceleratedVideoDecoder' ]] ||
  fail "a Chromium backend and feature the user set stay as they are" "$(cat "$home/.config/chromium-flags.conf")"
pass "settings the user chose stay as they are"

home=$(new_home shared-lines)
printf '%s\n' '--enable-features=Foo --ozone-platform=wayland # mine' '# --use-angle=vulkan' >"$home/.config/chromium-flags.conf"
run_helper "$home"
[[ $(cat "$home/.config/chromium-flags.conf") == $'--enable-features=Foo,AcceleratedVideoDecoder --ozone-platform=wayland # mine\n# --use-angle=vulkan\n--use-angle=gles-egl' ]] ||
  fail "switches sharing a line or commented out are handled as Chromium reads them" "$(cat "$home/.config/chromium-flags.conf")"
home=$(new_home inline-angle)
printf '%s\n' '--ozone-platform=wayland --use-angle=vulkan' '--enable-features=AcceleratedVideoDecoder<Trial' >"$home/.config/chromium-flags.conf"
run_helper "$home"
[[ $(cat "$home/.config/chromium-flags.conf") == $'--ozone-platform=wayland --use-angle=vulkan\n--enable-features=AcceleratedVideoDecoder<Trial' ]] ||
  fail "a --use-angle mid-line and a feature with a trial stay as they are" "$(cat "$home/.config/chromium-flags.conf")"
home=$(new_home crlf)
printf '%s\r\n' '--enable-features=Foo' >"$home/.config/chromium-flags.conf"
run_helper "$home"
[[ $(head -n1 "$home/.config/chromium-flags.conf") == $'--enable-features=Foo,AcceleratedVideoDecoder\r' ]] ||
  fail "a CRLF line gets the feature ahead of its line ending" "$(od -c "$home/.config/chromium-flags.conf" | head -3)"
pass "Chromium switches are found and extended as its launcher reads them"

if (( EUID == 0 )); then
  skip "a Chromium flags file that can't be written fails the helper (root writes read-only files)"
else
  home=$(new_home chromium-readonly)
  printf '%s\n' '--enable-features=AcceleratedVideoDecoder' >"$home/.config/chromium-flags.conf"
  chmod 0444 "$home/.config/chromium-flags.conf"
  if run_helper "$home" 2>/dev/null; then
    fail "a Chromium flags file that can't be written fails the helper, even when the feature is already there"
  fi
  pass "a Chromium flags file that can't be written fails the helper, even when the feature is already there"

  home=$(new_home chrome-beside-readonly)
  printf '%s\n' '--ozone-platform=wayland' >"$home/.config/chromium-flags.conf"
  chmod 0444 "$home/.config/chromium-flags.conf"
  cp "$shipped" "$home/.config/chrome-flags.conf"
  if run_helper "$home" 2>/dev/null; then
    fail "a Chromium flags file that can't be written fails the helper beside Chrome's"
  fi
  conf=$home/.config/chrome-flags.conf
  grep -Fxq -- '--use-angle=gles-egl' "$conf" && grep -Fxq -- "$features,AcceleratedVideoDecoder" "$conf" ||
    fail "a Chromium flags file that can't be written doesn't hold back Chrome's" "$(cat "$conf")"
  pass "a Chromium flags file that can't be written fails the helper but doesn't hold back Chrome's"
fi

home=$(new_home bare)
printf '%s' '--ozone-platform=wayland' >"$home/.config/chromium-flags.conf"
run_helper "$home"
[[ $(cat "$home/.config/chromium-flags.conf") == $'--ozone-platform=wayland\n--use-angle=gles-egl\n--enable-features=AcceleratedVideoDecoder' ]] ||
  fail "a Chromium file without a trailing newline or feature list gets both flags on lines of their own" "$(cat "$home/.config/chromium-flags.conf")"
pass "a Chromium file without a trailing newline or feature list gets both flags on lines of their own"

home=$(new_home missing)
run_helper "$home"
[[ ! -e $home/.config/chromium-flags.conf ]] || fail "a missing Chromium flags file stays missing"
pass "a missing Chromium flags file stays missing"

home=$(new_home symlink)
cp "$shipped" "$test_tmp/flags-target.conf"
ln -s "$test_tmp/flags-target.conf" "$home/.config/chromium-flags.conf"
run_helper "$home"
[[ -L $home/.config/chromium-flags.conf ]] || fail "a symlinked Chromium file stays a symlink"
grep -Fxq -- "$features,AcceleratedVideoDecoder" "$test_tmp/flags-target.conf" || fail "the target of a symlinked Chromium file gets the feature"
pass "a symlinked Chromium file stays a symlink and its target gets the settings"
