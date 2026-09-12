#!/bin/bash

# The screensaver launcher used to gate on `pgrep -f '[o]rg.omarchy.screensaver'`,
# which matches any process whose full command line contains that app-id string
# (#10197). A later attempt used `pgrep -x omarchy-screensaver`, which can never
# match: the script name is 19 characters and Linux truncates comm to 15, so
# procps refuses the pattern. The gate is now the Hyprland window class first,
# then `pidof -x omarchy-screensaver` for the openwindow race. Tests drive the
# real jq / pidof predicates; only hyprctl (and later helpers) are stubbed.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command pidof

launcher="$ROOT/bin/omarchy-launch-screensaver"
tmp=$(mktemp -d)
decoy_pid=""
script_pid=""

cleanup() {
  [[ -n ${decoy_pid:-} ]] && kill "$decoy_pid" 2>/dev/null || true
  [[ -n ${script_pid:-} ]] && kill "$script_pid" 2>/dev/null || true
  wait "$decoy_pid" 2>/dev/null || true
  wait "$script_pid" 2>/dev/null || true
  rm -rf "$tmp"
}
trap cleanup EXIT

# Static shape: the two broken gates must stay gone; the replacement pair must
# be present. Strip comments first so the documentation of the rejected forms
# cannot trip the guard.
launcher_code=$(grep -v '^[[:space:]]*#' "$launcher")

if grep -Eq "pgrep[[:space:]]+-f[[:space:]]+['\"]?\\[o\\]rg\\.omarchy\\.screensaver" <<<"$launcher_code"; then
  fail "launcher no longer uses pgrep -f against the app-id string"
fi

if grep -Eq 'pgrep[[:space:]]+-x[[:space:]]+omarchy-screensaver' <<<"$launcher_code"; then
  fail "launcher no longer uses pgrep -x omarchy-screensaver (comm is truncated to 15)"
fi

grep -Eq 'pidof[[:space:]]+-x[[:space:]]+omarchy-screensaver' <<<"$launcher_code" ||
  fail "launcher gates on pidof -x omarchy-screensaver for the in-flight process"

grep -Eq 'class == "org\.omarchy\.screensaver"|initialClass == "org\.omarchy\.screensaver"' <<<"$launcher_code" ||
  fail "launcher gates on the Hyprland screensaver class"

pass "launcher uses window class then pidof -x for the already-running check"

# --- stubs: hyprctl is the only compositor touch; jq and pidof stay real ------

cat >"$tmp/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${OMARCHY_TEST_HYPRCTL_LOG:?}"

if [[ $1 == clients && $2 == -j ]]; then
  printf '%s\n' "${OMARCHY_TEST_CLIENTS_JSON:?}"
  exit 0
fi

printf 'unexpected hyprctl call: %s\n' "$*" >&2
exit 99
SH
chmod +x "$tmp/hyprctl"

cat >"$tmp/omarchy-toggle-enabled" <<'SH'
#!/bin/bash
printf 'toggle\n' >>"${OMARCHY_TEST_HELPER_LOG:?}"
# Toggle file absent => screensaver is allowed.
exit 1
SH
chmod +x "$tmp/omarchy-toggle-enabled"

cat >"$tmp/omarchy-hyprland-monitor-focused" <<'SH'
#!/bin/bash
printf 'focused\n' >>"${OMARCHY_TEST_HELPER_LOG:?}"
printf 'MONITOR\n'
SH
chmod +x "$tmp/omarchy-hyprland-monitor-focused"

cat >"$tmp/xdg-terminal-exec" <<'SH'
#!/bin/bash
printf 'terminal\n' >>"${OMARCHY_TEST_HELPER_LOG:?}"
printf 'UnsupportedTerminal\n'
SH
chmod +x "$tmp/xdg-terminal-exec"

cat >"$tmp/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notification\n' >>"${OMARCHY_TEST_HELPER_LOG:?}"
exit 0
SH
chmod +x "$tmp/omarchy-notification-send"

