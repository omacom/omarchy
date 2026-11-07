#!/bin/bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export CAPTURE="$tmp/capture" CALLS="$tmp/calls"
mkdir -p "$tmp/bin"
export PATH="$tmp/bin:$PATH"
cat > "$tmp/bin/systemctl" <<'MOCK'
#!/bin/bash
printf '%s\0' "$@" >> "$CALLS"
if [[ " $* " == *' show '* ]]; then
  echo "${LOAD_STATE:-loaded}"
else
  if [[ ${OVERSIZED_OUTPUT:-0} == 1 ]]; then
    python3 - <<'PY_OUTPUT'
import os
from pathlib import Path
try:
    for _ in range(8192):
        os.write(1, b's' * 4096)
except BrokenPipeError:
    Path(os.environ['STATUS_STOPPED']).touch()
PY_OUTPUT
    exit 3
  fi
  printf 'failed: %s\n' "${*: -1}"
  exit 3
fi
MOCK
cat > "$tmp/bin/journalctl" <<'MOCK'
#!/bin/bash
printf '%s\0' "$@" >> "$CALLS"
if [[ ${OVERSIZED_OUTPUT:-0} == 1 ]]; then
  python3 -c 'import sys; sys.stdout.write("j" * 1048576 + "journal-tail")'
else
  printf '%s' 'failure: $(touch not-a-command)'
fi
MOCK
cat > "$tmp/bin/omarchy-agent" <<'MOCK'
#!/bin/bash
printf '%s\0' "$@" > "$CAPTURE"
MOCK
chmod +x "$tmp/bin/"*
run() { bash "$ROOT/bin/omarchy-agent-service" "$@"; }
run --inline --user example@instance
python3 - <<'PY'
import os
args=open(os.environ['CAPTURE'],'rb').read().split(b'\0')
calls=open(os.environ['CALLS'],'rb').read().split(b'\0')
assert args[:2] == [b'--inline',b'--prompt']
assert b'failed: example@instance.service' in args[2]
assert b'failure: $(touch not-a-command)' in args[2]
assert calls.count(b'--user') == 3,calls
assert b'--unit=example@instance.service' in calls
assert not any(x in calls for x in [b'restart',b'stop',b'enable'])
PY
pass 'user unit status and logs reach the agent despite failed-service exit status'
rm -f "$CALLS"
run bluetooth.service
python3 - <<'PY'
import os
calls=open(os.environ['CALLS'],'rb').read().split(b'\0')
assert b'--user' not in calls
assert b'--unit=bluetooth.service' in calls
PY
pass 'system service is the default scope'
for bad in '--all' '*' 'bluetooth?' 'foo[bar]' 'two units'; do
  rm -f "$CAPTURE" "$CALLS"
  if run "$bad" 2>/dev/null; then fail "reject $bad"; fi
  [[ ! -e $CAPTURE && ! -e $CALLS ]] || fail 'bad unit reached systemctl or agent'
done
rm -f "$CAPTURE"
if LOAD_STATE=not-found run missing 2>/dev/null; then fail 'reject missing unit'; fi
[[ ! -e $CAPTURE ]] || fail 'missing unit launched agent'
pass 'invalid and missing units do not launch diagnosis'

export STATUS_STOPPED="$tmp/status-stopped"
OVERSIZED_OUTPUT=1 run bluetooth.service
[[ -e $STATUS_STOPPED ]] || fail 'status producer was not stopped at the byte limit'
python3 - <<'PY_BOUNDS'
import os
args = open(os.environ['CAPTURE'], 'rb').read().split(b'\0')
status, journal = args[1].split(b'SERVICE STATUS:\n', 1)[1].split(b'\n\nJOURNAL:\n', 1)
assert status == b's' * 8192
assert len(journal) == 24576 and journal.endswith(b'journal-tail')
PY_BOUNDS
pass 'oversized status is stopped early and journal retains only its bounded tail'
