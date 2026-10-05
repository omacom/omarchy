#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - <<'PY'
import json
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(os.environ['ROOT'])
with tempfile.TemporaryDirectory(prefix='clipboard-privacy-') as temporary:
  folder = Path(temporary)
  (folder / 'bin').mkdir()
  lookup = folder / 'bin/wl-paste'
  env = {**os.environ, 'PATH': str(folder / 'bin') + ':' + os.environ['PATH'],
    'XDG_STATE_HOME': str(folder / 'state'), 'XDG_RUNTIME_DIR': temporary,
    'CLIPBOARD_STATE': 'data', 'CLIPBOARD_READ_DEADLINE': '1'}
  payload = b'synthetic-password-regression-fixture'
  for label, body in [
    ('failed', 'exit 1'),
    ('partially failed', "printf 'text/plain\\n'; exit 1"),
    ('timed out', 'exec sleep 5'),
  ]:
    lookup.write_text('#!/bin/bash\n' + body + '\n')
    lookup.chmod(0o755)
    for mode in ['text', 'image/png', None]:
      args = [str(root / 'shell/plugins/clipboard/capture.sh')]
      if mode:
        args.append(mode)
      result = subprocess.run(args, input=payload, env=env, capture_output=True, timeout=4)
      assert result.returncode == 0, result.stderr
      assert json.loads(result.stdout) == {'type': 'skipped', 'reason': 'types-unavailable'}, (label, mode, 'capture did not skip unverifiable content')
      assert not any(p.is_file() for p in (folder / 'state').rglob('*')), 'capture persisted unverifiable content'
      print('ok - clipboard skips ' + (mode or 'one-shot') + ' capture when password-hint lookup ' + label)
  lookup.write_text("#!/bin/bash\nprintf 'text/plain\\nx-kde-passwordManagerHint\\n'\n")
  result = subprocess.run([str(root / 'shell/plugins/clipboard/capture.sh'), 'text'], input=payload, env=env, capture_output=True, timeout=4)
  assert result.returncode == 0 and result.stdout == b'', 'capture retained a password-hinted payload'
  print('ok - clipboard skips a password hint without the sensitive-state flag')
PY
