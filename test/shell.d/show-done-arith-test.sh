#!/bin/bash

# omarchy-show-done takes an exit code as $1 and tests it with (( )). Bash
# evaluates (( )) operands as arithmetic, so a hostile argument like
# 'a[$(touch /tmp/pwned)]' would run command substitution. The script must
# validate the argument before the arithmetic test: only real exit statuses
# (0-255, ASCII digits read in base 10 even with leading zeros) are accepted.
# Malformed input is a caller bug: it gets a red Failed prompt naming the
# offending input (shell-quoted, so control characters cannot inject terminal
# escapes) and the script still waits for a keypress -- never a misleading
# "Done!", and never a raw stderr dump with no prompt.

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command script

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export SHOW_DONE_MARKER="$test_tmp/pwned"

# omarchy-show-done needs /dev/tty, so run it under script(1), which provides
# a pty. The script drains queued input (0.1s timeout) and then blocks for one
# keypress, so keep a keypress byte available until script exits: with a
# slow-starting child an up-front burst is drained before the blocking read,
# which then hangs the suite instead of failing.
run_under_pty() {
  coproc keyfeed { while :; do printf 'x'; sleep 0.2; done; }
  local key_fd=${keyfeed[0]}
  script -qec "bash $test_tmp/run.sh" /dev/null <&"$key_fd" 2>/dev/null
  local status=$?
  exec {key_fd}<&-
  kill "$keyfeed_PID" 2>/dev/null || true
  wait "$keyfeed_PID" 2>/dev/null || true
  return "$status"
}

write_runner() {
  cat >"$test_tmp/run.sh"
  chmod +x "$test_tmp/run.sh"
}

# A hostile first argument must not execute commands.
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 'a[$(touch "$SHOW_DONE_MARKER")]'
RUNNER
out=$(run_under_pty)
[[ ! -e $SHOW_DONE_MARKER ]] ||
  fail "hostile exit-code argument cannot execute commands" "marker file was created: $SHOW_DONE_MARKER"
[[ $out == *"Failed (invalid exit code"* ]] ||
  fail "hostile exit code gets a Failed prompt" "$out"
[[ $out == *"Press any key"* ]] ||
  fail "hostile exit code still waits for a keypress" "$out"
pass "hostile exit-code argument cannot execute commands"

# Non-numeric input gets a Failed prompt naming it, not a silent "Done!".
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" abc
RUNNER
out=$(run_under_pty)
[[ $out == *"Failed (invalid exit code abc)"* ]] ||
  fail "non-numeric exit code is named in a Failed prompt" "$out"
[[ $out == *"Press any key"* ]] ||
  fail "non-numeric exit code still waits for a keypress" "$out"
[[ $out != *"Done!"* ]] || fail "non-numeric exit code must not print Done!" "$out"
pass "non-numeric exit code is a Failed prompt"

# Invalid input must still wait for the keypress instead of exiting early:
# feed only the drain byte through a pipe we keep open (so script(1) never
# sees stdin EOF and can only leave via its keypress read) and confirm the
# script is still blocked afterwards.
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" abc
RUNNER
exec {pty_in}> >(script -qec "bash $test_tmp/run.sh" /dev/null >/dev/null 2>&1)
runner_pid=$!
printf 'x' >&$pty_in
sleep 1
if kill -0 "$runner_pid" 2>/dev/null; then
  waited=1
else
  waited=0
fi
exec {pty_in}>&-
kill "$runner_pid" 2>/dev/null || true
wait "$runner_pid" 2>/dev/null || true
(( waited )) || fail "invalid input still waits for a keypress" "exited before any keypress byte was sent"
pass "invalid input still waits for a keypress"

# 08 is a valid exit status (decimal 8), not an arithmetic error.
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 08
RUNNER
out=$(run_under_pty)
[[ $out == *"Failed (exit code 8)"* ]] || fail "08 is treated as decimal 8" "$out"
pass "08 is treated as decimal 8"

