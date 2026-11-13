#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

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
