#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command python3

python3 - "$ROOT" <<'PYTHON'
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

root = Path(sys.argv[1])
move = '1791479460.sh'
rewrite = '1791479461.sh'
old_names = ['1790098827.sh', '1791304794.sh']
legacy = b'''<fontconfig><match target="pattern"><test name="family" qual="any"><string>monospace</string></test><edit name="family" mode="prepend_first" binding="strong"><string>Adwaita Mono</string></edit></match></fontconfig>'''
custom = b'<!-- serif --><match target="pattern"><test name="family" qual="any"><string>serif</string></test><edit name="family" mode="prepend_first" binding="strong"><string>Alternate Serif</string></edit></match><!-- end -->'

with tempfile.TemporaryDirectory() as directory:
  work = Path(directory)
  fixture = work / 'omarchy'
  (fixture / 'migrations').mkdir(parents=True)
  for name in (move, rewrite):
    shutil.copyfile(root / 'migrations' / name, fixture / 'migrations' / name)
  stubs = work / 'bin'
  stubs.mkdir()
  dismiss = stubs / 'omarchy-notification-dismiss'
  dismiss.write_text('#!/bin/bash\nexit 0\n')
  dismiss.chmod(0o755)

  for label, markers, initial in [
    ('fresh legacy upgrade', [], 'legacy'),
    ('collision marker already recorded', old_names[:1], 'legacy'),
    ('both previous filenames recorded', old_names, 'legacy'),
    ('move already applied', old_names[:1], 'dropin'),
    ('alias already applied', old_names, 'alias'),
    ('mixed custom rules', old_names, 'mixed'),
    ('no font configuration', old_names, 'absent'),
    ('failed move and retry', old_names, 'blocked'),
  ]:
    home = work / label
    config = home / '.config/fontconfig'
    source = config / 'fonts.conf'
    dropin = config / 'conf.d/50-omarchy-monospace.conf'
    state = home / '.local/state/omarchy/migrations'
    state.mkdir(parents=True)
    for name in markers:
      (state / name).write_text('previous migration completed\n')
    config.mkdir(parents=True)
    if initial in ('legacy', 'blocked'):
      source.write_bytes(legacy)
    elif initial == 'mixed':
      source.write_bytes(legacy.replace(b'</fontconfig>', custom + b'</fontconfig>'))
    elif initial in ('dropin', 'alias'):
      dropin.parent.mkdir()
      dropin.write_bytes(legacy if initial == 'dropin' else b'<fontconfig><alias binding="strong"><family>monospace</family><prefer><family>Adwaita Mono</family></prefer></alias></fontconfig>')
    if initial == 'blocked':
      dropin.parent.write_text('obstruction')
    before = source.read_bytes() if source.exists() else None
    env = dict(os.environ, HOME=str(home), OMARCHY_PATH=str(fixture),
               OMARCHY_MIGRATION_STATE=str(state), PATH=str(stubs) + ':' + os.environ['PATH'])

    def run(*args):
      return subprocess.run(['bash', str(root / 'bin/omarchy-migrate'), *args], env=env, capture_output=True)

    pending = run('--pending')
    assert pending.returncode == 0 and pending.stdout.decode().splitlines() == [move, rewrite], label
    result = run()
    if initial == 'blocked':
      assert result.returncode != 0 and source.read_bytes() == before, result.stderr
      assert not (state / move).exists() and not (state / rewrite).exists()
      assert run('--pending').stdout == pending.stdout
      dropin.parent.unlink()
      result = run()
    assert result.returncode == 0, result.stderr.decode()
    assert (state / move).exists() and (state / rewrite).exists(), label
    if initial in ('legacy', 'blocked', 'dropin', 'alias'):
      assert not source.exists(), label
      assert ET.parse(dropin).find('alias/prefer/family').text == 'Adwaita Mono', label
      assert b'prepend_first' not in dropin.read_bytes(), label
    elif initial == 'mixed':
      assert source.read_bytes() == before and not dropin.exists(), label
    else:
      assert not source.exists() and not dropin.exists(), label
    for name in markers:
      assert (state / name).read_text() == 'previous migration completed\n', label
    after = {p.relative_to(home): p.read_bytes() for p in home.rglob('*') if p.is_file()}
    assert run('--pending').returncode != 0, label
    assert run().returncode == 0, label
    assert {p.relative_to(home): p.read_bytes() for p in home.rglob('*') if p.is_file()} == after, label
    print(f'ok - ordered migrations handle {label} and rerun unchanged')
PYTHON
