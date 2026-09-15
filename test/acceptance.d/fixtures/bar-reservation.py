"""Measure compositor reservations and a real tiled client throughout shell loss."""
import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import sys
import threading
import time

artifacts = Path(sys.argv[1])
artifacts.mkdir(parents=True, exist_ok=True)
config_path = Path.home() / '.config/omarchy/shell.json'
original_config = config_path.read_bytes()
flag = Path.home() / '.local/state/omarchy/toggles/bar-off'
original_hidden = flag.exists()
root = Path(os.environ['OMARCHY_PATH'])
socket_path = Path(os.environ['XDG_RUNTIME_DIR']) / 'hypr' / os.environ['HYPRLAND_INSTANCE_SIGNATURE'] / '.socket.sock'
terminal_pid = None


def command(*args, timeout=20):
  result = subprocess.run(args, text=True, capture_output=True, timeout=timeout)
  if result.returncode:
    raise RuntimeError(f'{args}: {result.stdout}{result.stderr}')
  return result.stdout.strip()


def query(name):
  with socket.socket(socket.AF_UNIX) as connection:
    connection.settimeout(2)
    connection.connect(str(socket_path))
    connection.sendall(('j/' + name).encode())
    chunks = []
    while True:
      data = connection.recv(65536)
      if not data:
        break
      chunks.append(data)
    return json.loads(b''.join(chunks))


def status():
  return json.loads(command('qs', 'ipc', '-n', '-p', str(root / 'shell/bar-reservation'), 'call', 'reservation', 'status'))


def wait(description, predicate, timeout=15):
  deadline = time.monotonic() + timeout
  while time.monotonic() < deadline:
    try:
      if predicate():
        print('ok - ' + description, flush=True)
        return
    except (RuntimeError, ValueError, OSError):
      pass
    time.sleep(.05)
  raise AssertionError(description)


def capture(name):
  command('grim', str(artifacts / (name + '.png')))


def layers(namespace):
  return [layer for monitor in query('layers').values()
      for level in monitor['levels'].values() for layer in level
      if layer['namespace'] == namespace]


def geometry():
  clients = [client for client in query('clients') if client['pid'] == terminal_pid]
  assert len(clients) == 1, 'test terminal remains alive'
  return {'monitors': {m['name']: m['reserved'] for m in query('monitors')},
      'at': clients[0]['at'], 'size': clients[0]['size']}


def stable_during(name, action):
  expected = geometry()
  old_pid = layers('omarchy-bar')[0]['pid']
  samples, errors = [], []
  stop = threading.Event()

  def sample():
    while not stop.is_set():
      try:
        samples.append({'time': time.monotonic(), **geometry()})
      except Exception as error:
        errors.append(str(error))
      stop.wait(.005)

  worker = threading.Thread(target=sample)
  worker.start()
  try:
    action()
    wait(name + ' recovers', lambda: status()['ready'] and any(layer['pid'] != old_pid for layer in layers('omarchy-bar')))
    time.sleep(.3)
  finally:
    stop.set()
    worker.join(3)
    (artifacts / (name + '-geometry.json')).write_text(json.dumps(samples))
  assert not errors, errors
  assert len(samples) >= 10, 'sampled the outage'
  mismatches = [s for s in samples if {k: s[k] for k in expected} != expected]
  assert not mismatches, f'{name}: geometry changed in {len(mismatches)}/{len(samples)} samples: {mismatches[:2]}'
  print(f'ok - {name}: unchanged geometry in all {len(samples)} samples', flush=True)


def set_config(**bar):
  config = json.loads(config_path.read_text())
  config['bar'].update(bar)
  config['idle'] = {'screensaver': 86400, 'lock': 86400}
  staged = config_path.with_suffix('.recovery-test')
  staged.write_text(json.dumps(config))
  staged.replace(config_path)
  command('omarchy-shell', 'shell', 'reloadConfig')
  wait('bar config applied', lambda: all(status()['snapshot'].get(k) == v for k, v in bar.items() if k in ('position',)))
  time.sleep(.5)


try:
  flag.unlink(missing_ok=True)
  set_config(position='top', transparent=False)
  command('omarchy-shell', 'omarchy.bar', 'syncHidden')
  wait('reservation host is ready', lambda: status()['ready'] and len(layers('omarchy-bar-reservation')) == len(query('monitors')))
  helper_pid = layers('omarchy-bar-reservation')[0]['pid']
  command('hyprctl', 'dispatch', 'hl.dsp.exec_cmd("foot --app-id=omarchy-bar-recovery-test")')
  wait('test terminal opens', lambda: any(c['class'] == 'omarchy-bar-recovery-test' for c in query('clients')))
  terminal_pid = next(c['pid'] for c in query('clients') if c['class'] == 'omarchy-bar-recovery-test')
  time.sleep(.5)
  capture('success-bar-before')

  def planned_outage():
    command('qs', 'ipc', '-n', '-p', str(root / 'shell/bar-reservation'), 'call', 'reservation', 'restarting')
    command('qs', 'kill', '-p', str(root / 'shell'))
    wait('planned outage is indicated', lambda: not status()['ready'] and 'restarting' in status()['message'])
    time.sleep(.4)
    capture('success-bar-restarting')
    command('hyprctl', 'dispatch', 'hl.dsp.exec_cmd("omarchy-launch-shell")')

  stable_during('planned-outage', planned_outage)
  capture('success-bar-recovered')
  for edge in ('top', 'bottom', 'left', 'right'):
    set_config(position=edge)
    stable_during(edge + '-restart', lambda: command('omarchy-restart-shell'))
    stable_during(edge + '-crash', lambda: os.kill(layers('omarchy-bar')[0]['pid'], signal.SIGKILL))
    capture('success-bar-' + edge)
  for attempt in range(3):
    stable_during('repeated-restart-' + str(attempt), lambda: command('omarchy-restart-shell'))
  assert layers('omarchy-bar-reservation')[0]['pid'] == helper_pid, 'same reservation host survives all restarts'
  assert len(layers('omarchy-bar-reservation')) == len(query('monitors')), 'one reservation per monitor'
  print('ok - restarts do not duplicate or replace the reservation host', flush=True)

  flag.parent.mkdir(parents=True, exist_ok=True)
  flag.touch()
  command('omarchy-shell', 'omarchy.bar', 'syncHidden')
  wait('hidden bar releases all space', lambda: all(m['reserved'] == [0,0,0,0] for m in query('monitors')))
  time.sleep(.4)
  stable_during('hidden-restart', lambda: command('omarchy-restart-shell'))
  stable_during('hidden-crash', lambda: os.kill(int(command('pgrep', '-f', '^quickshell -n -p ' + str(root / 'shell') + '$')), signal.SIGKILL))
  capture('success-bar-hidden')
  flag.unlink()
  command('omarchy-shell', 'omarchy.bar', 'syncHidden')
  wait('bar reveal restores reservation', lambda: bool(layers('omarchy-bar-reservation')))
  set_config(position='top', transparent=True)
  stable_during('transparent-restart', lambda: command('omarchy-restart-shell'))
  capture('success-bar-transparent')
  print('ok - bar reservation acceptance checks passed', flush=True)
except Exception:
  capture('failure-bar-reservation')
  raise
finally:
  config_path.write_bytes(original_config)
  if original_hidden:
    flag.touch()
  else:
    flag.unlink(missing_ok=True)
  if terminal_pid:
    try:
      os.kill(terminal_pid, signal.SIGTERM)
    except ProcessLookupError:
      pass
  subprocess.run(['omarchy-restart-shell'], timeout=60, capture_output=True)
