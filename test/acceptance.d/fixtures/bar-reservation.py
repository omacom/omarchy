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
style_path = Path.home() / '.config/omarchy/shell.toml'
original_style = style_path.read_bytes() if style_path.exists() else None
flag = Path.home() / '.local/state/omarchy/toggles/bar-off'
original_hidden = flag.exists()
root = Path(os.environ['OMARCHY_PATH'])
socket_path = Path(os.environ['XDG_RUNTIME_DIR']) / 'hypr' / os.environ['HYPRLAND_INSTANCE_SIGNATURE'] / '.socket.sock'
terminal_pid = None
initial_client_pids = set()
crash_clients = set()


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


def process_environment(pid):
  entries = os.fsdecode(Path(f'/proc/{pid}/environ').read_bytes()).split('\0')
  return dict(entry.split('=', 1) for entry in entries if '=' in entry)


def close_crash_reporters():
  for client in query('clients'):
    if client['class'] == 'org.quickshell' and client['pid'] not in initial_client_pids:
      try:
        descriptor = os.pidfd_open(client['pid'])
        try:
          environment = process_environment(client['pid'])
          # Only crash reporters receive DUMP_FD; the re-execed shell does not.
          # Match the launcher we deliberately crashed, not another Qt window.
          if environment.get('__QUICKSHELL_CRASH_DUMP_FD') and environment.get('OMARCHY_BAR_CLIENT') in crash_clients:
            signal.pidfd_send_signal(descriptor, signal.SIGTERM)
        finally:
          os.close(descriptor)
      except (ProcessLookupError, FileNotFoundError, PermissionError):
        pass


def layers(namespace):
  return [layer for monitor in query('layers').values()
      for level in monitor['levels'].values() for layer in level
      if layer['namespace'] == namespace]


def crash_shell():
  pid = layers('omarchy-bar')[0]['pid']
  crash_clients.add(process_environment(pid)['OMARCHY_BAR_CLIENT'])
  os.kill(pid, signal.SIGSEGV)


def geometry():
  clients = [client for client in query('clients') if client['pid'] == terminal_pid]
  assert len(clients) == 1, 'test terminal remains alive'
  return {'monitors': {m['name']: m['reserved'] for m in query('monitors')},
      'at': clients[0]['at'], 'size': clients[0]['size']}


def stable_during(name, action, recovered=None):
  expected = geometry()
  old_bar = layers('omarchy-bar')[0]
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
    # Quickshell's signal handler re-execs in the same PID. Its replacement
    # layer surface, rather than the PID alone, proves recovery completed.
    wait(name + ' recovers', recovered or (lambda: status()['ready'] and any(
      (layer['pid'], layer['address']) != (old_bar['pid'], old_bar['address']) for layer in layers('omarchy-bar'))))
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
  initial_client_pids = {client['pid'] for client in query('clients')}
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

  # A failed reconnect must not strand the main shell on its own zone. Keep
  # the host down past the first retry, then restart just that configuration.
  main_pid = layers('omarchy-bar')[0]['pid']
  main_env = process_environment(main_pid)
  os.kill(helper_pid, signal.SIGKILL)
  wait('dead reservation host is unmapped', lambda: not layers('omarchy-bar-reservation'))
  time.sleep(2)
  stable_during('late-host-handoff', lambda: command('env', 'OMARCHY_BAR_SOCKET=' + main_env['OMARCHY_BAR_SOCKET'],
    'quickshell', '-d', '-n', '-p', str(root / 'shell/bar-reservation')),
    lambda: status()['ready'] and bool(layers('omarchy-bar-reservation')))
  assert layers('omarchy-bar')[0]['pid'] == main_pid, 'reconnection does not restart the main shell'
  stable_during('restart-after-late-host', lambda: command('omarchy-restart-shell'))
  capture('success-bar-late-host')
  # SIGSEGV goes through Quickshell's own crash handler and core-dump child;
  # SIGKILL alone does not exercise inherited socket descriptors there.
  time.sleep(11)
  stable_during('segfault-recovery', crash_shell)
  capture('success-bar-segfault-recovery')
  close_crash_reporters()
  style_path.write_text('[bar]\nsize-horizontal = 300\nsize-vertical = 300\nscale-with-font = false\n')
  command('omarchy-restart-shell')
  wait('300-pixel bar reserves its configured size', lambda: status()['snapshot']['size'] == 300 and status()['ready'])
  time.sleep(.5)
  stable_during('large-bar-restart', lambda: command('omarchy-restart-shell'))
  stable_during('large-bar-crash', lambda: os.kill(layers('omarchy-bar')[0]['pid'], signal.SIGKILL))
  capture('success-bar-large')
  print('ok - bar reservation acceptance checks passed', flush=True)
except Exception:
  capture('failure-bar-reservation')
  raise
finally:
  close_crash_reporters()
  config_path.write_bytes(original_config)
  if original_style is None:
    style_path.unlink(missing_ok=True)
  else:
    style_path.write_bytes(original_style)
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
