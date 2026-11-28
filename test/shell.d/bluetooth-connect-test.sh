#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

python3 - "$ROOT" <<'PY'
import fcntl
import os
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
with tempfile.TemporaryDirectory() as directory:
  tmp = Path(directory)
  mock_bin = tmp / 'bin'
  mock_bin.mkdir()
  log = tmp / 'calls'
  for name, body in {
    'bluetoothctl': '''printf '%s\\n' "$*" >>"$CALLS"
case "$1" in
  show) echo 'Powered: yes' ;;
  connect) echo 'Failed to connect: org.bluez.Error.InProgress br-connection-busy'; exit "${CONNECT_STATUS:-0}" ;;
esac
''',
    'omarchy-notification-send': 'printf "notification %s\\n" "$*" >>"$CALLS"\n',
    'logger': 'printf "logger %s\\n" "$*" >>"$CALLS"\n',
  }.items():
    script = mock_bin / name
    script.write_text('#!/bin/bash\n' + body)
    script.chmod(0o755)
  env = dict(os.environ, PATH=f'{mock_bin}:{root / "bin"}:{os.environ["PATH"]}',
             XDG_RUNTIME_DIR=str(tmp), CALLS=str(log))
  address = 'AA:BB:CC:DD:EE:FF'

  def run(action='connect', target=address, status=0):
    log.write_text('')
    result = subprocess.run([str(root / 'bin/omarchy-bluetooth-device'), action, target],
                            env=dict(env, CONNECT_STATUS=str(status)), capture_output=True, text=True)
    return result, log.read_text()

  result, calls = run()
  assert result.returncode == 0 and calls.splitlines().count('connect ' + address) == 1
  assert 'notification' not in calls
  print('ok - successful connection does not notify')

  for action in ('connect', 'pair'):
    for status in (1, 124):
      result, calls = run(action=action, status=status)
      assert result.returncode == status
      assert 'br-connection-busy' in result.stderr and 'br-connection-busy' in calls
      assert calls.count('notification ') == 1
      assert calls.splitlines().count('connect ' + address) == 1
      assert 'disconnect ' not in calls
  print('ok - connect and pair preserve failures and timeouts, log details and notify once without retries')

  with open(tmp / f'omarchy-bluetooth-connect-{address}.lock', 'w') as lock:
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    for action in ('connect', 'pair'):
      result, calls = run(action=action, target=address.lower())
      assert result.returncode == 0 and calls == ''
    result, calls = run(target='11:22:33:44:55:66')
    assert result.returncode == 0 and 'connect 11:22:33:44:55:66' in calls
    result, calls = run(action='disconnect')
    assert result.returncode == 0 and 'disconnect ' + address in calls
  print('ok - same-device attempts share a case-insensitive lock; other devices and cancellation remain available')

  result, calls = run()
  assert result.returncode == 0 and 'connect ' + address in calls
  print('ok - connection lock is released after the previous command exits')
PY
