#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
python3 - "$ROOT" <<'PY'
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
with tempfile.TemporaryDirectory() as temporary:
  home = Path(temporary)
  stubs = home / 'bin'
  stubs.mkdir()
  branding = home / '.config/omarchy/branding'
  branding.mkdir(parents=True)
  target = home / 'dotfiles/shell.json'
  target.parent.mkdir()
  config = branding.parent / 'shell.json'
  config.symlink_to(target)
  original = {'idle': {'lock': 300}, 'custom': {'keep': True}, 'screensaver': {'source': '/old', 'other': 1}}
  target.write_text(json.dumps(original))
  target.chmod(0o640)
  (branding / 'screensaver.txt').write_text('ORIGINAL\n')
  source = home / 'images'
  source.mkdir()
  for name in ('10-last.png', '2-second.jpg', '1-$(touch EXECUTED).png'):
    (source / name).write_bytes(b'\x89PNG\r\n\x1a\nTEST')
  (source / '0-link.png').symlink_to(source / '2-second.jpg')
  (source / 'folder.jpg').mkdir()
  os.mkfifo(source / 'pipe.png')
  (source / '.hidden.png').write_bytes(b'fake')
  texts = home / 'texts'
  texts.mkdir()
  (texts / 'one.txt').write_text('TEXT\n')

  def stub(name, body):
    path = stubs / name
    path.write_text('#!/bin/bash\n' + body)
    path.chmod(0o755)

  stub('omarchy-transcode-ascii', 'printf "%s\\n" "$*" >> "$HOME/converts"\n[[ ${FAIL_CONVERT:-0} == 1 ]] && exit 1\nprintf "CONVERTED\\n" > "$2"\n')
  stub('omarchy-launch-screensaver', 'echo launch >> "$HOME/launches"\n')
  stub('omarchy-shell', 'echo reload >> "$HOME/reloads"\n')
  stub('omarchy-notification-send', 'printf "%s\\n" "$*" >> "$HOME/notifications"\n')
  stub('omarchy-launch-editor', 'exit "${FAIL_EDITOR:-0}"\n')
  stub('omarchy-file-select', '[[ ${CANCEL:-0} == 1 ]] && exit 1\nprintf "%s\\n" "$PICKED"\n')
  env = dict(os.environ, HOME=str(home), OMARCHY_PATH=str(root),
             PATH=str(stubs) + ':' + str(root / 'bin') + ':' + os.environ['PATH'], PICKED=str(source))

  def run(*args, success=True, **extra):
    result = subprocess.run([root / 'bin/omarchy-branding-screensaver', *args],
                            env=dict(env, **extra), capture_output=True, timeout=10, cwd=home)
    assert (result.returncode == 0) == success, result.stderr.decode()
    assert config.is_symlink()
    assert target.stat().st_mode & 0o777 == 0o640
    current = json.loads(target.read_text())
    assert current['idle'] == original['idle'] and current['custom'] == original['custom']
    assert current['screensaver']['other'] == 1
    return current

  current = run('images', str(source))
  imported = Path(current['screensaver']['source'])
  assert len(list(imported.glob('*.txt'))) == 3
  manifest = json.loads((imported / 'manifest.json').read_text())
  assert [r['source'].split('-')[0] for r in manifest['images']] == ['1', '2', '10']
  assert not (home / 'EXECUTED').exists()
  assert all(line.endswith(' --mode color') for line in (home / 'converts').read_text().splitlines())
  print('ok - image folder uses native converter in colour mode, numeric order, and skips links/special files')
  before = target.read_bytes()
  run('images', success=False, CANCEL='1')
  run('images', str(source), success=False, FAIL_CONVERT='1')
  assert target.read_bytes() == before
  assert "could not convert '1-$(touch EXECUTED).png'" in (home / 'notifications').read_text().splitlines()[-1]
  (source / '0-<b>bold&.png').write_bytes(b'\x89PNG\r\n\x1a\nTEST')
  run('images', str(source), success=False, FAIL_CONVERT='1')
  assert "'0-&lt;b&gt;bold&amp;.png'" in (home / 'notifications').read_text().splitlines()[-1]
  (source / '0-<b>bold&.png').unlink()
  assert list(imported.parent.iterdir()) == [imported]
  (source / 'bad.png').write_text('push graphic-context\nimage over 0,0 1,1 https://example.invalid/\n')
  run('images', str(source), success=False)
  assert target.read_bytes() == before
  assert list(imported.parent.iterdir()) == [imported]
  print('ok - cancellation, decoder failure, and disguised non-raster input preserve selection and clean incomplete imports')
  current = run('folder', str(texts))
  assert current['screensaver']['source'] == str(texts)
  print('ok - text folder selects a validated directory directly')
  for action in ('image', 'text', 'reset'):
    target.write_text(json.dumps(original))
    current = run(action)
    assert 'source' not in current['screensaver']
  print('ok - image, text and reset clear collection selection while preserving other settings and symlinks')
  target.write_text(json.dumps(original))
  before = target.read_bytes()
  run('image', FAIL_CONVERT='1')
  run('text', success=False, FAIL_EDITOR='1')
  assert target.read_bytes() == before
  target.write_text('{invalid json')
  result = subprocess.run([root / 'bin/omarchy-branding-screensaver', 'folder', str(texts)],
                          env=env, capture_output=True, timeout=10)
  assert result.returncode != 0 and target.read_text() == '{invalid json'
  assert not list(target.parent.glob('.shell-config.*'))
  print('ok - failed actions and malformed configuration do not silently replace selection or config')

  # Saving single-file artwork leaves shell.json alone when nothing is selected,
  # including a config the shell tolerates but jq cannot parse.
  for contents in ('{ "version": 1, }', '{"screensaver": "off"}', json.dumps({'idle': {'lock': 300}})):
    target.write_text(contents)
    (home / 'reloads').write_text('')
    (home / 'launches').write_text('')
    for action in ('image', 'text', 'reset'):
      result = subprocess.run([root / 'bin/omarchy-branding-screensaver', action],
                              env=env, capture_output=True, timeout=10, cwd=home)
      assert result.returncode == 0, result.stderr.decode()
    assert target.read_text() == contents and not (home / 'reloads').read_text()
    assert (home / 'launches').read_text().splitlines() == ['launch'] * 3
  assert (branding / 'screensaver.txt').read_text() == (root / 'logo.txt').read_text()
  print('ok - image, text and reset save artwork without touching shell.json when no collection is selected')
PY
