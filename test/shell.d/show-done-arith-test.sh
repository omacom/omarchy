#!/bin/bash

# omarchy-show-done takes an exit code as $1 and tests it with (( )). Bash
# evaluates (( )) operands as arithmetic, so a hostile argument like
# 'a[$(touch /tmp/pwned)]' would run command substitution. The script must
# validate the argument before the arithmetic test: only real exit statuses
# (0-255, ASCII digits read in base 10 even with leading zeros) are accepted.
# Malformed input is a caller bug and must be an error, never a silent
# "Done!".

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command script

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export SHOW_DONE_MARKER="$test_tmp/pwned"

# omarchy-show-done needs /dev/tty, so run it under script(1), which provides
# a pty. The script drains queued input (0.1s timeout) and then blocks for one
# keypress, so feed it two bytes: one for the drain, one for the wait.
run_under_pty() {
  (printf 'x'; sleep 0.5; printf 'x') | script -qec "bash $test_tmp/run.sh" /dev/null 2>/dev/null
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
run_under_pty >/dev/null || true
[[ ! -e $SHOW_DONE_MARKER ]] ||
  fail "hostile exit-code argument cannot execute commands" "marker file was created: $SHOW_DONE_MARKER"
pass "hostile exit-code argument cannot execute commands"

# Non-numeric input is an error, not a silent "Done!".
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" abc
RUNNER
if out=$(run_under_pty); then
  fail "non-numeric exit code is an error" "exited 0: $out"
fi
[[ $out == *"invalid exit code"* ]] || fail "non-numeric exit code reports the problem" "$out"
[[ $out != *"Done!"* ]] || fail "non-numeric exit code must not print Done!" "$out"
pass "non-numeric exit code is an error"

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

# 255 is the largest valid exit status.
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 255
RUNNER
out=$(run_under_pty)
[[ $out == *"Failed (exit code 255)"* ]] || fail "255 is accepted" "$out"
pass "255 is accepted"

# 256 is outside the exit-status range and must be an error.
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 256
RUNNER
if out=$(run_under_pty); then
  fail "256 is an error" "exited 0: $out"
fi
[[ $out == *"out of range"* ]] || fail "256 reports out of range" "$out"
[[ $out != *"Done!"* ]] || fail "256 must not print Done!" "$out"
pass "256 is an error"

# An extremely large number must not wrap around into a "Done!".
write_runner <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 99999999999999999999999999
RUNNER
if out=$(run_under_pty); then
  fail "huge exit code is an error" "exited 0: $out"
fi
[[ $out != *"Done!"* ]] || fail "huge exit code must not print Done!" "$out"
pass "huge exit code is an error"

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
