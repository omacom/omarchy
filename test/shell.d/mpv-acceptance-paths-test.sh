#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
python3 - <<'PY'
import os
from pathlib import Path
import runpy
import shutil
import subprocess
import tempfile
from unittest.mock import patch

root = Path(os.environ['ROOT'])

class SetupComplete(Exception):
  pass

with tempfile.TemporaryDirectory(prefix='mpv-acceptance-paths-') as temporary:
  temp = Path(temporary)
  checkout, product = temp / 'checkout', temp / 'installed'
  for relative in ('test/acceptance.d/fixtures/mpv_controls.py',
                   'test/acceptance.d/fixtures/mpv_parity.py',
                   'test/shell.d/fixtures/mpv/palette.py'):
    target = checkout / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(root / relative, target)
  config = product / 'config/mpv'
  config.mkdir(parents=True)
  (config / 'mpv.conf').write_text('# installed config\n')
  templates = product / 'default/themed'
  templates.mkdir(parents=True)
  template = root / 'default/themed/mpv-theme.conf.tpl'
  (templates / template.name).write_text(template.read_text() + '# installed template\n')
  for theme in ('nord', 'flexoki-light', 'catppuccin-latte'):
    target = product / 'themes' / theme
    target.mkdir(parents=True)
    shutil.copyfile(root / 'themes' / theme / 'colors.toml', target / 'colors.toml')
  (product / 'bin').mkdir()
  for helper in ('omarchy-theme-set-templates', 'omarchy-theme-color', 'omarchy-theme-set-glass'):
    shutil.copy2(root / 'bin' / helper, product / 'bin' / helper)

  real_run = subprocess.run
  def stop_before_playback(args, **kwargs):
    if args[0] == 'ffmpeg':
      home = Path(args[-1]).parent
      assert '# installed config' in (home / 'config/mpv.conf').read_text()
      palette = home / ('theme.conf' if (home / 'theme.conf').exists() else 'palette.conf')
      assert '# installed template' in palette.read_text()
      assert '{{' not in palette.read_text()
      raise SetupComplete
    assert Path(args[0]) == product / 'bin/omarchy-theme-set-templates', args
    assert kwargs['env']['OMARCHY_PATH'] == str(product)
    return real_run(args, **kwargs)

  os.environ.pop('MPV_PARITY_CONTROLLER', None)
  with patch.dict(os.environ, {'OMARCHY_PATH': str(product)}):
    for fixture in ('mpv_controls.py', 'mpv_parity.py'):
      module = runpy.run_path(str(checkout / 'test/acceptance.d/fixtures' / fixture))
      with patch('subprocess.run', side_effect=stop_before_playback):
        try:
          module['test']()
        except SetupComplete:
          print(f'ok - {fixture} prepares installed product files from a test-only checkout')
        else:
          raise AssertionError(f'{fixture} did not reach media creation')
PY
