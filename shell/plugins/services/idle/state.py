"""Native saved-state-only screensaver; the shell owns its lazy input guard."""
import contextlib
import fcntl
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import time
import uuid

import amiga
import pack
import renderer
import runtime as runtime_integrity
from audio import OwnedAudio, hint_labels
from amiga import owned_window, source_geometry_ready
from history import History


def runtime_path():
  system = Path('/usr/lib/omarchy-amiga-runtime')
  return system if system.is_dir() else Path.home() / '.local/lib/omarchy-amiga-runtime'


def runtime_check():
  root = runtime_path()
  required = ('fs-uae/FRAME_PROTOCOL', 'fs-uae/bin/fs-uae', 'audio/libopenal.so.1', 'audio/libamiga-pulse.so',
              'bin/gl-probe', 'guard/AmigaInput/libamigainput.so', 'guard/AmigaInput/qmldir', 'guard/Guard.qml')
  runtime_integrity.verify(root, required)
  if (root / 'fs-uae/FRAME_PROTOCOL').read_text() != '1\n':
    raise ValueError('FS-UAE frame protocol 1 is required; rebuild the private runtime')
  for command in ('bwrap', 'pactl'):
    if not shutil.which(command):
      raise ValueError('Missing optional dependency: ' + command)


def restore_completed(text, token=None):
  # These stock diagnostics can precede a successful completion callback.
  # Reject them anywhere in the child log, including after initial completion.
  for line in text.splitlines():
    if re.search(r'unknown chunk|was not accepted|total size .* but read|savestate.*(?:failed|error)', line, re.I):
      raise ValueError('State restoration rejected: ' + line)
  # Only the freshly truncated owned-child stream is accepted. Namespace PIDs
  # are not host identities; the child token binds one immutable restore.
  if token is None or not re.fullmatch(r'[a-f0-9]{32}', token):
    return False
  phase = 0
  for line in text.splitlines(keepends=True):
    if not line.startswith('OMARCHY_FRAME_V1 '):
      continue
    if not line.endswith('\n'):
      return False  # A concurrent writer may be reporting a restore error.
    fields = line.rstrip('\n').split(' ')
    if len(fields) < 4 or fields[1] != token:
      raise ValueError('State restoration protocol has a foreign child token')
    event = fields[2:]
    if event[0] == 'error':
      raise ValueError('State restoration rejected: ' + ' '.join(event[1:]))
    if phase == 0 and event == ['protocol', '1']:
      phase = 1
    elif phase == 1 and event == ['restored', '1']:
      phase = 2
    elif phase == 2 and re.fullmatch(r'frame 1 [1-9][0-9]* [1-9][0-9]* [1-9][0-9]* [a-f0-9]{16}', ' '.join(event)):
      if not all(0 < int(value) <= 8192 for value in event[3:5]):
        raise ValueError('State restoration frame dimensions are invalid')
      phase = 3
    else:
      raise ValueError('State restoration protocol order or version is invalid')
  return phase == 3


