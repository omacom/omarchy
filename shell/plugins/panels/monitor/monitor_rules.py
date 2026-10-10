"""Pure monitor configuration planning; no I/O or compositor access."""
import json
import math
import re

def quote(value):
  return json.dumps(value, ensure_ascii=False)


# A deliberately narrow grammar for flat monitor tables. String contents are
# tokenized, never searched as field names. Unsupported Lua is left untouched.
RULE = re.compile(r'^([ \t]*hl\.monitor\(\{)([^\n]*)(\}\)[ \t]*(?:--[^\n]*)?)$', re.M)
FIELD = re.compile(r'\s*([A-Za-z_]\w*)\s*=\s*("(?:[^"\\]|\\.)*"|[+-]?[0-9]+(?:\.[0-9]+)?|[A-Za-z_]\w*)\s*(,|$)')


def parse_fields(body):
  fields = {}
  position = 0
  while body[position:].strip():
    match = FIELD.match(body, position)
    if not match or match[1] in fields:
      raise ValueError('Unsupported or duplicate monitor field')
    fields[match[1]] = (match[2], match.start(2), match.end(2))
    position = match.end()
  return fields


def update_rule(source, monitor, fields):
  candidates = []
  for match in RULE.finditer(source):
    try:
      parsed = parse_fields(match[2])
      selector = json.loads(parsed['output'][0])
    except (ValueError, KeyError):
      continue
    if selector in (monitor['name'], 'desc:' + monitor.get('description', '')):
      candidates.append((match, parsed))
  if not candidates:
    raise ValueError('No supported simple monitor rule for ' + monitor['name'])
  if len(candidates) != 1:
    raise ValueError('Multiple monitor rules match ' + monitor['name'] + '; resolve them first')
  match, parsed = candidates[0]
  body = match[2]
  edits = [(parsed[key][1], parsed[key][2], value) for key, value in fields.items() if key in parsed]
  for start, end, value in sorted(edits, reverse=True):
    body = body[:start] + value + body[end:]
  for key, value in fields.items():
    if key not in parsed:
      body = body.rstrip().rstrip(',') + ', ' + key + ' = ' + value + ' '
  return source[:match.start()] + match[1] + body + match[3] + source[match.end():]


def logical_width(monitor, transform=None):
  transform = monitor['transform'] if transform is None else transform
  return round(monitor['height' if transform % 2 else 'width'] / monitor['scale'])


def plan(source, monitors, name, transform, scale=None):
  if isinstance(transform, bool) or transform not in range(8):
    raise ValueError('Invalid display transform')
  selected = next((m for m in monitors if m['name'] == name and not m.get('disabled')), None)
  if selected is None:
    raise ValueError('Display is no longer connected: ' + name)
  if selected.get('mirrorOf', 'none') not in ('none', ''):
    raise ValueError('Disable mirroring before changing orientation')
  if sum(m.get('description') == selected.get('description') for m in monitors) > 1:
    raise ValueError('Ambiguous display identity; use a unique monitor rule')
  if any(m.get('mirrorOf') == name for m in monitors):
    raise ValueError('Disable mirroring before changing the source display')
  fields = {'transform': str(transform)}
  expected = {name: {'transform': transform}}
  new_scale = selected['scale']
  if scale is not None:
    if not math.isfinite(scale) or not 1 <= scale <= 4:
      raise ValueError('Scale must be between 1 and 4')
    divisor = math.gcd(selected['width'] * 120, selected['height'] * 120)
    units = min(divisor, math.floor(scale * 120 + 0.5))
    while divisor % units:
      units += 1
    new_scale = units / 120
    fields['scale'] = str(new_scale)
    expected[name]['scale'] = new_scale
  updated = update_rule(source, selected, fields)
  # Keep a contiguous, top-aligned row touching after its panel width changes.
  # Other layouts remain unchanged unless resizing would introduce overlap.
  resized = dict(selected, scale=new_scale)
  delta = logical_width(resized, transform) - logical_width(selected)
  edge = selected['x'] + logical_width(selected)
  if delta:
    for other in sorted(monitors, key=lambda m: m['x']):
      if other['name'] == name or other.get('disabled') or other['y'] != selected['y']:
        continue
      if other['x'] == edge:
        new_x = other['x'] + delta
        updated = update_rule(updated, other, {'position': quote(f"{new_x}x{other['y']}")})
        expected[other['name']] = {'x': new_x, 'y': other['y']}
        edge += logical_width(other)
  proposed = [dict(m, **expected.get(m['name'], {})) for m in monitors if not m.get('disabled')]
  def overlaps(a, b):
    aw, bw = logical_width(a), logical_width(b)
    ah = round(a['width' if a['transform'] % 2 else 'height'] / a['scale'])
    bh = round(b['width' if b['transform'] % 2 else 'height'] / b['scale'])
    return a['x'] < b['x'] + bw and b['x'] < a['x'] + aw and a['y'] < b['y'] + bh and b['y'] < a['y'] + ah
  previous = {m['name']: m for m in monitors}
  for i, first in enumerate(proposed):
    for second in proposed[i + 1:]:
      if overlaps(first, second) and not overlaps(previous[first['name']], previous[second['name']]):
        raise ValueError('This change would overlap another display; adjust the display layout first')
  return updated, expected
