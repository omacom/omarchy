"""Arrange enabled Hyprland outputs while preserving their Lua monitor options."""

import argparse
import fcntl
import itertools
import json
import math
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time
import uuid

SIDES = ('left', 'right', 'above', 'below')
TOKEN = re.compile(r'''--\[(=*)\[.*?\]\1\]|--[^\n]*|\[(=*)\[.*?\]\2\]|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|[A-Za-z_][A-Za-z_0-9]*|[^\s]''', re.S)


class LayoutError(RuntimeError):
  """An invalid proposed layout does not invalidate earlier draft moves."""


def hypr(*args):
  result = subprocess.run(['hyprctl', *args], capture_output=True, text=True, timeout=12)
  if result.returncode:
    raise RuntimeError(result.stderr.strip() or result.stdout.strip() or 'Cannot reach Hyprland.')
  return result.stdout.strip()


def displays():
  monitors = [m for m in json.loads(hypr('monitors', '-j')) if not m.get('disabled')]
  if any(not re.fullmatch(r'[A-Za-z0-9._-]+', m['name']) for m in monitors):
    raise RuntimeError('Refusing an unsafe monitor name.')
  if len({m['name'] for m in monitors}) != len(monitors):
    raise RuntimeError('Hyprland returned duplicate monitor names.')
  if any(m.get('mirrorOf') not in (None, '', 'none') for m in monitors):
    raise RuntimeError('Turn off display mirroring before arranging screens.')
  return monitors


def logical_size(monitor):
  width, height, scale = monitor['width'], monitor['height'], monitor['scale']
  if not all(math.isfinite(v) and v > 0 for v in (width, height, scale)):
    raise RuntimeError('Invalid monitor dimensions or scale.')
  if monitor.get('transform', 0) % 2:
    width, height = height, width
  # Hyprland rounds positive logical dimensions to the nearest integer.
  return math.floor(width / scale + 0.5), math.floor(height / scale + 0.5)


