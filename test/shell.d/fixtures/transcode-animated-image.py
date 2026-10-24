"""Convert real animated GIFs through the CLI and inspect the published image."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

root = Path(os.environ['ROOT'])
magick = shutil.which('magick')
with tempfile.TemporaryDirectory() as tmp:
  work = Path(tmp)
  stub = work / 'bin'
  stub.mkdir()
  commands = {
    'omarchy-menu-select': '''import json, os, sys
value = os.environ['TEST_FORMAT'] if os.environ['TEST_FORMAT'] in sys.argv[2:] else 'medium'
print(json.dumps({'value': value, 'checked': True}) if '--checkbox' in sys.argv else value)
''',
    'omarchy-notification-send': '',
    'wl-copy': '''import os, pathlib, sys
pathlib.Path(os.environ['TEST_CLIPBOARD']).write_text(sys.stdin.read())
''',
  }
  for name, body in commands.items():
    path = stub / name
    path.write_text('#!/usr/bin/python3\n' + body)
    path.chmod(0o755)
  env = {**os.environ, 'HOME': str(work), 'OMARCHY_LANGUAGE_FILE': str(work / 'language'), 'OMARCHY_PATH': str(root), 'PATH': f'{stub}:{root / "bin"}:' + os.environ['PATH']}
  animated = work / 'source.gif'
  subprocess.run([magick, '-size', '32x24', 'xc:red', 'xc:blue', '-delay', '10', '-loop', '0', str(animated)], check=True)
  assert subprocess.check_output([magick, 'identify', '-format', '%n\n', str(animated)], text=True).splitlines() == ['2', '2']

  for batch in (False, True):
    for fmt in ('jpg', 'png'):
      folder = work / f'{"batch" if batch else "single"}-{fmt}'
      folder.mkdir()
      # ImageMagick's frame selector must still handle literal brackets/spaces.
      inputs = [folder / 'animated [test].gif']
      if batch:
        inputs.append(folder / 'another.gif')
      for path in inputs:
        shutil.copy2(animated, path)
      before = {path: path.read_bytes() for path in inputs}
      clipboard = folder / 'clipboard'
      args = ['--batch', '--', *map(str, inputs)] if batch else [str(inputs[0]), fmt, 'medium']
      result = subprocess.run([root / 'bin/omarchy-transcode', *args], env={**env, 'TEST_FORMAT': fmt, 'TEST_CLIPBOARD': str(clipboard)}, capture_output=True, text=True, timeout=20)
      assert result.returncode == 0, (args, result.stderr)
      outputs = [folder / f'{path.stem}-medium.{fmt}' for path in inputs]
      assert set(folder.glob(f'*.{fmt}')) == set(outputs), 'one published output per input; no numbered frame files'
      for output in outputs:
        info = subprocess.check_output([magick, 'identify', '-format', '%n %w %h %[fx:round(255*p{0,0}.r)] %[fx:round(255*p{0,0}.b)]', str(output)], text=True).split()
        assert info[:3] == ['1', '32', '24'], info
        assert int(info[3]) > 240 and int(info[4]) < 15, 'first (red) frame must be retained'
      assert all(path.read_bytes() == original for path, original in before.items())
      assert clipboard.read_text().strip() == f'file://{outputs[-1]}'
      assert not list(folder.glob('.omarchy-transcode.*'))
      print(f'ok - {"batch" if batch else "single"} animated GIF to {fmt}: first frame published, originals retained, final path copied')

  still = work / 'still.png'
  subprocess.run([magick, '-size', '32x24', 'xc:red', str(still)], check=True)
  subprocess.run([root / 'bin/omarchy-transcode', str(still), 'png', 'medium'], env={**env, 'TEST_CLIPBOARD': str(work / 'clipboard')}, check=True, capture_output=True, timeout=20)
  assert subprocess.check_output([magick, 'identify', '-format', '%n %w %h', str(work / 'still-medium.png')], text=True) == '1 32 24'
  print('ok - single-frame pictures still publish normally')
