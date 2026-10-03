#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
if (( EUID == 0 )); then
  skip "non-root helper timeout fixture while running as root"
  exit 0
fi
require_command timeout
require_command python3
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
sed -n '/^as_session_user() {$/,/^}$/p' "$ROOT/bin/omarchy-battery-guard" >"$tmp_dir/function.sh"
cat >"$tmp_dir/ignore-term.py" <<'PY'
import os, signal, sys, time
signal.signal(signal.SIGTERM, signal.SIG_IGN)
with open(sys.argv[1], 'w') as f:
  f.write(f'{os.getpid()} {os.getpgrp()}')
time.sleep(30)
PY
# Only a freshly spawned fixture group may be terminated by the supervisor.
# No daemon, compositor, user application, or power command is launched.
python3 - "$BASH" "$tmp_dir" <<'PY'
from pathlib import Path
import os, signal, subprocess, sys, time
p = Path(sys.argv[2])
start = time.monotonic()
proc = subprocess.Popen([sys.argv[1], '-c', 'source "$1"; as_session_user 1000 fixture "$2" "$3" "$4"', '_', str(p/'function.sh'), sys.executable, str(p/'ignore-term.py'), str(p/'pid')], stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
try:
  stdout, stderr = proc.communicate(timeout=4.5)
  elapsed = time.monotonic() - start
  if proc.returncode not in (124, 137):
    raise AssertionError(f'expected bounded timeout, got {proc.returncode}: {stderr.decode()}')
  if not (p/'pid').exists():
    raise AssertionError('TERM-ignoring fixture did not start')
  print(f'ok - TERM-ignoring session helper is bounded at {elapsed:.2f}s (exit {proc.returncode})')
finally:
  if (p/'pid').exists():
    pid, group = map(int, (p/'pid').read_text().split())
    if group != os.getpgrp():
      try: os.killpg(group, signal.SIGKILL)
      except ProcessLookupError: pass
  if proc.poll() is None:
    os.killpg(proc.pid, signal.SIGKILL)
    proc.communicate(timeout=2)
PY
