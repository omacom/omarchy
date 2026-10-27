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
grep -Fq 'no_screen_share = true' "$ROOT/default/hypr/apps/screenshot-selection.lua" ||
  fail "the Omasnap overlay is excluded from screen sharing"
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
[[ $(<"$capture_log") == $'\t--notify' ]] || fail "the default screenshot opens Omasnap announcing saved shots with buttons"

: >"$capture_log"
OMASNAP_TEST_LOG="$capture_log" OMARCHY_SCREENSHOT_DIR="$test_tmp/legacy-output" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" windows copy
[[ $(<"$capture_log") == "$test_tmp/legacy-output"$'\t--notify windows --copy' ]] ||
  fail "the screenshot command maps the legacy directory and copy argument to Omasnap"

: >"$capture_log"
OMASNAP_TEST_LOG="$capture_log" OMARCHY_SCREENSHOT_DIR="$test_tmp/legacy-output" OMASNAP_SCREENSHOT_DIR="$test_tmp/native-output" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" fullscreen save
[[ $(<"$capture_log") == "$test_tmp/native-output"$'\t--notify fullscreen --save' ]] ||
  fail "the native Omasnap directory wins while legacy save syntax still works"

: >"$capture_log"
OMASNAP_TEST_LOG="$capture_log" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" region slurp
[[ $(<"$capture_log") == $'\t--notify region' ]] || fail "the former default slurp argument remains a harmless compatibility no-op"

: >"$capture_log"
OMASNAP_TEST_LOG="$capture_log" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" scroll --save
[[ $(<"$capture_log") == $'\t--notify scroll --save' ]] || fail "native Omasnap modes and flags pass through unchanged"

pass "the Omarchy screenshot route delegates compatible arguments to Omasnap"
