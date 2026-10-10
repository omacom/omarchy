#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

test_home="$test_dir/home"
stub_bin="$test_dir/bin"
notify_log="$test_dir/busctl-args"
running="$test_dir/running"
mkdir -p "$test_home" "$stub_bin"

# Every Notify call is appended as a CALL marker followed by its argv, so one
# log holds both the single reminder a session with one terminal gets and the
# two a session with both gets.
cat >"$stub_bin/busctl" <<'SH'
#!/bin/bash

{
  printf 'CALL\n'
  printf '%s\n' "$@"
} >>"$OMARCHY_TEST_BUSCTL_ARGS"
echo "u 42"
SH

# Report the terminals the scenario says are running, and nothing else: a
# caller that forgets to redirect this leaks the PID into the user's terminal,
# which is half of the regression under test.
cat >"$stub_bin/pgrep" <<'SH'
#!/bin/bash

name=
while (($# > 0)); do
  name=$1
  shift
done

if grep -Fx -- "$name" "$OMARCHY_TEST_RUNNING_TERMINALS" >/dev/null; then
  printf '4242\n'
  exit 0
fi
exit 1
SH

cat >"$stub_bin/fc-list" <<'SH'
#!/bin/bash
printf 'Test Font\n'
SH

for command in omarchy-restart-shell omarchy-hook kitty pkill; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$command"
done
chmod +x "$stub_bin/"*

# The real bin/omarchy-notification-send stays on PATH so its own argument
# parser is what consumes the call. That is the point: `-g` with no glyph
# swallows the message as the glyph and leaves no headline, so the sender
# prints its usage and exits 1 instead of sending anything.
font_set() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_BUSCTL_ARGS="$notify_log" \
    OMARCHY_TEST_RUNNING_TERMINALS="$running" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-font-set" "Test Font"
}

# running-terminal-names, one per line; empty when none is open.
run_scenario() {
  : >"$notify_log"
  printf '%s' "$1" >"$running"

  if ! font_set >"$test_dir/out" 2>"$test_dir/err"; then
    fail "font change succeeds with these terminals running: ${1:-none}" "$(<"$test_dir/err")"
  fi

  [[ ! -s $test_dir/out ]] ||
    fail "font change keeps pgrep's PIDs out of stdout" "$(<"$test_dir/out")"
  [[ ! -s $test_dir/err ]] ||
    fail "font change keeps the sender's usage error out of stderr" "$(<"$test_dir/err")"
}

# Notify(susssasa{sv}i) argv by position in the recorded busctl call:
#   0 --user  1 --  2 call  3 dest  4 path  5 iface  6 Notify  7 signature
#   8 app_name  9 replaces_id  10 app_icon  11 summary  12 body
#   13 actions-count  14 hint-count  15.. hint triples  last expire_timeout
declare -a args
load() { mapfile -t args < <(tail -n +2 "$notify_log"); }
calls() { grep -c '^CALL$' "$notify_log" || true; }
hint_value() { # key
  local i end=$((15 + 3 * ${args[14]}))
  for ((i = 15; i < end; i += 3)); do
    [[ ${args[i]} == "$1" ]] && { printf '%s\n' "${args[i + 2]}"; return 0; }
  done
  return 1
}

# U+E659 as UTF-8 bytes: $'\ue659' stays a literal "\ue659" outside a UTF-8 locale.
glyph=$'\xee\x99\x99'

# --------------------------------------------------------------- Foot running
run_scenario 'foot'
[[ $(calls) == 1 ]] || fail "a running Foot gets exactly one reminder" "$(calls)"
load
[[ ${args[11]} == "You must restart Foot to see font change" ]] ||
  fail "the Foot reminder is the notification headline" "${args[11]-}"
[[ $(hint_value omarchy-glyph) == "$glyph" ]] ||
  fail "the Foot reminder carries the font glyph" "$(hint_value omarchy-glyph || true)"
pass "a running Foot gets one reminder carrying the font glyph"

# ------------------------------------------------------------ Ghostty running
run_scenario 'ghostty'
[[ $(calls) == 1 ]] || fail "a running Ghostty gets exactly one reminder" "$(calls)"
load
[[ ${args[11]} == "You must restart Ghostty to see font change" ]] ||
  fail "the Ghostty reminder is the notification headline" "${args[11]-}"
[[ $(hint_value omarchy-glyph) == "$glyph" ]] ||
  fail "the Ghostty reminder carries the font glyph" "$(hint_value omarchy-glyph || true)"
pass "a running Ghostty gets one reminder carrying the font glyph"

# ------------------------------------------------------------- Both running
run_scenario $'foot\nghostty'
[[ $(calls) == 2 ]] || fail "each running terminal gets its own reminder" "$(calls)"
grep -Fx 'You must restart Foot to see font change' "$notify_log" >/dev/null ||
  fail "the Foot reminder survives a Ghostty reminder beside it"
grep -Fx 'You must restart Ghostty to see font change' "$notify_log" >/dev/null ||
  fail "the Ghostty reminder survives a Foot reminder beside it"
pass "both running terminals get their own reminder"

# ------------------------------------------------------------ None running
run_scenario ''
[[ $(calls) == 0 ]] || fail "no running terminal means no reminder" "$(calls)"
pass "no running terminal gets no reminder"
