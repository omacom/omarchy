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
from amiga import owned_window
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


# Hardware renderer initialization can precede the first restored frame by tens of seconds.
# This remains a bounded failure gate; never substitute cold boot when it expires.
RESTORE_FRAME_DEADLINE_SECONDS = 40
PRESENTATION_STARTUP_DEADLINE_SECONDS = 45
# The explicit upper bound guarantees a stuck demo never holds the lock screen
# forever. A clean owned emulator exit advances sooner; a future curated pack
# may add verified per-demo endings without weakening this safety ceiling.
MAX_DEMO_SECONDS = 600


def max_demo_seconds(environment=None):
  value = (environment or os.environ).get('OMARCHY_AMIGA_MAX_DEMO_SECONDS', str(MAX_DEMO_SECONDS))
  if not re.fullmatch(r'[0-9]+', value):
    raise ValueError('Invalid Amiga demo timeout')
  seconds = int(value)
  if not 10 <= seconds <= 3600:
    raise ValueError('Amiga demo timeout must be between 10 and 3600 seconds')
  return seconds


def demo_timeout(demo, environment=None):
  """Use a signed curator measurement, capped by the operator safety ceiling."""
  maximum = max_demo_seconds(environment)
  duration = pack.playback_duration(demo)
  return min(duration, maximum) if duration is not None else maximum


def begin_guard(monitor, labels):
  """Open a fresh guard only while the desktop reports an unlocked session."""
  owner = uuid.uuid4().hex
  last_result = 'unavailable'
  for attempt in range(40):
    result = amiga.ipc('amigaBegin', owner, monitor, *labels)
    last_result = result
    if result == 'ok':
      return owner
    # The bounded shell lock probe fails closed while a reply is in flight.
    # Retry that transient state, but never resume after a persistent real lock.
    if result not in ('preparing', 'input-unavailable', 'locked'):
      raise InterruptedError('Guard unavailable: ' + result)
    time.sleep(.1)
  raise InterruptedError('Guard unavailable: ' + last_result)


def desktop_locked():
  """Read the canonical lock service; unknown results must remain locked."""
  try:
    output = subprocess.check_output(['omarchy-shell', 'lock', 'isLocked'], text=True, timeout=2).strip()
  except (OSError, subprocess.SubprocessError):
    return True
  return output != 'false'


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


