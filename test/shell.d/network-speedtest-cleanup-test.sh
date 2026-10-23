#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command jq
require_command ps
require_command pkill

python3 - <<'PY'
import os
from pathlib import Path
import signal
import subprocess
import tempfile
import time

root = Path(os.environ['ROOT'])


def wait_until(predicate, timeout=5):
  deadline = time.monotonic() + timeout
  while time.monotonic() < deadline:
    if predicate():
      return True
    time.sleep(0.02)
  return False


def session_processes(session):
  # Listing all processes succeeds even when the target session is empty.
  result = subprocess.run(['ps', '-eo', 'pid=,sid=,stat='],
                          capture_output=True, text=True, check=True)
  return [int(pid) for pid, sid, state in (line.split() for line in result.stdout.splitlines())
          if int(sid) == session and not state.startswith('Z')]


with tempfile.TemporaryDirectory() as scratch:
  scratch = Path(scratch)
  stubs = scratch / 'bin'
  stubs.mkdir()
  # Transfers block locally: cancellation must stop them without network access.
  scripts = {
    'ip': 'echo "1.1.1.1 dev lo src 127.0.0.1"',
    'curl': '''
for arg in "$@"; do
  if [[ $arg == *api.fast.com* ]]; then
    echo '{"targets":[{"url":"https://speedtest.invalid/transfer"}]}'
    exit 0
  fi
done
echo "curl $$ $PPID" >>"$TEST_TRANSFERS"
exec sleep 60
''',
    'dd': '''
echo "dd $$ $PPID" >>"$TEST_TRANSFERS"
exec sleep 60
''',
  }
  for name, body in scripts.items():
    stub = stubs / name
    stub.write_text('#!/bin/bash\n' + body + '\n')
    stub.chmod(0o755)

  def run_case(direction, stop):
    log = scratch / 'transfers'
    log.write_text('')
    env = dict(os.environ, PATH=f'{stubs}:{root / "bin"}:{os.environ["PATH"]}',
               TEST_TRANSFERS=str(log), HOME=str(scratch), OMARCHY_PATH=str(root))
    description = f'network speedtest {direction}: {stop.name} stops blocked transfers'
    with (scratch / 'stderr').open('w+') as errors:
      process = subprocess.Popen([str(root / 'bin/omarchy-network-speedtest'), direction],
                                 env=env, start_new_session=True,
                                 stdout=subprocess.DEVNULL, stderr=errors)
      try:
        def all_started():
          lines = log.read_text().splitlines()
          curl_workers = {line.split()[2] for line in lines if line.startswith('curl ')}
          upload_workers = {line.split()[2] for line in lines if line.startswith('dd ')}
          return len(curl_workers) == 8 and (direction == 'down' or len(upload_workers) == 8)

        assert wait_until(all_started), 'all eight transfers must start'
        process.send_signal(stop)
        process.wait(timeout=5)
        assert wait_until(lambda: not session_processes(process.pid)), (
          f'leftover processes: {session_processes(process.pid)}')
        print(f'ok - {description}', flush=True)
      except (AssertionError, subprocess.TimeoutExpired) as error:
        errors.seek(0)
        raise AssertionError(f'{description}: {error}\n{errors.read()}') from error
      finally:
        # Clean up only this test session, even when the unpatched script leaks.
        subprocess.run(['pkill', '-KILL', '-s', str(process.pid)], check=False)
        process.wait(timeout=5)

  for direction in ('down', 'up'):
    for stop in (signal.SIGTERM, signal.SIGKILL):
      run_case(direction, stop)
PY