def sandbox_command(demo, temporary, token):
  if not re.fullmatch(r'[a-f0-9]{32}', token):
    raise ValueError('Invalid child token')
  # Revalidate the complete catalog binding before every restored launch.
  current = next(r for r in pack.load(demo['root']) if r['task_id'] == demo['task_id'])
  if current != demo:
    raise ValueError('Selected state binding changed')
  temporary = Path(temporary)
  state = temporary / 'state'
  state.mkdir()
  shutil.copyfile(demo['state_path'], state / 'Saved State 1.uss')
  if pack.digest(state / 'Saved State 1.uss') != demo['state_sha256']:
    raise ValueError('State copy mismatch; no boot fallback')
  name = os.environ.get('WAYLAND_DISPLAY', '')
  if not re.fullmatch(r'wayland-[A-Za-z0-9_-]+', name):
    raise ValueError('Local Wayland display required')
  runtime = Path(os.environ['XDG_RUNTIME_DIR'])
  wayland, pulse = runtime / name, runtime / 'pulse/native'
  if not wayland.is_socket() or not pulse.is_socket():
    raise ValueError('Exact Wayland/Pulse sockets required')
  config = temporary / 'demo.fs-uae'
  pack.validate_settings(demo['settings'])
  config.write_text('[fs-uae]\n' + ''.join(f'{k} = {v}\n' for k, v in demo['settings'].items()))
  command = ['bwrap', '--unshare-all', '--die-with-parent', '--new-session', '--cap-drop', 'ALL',
             '--clearenv', '--ro-bind', '/usr', '/usr', '--symlink', 'usr/bin', '/bin',
             '--symlink', 'usr/lib', '/lib', '--symlink', 'usr/lib', '/lib64', '--proc', '/proc',
             '--dev', '/dev', '--tmpfs', '/tmp', '--dir', '/home/amiga', '--dir', '/run/user',
             '--ro-bind', str(wayland), '/run/user/' + name, '--ro-bind', str(pulse), '/run/pulse/native',
             '--ro-bind', str(runtime_path()), '/opt/amiga', '--ro-bind', str(config), '/demo.fs-uae',
             '--bind', str(state), '/restore']
  for index, (source, target, expected) in enumerate(demo['mounts']):
    copy = temporary / f'media-{index}'
    shutil.copyfile(source, copy)
    if pack.digest(copy) != expected:
      raise ValueError('Media copy mismatch')
    command += ['--ro-bind', str(copy), target]
  appid = amiga.APP_CLASS + '.' + token
  for key, value in {
      'PATH': '/usr/bin', 'HOME': '/home/amiga', 'XDG_RUNTIME_DIR': '/run/user', 'WAYLAND_DISPLAY': name,
      'SDL_VIDEODRIVER': 'wayland', 'SDL_APP_ID': appid, 'SDL_VIDEO_WAYLAND_WMCLASS': appid,
      'ALSOFT_DRIVERS': 'pulse', 'SDL_AUDIODRIVER': 'pulse', 'PULSE_SERVER': 'unix:/run/pulse/native',
      'PULSE_PROP_application.id': appid, 'LD_LIBRARY_PATH': '/opt/amiga/audio',
      'LD_PRELOAD': '/opt/amiga/audio/libamiga-pulse.so', 'LANG': 'C.UTF-8',
      'OMARCHY_FRAME_TOKEN': token, 'OMARCHY_FRAME_STATE': '/restore/Saved State 1.uss',
  }.items():
    command += ['--setenv', key, value]
  selection = renderer.select(command)
  (temporary / 'renderer.json').write_text(json.dumps(selection, indent=2))
  print('Amiga renderer: ' + json.dumps(selection), flush=True)
  command += renderer.arguments(selection)
  return command + ['/opt/amiga/fs-uae/bin/fs-uae', '/demo.fs-uae', '--stdout', '--base-dir=/tmp/base',
                    '--state-dir=/restore', '--load-state=1', '--fullscreen=0', '--automatic-input-grab=0',
                    '--initial-input-grab=0', '--keyboard-input-grab=0', '--volume=100',
                    '--notification-duration=0', '--suppress-warning-hud=1']


def play(process, demo, owner, monitor, appid, log, history, handled):
  start, shown, revision = time.monotonic(), False, None
  audio = OwnedAudio(appid, os.environ)
  while True:
    elapsed = time.monotonic() - start
    status = json.loads(amiga.ipc('amigaPoll', owner))
    if status.get('state') != 'active':
      raise InterruptedError('Guard stopped: ' + status.get('reason', 'closed'))
    navigation = status.get('navigationRevision', 0)
    if navigation != handled:
      handled = navigation
      if history.navigate(status['navigationDirection']):
        return handled
    if process.poll() is not None or status.get('reason') == 'capture-stopped':
      raise ValueError('Emulator or owned capture stopped')
    restored = restore_completed(Path(log.name).read_text(errors='replace'), appid.rsplit('.', 1)[-1])
    if not restored and elapsed > 10:
      raise ValueError('State restoration did not complete; no boot fallback')
    window = owned_window(appid, process)
    if restored and window and not shown:
      if source_geometry_ready(window):
        if amiga.ipc('amigaPresent', owner, monitor, appid, demo['title']) != 'ok':
          raise InterruptedError('Guard refused presentation')
        shown = True
      else:
        selector = 'window="address:' + window['address'] + '"'
        actions = []
        if not window.get('floating'):
          actions.append('hl.dsp.window.float({' + selector + ',action="on"})')
        actions.append('hl.dsp.window.resize({' + selector + ',x=640,y=480,relative=false})')
        for action in actions:
          subprocess.run(['hyprctl', 'dispatch', action], check=True, capture_output=True, timeout=2)
    if shown and revision != status.get('audioRevision') and audio.find() is not None:
      actual = audio.apply(status['requestedMuted'])
      if actual is None:
        raise ValueError('Owned audio disappeared')
      if amiga.ipc('amigaAudioApplied', owner, str(status['audioRevision']), str(actual['mute']).lower()) == 'ok':
        revision = status['audioRevision']
    if elapsed > 15 and (not shown or not status.get('frameReady') or revision is None):
      raise ValueError('Restored frame/audio startup deadline exceeded')
    # This pack has no verified ending contract. Stay on the restored demo until
    # classified dismissal or explicit navigation; elapsed time is NOT completion.
    time.sleep(.1)


