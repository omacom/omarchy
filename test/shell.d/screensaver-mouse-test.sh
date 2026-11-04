#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq
require_command script

tmpdir=$(mktemp -d)
saver_pid=
cleanup() {
  # script leaves its child running when killed, so stop the screensaver itself.
  if [[ -n $saver_pid ]]; then
    pkill -f "$ROOT/bin/omarchy-screensaver" 2>/dev/null || true
    wait "$saver_pid" 2>/dev/null || true
  fi
  pkill -f "$tmpdir/bin/ttfx" 2>/dev/null || true
  rm -rf "$tmpdir"
}
trap cleanup EXIT

mkdir -p "$tmpdir/bin"
cat >"$tmpdir/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_DIR/calls"
case "$*" in
  'activewindow -j') printf '{"class":"org.omarchy.screensaver"}\n' ;;
  cursorpos) cat "$TEST_DIR/cursor" ;;
esac
SH
cat >"$tmpdir/bin/ttfx" <<'SH'
#!/bin/bash
while :; do sleep 0.1; done
SH
chmod +x "$tmpdir/bin/hyprctl" "$tmpdir/bin/ttfx"
printf '100, 200\n' >"$tmpdir/cursor"
: >"$tmpdir/calls"

# Mouse input never reaches the screensaver's terminal, so moving the pointer
# must end it on its own. A stdin held open for writing keeps keyboard reads waiting.
mkfifo "$tmpdir/keys"
exec {keys}<>"$tmpdir/keys"
TEST_DIR=$tmpdir PATH="$tmpdir/bin:$PATH" \
  script -qec "$ROOT/bin/omarchy-screensaver" /dev/null <&"$keys" >/dev/null 2>&1 &
saver_pid=$!

for _ in {1..100}; do
  grep -q 'invisible = true' "$tmpdir/calls" && break
  sleep 0.05
done
grep -q 'invisible = true' "$tmpdir/calls" || fail "screensaver starts" "$(cat "$tmpdir/calls")"
# The launcher moves the pointer while it focuses each monitor to open the
# others, which must not count as the user coming back.
sleep 0.2
printf '960, 540\n' >"$tmpdir/cursor"
sleep 4
grep -q 'invisible = false' "$tmpdir/calls" && fail "screensaver ignores the pointer moving while it launches"

printf '140, 260\n' >"$tmpdir/cursor"
for _ in {1..60}; do
  grep -q 'invisible = false' "$tmpdir/calls" && break
  sleep 0.05
done
grep -q 'invisible = false' "$tmpdir/calls" || fail "screensaver exits and restores the cursor when the mouse moves" "$(cat "$tmpdir/calls")"
pass "screensaver exits when the mouse moves"
