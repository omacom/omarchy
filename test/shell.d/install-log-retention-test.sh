#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 - "$ROOT" <<'PY'
import fcntl
import os
from pathlib import Path
import sys
import tempfile
from unittest.mock import patch
sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(sys.argv[1]) / 'default/install-presentation'))
import dashboard
with tempfile.TemporaryDirectory() as tmp:
  directory = Path(tmp)
  for i in range(25):
    p = directory / f'install-{i:02}.log'
    p.write_text(str(i))
    os.utime(p, ns=(i, i))
  unrelated = directory / 'keep.txt'
  unrelated.write_text('keep')
  active = directory / 'install-00.log'
  with active.open('rb') as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    dashboard.prune_logs(directory)
    assert active.exists(), 'active logs must survive retention'
    assert len(list(directory.glob('install-*.log'))) == 21
  dashboard.prune_logs(directory)
  assert not active.exists()
  assert len(list(directory.glob('install-*.log'))) == 20
  assert (directory / 'install-24.log').exists() and unrelated.exists()
  with patch.object(Path, 'unlink', side_effect=PermissionError):
    dashboard.prune_logs(directory, keep=0)
  with patch.object(Path, 'stat', side_effect=FileNotFoundError):
    dashboard.prune_logs(directory)
  with patch.dict(os.environ, XDG_STATE_HOME=tmp):
    fd, log_path = dashboard.create_log()
    assert Path(log_path).stat().st_mode & 0o777 == 0o600
    os.close(fd)
print('ok - retention bounds completed logs, preserves active/unrelated files and tolerates cleanup races')
PY
