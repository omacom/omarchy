#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 - "$ROOT" <<'PY'
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from unittest.mock import patch

s = importlib.util.spec_from_file_location('layout', Path(sys.argv[1]) / 'default/hypr/monitor-layout.py')
m = importlib.util.module_from_spec(s); s.loader.exec_module(m)
def monitor(name, x=0, y=0, scale=1, width=1920, height=1080):
  return dict(name=name, x=x, y=y, scale=scale, width=width, height=height, refreshRate=60, transform=0)

with tempfile.TemporaryDirectory() as td, patch.dict(os.environ, {'XDG_STATE_HOME': td, 'XDG_RUNTIME_DIR': td}):
  owner = Path(td, 'monitors.lua')
  owner.write_text('local output = "A"\nhl.monitor({ output = output, mode = "preferred", scale = 2 })\n')
  original = owner.read_bytes()
  live = [monitor('A'), monitor('B', x=1920), monitor('C', x=3840)]
  stale = [dict(row) for row in live]
  calls = []
  def ipc(*args, **kwargs):
    global live, gtk
    calls.append(args)
    if args[0] == 'monitors': out = json.dumps(live)
    elif args[0] == 'repl': out = 'GDK_SCALE:' + gtk + '\n'
    elif args[0] == 'reload':
      live = [monitor('A', scale=2)]
      gtk = '2'
      out = 'ok'
    elif args[0] == 'getoption': out = '{"bool":false}'
    elif args[0] == 'eval':
      match = re.search(r'hl.env\("GDK_SCALE", "([^"]*)"\)', args[1])
      if match:
        gtk = re.sub(r'\\(\d{3})', lambda m: chr(int(m[1])), match[1])
      if 'hl.monitor(' in args[1]:
        live = [monitor(n, int(x), int(y), float(sc), int(w), int(h)) for n,w,h,rate,x,y,sc,t in re.findall(
        r'output = "([^"]+)", mode = "(\d+)x(\d+)@([\d.]+)", position = "(-?\d+)x(-?\d+)", scale = ([\d.]+), transform = (\d+)', args[1])]
      out = 'ok'
    else: raise AssertionError(args)
    return subprocess.CompletedProcess(args, 0, out, '')
  with patch.object(m, 'ipc', ipc), patch.object(m.time, 'sleep'):
    m.apply(stale, 'A', 2, owner)
    m.apply(stale, 'B', 2, owner)
    assert [r['scale'] for r in live] == [2,2,1]
    assert [r['x'] for r in live] == [0,960,1920]
    rows = m.read_state(m.state_path().read_bytes(), original)
    assert rows == live
    print('ok - successive stale callers preserve preceding scale and persist a coherent three-output chain (no 960px gap)')
    m.apply(stale, 'A', 'up', owner)
    assert live[0]['scale'] == 2.5
    m.apply(stale, 'A', 'up', owner)
    assert live[0]['scale'] == 3
    print('ok - relative requests step from the current locked scale, not their stale snapshot')
    # A remembered third output cannot be attached to an arbitrarily rearranged
    # subset using a single anchor. Refuse before any live mutation/publication.
    live = [monitor('A'), monitor('B', x=1920), monitor('C', x=3840)]
    m.state_path().unlink()
    m.apply(live, 'A', 1, owner)
    prior = m.state_path().read_bytes()
    live = [monitor('A'), monitor('B', y=1080)]
    before = json.loads(json.dumps(live))
    try: m.apply(live, 'A', 2, owner)
    except ValueError as error: assert 'remembered graph' in str(error)
    else: raise AssertionError('ambiguous remembered graph accepted')
    assert live == before and m.state_path().read_bytes() == prior
    print('ok - rearranged subset with absent neighbour fails before IPC writes instead of saving a reconnect gap')
    # Preserve the external display preference across unplug -> panel save -> reconnect.
    live = [monitor('DP-1',1280,0,2.5,3840,2160), monitor('eDP-1',1536,864,2,2560,1664)]
    m.state_path().unlink()
    m.apply(live, 'DP-1', 1.25, owner)
    live = [dict(next(r for r in live if r['name']=='eDP-1'))]
    m.apply(live, 'eDP-1', 1.6, owner)
    rows = m.read_state(m.state_path().read_bytes(), original)
    external = next(r for r in rows if r['name']=='DP-1'); panel = next(r for r in rows if r['name']=='eDP-1')
    assert external['scale']==1.25 and panel['scale']==1.6
    assert m.rect(external)[1]+m.rect(external)[3] == panel['y']
    assert m.rect(external)[0]+m.rect(external)[2] == m.rect(panel)[0]+m.rect(panel)[2]
    assert not m.overlap(m.rect(external), m.rect(panel))
    assert live == [panel]
    print('ok - unplug/save/reconnect retains absent external mode/scale and rebuilds touching bottom/right edges')
    # Loader uses these complete rows on reconnect, while owner custom Lua stays intact.
    assert owner.read_bytes() == original
    assert not any(c[0]=='reload' for c in calls)
    live = [monitor('A', scale=2)]
    m.state_path().unlink()
    m.apply(stale, 'A', 1.6, owner)
    assert m.read_state(m.state_path().read_bytes(), original)[0]['scale']==1.6
    print('ok - custom variable-selector single-output Lua persists through managed data without rewriting owner code')
    # Owner edits invalidate disconnected memory as well as the Lua loader.
    assert m.read_state(m.state_path().read_bytes(), original+b'-- edit') == []
    assert m.read_state(m.state_path().read_bytes()+b'not-a-monitor-row\n', original) == []
    print('ok - stale-baseline and malformed saved memory cannot override new owner settings')

  # Exercise the default managed GTK knob through the mocked compositor, with
  # failures at each transaction boundary and both autoreload policies.
  for disabled in (False, True):
    for phase in ('success', 'eval', 'publish', 'readback', 'gtk-readback', 'signal'):
      owner.write_text('local omarchy_gdk_scale = 2\n')
      live = [monitor('A', scale=2)]
      gtk = '3'  # Must restore the compositor value, not infer it from geometry.
      prior = m.encode_state(owner.read_bytes(), live, 'A')
      m.publish_state(m.state_path(), prior)
      calls.clear()
      real_publish = m.publish_state
      def guarded_ipc(*args, **kwargs):
        global gtk
        result = ipc(*args, **kwargs)
        if args[0] == 'getoption': result.stdout = json.dumps({'bool':disabled})
        if args[0] == 'eval' and 'hl.monitor(' in args[1] and len([c for c in calls if c[0]=='eval']) == 1:
          if phase == 'eval': result.stdout = 'error: partial apply'
          if phase == 'signal': raise m.Terminated(15)
        if args[0] == 'monitors' and phase == 'readback' and any(c[0]=='eval' for c in calls):
          result.stdout = json.dumps([monitor('A', scale=2)])
        if args[0] == 'repl' and phase == 'gtk-readback' and any(c[0]=='eval' for c in calls):
          gtk = '2'
          result.stdout = 'GDK_SCALE:2\n'
        return result
      def publication(path, content):
        if phase == 'publish' and content != prior: raise OSError('injected publication failure')
        real_publish(path, content)
      with patch.object(m, 'ipc', guarded_ipc), patch.object(m, 'publish_state', publication), patch.object(m.time, 'sleep'):
        if phase == 'success':
          assert m.apply(live, 'A', 1, owner) == 1
          assert gtk == '1' and m.state_path().read_bytes().split(b'\n')[2] == b'1'
          assert not any(c[0]=='reload' for c in calls)
        else:
          try: m.apply(live, 'A', 1, owner)
          except (ValueError, OSError, m.Terminated): pass
          else: raise AssertionError('false success: ' + phase)
          assert gtk == '3', (phase, disabled, gtk)
          assert live == [monitor('A', scale=2)] and m.state_path().read_bytes() == prior
          assert any(c[0]=='reload' for c in calls) == (not disabled)
      print(f'ok - GTK {phase}, autoreload disabled={disabled}: live environment and saved state follow transaction recovery')
PY
