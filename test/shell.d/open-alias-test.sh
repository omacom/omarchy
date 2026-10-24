#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/xdg-open" <<'SH'
#!/bin/bash
echo "launcher output"
echo "no handler for $1" >&2
touch "$OPEN_FINISHED"
exit "${OPEN_STATUS:-0}"
SH
chmod +x "$stub_bin/xdg-open"

export PATH="$stub_bin:$PATH"
export OPEN_FINISHED="$test_tmp/finished"
TERM=dumb source "$ROOT/default/bash/aliases"

OPEN_STATUS=1 open "unknown:target" >"$test_tmp/out" 2>"$test_tmp/err"

# open is deliberately detached, so wait for the stub rather than accidentally
# turning this into a test that requires the helper to block.
for _ in {1..100}; do
  grep -Fxq 'Unable to open: unknown:target' "$test_tmp/err" && break
  sleep 0.01
done

[[ -e $test_tmp/finished ]] || fail "open waits forever or never starts xdg-open"
[[ ! -s $test_tmp/out ]] || fail "open leaks xdg-open progress to the terminal"
grep -Fxq 'Unable to open: unknown:target' "$test_tmp/err" ||
  fail "open hides the reason xdg-open could not launch a target"
pass "open stays quiet but reports launcher failures"

rm "$OPEN_FINISHED"
open "https://example.com" >"$test_tmp/out" 2>"$test_tmp/err"
for _ in {1..100}; do
  [[ -e $OPEN_FINISHED ]] && break
  sleep 0.01
done
[[ -e $OPEN_FINISHED ]] || fail "a successful handler completes"
[[ ! -s $test_tmp/out && ! -s $test_tmp/err ]] || fail "successful handlers do not leak their output"
pass "successful open stays quiet even when the application logs errors"

cat >"$stub_bin/xdg-open" <<'SH'
#!/bin/bash
while [[ ! -e $OPEN_RELEASE ]]; do sleep 0.01; done
touch "$OPEN_FINISHED"
SH
export OPEN_RELEASE="$test_tmp/release"
rm "$OPEN_FINISHED"
open "image.png"
[[ ! -e $OPEN_FINISHED ]] || fail "the delayed launcher has not completed"
touch "$OPEN_RELEASE"
for _ in {1..100}; do
  [[ -e $OPEN_FINISHED ]] && break
  sleep 0.01
done
[[ -e $OPEN_FINISHED ]] || fail "the detached handler completes after release"
pass "open returns while the handler is still running"
