#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq
require_command script

tmpdir=$(mktemp -d)
saver_pid=
cleanup() {
  # Stop only this test's processes, by the IDs they recorded.
  [[ -n $saver_pid ]] && kill "$saver_pid" 2>/dev/null
  cat "$tmpdir"/*.pid 2>/dev/null | xargs -r kill 2>/dev/null
  [[ -n $saver_pid ]] && wait "$saver_pid" 2>/dev/null
  rm -rf "$tmpdir"
}
trap 'cleanup || true' EXIT

mkdir -p "$tmpdir/bin"
cat >"$tmpdir/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_DIR/calls"
case "$*" in
  'activewindow -j') printf '{"class":"org.omarchy.screensaver"}\n' ;;
  cursorpos) cat "$TEST_DIR/cursor" ;;
  *'invisible = true'*) printf '%s\n' "$PPID" >"$TEST_DIR/screensaver.pid" ;;
esac
SH
cat >"$tmpdir/bin/ttfx" <<'SH'
#!/bin/bash
printf '%s\n' "$$" >"$TEST_DIR/ttfx.pid"
while :; do sleep 0.1; done
SH
# The screensaver's exit kills every ttfx and screensaver window, which would
# reach the developer's own.
cat >"$tmpdir/bin/pkill" <<'SH'
#!/bin/bash
printf 'pkill %s\n' "$*" >>"$TEST_DIR/calls"
SH
chmod +x "$tmpdir/bin/hyprctl" "$tmpdir/bin/ttfx" "$tmpdir/bin/pkill"
printf '100, 200\n' >"$tmpdir/cursor"
: >"$tmpdir/calls"
touch "$tmpdir/omarchy-screensaver-launching"

cursor_checks() {
  grep -cx cursorpos "$tmpdir/calls" || true
}

wait_for_cursor_checks() {
  local target=$1
  for _ in {1..60}; do
    (( $(cursor_checks) >= target )) && return
    grep -q 'invisible = false' "$tmpdir/calls" && fail "screensaver ignores the pointer moving while it launches"
    sleep 0.05
  done
  fail "screensaver checks the pointer while it runs" "$(cat "$tmpdir/calls")"
}

# Mouse input never reaches the screensaver's terminal, so moving the pointer
# must end it on its own. A stdin held open for writing keeps keyboard reads waiting.
mkfifo "$tmpdir/keys"
exec {keys}<>"$tmpdir/keys"
TEST_DIR=$tmpdir XDG_RUNTIME_DIR=$tmpdir PATH="$tmpdir/bin:$PATH" \
  script -qec "$ROOT/bin/omarchy-screensaver" /dev/null <&"$keys" >/dev/null 2>&1 &
saver_pid=$!

# The launcher moves the pointer as it focuses each monitor, however long the
# terminals take to open, which must not count as the user coming back.
wait_for_cursor_checks 1
printf '960, 540\n' >"$tmpdir/cursor"
wait_for_cursor_checks 2
rm "$tmpdir/omarchy-screensaver-launching"
checks=$(cursor_checks)
wait_for_cursor_checks $((checks + 2))

printf '140, 260\n' >"$tmpdir/cursor"
for _ in {1..60}; do
  grep -q 'invisible = false' "$tmpdir/calls" && break
  sleep 0.05
done
grep -q 'invisible = false' "$tmpdir/calls" || fail "screensaver exits and restores the cursor when the mouse moves" "$(cat "$tmpdir/calls")"
pass "screensaver exits when the mouse moves"