def arrange(monitors, output, reference, side, alignment=None, allow_disconnected=False):
  by_name = {m['name']: m for m in monitors}
  if output == reference:
    raise RuntimeError('Choose two different screens.')
  if output not in by_name or reference not in by_name:
    raise RuntimeError('A selected screen is no longer connected and enabled.')
  moving, anchor = by_name[output], by_name[reference]
  width, height = logical_size(moving)
  anchor_width, anchor_height = logical_size(anchor)
  horizontal = side in ('left', 'right')
  alignments = ('top', 'center', 'bottom') if horizontal else ('left', 'center', 'right')
  if alignment is None:
    alignment = alignments[0]
  if alignment not in alignments:
    raise RuntimeError(f'Choose a valid alignment for {side}: {", ".join(alignments)}.')
  x, y = anchor['x'], anchor['y']
  x, y = {'left': (x - width, y), 'right': (x + anchor_width, y),
          'above': (x, y - height), 'below': (x, y + anchor_height)}[side]
  difference = anchor_height - height if horizontal else anchor_width - width
  offset = {'top': 0, 'left': 0, 'center': difference // 2, 'bottom': difference, 'right': difference}[alignment]
  if horizontal:
    y += offset
  else:
    x += offset
  positions = {m['name']: (m['x'], m['y']) for m in monitors}
  positions[output] = (x, y)
  return validate_positions(monitors, positions, allow_disconnected)


def validate_positions(monitors, positions, allow_disconnected=False):
  if not isinstance(positions, dict) or set(positions) != {m['name'] for m in monitors}:
    raise LayoutError('The layout must include each enabled screen exactly once.')
  if any(not isinstance(point, (list, tuple)) or len(point) != 2
         or any(type(value) is not int or abs(value) > 1000000 for value in point)
         for point in positions.values()):
    raise LayoutError('Screen positions must be integer coordinates within range.')
  for a, b in itertools.combinations(monitors, 2):
    ax, ay = positions[a['name']]
    bx, by = positions[b['name']]
    aw, ah = logical_size(a)
    bw, bh = logical_size(b)
    if ax < bx + bw and bx < ax + aw and ay < by + bh and by < ay + ah:
      raise LayoutError(f"The layout would overlap {a['name']} and {b['name']}. Move the obstructing screen first.")
  if not allow_disconnected and len(connected_groups(monitors, positions)) > 1:
    raise LayoutError('Every screen must touch the layout along an edge. Move the disconnected screens together before applying.')
  return {name: tuple(point) for name, point in positions.items()}


def connected_groups(monitors, positions):
  """Corner contact alone does not provide a path between screens."""
  neighbors = {m['name']: set() for m in monitors}
  for a, b in itertools.combinations(monitors, 2):
    ax, ay = positions[a['name']]
    bx, by = positions[b['name']]
    aw, ah = logical_size(a)
    bw, bh = logical_size(b)
    if ((ax + aw == bx or bx + bw == ax) and max(ay, by) < min(ay + ah, by + bh)
        or (ay + ah == by or by + bh == ay) and max(ax, bx) < min(ax + aw, bx + bw)):
      neighbors[a['name']].add(b['name'])
      neighbors[b['name']].add(a['name'])
  remaining = set(neighbors)
  groups = []
  while remaining:
    pending = [remaining.pop()]
    group = set(pending)
    while pending:
      for name in neighbors[pending.pop()] & remaining:
        remaining.remove(name)
        group.add(name)
        pending.append(name)
    groups.append(group)
  return groups


def monitor_rules(contents):
  """Locate literal, top-level hl.monitor tables without matching comments/strings.

  Lua remains user-authored code. Reject dynamic declarations instead of guessing
  which branch, helper or variable provides a monitor's settings.
  """
  tokens = [m for m in TOKEN.finditer(contents) if not m[0].startswith('--')]
  rules = []
  blocks = 0
  i = 0
  while i < len(tokens):
    value = tokens[i][0]
    if value in ('function', 'if', 'do', 'repeat'):
      blocks += 1
    elif value in ('end', 'until'):
      blocks -= 1
    if [m[0] for m in tokens[i:i + 4]] != ['hl', '.', 'monitor', '(']:
      i += 1
      continue
    line_start = contents.rfind('\n', 0, tokens[i].start()) + 1
    if contents[line_start:tokens[i].start()].strip() or (i and tokens[i - 1][0] in ('=', '(', ',', '{', '+', '-', '*', '/', '^', '%', '#', '.', 'and', 'or', 'not', 'return')):
      raise RuntimeError('Monitor rules must be standalone statements in monitors.lua.')
    if blocks or i + 4 >= len(tokens) or tokens[i + 4][0] != '{':
      raise RuntimeError('Arrange screens manually in monitors.lua when monitor rules use helpers or conditional code.')
    start = i + 4
    depth = 1
    end = start + 1
    while end < len(tokens) and depth:
      if tokens[end][0] == '{':
        depth += 1
      elif tokens[end][0] == '}':
        depth -= 1
      end += 1
    if depth or end >= len(tokens) or tokens[end][0] != ')':
      raise RuntimeError('Cannot safely read a monitor table in monitors.lua.')
    line_end = contents.find('\n', tokens[end].end())
    trailing = contents[tokens[end].end():line_end if line_end >= 0 else len(contents)].strip()
    if trailing and not trailing.startswith(('--', ';')):
      raise RuntimeError('Monitor rules must be standalone statements in monitors.lua.')
    closing = tokens[end - 1].start()
    fields = {}
    j = start + 1
    while j < end - 1:
      if tokens[j][0] in (',', ';'):
        j += 1
        continue
      if j + 2 >= end - 1 or not re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*', tokens[j][0]) or tokens[j + 1][0] != '=':
        raise RuntimeError('Monitor tables must use named fields in monitors.lua.')
      key = tokens[j][0]
      first = j + 2
      j = first
      nesting = []
      while j < end - 1:
        token = tokens[j][0]
        if not nesting and token in (',', ';'):
          break
        if token in ('{', '(', '['):
          nesting.append(token)
        elif token in ('}', ')', ']'):
          if not nesting:
            raise RuntimeError('Cannot safely read a monitor field.')
          nesting.pop()
        j += 1
      if first == j or key in fields:
        raise RuntimeError('Empty or duplicate monitor field in monitors.lua.')
      fields[key] = (tokens[first].start(), tokens[j - 1].end())
    if 'output' not in fields:
      raise RuntimeError('Monitor rule has no output field.')
    a, b = fields['output']
    literal = contents[a:b]
    if not re.fullmatch(r'''(?:"[^"\\]*"|'[^'\\]*')''', literal):
      raise RuntimeError('Monitor output names must be literal strings in monitors.lua.')
    rules.append((literal[1:-1], tokens[start].start(), closing, fields, tokens[end].end()))
    i = end + 1
  return rules


def set_fields(contents, rule, values):
  _, start, closing, fields = rule[:4]
  edits = []
  missing = []
  for key, value in values.items():
    if key in fields:
      a, b = fields[key]
      edits.append((a, b, value))
    else:
      missing.append(f'{key} = {value}')
  if missing:
    # A semicolon is also a valid Lua table separator. Ignore trailing comments.
    body_tokens = [m[0] for m in TOKEN.finditer(contents[start + 1:closing]) if not m[0].startswith('--')]
    separator = '' if not body_tokens or body_tokens[-1] in (',', ';') else ','
    edits.append((closing, closing, '\n' + separator + '  ' + ', '.join(missing) + '\n'))
  table = contents[start:closing + 1]
  for a, b, value in sorted(edits, reverse=True):
    table = table[:a - start] + value + table[b - start:]
  return table


def copyable_value(tokens):
  """Only copy scalar references/literals and tables; never re-run computations."""
  def value(index):
    if index >= len(tokens):
      return None
    token = tokens[index]
    if token == '{':
      index += 1
      while index < len(tokens) and tokens[index] != '}':
        if index + 1 < len(tokens) and re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*', tokens[index]) and tokens[index + 1] == '=':
          index += 2
        index = value(index)
        if index is None or index >= len(tokens):
          return None
        if tokens[index] in (',', ';'):
          index += 1
        elif tokens[index] != '}':
          return None
      return index + 1 if index < len(tokens) else None
    if token.startswith(('"', "'", '[')) or re.fullmatch(r'-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?', token):
      return index + 1
    if re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*', token) and token not in ('function', 'if', 'then', 'else', 'end', 'do', 'for', 'while', 'repeat', 'until', 'and', 'or', 'not', 'return'):
      return index + 1
    return None
  return value(0) == len(tokens)


def update_config(contents, monitors, positions):
  rules = monitor_rules(contents)
  edits = []
  additions = {}
  for monitor in monitors:
    name = monitor['name']
    position = json.dumps('%dx%d' % positions[name])
    exact = [r for r in rules if r[0] == name]
    if exact:
      rule = exact[-1]
      edits.append((rule[1], rule[2] + 1, set_fields(contents, rule, {'position': position})))
      continue
    descriptions = [r for r in rules if r[0].startswith('desc:') and monitor.get('description', '').startswith(r[0][5:])]
    if len({r[0] for r in descriptions}) > 1:
      raise RuntimeError(f'Ambiguous description rules for {name}; add an explicit output rule first.')
    templates = descriptions or [r for r in rules if r[0] == '']
    if not templates:
      raise RuntimeError(f'Add an explicit or fallback hl.monitor rule for {name} in monitors.lua first.')
    # Insert copies beside their source so locals retain their value and scope.
    # Calls/indexing/operators could have side effects when evaluated twice.
    for rule in templates:
      for field, (start, end) in rule[3].items():
        if field in ('output', 'position'):
          continue
        value_tokens = [m[0] for m in TOKEN.finditer(contents[start:end]) if not m[0].startswith('--')]
        if not copyable_value(value_tokens):
          raise RuntimeError(f'Cannot copy computed {field} settings for {name}; add an explicit output rule first.')
      table = set_fields(contents, rule, {'output': json.dumps(name), 'position': position})
      additions.setdefault(rule[4], []).append('\n-- Position saved by omarchy hyprland monitor position.\nhl.monitor(' + table + ')')
  updated = contents
  edits.extend((offset, offset, ''.join(copies)) for offset, copies in additions.items())
  for start, end, table in sorted(edits, reverse=True):
    updated = updated[:start] + table + updated[end:]
  return updated


def atomic_write(path, contents):
  temp_path = None
  try:
    with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', dir=path.parent, delete=False) as temp:
      temp_path = Path(temp.name)
      temp.write(contents)
      temp.flush()
      os.fsync(temp.fileno())
    temp_path.chmod(path.stat().st_mode & 0o777 if path.exists() else 0o600)
    temp_path.replace(path)
  finally:
    if temp_path is not None and temp_path.exists():
      temp_path.unlink()


def publish_config(path, contents, expected):
  """Retain the displaced file so an editor racing publication is detectable."""
  if path.is_symlink() or not path.is_file() or path.read_text() != expected:
    raise RuntimeError('The monitor configuration changed before saving. Try again.')
  with tempfile.NamedTemporaryFile(dir=path.parent, prefix='.monitor-position-conflict-', delete=False) as temp:
    replacement = Path(temp.name)
  retain = False
  try:
    atomic_write(replacement, contents)
    replacement.chmod(path.stat().st_mode & 0o777)
    candidate = replacement.stat()
    retain = True
    try:
      exchange_config(replacement, path)
    except (OSError, RuntimeError, subprocess.SubprocessError) as error:
      raise RuntimeError(f'{error}\nFile exchange could not be verified. Versions were retained at {path} and {replacement}.') from error
    try:
      changed = replacement.is_symlink() or not replacement.is_file() or replacement.read_text() != expected
    except (OSError, UnicodeError):
      changed = True
    if changed:
      # A later external writer may already own path. Do not replace that file.
      try:
        current = path.lstat()
        if (current.st_dev, current.st_ino) == (candidate.st_dev, candidate.st_ino) and path.read_text() == contents:
          exchange_config(replacement, path)
      except (OSError, UnicodeError, RuntimeError, subprocess.SubprocessError) as error:
        raise RuntimeError(f'{error}\nConcurrent edit recovery could not be verified. Versions were retained at {path} and {replacement}.') from error
      raise RuntimeError(f'Concurrent monitors.lua edit. File versions were retained at {path} and {replacement}.')
    retain = False
  finally:
    if not retain:
      replacement.unlink(missing_ok=True)


def exchange_config(replacement, path):
  result = subprocess.run(['mv', '--exchange', '--no-copy', '-T', str(replacement), str(path)],
                          capture_output=True, text=True, timeout=12)
  if result.returncode:
    raise RuntimeError(result.stderr.strip() or 'Cannot safely publish the monitor configuration.')


def snapshot(monitors):
  return sorted((m['name'], m['x'], m['y'], m['width'], m['height'], m['scale'], m.get('transform', 0)) for m in monitors)


def wait_layout(monitors, positions):
  expected = sorted((m['name'], *positions[m['name']], m['width'], m['height'], m['scale'], m.get('transform', 0)) for m in monitors)
  for attempt in range(30):
    errors = hypr('configerrors')
    if errors:
      raise RuntimeError(errors)
    if snapshot(displays()) == expected:
      return
    time.sleep(0.1)
  raise RuntimeError('Hyprland did not apply the requested layout, or the connected screens changed.')


def restore_layout(monitors):
  # Runtime scaling can move outputs without persisting their positions to Lua.
  # Restore the captured live rules after reloading the original file.
  rules = []
  for monitor in monitors:
    mode = f'{monitor["width"]}x{monitor["height"]}'
    if monitor.get('refreshRate'):
      mode += f'@{monitor["refreshRate"]}'
    fields = dict(output=monitor['name'], mode=mode,
                  position=f'{monitor["x"]}x{monitor["y"]}', scale=monitor['scale'],
                  transform=monitor.get('transform', 0))
    rules.append('hl.monitor({' + ', '.join(f'{key}={json.dumps(value)}' for key, value in fields.items()) + '})')
  hypr('eval', '\n'.join(rules))
  wait_layout(monitors, {m['name']: (m['x'], m['y']) for m in monitors})


def apply(output=None, reference=None, side=None, dry_run=False, expected_snapshot=None, alignment=None, positions=None, confirmation=None):
  config = (Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config')) / 'hypr/monitors.lua').resolve(strict=True)
  # Lock a separate inode because atomic replacement changes the config inode.
  state = Path(os.environ.get('XDG_STATE_HOME', Path.home() / '.local/state')) / 'omarchy'
  state.mkdir(parents=True, exist_ok=True)
  with (state / 'monitor-config.lock').open('a') as lock:
    try:
      fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError as error:
      raise RuntimeError('Another monitor arrangement is in progress.') from error
    monitors = displays()
    if expected_snapshot is not None and snapshot(monitors) != expected_snapshot:
      raise RuntimeError('The screens changed since the preview. Refresh screens and choose the position again.')
    positions = validate_positions(monitors, positions) if positions is not None else arrange(monitors, output, reference, side, alignment)
    original = config.read_text()
    updated = update_config(original, monitors, positions)
    if dry_run:
      print(json.dumps(positions, indent=2))
      return
    errors = hypr('configerrors')
    if errors:
      raise RuntimeError('Fix the existing Hyprland configuration errors first:\n' + errors)
    if snapshot(displays()) != snapshot(monitors) or config.read_text() != original:
      raise RuntimeError('The screens or configuration changed. Try again.')
    if updated == original and all(positions[m['name']] == (m['x'], m['y']) for m in monitors):
      return
    atomic_write(config.with_name('monitors.lua.bak.monitor-position'), original)
    if config.read_text() != original:
      raise RuntimeError('The configuration changed while creating its backup. Try again.')
    publish_config(config, updated, original)
    restored = False
    try:
      hypr('reload')
      wait_layout(monitors, positions)
      if confirmation:
        status_path, decision_path = confirmation
        deadline = time.time() + 20
        stop = time.monotonic() + 20
        atomic_write(status_path, json.dumps({'status': 'confirming', 'deadline': deadline}))
        keep = False
        while time.monotonic() < stop:
          if decision_path.exists():
            keep = decision_path.read_text() == 'keep'
            break
          time.sleep(0.1)
        if config.read_text() != updated:
          raise RuntimeError('Configuration changed during confirmation; restore monitors.lua.bak.monitor-position manually.')
        if keep:
          wait_layout(monitors, positions)
        else:
          publish_config(config, original, updated)
          restored = True
          hypr('reload')
          restore_layout(monitors)
          return False
    except Exception as error:
      if config.read_text() != (original if restored else updated):
        raise RuntimeError(f'{error}\nConfiguration changed during apply; restore monitors.lua.bak.monitor-position manually.') from error
      publish_config(config, original, original if restored else updated)
      try:
        hypr('reload')
        restore_layout(monitors)
      except Exception as rollback_error:
        raise RuntimeError(f'{error}\nPrevious configuration restored, but its layout could not be verified: {rollback_error}') from error
      raise RuntimeError(f'{error}\nThe previous configuration and layout were restored.') from error
    return True


def layout_state(monitors, positions=None):
  layout = []
  names = sorted((m['name'] for m in monitors), key=lambda name: (not re.match(r'^(eDP|LVDS|DSI)', name), name))
  numbers = {name: number for number, name in enumerate(names, 1)}
  for monitor in monitors:
    width, height = logical_size(monitor)
    x, y = positions[monitor['name']] if positions else (monitor['x'], monitor['y'])
    label = 'Built-in display' if re.match(r'^(eDP|LVDS|DSI)', monitor['name']) else (monitor.get('model') or monitor.get('description') or monitor['name'])
    layout.append(dict(name=monitor['name'], label=label, number=numbers[monitor['name']], x=x, y=y, logicalWidth=width, logicalHeight=height))
  connected = len(connected_groups(monitors, positions or {m['name']: (m['x'], m['y']) for m in monitors})) <= 1
  return {'monitors': layout, 'snapshot': snapshot(monitors), 'connected': connected}


def trial_paths(token):
  if not isinstance(token, str) or not re.fullmatch(r'[a-f0-9]{32}', token):
    raise RuntimeError('Invalid layout confirmation token.')
  directory = Path(os.environ.get('XDG_STATE_HOME', Path.home() / '.local/state')) / 'omarchy/monitor-position'
  directory.mkdir(parents=True, exist_ok=True, mode=0o700)
  return directory / (token + '.json'), directory / (token + '.decision')


def trial_request(request):
  token = request.get('token') or uuid.uuid4().hex
  status_path, decision_path = trial_paths(token)
  if request.get('worker'):
    try:
      result = panel_request(dict(request, action='apply', confirmation=(status_path, decision_path)))
      atomic_write(status_path, json.dumps({'status': 'kept' if result['kept'] else 'reverted', 'message': result['message']}))
    except Exception as error:
      atomic_write(status_path, json.dumps({'status': 'error', 'message': str(error)}))
    finally:
      decision_path.unlink(missing_ok=True)
    return {}
  # Terminal records may outlive a closed panel. Only prune our own expired files.
  for path in status_path.parent.glob('*.json'):
    if re.fullmatch(r'[a-f0-9]{32}\.json', path.name) and time.time() - path.stat().st_mtime > 86400:
      path.unlink(missing_ok=True)
      path.with_suffix('.decision').unlink(missing_ok=True)
  atomic_write(status_path, json.dumps({'status': 'applying'}))
  try:
    subprocess.Popen([sys.executable, __file__, '--request', json.dumps(dict(request, token=token, worker=True))],
                     stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
  except OSError:
    status_path.unlink(missing_ok=True)
    raise
  return {'token': token, 'statePath': str(status_path)}


def panel_request(request):
  """JSON boundary for the Display panel; preview never writes configuration."""
  if not isinstance(request, dict):
    raise RuntimeError('Expected a monitor arrangement request.')
  action = request.get('action')
  if action == 'trial':
    return trial_request(request)
  if action in ('keep', 'revert', 'dismiss'):
    status_path, decision_path = trial_paths(request.get('token'))
    status = json.loads(status_path.read_text())
    if action == 'dismiss':
      if status['status'] in ('kept', 'reverted', 'error'):
        status_path.unlink(missing_ok=True)
      return {}
    if status['status'] != 'confirming' or time.time() >= status['deadline']:
      raise RuntimeError('This layout confirmation has already ended.')
    atomic_write(decision_path, action)
    return {}
  if action == 'state':
    return layout_state(displays())
  if action not in ('preview', 'apply'):
    raise RuntimeError('Unknown monitor arrangement action.')
  output, reference, side = (request.get(key) for key in ('output', 'reference', 'side'))
  positions = request.get('positions')
  if positions is None and (not isinstance(output, str) or not isinstance(reference, str) or side not in SIDES):
    raise RuntimeError('Choose two screens and a valid position.')
  expected = request.get('snapshot')
  if not isinstance(expected, list) or any(
    not isinstance(row, (list, tuple)) or len(row) != 7 or not isinstance(row[0], str)
    or any(not isinstance(value, (int, float)) or isinstance(value, bool) or not math.isfinite(value) for value in row[1:])
    for row in expected
  ):
    raise RuntimeError('A valid preview snapshot is required. Refresh screens first.')
  expected = sorted(tuple(row) for row in expected)
  alignment = request.get('alignment')
  if action == 'apply':
    kept = apply(output, reference, side, expected_snapshot=expected, alignment=alignment, positions=positions, confirmation=request.get('confirmation'))
    if positions is not None:
      return {'kept': kept is not False, 'message': 'Layout saved for next time.' if kept is not False else 'Previous layout restored.'}
    alignment = alignment or ('top' if side in ('left', 'right') else 'left')
    return {'kept': kept is not False, 'message': f'{output} is {side} of {reference}, aligned {alignment}. Saved for next time.' if kept is not False else 'Previous layout restored.'}
  monitors = displays()
  if snapshot(monitors) != expected:
    raise RuntimeError('The screens changed since the preview. Refresh screens and choose the position again.')
  # A disconnected draft can take several moves to repair. Only Apply requires
  # one connected group; preview still rejects overlap and invalid coordinates.
  return layout_state(monitors, validate_positions(monitors, positions, allow_disconnected=True) if positions is not None
                      else arrange(monitors, output, reference, side, alignment, allow_disconnected=True))


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument('output', nargs='?')
  parser.add_argument('reference', nargs='?')
  parser.add_argument('side', nargs='?', choices=SIDES)
  parser.add_argument('--list', action='store_true')
  parser.add_argument('--dry-run', action='store_true')
  parser.add_argument('--align', choices=('top', 'center', 'bottom', 'left', 'right'))
  parser.add_argument('--request', help=argparse.SUPPRESS)
  parser.add_argument('--request-worker', action='store_true', help=argparse.SUPPRESS)
  args = parser.parse_args()
  try:
    if args.request is not None:
      request = json.loads(args.request)
      if isinstance(request, dict) and request.get('action') == 'apply' and not args.request_worker:
        # A per-screen panel can disappear on hotplug or shell reload. Its
        # Process owns this waiter, but must not kill a save/rollback transaction.
        result = subprocess.run([sys.executable, __file__, '--request', args.request, '--request-worker'],
                                capture_output=True, text=True, start_new_session=True)
        sys.stdout.write(result.stdout)
        sys.stderr.write(result.stderr)
        return result.returncode
      print(json.dumps(panel_request(request)))
    elif args.list:
      print(json.dumps(displays()))
    elif args.output and args.reference and args.side:
      apply(args.output, args.reference, args.side, args.dry_run, alignment=args.align)
      if not args.dry_run:
        print(f'{args.output} is {args.side} of {args.reference}. Saved for next time.')
    else:
      parser.error('provide OUTPUT REFERENCE SIDE, or --list')
  except (RuntimeError, OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
    detail = json.dumps({'message': str(error), 'code': 'invalid-layout' if isinstance(error, LayoutError) else 'request-failed'}) if args.request is not None else str(error)
    print(detail, file=sys.stderr)
    return 1
  return 0


if __name__ == '__main__':
  sys.exit(main())