# 010 means decimal 10, not octal 8.
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 010
RUNNER
out=$(run_under_pty)
[[ $out == *"Failed (exit code 10)"* ]] || fail "010 is treated as decimal 10" "$out"
pass "010 is treated as decimal 10"

# Zero-padded codes are accepted as their decimal value: 0007 is 7.
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 0007
RUNNER
out=$(run_under_pty)
[[ $out == *"Failed (exit code 7)"* ]] || fail "0007 is treated as decimal 7" "$out"
pass "0007 is treated as decimal 7"

# A pathological all-zero argument must validate promptly, not stall: stripping
# zeros one at a time is quadratic, so 60000 zeros took ~18s and stalled the
# script before any prompt. The 10s budget fails the old code and passes the
# single-pass strip with wide margin either way.
write_runner <<'RUNNER'
#!/bin/bash
zeros=$(printf '%060000d' 0)
"$ROOT/bin/omarchy-show-done" "$zeros"
RUNNER
start=$SECONDS
out=$(run_under_pty)
elapsed=$((SECONDS - start))
(( elapsed < 10 )) ||
  fail "long all-zero input validates promptly" "validation took ${elapsed}s"
[[ $out == *"Done!"* ]] ||
  fail "all-zero input is exit code 0" "$out"
pass "long all-zero input validates promptly"

# 255 is the largest valid exit status.
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 255
RUNNER
out=$(run_under_pty)
[[ $out == *"Failed (exit code 255)"* ]] || fail "255 is accepted" "$out"
pass "255 is accepted"

# 256 is outside the exit-status range: a Failed prompt, not an error dump.
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 256
RUNNER
out=$(run_under_pty)
[[ $out == *"Failed (invalid exit code 256)"* ]] || fail "256 reports invalid exit code" "$out"
[[ $out == *"Press any key"* ]] || fail "256 still waits for a keypress" "$out"
[[ $out != *"Done!"* ]] || fail "256 must not print Done!" "$out"
pass "256 is an invalid exit code"

# An extremely large number must not wrap around into a "Done!", and must
# never reach arithmetic evaluation.
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 99999999999999999999999999
RUNNER
out=$(run_under_pty)
[[ $out == *"Failed (invalid exit code 99999999999999999999999999)"* ]] ||
  fail "huge exit code reports invalid exit code" "$out"
[[ $out != *"Done!"* ]] || fail "huge exit code must not print Done!" "$out"
pass "huge exit code is an invalid exit code"

# A raw escape byte in the input must be shell-quoted in the prompt, never
# passed through to the terminal unquoted. bash %q renders ESC inside the
# ANSI-C quoted form $'\E[31mRED' (backslash-E, not a raw escape byte).
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" $'\e[31mRED'
RUNNER
out=$(run_under_pty)
printf '%s' "$out" | grep -qF "\$'\\E[31mRED'" ||
  fail "raw ESC in input is shell-quoted" "$out"
# The red prompt itself uses exactly two raw ESC bytes (color on/off); any
# more would mean the input's escape reached the terminal unquoted.
esc_count=$(printf '%s' "$out" | tr -cd '\033' | wc -c)
(( esc_count == 2 )) ||
  fail "raw ESC in input is shell-quoted" "raw ESC bytes in output: $esc_count"
[[ $out == *"Press any key"* ]] || fail "ESC input still waits for a keypress" "$out"
pass "raw ESC in input is shell-quoted"

# A numeric failure still reports its exit code.
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 3
RUNNER
out=$(run_under_pty)
[[ $out == *"Failed (exit code 3)"* ]] || fail "numeric exit code still reported" "$out"
pass "numeric exit code still reported"

# Success still reports "Done!".
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 0
RUNNER
out=$(run_under_pty)
[[ $out == *"Done!"* ]] || fail "exit code 0 reports Done!" "$out"
pass "exit code 0 reports Done!"

# No argument defaults to 0 and reports "Done!".
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done"
RUNNER
out=$(run_under_pty)
[[ $out == *"Done!"* ]] || fail "missing argument reports Done!" "$out"
pass "missing argument reports Done!"
