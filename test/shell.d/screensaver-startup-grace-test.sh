#!/bin/bash

# Regression test for #15489: omarchy-launch-screensaver walks the focus
# across monitors while the screensaver starts, so the focus check in
# omarchy-screensaver can fail seconds after launch with no key pressed. The
# script used to exit right away, and the idle service read that close as the
# user dismissing the screensaver, cancelling the pending lock. A startup
# grace window now keeps the screensaver up until a key arrives or the grace
# expires; losing focus after the grace still closes it.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

tmpdir=$(mktemp -d)
cleanup() {
  [[ -n ${saver_pid:-} ]] && kill "$saver_pid" 2>/dev/null || true
  [[ -f $tmpdir/ttfx-stop ]] || touch "$tmpdir/ttfx-stop" 2>/dev/null || true
  rm -rf "$tmpdir"
}
trap cleanup EXIT

mkdir -p "$tmpdir/bin"
# A fifo held open on both ends keeps the script's `read -n1 -t 1` ticking at
# its one-second cadence without ever delivering a key.
mkfifo "$tmpdir/keys"
exec {keys}<> "$tmpdir/keys"

cat >"$tmpdir/bin/hyprctl" <<'SH'
#!/bin/bash
case "$1 $2" in
  'activewindow -j') cat "$TEST_DIR/activewindow.json" ;;
esac
SH
# ttfx itself never runs in the test; the stubbed pgrep reports it alive for
# as long as the marker file exists, so the script stays in its watch loop.
printf '#!/bin/bash\n[[ -e $TEST_DIR/ttfx-alive ]]\n' >"$tmpdir/bin/pgrep"
printf '#!/bin/bash\nexit 0\n' >"$tmpdir/bin/pkill"
# ttfx never renders in the test; it just marks itself running until the
# (stubbed) pkill asks it to stop.
cat >"$tmpdir/bin/ttfx" <<'SH'
#!/bin/bash
touch "$TEST_DIR/ttfx-running"
while [[ ! -e $TEST_DIR/ttfx-stop ]]; do sleep 0.05; done
rm -f "$TEST_DIR/ttfx-running"
SH
chmod +x "$tmpdir/bin/"*

# The screensaver window is never focused, as while the launcher is still
# walking the focus across monitors.
printf '{"class":"foot","mapped":true}\n' >"$tmpdir/activewindow.json"
touch "$tmpdir/ttfx-alive"

start_saver() {
  PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" \
    timeout 20 "$ROOT/bin/omarchy-screensaver" \
    <"$tmpdir/keys" >"$tmpdir/out" 2>&1 &
  saver_pid=$!
}

# Losing focus during the startup grace window must not close the screensaver.
start_saver
sleep 2.5
kill -0 "$saver_pid" 2>/dev/null ||
  fail "an unfocused screensaver stays up through the startup grace window" "$(head -c 400 "$tmpdir/out")"
pass "an unfocused screensaver stays up through the startup grace window"

# A key still exits immediately, grace or not.
printf 'x' >&"$keys"
for (( attempt = 0; attempt < 50; attempt++ )); do
  kill -0 "$saver_pid" 2>/dev/null || break
  sleep 0.1
done
if kill -0 "$saver_pid" 2>/dev/null; then
  fail "a key closes the screensaver even inside the grace window" "$(head -c 400 "$tmpdir/out")"
fi
wait "$saver_pid" 2>/dev/null || true
pass "a key closes the screensaver even inside the grace window"

# Once the grace is over, an unfocused screensaver still closes on its own —
# but no earlier than the grace, which is what the old script did not honor.
: >"$tmpdir/out"
start=$(date +%s)
start_saver
for (( attempt = 0; attempt < 150; attempt++ )); do
  kill -0 "$saver_pid" 2>/dev/null || break
  sleep 0.1
done
if kill -0 "$saver_pid" 2>/dev/null; then
  fail "an unfocused screensaver closes once the grace window expires" "$(head -c 400 "$tmpdir/out")"
fi
wait "$saver_pid" 2>/dev/null || true
elapsed=$(( $(date +%s) - start ))
(( elapsed >= 4 )) ||
  fail "an unfocused screensaver survives at least the grace window" "exited after ${elapsed}s"
pass "an unfocused screensaver closes once the grace window expires"
