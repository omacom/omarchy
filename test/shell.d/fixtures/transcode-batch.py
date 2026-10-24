"""Exercise the actual CLI with isolated media, menus, encoders and clipboard."""
import importlib.util
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys
import signal
import time
import tempfile
import types

ROOT = Path(os.environ['ROOT'])
STUB = '''#!/usr/bin/python3
import json, os, pathlib, sys, time
root = pathlib.Path(os.environ['TRANSCODE_TEST'])
name = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
with (root / 'calls').open('a') as f:
  f.write(json.dumps([name, args]) + '\\n')
if name == 'file':
  print(json.loads((root / 'mimes').read_text())[args[-1]])
elif name == 'omarchy-menu-select':
  if os.environ.get('RACE_DIR'):
    print(next(value for value in ('jpg', 'mp4', 'medium', '720p') if value in args))
    sys.exit(0)
  answers = json.loads((root / 'answers').read_text())
  if not answers: sys.exit(99)
  answer = answers.pop(0)
  (root / 'answers').write_text(json.dumps(answers))
  if answer is None: sys.exit(1)
  if isinstance(answer, int): sys.exit(answer)
  print(json.dumps(answer) if isinstance(answer, dict) else answer)
elif name in ('magick', 'ffmpeg'):
  if os.environ.get('RACE_DIR'):
    race = pathlib.Path(os.environ['RACE_DIR'])
    role = os.environ['RACE_ROLE']
    if os.environ.get('PAUSE_AFTER_WRITE'):
      pathlib.Path(args[-1]).write_text('partial')
    (race / (role + '.ready')).write_text(args[-1])
    deadline = time.monotonic() + 15
    while not (race / (role + '.release')).exists():
      if time.monotonic() > deadline: sys.exit(98)
      time.sleep(0.01)
    if os.environ.get('RACE_FAIL'): sys.exit(7)
    pathlib.Path(args[-1]).write_text(role)
    sys.exit(0)
  if os.environ.get('FAIL_INPUT') in args:
    pathlib.Path(args[-1]).write_text('incomplete output')
    sys.exit(int(os.environ.get('FAIL_CODE', '1')))
  pathlib.Path(args[-1]).touch()
elif name == 'wl-copy':
  sys.stdin.read()
  sys.exit(int(os.environ.get('CLIPBOARD_STATUS', '0')))
'''


def check(description, condition):
  assert condition, description
  print('ok - ' + description)


