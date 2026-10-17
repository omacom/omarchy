#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/units" "$test_tmp/runtime"
export TEST_REMINDER_DIR="$test_tmp"
export XDG_RUNTIME_DIR="$test_tmp/runtime"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

# Keep calls within the same second deterministically. Other date operations
# still use GNU date, as they do when creating and listing real timers.
cat >"$test_tmp/bin/date" <<'SH'
#!/bin/bash
if [[ $* == "+%s" ]]; then
  echo 1700000000
else
  exec /usr/bin/date "$@"
fi
SH

# Model systemd's refusal to register a unit that is already present. mkdir
# makes the collision check atomic even when the reminders run concurrently.
cat >"$test_tmp/bin/systemd-run" <<'SH'
#!/bin/bash
[[ ${TEST_REMINDER_FAIL:-false} == "true" ]] && exit 1
for arg in "$@"; do
  [[ $arg == --unit=* ]] && unit=${arg#--unit=}
done
mkdir "$TEST_REMINDER_DIR/units/$unit" 2>/dev/null || exit 1
printf '%s\0' "$@" >"$TEST_REMINDER_DIR/units/$unit/args"
SH

cat >"$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
if [[ $* == *--output=json* ]]; then
  python3 - <<'PY'
import json, os
from pathlib import Path
print(json.dumps([{'unit': p.name + '.timer', 'next': 1700000600000000}
                  for p in Path(os.environ['TEST_REMINDER_DIR'], 'units').iterdir()]))
PY
elif [[ $* == *list-timers* ]]; then
  for unit in "$TEST_REMINDER_DIR/units/"*; do
    printf 'future %s.timer %s.service\n' "${unit##*/}" "${unit##*/}"
  done
elif [[ ${2:-} == "stop" ]]; then
  printf '%s\n' "${@:3}" >>"$TEST_REMINDER_DIR/stopped"
fi
SH

for command in omarchy-shell omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/$command"
done
chmod +x "$test_tmp/bin/"*

"$ROOT/bin/omarchy-reminder" 10 "First reminder"
"$ROOT/bin/omarchy-reminder" 10 "Second reminder" ||
  fail "two reminders in the same second both start"
pass "two reminders in the same second both start"

pids=()
for i in {1..12}; do
  "$ROOT/bin/omarchy-reminder" 10 "Parallel reminder $i" &
  pids+=("$!")
done
for pid in "${pids[@]}"; do
  wait "$pid" || fail "parallel reminders each start their own timer"
done
pass "parallel reminders each start their own timer"

"$ROOT/bin/omarchy-reminder" 10
"$ROOT/bin/omarchy-reminder" 10

python3 - <<'PY'
import os
from pathlib import Path
root = Path(os.environ['TEST_REMINDER_DIR'])
units = list((root / 'units').iterdir())
expected = ['First reminder', 'Second reminder'] + [f'Parallel reminder {i}' for i in range(1, 13)]
messages = []
defaults = 0
for unit in units:
    args = (unit / 'args').read_bytes().split(b'\0')[:-1]
    message, filename = args[-2:]
    message_file = Path(os.fsdecode(filename))
    assert message_file.stem == unit.name
    assert unit.name.startswith('omarchy-reminder-10m-')
    if message == b'Your 10 minutes are up':
        defaults += 1
    else:
        assert message_file.read_bytes() == message, (unit.name, message_file.read_bytes(), message)
        messages.append(message.decode())
assert sorted(messages) == sorted(expected), messages
assert defaults == 2, defaults
assert len(units) == 16, len(units)
print('ok - each custom message belongs to its own timer and default messages do not collide')
PY

"$ROOT/bin/omarchy-reminder" show --json >"$test_tmp/list.json"
jq -e '.count == 16 and ([.reminders[] | select(.label == "10-min reminder")] | length == 2)' "$test_tmp/list.json" >/dev/null ||
  fail "listing recognizes each unique timer and default-message label"
pass "listing recognizes each unique timer and default-message label"

if TEST_REMINDER_FAIL=true "$ROOT/bin/omarchy-reminder" 10 "Cannot start"; then
  fail "failed timer creation exits unsuccessfully"
fi
[[ $(find "$XDG_RUNTIME_DIR/omarchy-reminders" -name '*.message' | wc -l) == 16 ]] ||
  fail "failed timer creation leaves no reserved message file"
pass "failed timer creation leaves no reserved message file"

"$ROOT/bin/omarchy-reminder" clear
[[ -z $(find "$XDG_RUNTIME_DIR/omarchy-reminders" -name '*.message' -print -quit) ]] ||
  fail "clear removes unique reminder message files"
pass "clear removes unique reminder message files"

python3 - <<'PY'
import os
from pathlib import Path
root = Path(os.environ['TEST_REMINDER_DIR'])
expected = {p.name + suffix for p in (root / 'units').iterdir() for suffix in ['.timer', '.service']}
assert set((root / 'stopped').read_text().splitlines()) == expected
print('ok - clear stops every unique timer and service')
PY
