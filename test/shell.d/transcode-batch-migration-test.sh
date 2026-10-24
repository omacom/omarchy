#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

python3 <<'PY'
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(os.environ['ROOT'])
migration = root / 'migrations/1792293387.sh'
# The old shipped loop with an unrelated user edit before and after it.
legacy = '''# custom leading comment
        if len(paths) == 1:
            cmd = shlex.join([binary, paths[0]])
        else:
            cmd = "; ".join(
                f"echo {shlex.quote(f'Transcoding {path}')} && "
                f"{shlex.join([binary, path])} || true"
                for path in paths
            )
# custom trailing comment
'''
with tempfile.TemporaryDirectory() as home:
  extension = Path(home) / '.local/share/nautilus-python/extensions/transcode.py'
  env = {**os.environ, 'HOME': home, 'OMARCHY_PATH': str(root)}
  def migrate():
    subprocess.run(['bash', '-euo', 'pipefail', str(migration)], env=env, check=True, stdout=subprocess.DEVNULL)
  migrate()
  assert not extension.exists()
  print('ok - migration leaves an intentionally missing extension absent')
  extension.parent.mkdir(parents=True)
  extension.write_text(legacy)
  migrate()
  patched = extension.read_text()
  assert '--batch' in patched and patched.startswith('# custom leading') and patched.endswith('# custom trailing comment\n')
  backup = extension.with_name('transcode.py.bak.1792293387')
  assert backup.read_text() == legacy
  print('ok - migration backs up and changes only the old launch loop')
  migrate()
  assert extension.read_text() == patched and backup.read_text() == legacy
  print('ok - migration is idempotent and keeps its original backup')
  extension.write_text('# My own launcher\n')
  migrate()
  assert extension.read_text() == '# My own launcher\n'
  print('ok - migration leaves a custom launcher unchanged')
  extension.unlink()
  target = Path(home) / 'linked.py'
  target.write_text(legacy)
  extension.symlink_to(target)
  migrate()
  assert extension.is_symlink() and target.read_text() == legacy
  print('ok - migration does not rewrite a symlink target')
PY
