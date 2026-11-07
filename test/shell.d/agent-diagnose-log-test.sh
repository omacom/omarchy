#!/bin/bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export CAPTURE="$tmp/capture"
mkdir -p "$tmp/bin"
export PATH="$tmp/bin:$PATH"
cat > "$tmp/bin/omarchy-agent" <<'MOCK'
#!/bin/bash
printf '%s\0' "$@" > "$CAPTURE"
exit "${AGENT_STATUS:-0}"
MOCK
chmod +x "$tmp/bin/omarchy-agent"
run() { bash "$ROOT/bin/omarchy-agent-diagnose-log" "$@"; }
printf '%s\n' 'error: $(touch marker)' 'second line' > "$tmp/build output.log"
run --inline "$tmp/build output.log" 'make test' 'failed with 2'
python3 - <<'PY'
import os
args=open(os.environ['CAPTURE'],'rb').read().split(b'\0')
assert args[:2]==[b'--inline',b'--prompt']
assert b'make test failed with 2' in args[2]
assert b'error: $(touch marker)\nsecond line\n' in args[2]
PY
pass 'multiline log and context are passed literally as one prompt'
python3 -c 'import sys;sys.stdout.write("omitted-start"+"a"*40000+"failure-at-end")' > "$tmp/large.log"
run "$tmp/large.log"
python3 - <<'PY'
import os
args=open(os.environ['CAPTURE'],'rb').read().split(b'\0')
assert b'omitted-start' not in args[1]
assert b'failure-at-end' in args[1]
assert len(args[1])<34000
PY
pass 'large log is bounded and keeps the most recent failure'
printf ' \n' > "$tmp/empty.log"
for bad in "$tmp/missing" "$tmp" "$tmp/empty.log"; do
  rm -f "$CAPTURE"
  if run "$bad" 2>/dev/null; then fail "reject $bad"; fi
  [[ ! -e $CAPTURE ]] || fail 'invalid input launched agent'
done
if AGENT_STATUS=7 run "$tmp/build output.log"; then fail 'propagate launch failure'; else [[ $? == 7 ]] || fail 'wrong status'; fi
pass 'missing, non-file and empty logs are rejected; harness failures propagate'
