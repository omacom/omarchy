#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

python3 <<'PY'
import json
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(os.environ['ROOT'])
with tempfile.TemporaryDirectory() as tmp:
  tmp = Path(tmp)
  shell = tmp / 'omarchy-shell'
  shell.write_text('''#!/usr/bin/python3
import json, os, pathlib, sys
payload = json.loads(sys.argv[-1])
pathlib.Path(os.environ['PAYLOAD']).write_text(json.dumps(payload))
if os.environ.get('CANCEL') != '1':
  value = payload['options'][0]
  if payload.get('checkbox'): value = json.dumps({'value': value, 'checked': True})
  pathlib.Path(payload['selectionFile']).write_text(value + '\\n')
pathlib.Path(payload['doneFile']).touch()
''')
  shell.chmod(0o755)
  env = {**os.environ, 'PATH': f'{tmp}:' + os.environ['PATH'], 'PAYLOAD': str(tmp / 'payload')}
  command = [root / 'bin/omarchy-menu-select', 'Resolution', 'medium', 'low']
  r = subprocess.run(command, env=env, capture_output=True, text=True)
  assert r.returncode == 0 and r.stdout == 'medium\n'
  print('ok - menus without checkbox keep their plain-text result')
  r = subprocess.run([*command, '--', '--checkbox', "Apply to all heic files", '--width', '460'], env=env, capture_output=True, text=True)
  assert r.returncode == 0 and json.loads(r.stdout) == {'value': 'medium', 'checked': True}
  payload = json.loads((tmp / 'payload').read_text())
  assert payload['checkbox'] == 'Apply to all heic files' and payload['width'] == 460
  assert not Path(payload['selectionFile']).exists() and not Path(payload['doneFile']).exists()
  print('ok - checkbox label reaches the shell and JSON result survives with temporary files cleaned up')
  for args in (['--checkbox'], ['--checkbox', ''], ['--multiple', '--checkbox', 'All']):
    r = subprocess.run([*command, '--', *args], env=env, capture_output=True, text=True)
    assert r.returncode == 2, (args, r.stderr)
  print('ok - missing checkbox labels and incompatible multi-select mode are rejected')
  r = subprocess.run([*command, '--', '--checkbox', 'All'], env={**env, 'CANCEL': '1'}, capture_output=True, text=True)
  assert r.returncode == 1 and not r.stdout
  print('ok - canceling a checkbox menu does not emit a selection')
PY