# A pidof that pretends no screensaver script is running. Real pidof is used in
# the script-process case below; this stub only isolates the window-gate cases
# from whatever the host happens to be doing.
cat >"$tmp/pidof" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${OMARCHY_TEST_PIDOF_LOG:?}"
# Mirror real pidof's -x contract enough that a wrong call shape fails loudly.
if [[ $1 == -x && $2 == omarchy-screensaver ]]; then
  exit 1
fi
printf 'unexpected pidof call: %s\n' "$*" >&2
exit 99
SH
chmod +x "$tmp/pidof"

hyprctl_log="$tmp/hyprctl.log"
helper_log="$tmp/helper.log"
pidof_log="$tmp/pidof.log"

run_launcher() {
  local clients_json="$1"
  shift || true

  : >"$hyprctl_log"
  : >"$helper_log"
  : >"$pidof_log"
  # OMARCHY_TEST_PIDOF_LOG is only read by the pidof stub. When that stub is
  # absent (live pidof cases), leaving the var unset is fine.
  OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
    OMARCHY_TEST_HYPRCTL_LOG="$hyprctl_log" \
    OMARCHY_TEST_HELPER_LOG="$helper_log" \
    OMARCHY_TEST_PIDOF_LOG="$pidof_log" \
    PATH="$tmp:$PATH" \
    "$launcher" "$@" 2>&1
}

assert_early_exit() {
  local clients_json="$1"
  local description="$2"
  local expect_pidof="${3:-0}"
  local output rc

  set +e
  output=$(run_launcher "$clients_json")
  rc=$?
  set -e

  ((rc == 0)) || fail "$description" "rc=$rc output=$output"
  [[ $(<"$hyprctl_log") == "clients -j" ]] ||
    fail "$description" "unexpected hyprctl calls: $(<"$hyprctl_log")"
  [[ ! -s $helper_log ]] ||
    fail "$description" "launcher continued after the gate: $(<"$helper_log")"

  if ((expect_pidof)); then
    [[ $(<"$pidof_log") == "-x omarchy-screensaver" ]] ||
      fail "$description" "expected pidof -x omarchy-screensaver, log=$(<"$pidof_log")"
  else
    [[ ! -s $pidof_log ]] ||
      fail "$description" "window hit should not reach pidof: $(<"$pidof_log")"
  fi

  pass "$description"
}

# Mapped screensaver window: exit before helpers and before pidof.
assert_early_exit \
  '[{"class":"org.omarchy.screensaver","initialClass":"foot"}]' \
  "current screensaver class prevents a duplicate launch"

assert_early_exit \
  '[{"class":"foot","initialClass":"org.omarchy.screensaver"}]' \
  "initial screensaver class prevents a duplicate launch"

# App-id in title / near-miss class must not trip the window gate. With the
# pidof stub reporting no script, the launcher continues and stops at the
# unsupported-terminal path (exit 1) — proof the gate did not exit 0.
set +e
output=$(run_launcher '[{"class":"org.omarchy.screensaver-helper","initialClass":"foot","title":"org.omarchy.screensaver"}]')
rc=$?
set -e

((rc == 1)) || fail "non-matching clients continue past the window gate" "rc=$rc output=$output"
[[ $(<"$hyprctl_log") == "clients -j" ]] ||
  fail "non-matching clients still query hyprctl clients" "log=$(<"$hyprctl_log")"
[[ $(<"$pidof_log") == "-x omarchy-screensaver" ]] ||
  fail "non-matching clients fall through to pidof -x" "log=$(<"$pidof_log")"
[[ $(<"$helper_log") == $'toggle\nfocused\nterminal\nnotification' ]] ||
  fail "non-matching clients continue past the gate" "helper calls: $(<"$helper_log")"
pass "non-matching clients continue past the window gate"

# --- real pidof -x against a live decoy argv and a live script -----------------

# Drop the pidof stub so the next cases exercise procps itself.
rm -f "$tmp/pidof"

# Decoy: app-id only in argv, process name is bash. Old pgrep -f would match;
# pidof -x omarchy-screensaver must not.
bash -c 'while true; do sleep 30; done' org.omarchy.screensaver decoy-for-screensaver-test &
decoy_pid=$!

for _ in 1 2 3 4 5 6 7 8 9 10; do
  if pgrep -f 'org\.omarchy\.screensaver decoy-for-screensaver-test' >/dev/null; then
    break
  fi
  sleep 0.05
