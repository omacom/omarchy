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

# Like omasnap, saves the region and announces it with the saved file.
cat >"$stub_bin/omasnap" <<'SH'
#!/bin/bash
printf 'png' >"$OMASNAP_SCREENSHOT_DIR/shot.png"
omarchy-notification-send "Screenshot saved" --image "$OMASNAP_SCREENSHOT_DIR/shot.png"
SH
cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFY_TEST_LOG"
SH
cat >"$stub_bin/tesseract" <<'SH'
#!/bin/bash
printf 'hello'
SH
cat >"$stub_bin/zbarimg" <<'SH'
#!/bin/bash
printf 'https://example.com'
SH
cat >"$stub_bin/wl-copy" <<'SH'
#!/bin/bash
cat >/dev/null
SH
chmod +x "$stub_bin"/*

notify_log="$test_tmp/notify.log"

NOTIFY_TEST_LOG="$notify_log" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-capture-text"
[[ $(<"$notify_log") == "-g 󰴑 $("$ROOT/bin/omarchy-i18n" capture.textCopied)" ]] ||
  fail "text capture announces the copied text and not the temporary shot" "$(<"$notify_log")"
pass "text capture announces the copied text and not the temporary shot"

: >"$notify_log"
NOTIFY_TEST_LOG="$notify_log" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-capture-qr"
[[ $(<"$notify_log") == "-g 󰐲 $("$ROOT/bin/omarchy-i18n" capture.qrCopied)" ]] ||
  fail "QR capture announces the copied code and not the temporary shot" "$(<"$notify_log")"
pass "QR capture announces the copied code and not the temporary shot"