def play(process, demo, owner, monitor, appid, log, history, handled, timeout=None):
  start, shown, revision = time.monotonic(), False, None
  timeout = demo_timeout(demo) if timeout is None else timeout
  audio = OwnedAudio(appid, os.environ)
  while True:
    elapsed = time.monotonic() - start
    status = json.loads(amiga.ipc('amigaPoll', owner))
    if status.get('state') != 'active':
      if status.get('reason') == 'locked' and not desktop_locked():
        raise ValueError('Transient guard lock lease lost')
      raise InterruptedError('Guard stopped: ' + status.get('reason', 'closed'))
    navigation = status.get('navigationRevision', 0)
    if navigation != handled:
      handled = navigation
      if history.navigate(status['navigationDirection']):
        return handled, 'manual'
    if process.poll() is not None:
      if shown:
        return handled, 'ended'
      raise ValueError('Emulator stopped before presentation')
    restored = restore_completed(Path(log.name).read_text(errors='replace'), appid.rsplit('.', 1)[-1])
    if not restored and elapsed > RESTORE_FRAME_DEADLINE_SECONDS:
      raise ValueError('State restoration did not complete; no boot fallback')
    window = owned_window(appid, process)
    if shown and window is None:
      # bwrap can outlive a SIGKILLed emulator child briefly. The disappeared
      # token-bound Wayland toplevel is the exact crash signal for recovery.
      return handled, 'crash'
    if restored and window and not shown:
      # Presentation is the emulator's own compositor-fullscreen window
      # below the transparent guard overlay. Never gate on screencopy or on
      # a fixed window geometry: dma-buf negotiation differs per GPU/driver
      # and fullscreen works from any mapped state.
      amiga.fullscreen_window(window['address'])
      if amiga.ipc('amigaPresent', owner, monitor, appid, demo['title']) != 'ok':
        raise InterruptedError('Guard refused presentation')
      shown = True
      print('Amiga presented: ' + demo.get('task_id', '?') + ' ' + demo.get('title', ''), flush=True)
    if shown and revision != status.get('audioRevision') and audio.find() is not None:
      actual = audio.apply(status['requestedMuted'])
      if actual is None:
        raise ValueError('Owned audio disappeared')
      if amiga.ipc('amigaAudioApplied', owner, str(status['audioRevision']), str(actual['mute']).lower()) == 'ok':
        revision = status['audioRevision']
    if elapsed > PRESENTATION_STARTUP_DEADLINE_SECONDS and (not shown or not status.get('frameReady') or revision is None):
      raise ValueError('Restored frame/audio startup deadline exceeded')
    if shown and elapsed >= timeout:
      return handled, 'timeout'
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
    monitor = next(m['name'] for m in amiga.hypr('monitors') if m.get('focused'))
    logdir = Path.home() / '.local/state/omarchy/amiga'
    logdir.mkdir(parents=True, exist_ok=True)
    begun = False
    owner = ''
    try:
      labels = hint_labels(json.loads(amiga.ipc('amigaLocale')))
      owner = begin_guard(monitor, labels)
      begun = True
      previous = None
      session = logdir / 'session.json'
      with contextlib.suppress(OSError, ValueError, KeyError, StopIteration):
        previous_task = json.loads(session.read_text())['task_id']
        previous = next(index for index, demo in enumerate(choices) if demo['task_id'] == previous_task)
      history, handled, generation, consecutive_failures = History(len(choices), excluded=previous), 0, 0, 0
      transitions = logdir / 'transitions.jsonl'
      while True:
        demo = choices[history.current]
        generation += 1
        transition, failure = None, None
        with tempfile.TemporaryDirectory(prefix='omarchy-amiga-', dir=runtime) as temporary:
          with (logdir / 'emulator.log').open('w') as log:
            token = uuid.uuid4().hex
            command = sandbox_command(demo, temporary, token)
            process = amiga.launch_command(command, log)
            try:
              session.write_text(json.dumps({'owner': owner, 'task_id': demo['task_id'],
                'generation': generation, 'controller_pid': os.getpid(), 'child_pid': process.pid,
                'state_sha256': demo['state_sha256'], 'mode': 'state-only', 'command': command,
                'renderer': json.loads((Path(temporary) / 'renderer.json').read_text()),
                'history': history.items, 'order': history.order, 'cursor': history.cursor}, indent=2))
              handled, transition = play(process, demo, owner, monitor, amiga.APP_CLASS + '.' + token, log, history, handled)
              if amiga.ipc('amigaCover', owner) != 'ok':
                raise InterruptedError('Guard refused transition cover')
            except ValueError as error:
              failure = str(error)
              if amiga.ipc('amigaCover', owner) != 'ok':
                # An emulator failure must not leave an unlocked desktop with a
                # dead guard. Re-open an owned guard and continue to the next
                # candidate; begin_guard fails closed if the real lock engaged.
                with contextlib.suppress(Exception):
                  amiga.ipc('amigaEnd', owner)
                owner = begin_guard(monitor, labels)
            finally:
              amiga.stop(process)
        if failure is not None:
          consecutive_failures += 1
          transition = 'failure'
          if consecutive_failures >= len(choices):
            raise ValueError('Every eligible Amiga demo failed during this session')
        else:
          consecutive_failures = 0
        with transitions.open('a') as stream:
          stream.write(json.dumps({
            'at': time.time(), 'generation': generation, 'task_id': demo['task_id'],
            'title': demo['title'], 'reason': transition, 'error': failure,
            'max_demo_seconds': max_demo_seconds(), 'scheduled_seconds': demo_timeout(demo),
          }, sort_keys=True) + '\n')
        # Manual next/previous already updates History inside play(). Every
        # normal completion, timeout and recoverable failure advances exactly once.
        if transition != 'manual':
          history.navigate('next')
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
