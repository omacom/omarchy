#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command jq

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
  result = subprocess.run(['ps', '-s', str(session), '-o', 'pid=,stat='],
                          capture_output=True, text=True, check=False)
  return [int(pid) for pid, state in (line.split() for line in result.stdout.splitlines())
          if not state.startswith('Z')]


with tempfile.TemporaryDirectory() as scratch:
  scratch = Path(scratch)
  stubs = scratch / 'bin'
  stubs.mkdir()
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
if [[ $TEST_TRANSFER_MODE == "fail" ]]; then
  exit 7
fi
exec sleep "$TEST_TRANSFER_SECONDS"
''',
    'dd': '''
echo "dd $$ $PPID" >>"$TEST_TRANSFERS"
exec sleep "$TEST_TRANSFER_SECONDS"
''',
  }
  for name, body in scripts.items():
    stub = stubs / name
    stub.write_text('#!/bin/bash\n' + body + '\n')
    stub.chmod(0o755)

  def run_case(direction, stop, seconds='60', mode='wait'):
    log = scratch / 'transfers'
    log.write_text('')
    env = dict(os.environ, PATH=f'{stubs}:{root / "bin"}:{os.environ["PATH"]}',
               TEST_TRANSFERS=str(log), TEST_TRANSFER_SECONDS=seconds,
               TEST_TRANSFER_MODE=mode, HOME=str(scratch), OMARCHY_PATH=str(root))
    stop_name = stop.name if isinstance(stop, signal.Signals) else (stop or 'endpoint failure')
    description = f'network speedtest {direction}: {stop_name}, transfers {mode}/{seconds}s'
    with (scratch / 'stderr').open('w+') as errors:
      process = subprocess.Popen([str(root / 'bin/omarchy-network-speedtest'), direction],
                                 env=env, start_new_session=True,
                                 stdout=subprocess.PIPE, stderr=errors)
      try:
        def all_started():
          lines = log.read_text().splitlines()
          curl_workers = {line.split()[2] for line in lines if line.startswith('curl ')}
          upload_workers = {line.split()[2] for line in lines if line.startswith('dd ')}
          return len(curl_workers) == 8 and (direction == 'down' or len(upload_workers) == 8)

        assert wait_until(all_started), 'all eight transfers must start'
        if stop == 'closed stdout':
          process.stdout.close()
        elif stop is not None:
          process.send_signal(stop)
        process.wait(timeout=5)
        assert wait_until(lambda: not session_processes(process.pid)), (
          f'leftover processes: {session_processes(process.pid)}')
        request_count = len(log.read_text().splitlines())
        time.sleep(0.1)
        assert len(log.read_text().splitlines()) == request_count, 'transfers restarted after exit'
        print(f'ok - {description}', flush=True)
      except (AssertionError, subprocess.TimeoutExpired) as error:
        errors.seek(0)
        raise AssertionError(f'{description}: {error}\n{errors.read()}') from error
      finally:
        # Clean up only this test session, even when the unpatched script leaks.
        for pid in session_processes(process.pid):
          try:
            os.kill(pid, signal.SIGKILL)
          except ProcessLookupError:
            pass
        process.wait(timeout=5)
        process.stdout.close()

  for direction in ('down', 'up'):
    for stop in (signal.SIGTERM, signal.SIGKILL, signal.SIGINT, signal.SIGHUP, 'closed stdout'):
      run_case(direction, stop)
    run_case(direction, None, seconds='0.1', mode='fail')
    for _ in range(5):
      run_case(direction, signal.SIGTERM, seconds='0.02')
PY
