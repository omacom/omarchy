#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 - "$ROOT" <<'PY'
import importlib.util
import json
import os
from pathlib import Path
import subprocess as sp
import sys
import tempfile
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('layout', Path(sys.argv[1]) / 'default/hypr/monitor-layout.py')
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
monitors = [dict(name='eDP-1', width=1920, height=1080, refreshRate=60, x=0, y=0, scale=1, transform=0)]
desired = m.plan(monitors, 'eDP-1', 2)
for prior_exists in (False, True):
  for phase in ('before-publish', 'old-after-publish', 'final-readback', 'between-final-readbacks', 'new-record-reload', 'new-output'):
    with tempfile.TemporaryDirectory() as td, patch.dict(os.environ, {'XDG_STATE_HOME':td, 'XDG_RUNTIME_DIR':td}):
      config = Path(td, 'monitors.lua'); config.write_text('-- unchanged owner baseline\n')
      unrelated = Path(td, 'input.lua'); unrelated.write_text('-- owner input\n')
      original = config.read_bytes(); saved = m.state_path()
      prior = m.encode_state(original, monitors, 'eDP-1') if prior_exists else None
      if prior is not None: m.publish_state(saved, prior)
      live = monitors
      queries = 0
      calls = []
      real_replace = m.os.replace
      fired = False
      def run(args, **kwargs):
        global live, queries, fired
        assert kwargs['timeout'] == 10
        calls.append(args)
        if args[1] == 'eval': live = desired
        if args[1] == 'reload': live = monitors
        if args[1] == 'monitors':
          queries += 1
          if queries == 3 and phase == 'final-readback': live = monitors
          if queries == 3 and phase == 'new-output': live = desired + [dict(monitors[0], name='DP-1', x=960)]
          out = json.dumps(live)
          if queries == 3 and phase == 'between-final-readbacks': live = monitors
        else: out = json.dumps({'bool':False}) if args[1] == 'getoption' else 'ok'
        return sp.CompletedProcess(args, 0, out, '')
      def publication(src, dst):
        global live, fired
        if fired:
          real_replace(src, dst)
          return
        fired = True
        unrelated.write_text('-- saved owner input edit\n')
        if phase == 'before-publish': live = monitors
        real_replace(src, dst)
        if phase == 'old-after-publish': live = monitors
        if phase == 'new-record-reload': live = desired
      with patch.object(m.subprocess, 'run', run), patch.object(m.os, 'replace', publication), patch.object(m.time, 'sleep'):
        if phase == 'new-record-reload':
          assert m.apply(monitors, 'eDP-1', 2, config) == 2
          assert live == desired and saved.read_bytes() == m.encode_state(original, desired, 'eDP-1')
          assert queries >= 3 and not any(c[1] == 'reload' for c in calls)
        else:
          try: m.apply(monitors, 'eDP-1', 2, config)
          except ValueError as error: assert 'Final live geometry differs' in str(error)
          else: raise AssertionError((phase, 'false success'))
          assert saved.read_bytes() == prior if prior is not None else not saved.exists()
          assert any(c[1] == 'reload' for c in calls)
      assert config.read_bytes() == original and unrelated.read_text() == '-- saved owner input edit\n'
      print(f'ok - prior={prior_exists}/{phase}: live/saved match required; false success rejected; owner edits preserved')
PY
