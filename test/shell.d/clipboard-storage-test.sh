#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - <<'PY'
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(os.environ['ROOT'])
spec = importlib.util.spec_from_file_location('storage', root / 'shell/plugins/clipboard/migrate-history.py')
storage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(storage)

def check(condition, description):
  assert condition, description
  print('ok - ' + description)

with tempfile.TemporaryDirectory(prefix='clipboard-storage-') as folder:
  folder = Path(folder)
  history = folder / 'clipboard-history.json'
  directory = folder / 'omarchy/clipboard-text'
  # Exercise the exact boundary cheaply; production constants are unchanged.
  storage.LARGE_LIMIT = 1024
  original = json.dumps(['before', 'x' * 1025, 'after']).encode()
  history.write_bytes(original)
  warnings = io.StringIO()
  with contextlib.redirect_stderr(warnings), storage.history_lock(history):
    loaded = json.loads(storage.load_history(history, directory, storage.HISTORY_BUDGET))
  check([entry['text'] for entry in loaded] == ['before', 'after'], 'clipboard migration skips an oversized entry and keeps both neighbors')
  check(any(p.read_bytes() == original for p in folder.glob('*.migrated-*')), 'clipboard preserves the oversized entry in an exact recovery backup')
  check('some entries kept only' in warnings.getvalue(), 'clipboard migration reports entries available only in recovery')
  check(not directory.exists(), 'clipboard migration does not persist a skipped oversized text file')

  original = json.dumps(['x' * 1024]).encode()
  history.write_bytes(original)
  with storage.history_lock(history):
    loaded = json.loads(storage.load_history(history, directory, storage.HISTORY_BUDGET))
  check(loaded[0]['text'] == 'x' * 1024, 'clipboard migration retains a text exactly at the per-copy limit')

  # Start the actual save entry point while migration holds the shared lock.
  # Its readiness line makes this independent of process startup speed.
  history.write_text('["legacy"]')
  newest = '[{"type":"text","text":"newer captured copy"}]'
  child = None
  with tempfile.TemporaryFile() as input_file:
    input_file.write(newest.encode())
    input_file.seek(0)
    try:
      with storage.history_lock(history):
        child = subprocess.Popen(['python3', '-c', '''
import importlib.util, sys
spec = importlib.util.spec_from_file_location('storage', sys.argv[1])
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
sys.argv = [sys.argv[1], '--save', sys.argv[2], sys.argv[3]]
print('ready', flush=True)
m.main()
''', str(root / 'shell/plugins/clipboard/migrate-history.py'), str(history), str(storage.HISTORY_BUDGET)], stdin=input_file, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        check(child.stdout.readline().strip() == 'ready', 'clipboard concurrent save reaches the storage entry point')
        try:
          child.wait(timeout=0.2)
          raise AssertionError('save bypassed the migration lock')
        except subprocess.TimeoutExpired:
          pass
        storage.load_history(history, directory, storage.HISTORY_BUDGET)
        check(json.loads(history.read_text())[0]['text'] == 'legacy', 'clipboard migration completes before the waiting save')
      _, errors = child.communicate(timeout=5)
      check(child.returncode == 0, 'clipboard waiting save succeeds: ' + errors.strip())
      check(json.loads(history.read_text())[0]['text'] == 'newer captured copy', 'clipboard migration cannot overwrite a newer coordinated save')
    finally:
      if child and child.poll() is None:
        child.kill()
        child.communicate()

  before = history.read_bytes()
  for payload in [b'not json', b'{}', b'[]' + b' ' * storage.HISTORY_BUDGET]:
    result = subprocess.run(['bash', str(root / 'shell/plugins/clipboard/save-history.sh'), str(history), str(storage.HISTORY_BUDGET)], input=payload, capture_output=True)
    check(result.returncode == 3 and history.read_bytes() == before, 'clipboard failed save preserves the last saved history')
  replace = storage.os.replace
  def fail_replace(*_):
    raise OSError('simulated failed atomic commit')
  storage.os.replace = fail_replace
  try:
    try:
      storage.atomic_write(history, b'[]')
      raise AssertionError('failed commit unexpectedly succeeded')
    except OSError:
      pass
    check(history.read_bytes() == before, 'clipboard failed atomic commit preserves the previous history')
    check(all(p.name.startswith('clipboard-history.json') for p in folder.glob('clipboard-history.*')), 'clipboard failed atomic commit removes its temporary file')
  finally:
    storage.os.replace = replace

  cleared = folder / 'cleared'
  cleared.mkdir()
  history = cleared / 'clipboard-history.json'
  history.write_text('[]')
  save = ['bash', str(root / 'shell/plugins/clipboard/save-history.sh'), str(history), str(storage.HISTORY_BUDGET)]
  for name in ['migrated-1', 'rejected-2']:
    (cleared / ('clipboard-history.json.' + name)).write_text('["old secret"]')
  result = subprocess.run(save, input=b'[]', capture_output=True)
  check(result.returncode == 0 and len(list(cleared.glob('*.migrated-*')) + list(cleared.glob('*.rejected-*'))) == 2, 'clipboard ordinary save keeps recovery backups')
  result = subprocess.run(save + ['--clear-backups'], input=b'[]', capture_output=True)
  check(result.returncode == 0 and history.read_text() == '[]', 'clipboard clear saves the empty history: ' + result.stderr.decode().strip())
  check(not list(cleared.glob('*.migrated-*')) and not list(cleared.glob('*.rejected-*')), 'clipboard clear removes recovery backups of the cleared history')
  stuck = folder / 'stuck'
  stuck.mkdir()
  history = stuck / 'clipboard-history.json'
  history.write_text('["kept until cleared"]')
  (stuck / 'clipboard-history.json.migrated-1').write_text('["old secret"]')
  real_unlink = Path.unlink
  def fail_backup_unlink(self, *args, **kwargs):
    if '.migrated-' in self.name:
      raise PermissionError('simulated undeletable backup')
    return real_unlink(self, *args, **kwargs)
  Path.unlink = fail_backup_unlink
  warnings = io.StringIO()
  try:
    with contextlib.redirect_stderr(warnings):
      storage.clear_backups(history)
  finally:
    Path.unlink = real_unlink
  check('could not remove recovery backup' in warnings.getvalue(), 'clipboard clear reports a backup it cannot remove without failing the save')
  check(history.read_text() == '["kept until cleared"]', 'clipboard backup cleanup never touches the committed history')
  check('saveWarnings.text.indexOf("could not remove recovery backup")' in (root / 'shell/plugins/clipboard/Clipboard.qml').read_text(), 'clipboard picker explains a backup that could not be removed')
PY
