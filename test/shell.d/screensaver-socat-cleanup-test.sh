#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

tmpdir=$(mktemp -d)
cleanup() {
  [[ -f $tmpdir/socat.pid ]] && kill "$(<"$tmpdir/socat.pid")" 2>/dev/null || true
  rm -rf "$tmpdir"
}
trap cleanup EXIT

mkdir -p "$tmpdir/bin"
mkfifo "$tmpdir/events"
# Held open for writing so the event reader never sees end of file between events.
exec {events}<>"$tmpdir/events"

cat >"$tmpdir/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_DIR/calls"
case "$*" in
  'monitors -j')
    printf '[{"name":"DP-1","specialWorkspace":{"name":""}}]\n'
    ;;
  'clients -j')
    cat "$TEST_DIR/clients.json"
    ;;
  *exec_cmd*)
    count=$(($(wc -l <"$TEST_DIR/spawned") + 1))
    printf '%s\n' "$count" >>"$TEST_DIR/spawned"
    printf 'openwindow>>%s,1,org.omarchy.screensaver,foot\n' "$count" >"$TEST_DIR/events"
    ;;
esac
SH
cat >"$tmpdir/bin/socat" <<'SH'
#!/bin/bash
printf '%s\n' "$$" >"$TEST_DIR/socat.pid"
exec cat "$TEST_DIR/events"
SH
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/pgrep"
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/omarchy-toggle-enabled"
printf '#!/bin/bash\necho DP-1\n' >"$tmpdir/bin/omarchy-hyprland-monitor-focused"
printf '#!/bin/bash\necho foot.desktop\n' >"$tmpdir/bin/xdg-terminal-exec"
chmod +x "$tmpdir/bin/"*

: >"$tmpdir/calls"
: >"$tmpdir/spawned"
printf '[{"class":"org.omarchy.screensaver","mapped":true}]\n' >"$tmpdir/clients.json"

PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test \
  timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force

[[ -f $tmpdir/socat.pid ]] || fail "socat started and recorded its pid"
socat_pid=$(<"$tmpdir/socat.pid")
kill -0 "$socat_pid" 2>/dev/null || fail "socat is still running after the launcher returns" "pid $socat_pid"
pass "socat is still running after the launcher returns (waiter still needs the event FD)"

# Let the focus-restore waiter finish: no mapped screensaver, then one more event to unblock read.
: >"$tmpdir/calls"
printf '[{"class":"org.omarchy.screensaver","mapped":false}]\n' >"$tmpdir/clients.json"
printf 'closewindow>>1\n' >&"$events"
for (( attempt = 0; attempt < 100; attempt++ )); do
  grep -q 'hl.dsp.focus({ monitor = "DP-1" })' "$tmpdir/calls" && break
  sleep 0.05
done
grep -q 'hl.dsp.focus({ monitor = "DP-1" })' "$tmpdir/calls" ||
  fail "focus-restore waiter finished" "$(<"$tmpdir/calls")"
pass "focus-restore waiter finished"

# After the waiter exits, socat must be gone. The harness must not kill it first.
for (( attempt = 0; attempt < 100; attempt++ )); do
  kill -0 "$socat_pid" 2>/dev/null || break
  sleep 0.05
done
if kill -0 "$socat_pid" 2>/dev/null; then
  fail "socat is gone after the focus-restore waiter exits" "pid $socat_pid still alive"
fi
pass "socat is gone after the focus-restore waiter exits"
