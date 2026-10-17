#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

# TMPDIR can be read-only in sandboxes; fall back to the checkout.
tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -p "$ROOT")
launcher_pid=
cleanup() {
  [[ -f $tmpdir/socat.pid ]] && kill "$(<"$tmpdir/socat.pid")" 2>/dev/null || true
  [[ -n $launcher_pid ]] && kill "$launcher_pid" 2>/dev/null || true
  rm -rf "$tmpdir"
}
trap cleanup EXIT

marker=$tmpdir/omarchy-screensaver-launching
mkdir -p "$tmpdir/bin"
mkfifo "$tmpdir/events"
# Held open for writing so the event reader never sees end of file between events.
exec {events}<>"$tmpdir/events"

# Another window holds focus, as it does between the launcher focusing a monitor and its screensaver mapping.
cat >"$tmpdir/bin/hyprctl" <<'SH'
#!/bin/bash
case "$*" in
  'activewindow -j') echo '{"class":"other"}' ;;
  'monitors -j') echo '[{"name":"DP-1","specialWorkspace":{"name":""}}]' ;;
  *exec_cmd*)
    [[ -e $TEST_DIR/omarchy-screensaver-launching ]] && touch "$TEST_DIR/marker-seen-at-spawn"
    # In the interrupt case no window ever maps, so the launcher stays in its wait.
    [[ -e $TEST_DIR/never-map ]] || printf 'openwindow>>1,1,org.omarchy.screensaver,foot\n' >"$TEST_DIR/events"
    ;;
esac
SH
cat >"$tmpdir/bin/socat" <<'SH'
#!/bin/bash
printf '%s\n' "$$" >"$TEST_DIR/socat.pid"
exec cat "$TEST_DIR/events"
SH
# The watchdog's ttfx check (-t) finds ttfx; the launcher's "already running" check finds nothing.
printf '#!/bin/bash\n[[ $* == *-x\\ ttfx* ]]\n' >"$tmpdir/bin/pgrep"
printf '#!/bin/bash\nsleep 5\n' >"$tmpdir/bin/ttfx"
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"$TEST_DIR/pkill"\n' >"$tmpdir/bin/pkill"
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/omarchy-toggle-enabled"
printf '#!/bin/bash\necho DP-1\n' >"$tmpdir/bin/omarchy-hyprland-monitor-focused"
printf '#!/bin/bash\necho foot.desktop\n' >"$tmpdir/bin/xdg-terminal-exec"
chmod +x "$tmpdir/bin/"*

run_watchdog() {
  rm -f "$tmpdir/pkill" "$tmpdir/stderr"
  # stdin stays open and silent, so the only way out is the focus check.
  { sleep 4 | PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" timeout -s KILL 2.5 "$ROOT/bin/omarchy-screensaver" >/dev/null 2>"$tmpdir/stderr"; } 2>/dev/null || true
}

run_launcher() {
  PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test \
    "$ROOT/bin/omarchy-launch-screensaver" force
}

# The launcher's own cycle: the marker exists while it spawns and is gone when it returns.
run_launcher
[[ -e $tmpdir/marker-seen-at-spawn ]] || fail "the launcher marks itself while it steps through monitors" "no marker at spawn"
pass "the launcher marks itself while it steps through monitors"
[[ ! -e $marker ]] || fail "the launcher clears its marker when it finishes" "$(<"$marker")"
pass "the launcher clears its marker when it finishes"
kill "$(<"$tmpdir/socat.pid")" 2>/dev/null || true

# An interrupted launcher must not leave the marker behind.
touch "$tmpdir/never-map"
rm -f "$tmpdir/marker-seen-at-spawn"
PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test \
  "$ROOT/bin/omarchy-launch-screensaver" force &
launcher_pid=$!
for (( attempt = 0; attempt < 100; attempt++ )); do
  [[ -e $tmpdir/marker-seen-at-spawn && -e $marker ]] && break
  sleep 0.05
done
[[ -e $tmpdir/marker-seen-at-spawn && -e $marker ]] || fail "the launcher is waiting on a window with its marker set" "no spawn with the marker set"
kill -TERM "$launcher_pid"
wait "$launcher_pid" 2>/dev/null || true
launcher_pid=
[[ ! -e $marker ]] || fail "an interrupted launcher clears its marker" "$(<"$marker")"
pass "an interrupted launcher clears its marker"
rm -f "$tmpdir/never-map"

# The watchdog honours the marker only while its launcher is alive.
echo $$ >"$marker"
run_watchdog
[[ -e $tmpdir/pkill ]] && fail "a screensaver stays up while the launcher is still moving focus between monitors" "$(<"$tmpdir/pkill")"
pass "a screensaver stays up while the launcher is still moving focus between monitors"

true &
dead=$!
wait "$dead"
echo "$dead" >"$marker"
run_watchdog
[[ -e $tmpdir/pkill ]] || fail "a marker left by a dead launcher does not suspend the focus check" "no pkill"
pass "a marker left by a dead launcher does not suspend the focus check"

rm "$marker"
run_watchdog
[[ -e $tmpdir/pkill ]] || fail "a screensaver still closes when focus is lost after the launch" "no pkill"
pass "a screensaver still closes when focus is lost after the launch"
[[ ! -s $tmpdir/stderr ]] || fail "a missing marker prints nothing into the screensaver's terminal" "$(<"$tmpdir/stderr")"
pass "a missing marker prints nothing into the screensaver's terminal"
