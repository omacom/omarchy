"""Bounded compositor access and user-owned operation state."""
import fcntl
import json
import os
from pathlib import Path
import subprocess
import time
from contextlib import contextmanager

class OperationBusy(ValueError):
  pass

def hypr(*args, timeout=10):
  result = subprocess.run(['hyprctl', *args], capture_output=True, text=True, check=True, timeout=timeout)
  return result.stdout.strip()


def state_dir():
  directory = Path(os.environ.get('XDG_STATE_HOME', str(Path.home() / '.local/state'))) / 'omarchy/display-orientation'
  directory.mkdir(parents=True, exist_ok=True, mode=0o700)
  return directory


def record(event, **fields):
  # Diagnostics must never turn a successful modeset into a rollback.
  try:
    with (state_dir() / 'events.jsonl').open('a') as log:
      log.write(json.dumps(dict(time=time.strftime('%Y-%m-%dT%H:%M:%S%z'),
                   event=event, **fields)) + '\n')
  except OSError:
    pass



@contextmanager
def operation_lock():
  # Runtime data MUST stay outside the shell's watched plugin directory.
  runtime = Path(os.environ.get('XDG_RUNTIME_DIR', f'/run/user/{os.getuid()}'))
  if not runtime.is_dir() or runtime.stat().st_uid != os.getuid():
    raise ValueError('User runtime directory is unavailable')
  fd = os.open(runtime / 'omarchy-display-orientation.lock',
        os.O_RDWR | os.O_CREAT | os.O_NOFOLLOW, 0o600)
  with os.fdopen(fd, 'r+') as lock:
    try:
      fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
      raise OperationBusy('Another display operation is still running') from None
    yield lock