done

pgrep -f 'org\.omarchy\.screensaver decoy-for-screensaver-test' >/dev/null ||
  fail "decoy process with app-id in argv is running for the regression probe"

pgrep -f '[o]rg.omarchy.screensaver' >/dev/null ||
  fail "baseline: pgrep -f still matches a decoy argv containing the app-id"

if pidof -x omarchy-screensaver >/dev/null 2>&1; then
  fail "pidof -x omarchy-screensaver must not match a decoy argv" \
    "matched: $(pidof -x omarchy-screensaver 2>/dev/null | tr '\n' ' ')"
fi

set +e
output=$(run_launcher '[]')
rc=$?
set -e

((rc == 1)) || fail "decoy argv does not early-exit the launcher" "rc=$rc output=$output"
[[ $(<"$helper_log") == $'toggle\nfocused\nterminal\nnotification' ]] ||
  fail "decoy argv does not early-exit the launcher" "helper calls: $(<"$helper_log")"
pass "decoy argv containing org.omarchy.screensaver does not trip the gate"

kill "$decoy_pid" 2>/dev/null || true
wait "$decoy_pid" 2>/dev/null || true
decoy_pid=""

# Real screensaver script process: name is longer than 15 chars so pgrep -x
# cannot match, but pidof -x can. Put a sleep-script named omarchy-screensaver
# on PATH and run it the way a terminal would (-e omarchy-screensaver).
cp /bin/sleep "$tmp/omarchy-screensaver-sleep" 2>/dev/null || true
cat >"$tmp/omarchy-screensaver" <<'SH'
#!/bin/bash
# Stand in for bin/omarchy-screensaver: long name, bash shebang, stays alive.
# Do not exec — pidof -x matches shells running the named script, not a
# replaced sleep binary.
while true; do sleep 30; done
SH
chmod +x "$tmp/omarchy-screensaver"

# Invoke by path so argv0 is the script (same shape a terminal -e uses when the
# script is on PATH). Kernel comm is the truncated basename.
"$tmp/omarchy-screensaver" &
script_pid=$!

for _ in 1 2 3 4 5 6 7 8 9 10; do
  if pidof -x omarchy-screensaver >/dev/null 2>&1; then
    break
  fi
  sleep 0.05
done

pidof -x omarchy-screensaver >/dev/null 2>&1 ||
  fail "pidof -x omarchy-screensaver matches a running screensaver script" \
    "pid=$script_pid comm=$(cat /proc/$script_pid/comm 2>/dev/null || echo missing)"

# pgrep -x must still be the broken tool this PR is leaving behind.
if pgrep -x omarchy-screensaver >/dev/null 2>&1; then
  fail "control: pgrep -x omarchy-screensaver unexpectedly matched" \
    "pids: $(pgrep -x omarchy-screensaver | tr '\n' ' ')"
fi

# Empty clients JSON: window gate misses, pidof -x hits, launcher exits 0
# without touching toggle/terminal helpers. PATH still has the hyprctl stub,
# but not a pidof stub — real procps sees the script started above.
set +e
output=$(run_launcher '[]')
rc=$?
set -e

((rc == 0)) || fail "running screensaver script prevents a duplicate launch via pidof -x" \
  "rc=$rc output=$output pid=$(pidof -x omarchy-screensaver 2>/dev/null)"
[[ $(<"$hyprctl_log") == "clients -j" ]] ||
  fail "script-process path still queries hyprctl clients first" "log=$(<"$hyprctl_log")"
[[ ! -s $helper_log ]] ||
  fail "script-process path must not reach toggle/terminal helpers" "helpers=$(<"$helper_log")"
# run_launcher puts the pidof stub back on PATH via $tmp; the live script case
# removed that stub earlier, so confirm we did not accidentally restore it.
[[ ! -e $tmp/pidof ]] || fail "live pidof path must not restore the pidof stub"
pass "running screensaver script prevents a duplicate launch via pidof -x"

kill "$script_pid" 2>/dev/null || true
wait "$script_pid" 2>/dev/null || true
script_pid=""

pass "screensaver already-running gate covers window and in-flight process"
