"""Persist display orientation in Omarchy's existing simple monitor rules."""
import argparse
import json
import math
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time


# Imported helpers must never create cache files in the watched plugin directory.
sys.dont_write_bytecode = True
from display_runtime import hypr, state_dir, record, operation_lock


from monitor_rules import plan, update_rule


def atomic_write(path, content):
  with tempfile.NamedTemporaryFile(mode='w', dir=path.parent, prefix='.orientation-', delete=False) as tmp:
    temp = Path(tmp.name)
    try:
      tmp.write(content)
      tmp.flush()
      os.fsync(tmp.fileno())
      os.chmod(temp, path.stat().st_mode & 0o777)
      os.replace(temp, path)
    finally:
      temp.unlink(missing_ok=True)


def equal(actual, expected):
  if isinstance(actual, (int, float)) and isinstance(expected, (int, float)):
    return math.isclose(actual, expected, rel_tol=0, abs_tol=1e-5)
  return actual == expected


def matches(monitors, expected):
  current = {m['name']: m for m in monitors}
  return all(name in current and all(equal(current[name].get(k), v) for k, v in fields.items())
       for name, fields in expected.items())


def wait_for(expected, seconds=6):
  deadline = time.monotonic() + seconds
  while True:
    remaining = max(0.1, deadline - time.monotonic())
    errors = hypr('configerrors', timeout=min(2, remaining))
    if errors:
      raise ValueError(errors)
    remaining = max(0.1, deadline - time.monotonic())
    if matches(json.loads(hypr('monitors', '-j', timeout=min(2, remaining))), expected):
      return
    if time.monotonic() >= deadline:
      raise ValueError('Display did not accept the orientation')
    time.sleep(0.2)


def apply(path, name, transform, dry_run=False, lock=None, scale=None, expected_description=None, expected_state=None):
  path = path.resolve(strict=True)
  before = path.read_text()
  if hypr('configerrors'):
    raise ValueError('Resolve existing Hyprland configuration errors first')
  monitors = json.loads(hypr('monitors', '-j'))
  selected = next((m for m in monitors if m['name'] == name), None)
  if expected_description is not None and (not selected or selected.get('description') != expected_description):
    raise ValueError('Display connection changed; select the display again')
  if expected_state is not None and not matches(monitors, {name: expected_state}):
    raise ValueError('Display settings changed elsewhere; review the values and try again')
  after, expected = plan(before, monitors, name, transform, scale)
  autoreload = json.loads(hypr('getoption', 'misc:disable_autoreload', '-j'))
  if autoreload.get('bool', autoreload.get('int')) not in (False, 0):
    raise ValueError('Automatic configuration reload is disabled; no change was made')
  if dry_run:
    print(json.dumps({'changes': expected, 'config': after}, ensure_ascii=False))
    return
  if after == before and matches(monitors, expected):
    record('unchanged', monitor=name, transform=transform)
    print('Orientation already saved')
    return
  if after == before:
    raise ValueError('Saved and active display settings differ; no change was made')
  if lock is not None:
    lock.seek(0)
    last = lock.read().strip()
    try:
      elapsed = time.monotonic() - float(last) if last else 3
    except ValueError:
      elapsed = 3
    if 0 <= elapsed < 3:
      raise ValueError('Please wait a few seconds before changing orientation again')
    lock.seek(0)
    lock.truncate()
    lock.write(str(time.monotonic()))
    lock.flush()
  with tempfile.NamedTemporaryFile(mode='w', suffix='.lua') as check:
    check.write(after)
    check.flush()
    subprocess.run(['luac', '-p', check.name], capture_output=True, text=True, check=True)
  backup = state_dir() / ('monitors-' + str(time.time_ns()) + '.lua')
  backup.write_text(before)
  if path.read_text() != before:
    raise ValueError('Monitor configuration changed; try again')
  record('apply', monitor=name, transform=transform, changes=expected, backup=str(backup))
  # Reject a hotplug or concurrent display change that happened during validation.
  snapshot_keys = ('description', 'width', 'height', 'x', 'y', 'scale', 'transform')
  snapshot = {m['name']: {k: m.get(k) for k in snapshot_keys} for m in monitors}
  current = json.loads(hypr('monitors', '-j'))
  if len(current) != len(monitors) or not matches(current, snapshot):
    raise ValueError('Display layout changed during validation; try again')
  if path.read_text() != before:
    raise ValueError('Monitor configuration changed; try again')
  atomic_write(path, after)
  try:
    # Saving a watched config already triggers Hyprland's reload. Do not
    # issue a second forced reload while its outputs are being reconfigured.
    wait_for(expected)
    record('saved', monitor=name, transform=transform)
  except Exception as error:
    if path.read_text() == after:
      atomic_write(path, before)
      record('restore', reason=str(error))
      previous = {m['name']: {k: m[k] for k in fields}
            for m in monitors if (fields := expected.get(m['name']))}
      try:
        wait_for(previous)
        record('restored')
      except Exception as rollback_error:
        record('restore-unverified', reason=str(rollback_error))
        raise ValueError('Previous configuration restored on disk, but display recovery could not be verified') from error
    else:
      record('restore-skipped', reason='Configuration was edited by another process')
    raise

  print("Display settings saved")


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument('monitor')
  parser.add_argument('transform', type=int, choices=range(8))
  parser.add_argument('--dry-run', action='store_true')
  parser.add_argument('--scale', type=float)
  parser.add_argument('--expected-description')
  parser.add_argument('--expected-state', type=json.loads)
  args = parser.parse_args()
  with operation_lock() as lock:
    apply(Path(os.environ.get('XDG_CONFIG_HOME', str(Path.home() / '.config'))) / 'hypr/monitors.lua', args.monitor, args.transform,
       args.dry_run, lock, args.scale, args.expected_description, args.expected_state)


if __name__ == '__main__':
  try:
    main()
  except Exception as error:
    try:
      record('error', reason=str(error))
    except OSError:
      pass
    print(str(error), file=sys.stderr)
    sys.exit(1)
