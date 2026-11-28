#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-plymouth-handoff"
autostart="$ROOT/default/hypr/autostart.lua"
dropin="$ROOT/default/systemd/system/plymouth-quit.service.d/10-omarchy-retain-splash.conf"

[[ -x $helper ]] || fail "boot handoff helper is installed as an executable"
[[ -f $dropin ]] || fail "Plymouth quit drop-in retains the last splash"
grep -Fx 'ExecStart=' "$dropin" >/dev/null || fail "drop-in clears the vendor quit command"
grep -Fx "ExecStart=/usr/bin/sh -c '/usr/bin/timeout -k 1s 3s /usr/bin/plymouth deactivate || /usr/bin/timeout -k 1s 3s /usr/bin/plymouth quit --retain-splash'" "$dropin" >/dev/null ||
  fail "drop-in only deactivates Plymouth, quitting at once when that fails"
grep -Fx 'ExecStartPost=/usr/bin/systemctl start --no-block omarchy-plymouth-reap.service' "$dropin" >/dev/null ||
  fail "drop-in starts the bounded Plymouth reaper without holding up the login screen"
[[ $(grep -c '^ExecStart=.' "$dropin") == 1 ]] || fail "drop-in runs only the deactivate, never a plain quit first"
reaper="$ROOT/bin/omarchy-plymouth-reap"
[[ -x $reaper ]] || fail "the Plymouth reaper is installed as an executable"
python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' "$reaper" || fail "the Plymouth reaper parses"
grep -Fx 'ExecStart=-/usr/share/omarchy/bin/omarchy-plymouth-reap' "$ROOT/default/systemd/system/omarchy-plymouth-reap.service" >/dev/null ||
  fail "the reaper service runs the packaged reaper"
pass "Plymouth only deactivates, so its last frame stays on screen for the compositor to take over"

grep -F 'hl.exec_cmd("omarchy-plymouth-handoff --launch-shell")' "$autostart" >/dev/null ||
  fail "Hyprland startup starts the shell through the handoff helper"
grep -Fx '  hl.exec_cmd("omarchy-launch-shell")' "$autostart" >/dev/null &&
  fail "the shell is still started on its own, ahead of the continuity client"
pass "Hyprland startup runs the continuity client ahead of the shell"

tmp=$(mktemp -d "${TMPDIR:-/var/tmp}/ttfx-test.XXXXXXXX")
printf 'Test fixtures: %s\n' "$tmp"
mkdir -p "$tmp/bin"

cat >"$tmp/launcher" <<'EOF'
#!/bin/bash
line=launcher
for arg in "$@"; do line+=" <$arg>"; done
printf '%s\n' "$line" >>"$HANDOFF_TEST_LOG"
EOF
cat >"$tmp/bin/omarchy-launch-shell" <<'EOF'
#!/bin/bash
printf 'shell args=%s\n' "$#" >>"$HANDOFF_TEST_LOG"
EOF
chmod 0755 "$tmp/launcher" "$tmp/bin/omarchy-launch-shell"
printf 'OMBFRAW1' >"$tmp/frame"

# Runs one scenario in its own runtime directory and waits for the
# backgrounded launcher, which the helper never waits for.
run_case() {
  local name=$1
  shift
  local case_dir="$tmp/$name"
  mkdir -p "$case_dir/runtime"
  : >"$case_dir/log"
  env PATH="$tmp/bin:/usr/bin:/bin" XDG_RUNTIME_DIR="$case_dir/runtime" HANDOFF_TEST_LOG="$case_dir/log" \
    OMARCHY_PLYMOUTH_CONTINUITY_LAUNCHER="${CASE_LAUNCHER:-$tmp/launcher}" \
    OMARCHY_PLYMOUTH_HANDOFF_FRAME="${CASE_FRAME:-$tmp/frame}" \
    "$helper" "$@" || fail "$name: the helper never fails login"
  for _ in {1..100}; do
    [[ -z ${CASE_EXPECT_LAUNCHER:-} ]] || grep -q '^launcher' "$case_dir/log" && break
    sleep 0.02
  done
  case_log=$(<"$case_dir/log")
}

expected_launch="launcher <--settle-ms> <30> <--pid-file> <$tmp/handoff/runtime/omarchy-plymouth-continuity.pid>"

CASE_EXPECT_LAUNCHER=1 run_case handoff --launch-shell
grep -Fx -- "$expected_launch" <<<"$case_log" >/dev/null || fail "a boot frame starts the continuity client" "$case_log"
grep -Fx 'shell args=0' <<<"$case_log" >/dev/null || fail "the shell starts after the continuity client" "$case_log"
pass "a boot frame starts the continuity client, then the shell"

CASE_EXPECT_LAUNCHER=1 run_case no-shell
grep -q '^launcher' <<<"$case_log" || fail "without --launch-shell the client still starts" "$case_log"
grep -q '^shell' <<<"$case_log" && fail "without --launch-shell no shell starts" "$case_log"
pass "without --launch-shell only the continuity client starts"

CASE_FRAME="$tmp/missing" run_case no-frame --launch-shell
[[ $case_log == 'shell args=0' ]] || fail "without a boot frame only the shell starts" "$case_log"
pass "without a boot frame only the shell starts"

cp "$tmp/launcher" "$tmp/writable-launcher"
chmod 0775 "$tmp/writable-launcher"
CASE_LAUNCHER="$tmp/writable-launcher" run_case writable --launch-shell
[[ $case_log == 'shell args=0' ]] || fail "a group-writable launcher is never run" "$case_log"
ln -s "$tmp/launcher" "$tmp/linked-launcher"
CASE_LAUNCHER="$tmp/linked-launcher" run_case symlink --launch-shell
[[ $case_log == 'shell args=0' ]] || fail "a symlinked launcher is never run" "$case_log"
CASE_LAUNCHER="$tmp/missing" run_case no-launcher --launch-shell
[[ $case_log == 'shell args=0' ]] || fail "a missing launcher still starts the shell" "$case_log"
pass "an untrusted or missing launcher is skipped and the shell still starts"

run_case extra-arguments --launch-shell extra
sleep 0.2
[[ -z $(<"$tmp/extra-arguments/log") ]] || fail "unexpected arguments start nothing" "$(<"$tmp/extra-arguments/log")"
pass "unexpected arguments start nothing but never fail"
