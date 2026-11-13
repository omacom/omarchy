#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

packages="$ROOT/install/omarchy-base.packages"

grep -qxF omasnap "$packages" || fail "fresh installs include Omasnap"
! grep -qxF tensaku "$packages" || fail "fresh installs no longer include Tensaku"
! grep -qxF satty "$packages" || fail "fresh installs no longer include Satty"
pass "fresh installs use Omasnap as the screenshot tool"

grep -Fq 'namespace = "^omasnap$"' "$ROOT/default/hypr/apps/screenshot-selection.lua" ||
  fail "Omasnap has a layer rule"
! grep -Fq 'dev.tensaku.Tensaku' "$ROOT/default/hypr/apps/system.lua" ||
  fail "the removed Tensaku window rules are gone"
pass "Hyprland applies Omasnap's overlay policy without stale Tensaku rules"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omasnap" <<'SH'
#!/bin/bash
printf '%s\t%s\n' "${OMASNAP_SCREENSHOT_DIR:-}" "$*" >>"$OMASNAP_TEST_LOG"
SH
chmod +x "$stub_bin/omasnap"

capture_log="$test_tmp/capture.log"
OMASNAP_TEST_LOG="$capture_log" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot"
[[ $(<"$capture_log") == $'\t' ]] || fail "the default screenshot opens Omasnap with no arguments"

: >"$capture_log"
OMASNAP_TEST_LOG="$capture_log" OMARCHY_SCREENSHOT_DIR="$test_tmp/legacy-output" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" windows copy
[[ $(<"$capture_log") == "$test_tmp/legacy-output"$'\twindows --copy' ]] ||
  fail "the screenshot command maps the legacy directory and copy argument to Omasnap"

: >"$capture_log"
OMASNAP_TEST_LOG="$capture_log" OMARCHY_SCREENSHOT_DIR="$test_tmp/legacy-output" OMASNAP_SCREENSHOT_DIR="$test_tmp/native-output" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" fullscreen save
[[ $(<"$capture_log") == "$test_tmp/native-output"$'\tfullscreen --save' ]] ||
  fail "the native Omasnap directory wins while legacy save syntax still works"

: >"$capture_log"
OMASNAP_TEST_LOG="$capture_log" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" region slurp
[[ $(<"$capture_log") == $'\tregion' ]] || fail "the former default slurp argument remains a harmless compatibility no-op"

: >"$capture_log"
OMASNAP_TEST_LOG="$capture_log" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" scroll --save
[[ $(<"$capture_log") == $'\tscroll --save' ]] || fail "native Omasnap modes and flags pass through unchanged"

pass "the Omarchy screenshot route delegates compatible arguments to Omasnap"

cat >"$stub_bin/omasnap" <<'SH'
#!/bin/bash
for name in $OMASNAP_TEST_SAVES; do
  printf 'png' >"$OMASNAP_SCREENSHOT_DIR/$name"
done
SH
cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$NOTIFY_TEST_LOG"
SH
chmod +x "$stub_bin/omarchy-notification-send"

shots="$test_tmp/shots"
mkdir -p "$shots"
printf 'png' >"$shots/earlier.png"
notify_log="$test_tmp/notify.log"

OMASNAP_TEST_SAVES="shot.png" NOTIFY_TEST_LOG="$notify_log" OMASNAP_SCREENSHOT_DIR="$shots" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" scroll --save
mapfile -t sent <"$notify_log"
[[ ${sent[0]} == "Screenshot saved" ]] || fail "a native --save is announced as saved, not copied" "${sent[*]}"
[[ " ${sent[*]} " == *" --image $shots/shot.png "* && ${sent[-1]} == "$shots/shot.png" ]] ||
  fail "the toast shows and opens the file the capture saved" "${sent[*]}"
pass "a saved shot is announced with its own file"

rm -f "$notify_log"
OMASNAP_TEST_SAVES="second.png other.png" NOTIFY_TEST_LOG="$notify_log" OMASNAP_SCREENSHOT_DIR="$shots" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" save
[[ ! -e $notify_log ]] || fail "a capture is not announced when another file appeared beside it" "$(<"$notify_log")"
pass "a capture is not announced when another file appeared beside it"
