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
  printf 'failed: %s\n' "${*: -1}"
  exit 3
fi
MOCK
cat > "$tmp/bin/journalctl" <<'MOCK'
#!/bin/bash
printf '%s\0' "$@" >> "$CALLS"
printf '%s' 'failure: $(touch not-a-command)'
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
