"""Simulated compositor boundary for the real monitor backend and QML controls."""

import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time

state_path = Path(os.environ['ARRANGEMENT_TEST_STATE'])
config = Path(os.environ['XDG_CONFIG_HOME']) / 'hypr/monitors.lua'
base = [dict(name=name, x=index * 1920, y=0, width=1920, height=1080, scale=1, transform=0)
        for index, name in enumerate(('eDP-1', 'DP-2', 'DP-3'))]
base[2].update(width=1280, height=720)


def save_state(state):
  temporary = state_path.with_suffix('.tmp')
  temporary.write_text(json.dumps(state))
  temporary.replace(state_path)


if sys.argv[1] == '--control':
  values = json.loads(sys.argv[2])
  if values.pop('reset', False):
    state = dict(monitors=base, delay=0, readError=False, reloadError=False, reloads=0)
    config.parent.mkdir(parents=True, exist_ok=True)
    config.write_text('hl.monitor({output="", scale=1})\n')
  else:
    state = json.loads(state_path.read_text())
  if values.pop('disconnect', False):
    state['monitors'] = base[:1]
  if values.pop('move', False):
    state['monitors'][2]['x'] = 4000
  state.update(values)
  save_state(state)
  sys.exit(0)

state = json.loads(state_path.read_text())
args = sys.argv[1:]
if args == ['monitors', '-j']:
  time.sleep(state['delay'])
  if state['readError']:
    print('Simulated display query failed', file=sys.stderr)
    sys.exit(1)
  print(json.dumps(state['monitors']))
elif args == ['configerrors']:
  print('')
elif args[0] == 'eval':
  script = 'hl = {monitor = function(rule) for key, value in pairs(rule) do print(rule.output .. "\\t" .. key .. "\\t" .. tostring(value)) end end}\n'
  result = subprocess.run(['lua5.1', '-'], input=script + args[1], capture_output=True, text=True, check=True)
  for line in result.stdout.splitlines():
    name, key, value = line.split('\t')
    monitor = next(screen for screen in state['monitors'] if screen['name'] == name)
    if key == 'position':
      monitor['x'], monitor['y'] = map(int, re.fullmatch(r'(-?\d+)x(-?\d+)', value).groups())
    elif key in ('scale', 'transform'):
      monitor[key] = float(value)
    elif key == 'mode':
      mode = re.fullmatch(r'(\d+)x(\d+)(?:@([\d.]+))?', value)
      monitor['width'], monitor['height'] = map(int, mode.groups()[:2])
      if mode[3]: monitor['refreshRate'] = float(mode[3])
  save_state(state)
elif args == ['reload']:
  state['reloads'] += 1
  if state.get('reloadDelay'):
    state['reloadStarted'] = True
    save_state(state)
    time.sleep(state['reloadDelay'])
  if state['reloadError']:
    state['reloadError'] = False
    save_state(state)
    print('Simulated reload failed', file=sys.stderr)
    sys.exit(1)
  # Execute saved Lua rather than reimplementing the backend's config parser.
  script = 'hl = {monitor = function(rule) if rule.output ~= "" and rule.position then print(rule.output .. " " .. rule.position) end end}\n'
  result = subprocess.run(['lua5.1', '-'], input=script + config.read_text(), capture_output=True, text=True, check=True)
  positions = {}
  for line in result.stdout.splitlines():
    name, position = line.split()
    coordinates = re.fullmatch(r'(-?\d+)x(-?\d+)', position)
    positions[name] = tuple(map(int, coordinates.groups()))
  for monitor in state['monitors']:
    original = next(screen for screen in base if screen['name'] == monitor['name'])
    monitor['x'], monitor['y'] = positions.get(monitor['name'], (original['x'], original['y']))
  save_state(state)
else:
  print('Unexpected simulated compositor command: ' + repr(args), file=sys.stderr)
  sys.exit(1)