with tempfile.TemporaryDirectory() as tmp:
  work = Path(tmp)
  stub = work / 'bin'
  stub.mkdir()
  for name in ('file', 'omarchy-menu-select', 'magick', 'ffmpeg', 'wl-copy', 'omarchy-notification-send'):
    path = stub / name
    path.write_text(STUB)
    path.chmod(0o755)
  env = {**os.environ, 'HOME': tmp, 'OMARCHY_PATH': str(ROOT), 'TRANSCODE_TEST': tmp,
         'PATH': f'{stub}:{ROOT / "bin"}:' + os.environ['PATH']}

  def run(files, answers, *, single=None, failed=None, existing=None, reset=True, fail_code=1, clipboard_status=0):
    media = work / 'media'
    if reset and media.exists():
      import shutil
      shutil.rmtree(media)
    media.mkdir(exist_ok=True)
    paths = [str(media / name) for name, mime in files]
    for path in paths:
      Path(path).touch()
    if existing:
      (media / existing).write_text('keep existing output')
    (work / 'mimes').write_text(json.dumps(dict(zip(paths, [mime for _, mime in files]))))
    (work / 'answers').write_text(json.dumps(answers))
    (work / 'calls').write_text('')
    args = ['--batch', '--', *paths] if single is None else [paths[0], *single]
    result = subprocess.run([ROOT / 'bin/omarchy-transcode', *args], env={**env, 'FAIL_INPUT': paths[failed] if failed is not None else '', 'FAIL_CODE': str(fail_code), 'CLIPBOARD_STATUS': str(clipboard_status)}, capture_output=True, text=True, timeout=15)
    assert not list(media.glob('.omarchy-transcode.*')), 'temporary outputs leaked'
    calls = [json.loads(line) for line in (work / 'calls').read_text().splitlines()]
    menus = [args for name, args in calls if name == 'omarchy-menu-select']
    encodes = [(name, args) for name, args in calls if name in ('magick', 'ffmpeg')]
    return result, menus, encodes, calls

  heics = [('one.heic', 'image/heic'), ('two.HEIC', 'image/heic'), ('three.heic', 'image/heic')]
  r, menus, encodes, calls = run(heics, ['jpg', {'value': 'medium', 'checked': True}])
  check('checked settings convert three HEICs with just one format/resolution pair', r.returncode == 0 and len(menus) == 2 and len(encodes) == 3)
  check('both format and resolution carry over', all('2160x>' in args and args[-1].endswith('-medium.jpg') for _, args in encodes))
  check('checkbox identifies the source type', '--checkbox' in menus[1] and 'Apply to all heic files' in menus[1])

  r, menus, encodes, _ = run(heics, ['jpg', {'value': 'medium', 'checked': False}, 'png', {'value': 'low', 'checked': False}, 'jpg', 'high'])
  check('unchecked settings prompt separately and final file has no checkbox', r.returncode == 0 and len(menus) == 6 and '--checkbox' not in menus[-1] and encodes[1][1][-1].endswith('-low.png'))

  mixed = [heics[0], ('clip.mov', 'video/quicktime'), heics[1], ('second.MOV', 'video/quicktime'), ('fake.heic', 'image/png')]
  r, menus, encodes, _ = run(mixed, ['jpg', {'value': 'low', 'checked': True}, 'mp4', {'value': '720p', 'checked': True}, 'png', 'high'])
  check('interleaved pictures/videos cache separately and misleading suffixes do not share', r.returncode == 0 and len(menus) == 6 and [name for name, _ in encodes] == ['magick', 'ffmpeg', 'magick', 'ffmpeg', 'magick'])
  check('cached video settings reach ffmpeg', 'scale=-2:720' in encodes[3][1] and encodes[3][1][-1].endswith('-720p.mp4'))

  r, menus, encodes, _ = run([('one.jpg', 'image/jpeg'), ('two.JPEG', 'image/jpeg')], ['png', {'value': 'low', 'checked': True}])
  check('JPEG aliases share detected source type', r.returncode == 0 and len(menus) == 2 and len(encodes) == 2)

  r, menus, encodes, _ = run(heics, ['jpg', None])
  check('cancel stops the whole batch before encoding', r.returncode == 130 and len(menus) == 2 and not encodes)

  r, menus, encodes, calls = run(heics, ['jpg', {'value': 'medium', 'checked': True}], failed=0)
  check('encoder failure is reported, later files still reuse settings', r.returncode == 1 and len(encodes) == 3 and len(menus) == 2 and sum(name == 'wl-copy' for name, _ in calls) == 2)

  check('failed image output is removed while successful outputs and originals remain', not (work / 'media/one-medium.jpg').exists() and all((work / 'media' / name).exists() for name in ('two-medium.jpg', 'three-medium.jpg', 'one.heic', 'two.HEIC', 'three.heic')))
  r, _, encodes, _ = run(heics, ['jpg', {'value': 'medium', 'checked': True}], reset=False)
  check('retry converts the failed image and preserves completed outputs', r.returncode == 1 and len(encodes) == 1 and encodes[0][1][-1].endswith('one-medium.jpg') and (work / 'media/one-medium.jpg').exists())

  videos = [('one.mov', 'video/quicktime'), ('two.mov', 'video/quicktime')]
  r, _, encodes, _ = run(videos, ['mp4', {'value': '720p', 'checked': True}], failed=0, fail_code=7)
  check('failed video output is removed and its error code survives the batch', r.returncode == 7 and not (work / 'media/one-720p.mp4').exists() and (work / 'media/two-720p.mp4').exists())
  r, _, encodes, _ = run(videos, ['mp4', {'value': '720p', 'checked': True}], reset=False)
  check('retry converts only the failed video', r.returncode == 1 and len(encodes) == 1 and encodes[0][1][-1].endswith('one-720p.mp4') and (work / 'media/one-720p.mp4').exists())

  r, _, _, _ = run(heics[:1], [], single=['jpg', 'medium'], failed=0)
  check('single-file encoder failure also removes only newly created output', r.returncode == 1 and not (work / 'media/one-medium.jpg').exists())
  dangling = work / 'media/one-medium.jpg'
  dangling.symlink_to('missing.jpg')
  r, _, encodes, _ = run(heics[:1], ['jpg', 'medium'], reset=False)
  check('batch preserves dangling output symlinks without following them', r.returncode == 1 and not encodes and dangling.is_symlink() and not (work / 'media/missing.jpg').exists())
  r, _, encodes, _ = run(heics[:1], [], single=['jpg', 'medium'], failed=0, existing='one-medium.jpg')
  check('single-file conversion preserves existing output without encoding', r.returncode == 1 and not encodes and (work / 'media/one-medium.jpg').read_text() == 'keep existing output')
  r, _, _, _ = run(heics[:1], [], single=['jpg', 'medium'], clipboard_status=3)
  check('clipboard failure preserves successfully encoded output', r.returncode == 3 and (work / 'media/one-medium.jpg').exists())

  for files, fmt in ((heics[:1], 'jpg'), (videos[:1], 'mp4')):
    for stage, answers in (('format', [None]), ('resolution', [fmt, None])):
      r, _, encodes, _ = run(files, answers, single=[])
      check(f'{fmt} {stage} cancellation maps to 130', r.returncode == 130 and not encodes)
    for code in (2, 127):
      for stage, answers in (('format', [code]), ('resolution', [fmt, code])):
        r, _, encodes, _ = run(files, answers, single=[])
        check(f'{fmt} {stage} menu failure preserves exit {code}', r.returncode == code and not encodes)

  r, menus, encodes, _ = run(heics[:2], [2, 'jpg', 'medium'])
  check('batch reports a format-menu error and still converts the next file', r.returncode == 2 and len(encodes) == 1 and 'Failed to transcode:' in r.stderr)
  r, menus, encodes, _ = run(videos, ['mp4', 2, 'mp4', '720p'])
  check('batch reports a resolution-menu error and still converts the next video', r.returncode == 2 and len(encodes) == 1 and 'Failed to transcode:' in r.stderr)
  r, _, _, _ = run(heics[:2], [2, 127])
  check('batch retains its first failure code', r.returncode == 2)

  r, menus, encodes, _ = run(heics[:2], ['jpg', {'value': 'medium', 'checked': True}], existing='one-medium.jpg')
  check('batch skips existing output without overwriting it', r.returncode == 1 and len(encodes) == 1 and (work / 'media/one-medium.jpg').read_text() == 'keep existing output')

  unusual = [('a space\nand quote\' $(touch INJECTED).heic', 'image/heic'), ('--odd.heic', 'image/heic')]
  r, _, encodes, _ = run(unusual, ['jpg', {'value': 'medium', 'checked': True}])
  check('spaces, newlines, quotes and shell syntax remain literal file paths', r.returncode == 0 and len(encodes) == 2 and not (work / 'media/INJECTED').exists())

  r, menus, encodes, _ = run(heics[:1], [], single=['jpg', 'medium'])
  check('existing explicit single-file CLI stays noninteractive', r.returncode == 0 and not menus and len(encodes) == 1)
  r, menus, encodes, _ = run(heics[:1], ['png', 'low'], single=[])
  check('single-file interactive flow has no checkbox or retained batch settings', r.returncode == 0 and len(menus) == 2 and '--checkbox' not in menus[1])

  r, menus, encodes, _ = run([('notes.txt', 'text/plain'), heics[0]], ['jpg', 'low'])
  check('unsupported input reports failure without preventing supported conversions', r.returncode == 1 and len(encodes) == 1)

  r = subprocess.run([ROOT / 'bin/omarchy-transcode', '--batch'], env=env, capture_output=True)
  check('empty batch is a usage error', r.returncode == 2)


  # Release actual CLI processes in a fixed order, after both encoders have
  # reached the output path. No timing assumption decides which run wins.
  def wait_ready(path):
    deadline = time.monotonic() + 10
    while not path.exists():
      if time.monotonic() > deadline:
        raise AssertionError(f'encoder did not reach barrier: {path}')
      time.sleep(0.01)

  for video in (False, True):
    for fail_loser in (True, False):
      with tempfile.TemporaryDirectory(dir=work) as tmp_race:
        race = Path(tmp_race)
        source = race / ('clip.mov' if video else 'photo.heic')
        source.write_text('original')
        fmt, resolution = ('mp4', '720p') if video else ('jpg', 'medium')
        output = race / f'{source.stem}-{resolution}.{fmt}'
        (work / 'mimes').write_text(json.dumps({str(source): 'video/quicktime' if video else 'image/heic'}))
        args = ['--batch', '--', str(source)] if video else [str(source), fmt, resolution]
        processes = []
        try:
          for role in ('winner', 'loser'):
            processes.append(subprocess.Popen([ROOT / 'bin/omarchy-transcode', *args], env={**env, 'RACE_DIR': str(race), 'RACE_ROLE': role, 'RACE_FAIL': '1' if role == 'loser' and fail_loser else ''}, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True))
          wait_ready(race / 'winner.ready')
          wait_ready(race / 'loser.ready')
          (race / 'winner.release').touch()
          processes[0].communicate(timeout=10)
          assert processes[0].returncode == 0
          (race / 'loser.release').touch()
          processes[1].communicate(timeout=10)
          check(f'{fmt}: overlapping {"failed" if fail_loser else "successful"} encoder preserves the winning output', processes[1].returncode == (7 if fail_loser else 1) and output.exists() and output.read_text() == 'winner' and source.read_text() == 'original')
          check(f'{fmt}: both overlapping runs clean up their private outputs', not list(race.glob('.omarchy-transcode.*')))
        finally:
          for process in processes:
            if process.poll() is None:
              process.kill()
            process.communicate()

  with tempfile.TemporaryDirectory(dir=work) as tmp_race:
    race = Path(tmp_race)
    source = race / 'clip.mov'
    source.write_text('original')
    (work / 'mimes').write_text(json.dumps({str(source): 'video/quicktime'}))
    process = subprocess.Popen([ROOT / 'bin/omarchy-transcode', str(source), 'mp4', '720p'], env={**env, 'RACE_DIR': str(race), 'RACE_ROLE': 'interrupted', 'PAUSE_AFTER_WRITE': '1'}, stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
    try:
      wait_ready(race / 'interrupted.ready')
      os.killpg(process.pid, signal.SIGTERM)
      process.communicate(timeout=10)
      check('termination removes only private partial output', process.returncode != 0 and not (race / 'clip-720p.mp4').exists() and not list(race.glob('.omarchy-transcode.*')) and source.read_text() == 'original')
    finally:
      if process.poll() is None:
        os.killpg(process.pid, signal.SIGKILL)
      process.communicate()

# Import the Nautilus extension against minimal GI doubles, then inspect what
# it actually launches rather than matching the source text.
gi = types.ModuleType('gi')
gi.require_version = lambda *args: None
repository = types.ModuleType('gi.repository')
launched = []
repository.GObject = types.SimpleNamespace(GObject=type('GObject', (), {}))
repository.Nautilus = types.SimpleNamespace(MenuProvider=type('MenuProvider', (), {}))
repository.Gio = types.SimpleNamespace(Subprocess=types.SimpleNamespace(new=lambda args, flags: launched.append(args)), SubprocessFlags=types.SimpleNamespace(NONE=0))
sys.modules['gi'] = gi
sys.modules['gi.repository'] = repository
spec = importlib.util.spec_from_file_location('transcode_extension', ROOT / 'default/nautilus-python/extensions/transcode.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.shutil.which = lambda cmd: '/test/' + cmd
paths = ['/tmp/a space.heic', "/tmp/quote'$(touch nope).HEIC", '/tmp/new\nline.heic']
module.TranscodeAction()._launch_transcode(paths)
check('Files launches exactly one batch with safely quoted paths', len(launched) == 1 and shlex.split(launched[0][1]) == ['/test/omarchy-transcode', '--batch', '--', *paths])
