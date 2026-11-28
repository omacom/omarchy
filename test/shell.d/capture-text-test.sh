#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/run"
export TEST_LOG="$tmp_dir/log"

# Every tool the capture runs only records that it ran.
for stub in hyprpicker grim omarchy-notification-send omarchy-i18n sleep; do
  cat >"$tmp_dir/bin/$stub" <<'SH'
#!/bin/bash
printf '%s\n' "$(basename "$0")" >>"$TEST_LOG"
SH
  chmod +x "$tmp_dir/bin/$stub"
done

# slurp waits for the freeze to have started, then returns no selection, as a
# cancelled pick does, or the region in $TEST_SELECTION.
cat >"$tmp_dir/bin/slurp" <<'SH'
#!/bin/bash
for _ in {1..100}; do
  grep -qx hyprpicker "$TEST_LOG" && break
  command -p sleep 0.02
done
printf 'slurp\n' >>"$TEST_LOG"
printf '%s' "${TEST_SELECTION:-}"
SH
chmod +x "$tmp_dir/bin/slurp"

printf '#!/bin/bash\necho words\n' >"$tmp_dir/bin/tesseract"
chmod +x "$tmp_dir/bin/tesseract"

# wl-copy forks a process that stays behind to own the clipboard.
cat >"$tmp_dir/bin/wl-copy" <<'SH'
#!/bin/bash
printf 'wl-copy\n' >>"$TEST_LOG"
command -p sleep 5 >/dev/null 2>&1 &
SH
chmod +x "$tmp_dir/bin/wl-copy"

capture_text() {
  : >"$TEST_LOG"
  PATH="$tmp_dir/bin:$ROOT/bin:$PATH" XDG_RUNTIME_DIR="$tmp_dir/run" "$ROOT/bin/omarchy-capture-text"
}

capture_text
grep -qx hyprpicker "$TEST_LOG" && grep -qx slurp "$TEST_LOG" ||
  fail "OCR capture freezes the screen and picks a region" "$(cat "$TEST_LOG")"
pass "OCR capture freezes the screen and picks a region"

# Pressing the shortcut again while a capture is under way must not stack
# another freeze over the first, which whitens the screen a step each time.
exec 8>"$tmp_dir/run/omarchy-capture-text.lock"
flock -n 8
capture_text
exec 8>&-
! grep -qx hyprpicker "$TEST_LOG" && ! grep -qx slurp "$TEST_LOG" ||
  fail "a second OCR capture leaves the one under way alone" "$(cat "$TEST_LOG")"
pass "a second OCR capture leaves the one under way alone"

capture_text
grep -qx hyprpicker "$TEST_LOG" ||
  fail "OCR capture runs again once the first has finished" "$(cat "$TEST_LOG")"
pass "OCR capture runs again once the first has finished"

# The clipboard owner wl-copy leaves running must not keep the next capture out.
TEST_SELECTION="0,0 10x10" capture_text
grep -qx wl-copy "$TEST_LOG" ||
  fail "a finished OCR capture leaves the next one free to start" "nothing was copied: $(cat "$TEST_LOG")"
capture_text
grep -qx hyprpicker "$TEST_LOG" ||
  fail "a finished OCR capture leaves the next one free to start" "$(cat "$TEST_LOG")"
pass "a finished OCR capture leaves the next one free to start"