def run():
  runtime_check()
  if amiga.ipc('amigaRuntime', str(runtime_path() != Path('/usr/lib/omarchy-amiga-runtime')).lower()) != 'ok':
    raise ValueError('Native idle service cannot load the selected runtime')
  choices = pack.load()
  runtime = Path(os.environ['XDG_RUNTIME_DIR'])
  with (runtime / 'omarchy-amiga-screensaver.lock').open('w') as lock:
    try:
      fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
      return 0
    owner = uuid.uuid4().hex
    monitor = next(m['name'] for m in amiga.hypr('monitors') if m.get('focused'))
    logdir = Path.home() / '.local/state/omarchy/amiga'
    logdir.mkdir(parents=True, exist_ok=True)
    begun = False
    try:
      labels = hint_labels(json.loads(amiga.ipc('amigaLocale')))
      for attempt in range(40):
        result = amiga.ipc('amigaBegin', owner, monitor, *labels)
        if result == 'ok':
          begun = True
          break
        if result not in ('preparing', 'locked', 'input-unavailable'):
          raise ValueError('Native guard unavailable: ' + result)
        time.sleep(.1)
      if not begun:
        raise ValueError('Native input/lock guard unavailable')
      history, handled, generation = History(len(choices)), 0, 0
      while True:
        demo = choices[history.current]
        generation += 1
        with tempfile.TemporaryDirectory(prefix='omarchy-amiga-', dir=runtime) as temporary:
          with (logdir / 'emulator.log').open('w') as log:
            token = uuid.uuid4().hex
            command = sandbox_command(demo, temporary, token)
            process = amiga.launch_command(command, log)
            try:
              (logdir / 'session.json').write_text(json.dumps({'owner': owner, 'task_id': demo['task_id'],
                'generation': generation, 'controller_pid': os.getpid(), 'child_pid': process.pid,
                'state_sha256': demo['state_sha256'], 'mode': 'state-only', 'command': command,
                'renderer': json.loads((Path(temporary) / 'renderer.json').read_text()),
                'history': history.items, 'cursor': history.cursor}, indent=2))
              handled = play(process, demo, owner, monitor, amiga.APP_CLASS + '.' + token, log, history, handled)
              if amiga.ipc('amigaCover', owner) != 'ok':
                raise InterruptedError('Guard refused transition cover')
            finally:
              amiga.stop(process)
    finally:
      if begun:
        with contextlib.suppress(Exception):
          amiga.ipc('amigaEnd', owner)
  return 0


def main():
  def interrupted(signum, frame):
    raise InterruptedError('Controller signal: ' + str(signum))
  for sig in (signal.SIGTERM, signal.SIGINT, signal.SIGHUP, signal.SIGQUIT):
    signal.signal(sig, interrupted)
  try:
    args = sys.argv[1:]
    if args == ['--check-runtime']:
      runtime_check()
    elif args == ['--check-media']:
      pack.load()
    elif args == ['--check']:
      runtime_check()
      pack.load()
      if amiga.ipc('amigaRuntime', str(runtime_path() != Path('/usr/lib/omarchy-amiga-runtime')).lower()) != 'ok':
        raise ValueError('Native idle service is not installed or is busy')
    elif len(args) == 2 and args[0] == '--install-pack':
      pack.install(args[1])
    elif not args:
      return run()
    else:
      raise ValueError('Unknown Amiga argument')
    return 0
  except InterruptedError as error:
    print(error, file=sys.stderr)
    return 0
  except (ValueError, OSError, subprocess.SubprocessError, KeyError, StopIteration) as error:
    print('Amiga: ' + str(error), file=sys.stderr)
    return 1


if __name__ == '__main__':
  sys.exit(main())
