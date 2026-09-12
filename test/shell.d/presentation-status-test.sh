#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export TEST_LOG="$test_tmp/log"
export PATH="$test_tmp:$ROOT/bin:$PATH"
printf '#!/bin/bash\n:\n' >"$test_tmp/omarchy-restart-gum"
cp "$test_tmp/omarchy-restart-gum" "$test_tmp/omarchy-show-logo"
cat >"$test_tmp/setsid" <<'STUB'
#!/bin/bash
while (( $# >= 3 )); do
  if [[ $1 == "bash" && $2 == "-c" ]]; then
    exec bash -c "$3"
  fi
  shift
done
exit 97
STUB
cat >"$test_tmp/omarchy-show-done" <<'STUB'
#!/bin/bash
printf '%s\n' "$1" >>"$TEST_LOG"
STUB
chmod +x "$test_tmp"/omarchy-* "$test_tmp/setsid"

for status in 0 7 19 130; do
  : >"$TEST_LOG"
  actual=0
  "$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" "exit $status" || actual=$?
  (( actual == status )) || fail "presentation preserves exit status $status" "got $actual"
  if (( status == 130 )); then
    [[ ! -s $TEST_LOG ]] || fail "cancellation closes without a completion prompt"
  else
    [[ $(cat "$TEST_LOG") == "$status" ]] || fail "completion receives the command status"
  fi
done
pass "success, failure, explicit exits and cancellation retain their status"

actual=0
"$ROOT/bin/omarchy-launch-floating-terminal-with-presentation" 'false && echo unreachable' || actual=$?
(( actual == 1 )) || fail "compound commands retain their failure status"
pass "shell command lists still work inside the presentation"
