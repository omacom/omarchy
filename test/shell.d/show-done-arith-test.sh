#!/bin/bash

# omarchy-show-done takes an exit code as $1 and tests it with (( )). Bash
# evaluates (( )) operands as arithmetic, so a hostile argument like
# 'a[$(touch /tmp/pwned)]' would run command substitution. The script must
# coerce non-numeric input before the arithmetic test.

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

# A hostile first argument must not execute commands.
cat >"$test_tmp/run.sh" <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 'a[$(touch "$SHOW_DONE_MARKER")]'
RUNNER
chmod +x "$test_tmp/run.sh"
run_under_pty >/dev/null
[[ ! -e $SHOW_DONE_MARKER ]] ||
  fail "hostile exit-code argument cannot execute commands" "marker file was created: $SHOW_DONE_MARKER"
pass "hostile exit-code argument cannot execute commands"

# Non-numeric input is coerced to success ("Done!").
cat >"$test_tmp/run.sh" <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" abc
RUNNER
out=$(run_under_pty)
[[ $out == *"Done!"* ]] || fail "non-numeric exit code is treated as success" "$out"
pass "non-numeric exit code is treated as success"

# A numeric failure still reports its exit code.
cat >"$test_tmp/run.sh" <<'RUNNER'
#!/bin/bash
"$ROOT/bin/omarchy-show-done" 3
RUNNER
out=$(run_under_pty)
[[ $out == *"Failed (exit code 3)"* ]] || fail "numeric exit code still reported" "$out"
pass "numeric exit code still reported"
