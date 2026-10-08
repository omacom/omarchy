#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 - "$ROOT" <<'PY'
import copy
import importlib.util
import sys

spec = importlib.util.spec_from_file_location('layout', sys.argv[1] + '/default/hypr/monitor-layout.py')
layout = importlib.util.module_from_spec(spec)
spec.loader.exec_module(layout)

def display(name, x, y, mode='1920x1080@60', transform=0):
  return dict(name=name, x=x, y=y, mode=mode, scale=1, transform=transform)

def resize(displays, name, key, value):
  original = copy.deepcopy(displays)
  result = layout.resize(dict(displays=displays, workspaces=[dict(id=1, monitor=name)]), name, key, value)
  assert displays == original, 'resize must not mutate its input'
  assert result['workspaces'] == [dict(id=1, monitor=name)]
  return {d['name']: d for d in result['displays']}

pair = [display('eDP-1', 0, 0), display('DP-1', 1920, 0)]
r = resize(pair, 'eDP-1', 'scale', '2')
assert (r['eDP-1']['x'], r['eDP-1']['y']) == (0, 0)
assert r['DP-1']['x'] == 960
print('ok - scale preserves adjacency and fixed laptop anchor')

pair = [display('eDP-1', 0, 0), display('DP-1', -1920, -1080)]
r = resize(pair, 'DP-1', 'scale', '2')
assert (r['DP-1']['x'], r['DP-1']['y']) == (-1920, -1080), 'corner-only contact does not imply an edge'

pair = [display('eDP-1', 0, 0), display('DP-1', -1920, 0)]
r = resize(pair, 'DP-1', 'scale', '2')
assert r['DP-1']['x'] == -960
print('ok - negative coordinates preserve left relation')

pair = [display('eDP-1', 0, 0), display('DP-1', 1920, -360, '2560x1440@60')]
r = resize(pair, 'DP-1', 'scale', '2')
assert r['DP-1']['y'] == 360, 'bottom alignment'
r = resize(pair, 'DP-1', 'mode', '1920x1080@75')
assert (r['DP-1']['x'], r['DP-1']['y']) == (1920, 0)
print('ok - resolution and scale preserve bottom alignment')

pair = [display('eDP-1', 0, 0), display('DP-1', 1920, -180, '2560x1440@60')]
r = resize(pair, 'DP-1', 'scale', '2')
assert r['DP-1']['y'] == 180, 'center alignment'

triple = [display('eDP-1', 0, 0), display('DP-1', 1940, 0), display('DP-2', 3860, 0)]
r = resize(triple, 'DP-1', 'scale', '2')
assert r['DP-1']['x'] == 1940 and r['DP-2']['x'] == 2900
print('ok - resize propagates through chain and preserves deliberate gaps')

pair = [display('eDP-1', 0, 0), display('DP-1', 0, -1080)]
r = resize(pair, 'DP-1', 'transform', '1')
assert (r['DP-1']['x'], r['DP-1']['y']) == (0, -1920)
print('ok - portrait resize preserves above relation')

r = resize(triple, 'DP-1', 'mode', '1920x1080@75')
assert [(r[d['name']]['x'], r[d['name']]['y']) for d in triple] == [(d['x'], d['y']) for d in triple]
print('ok - refresh-only changes never move displays')

quad = [display('eDP-1', 0, 0), display('B', 1920, 0), display('C', 0, 1080), display('D', 1920, 1080)]
try:
  resize(quad, 'B', 'scale', '2')
except ValueError:
  print('ok - contradictory contact cycle rejects automatic rearrangement')
else:
  raise AssertionError('must reject inconsistent contact cycle')

pair = [display('eDP-1', 0, 0), display('DP-1', 1920, -1000)]
try:
  resize(pair, 'DP-1', 'scale', '2')
except ValueError:
  print('ok - resize cannot silently remove the shared pointer edge')
else:
  raise AssertionError('must retain positive overlap on touching edge')
PY
