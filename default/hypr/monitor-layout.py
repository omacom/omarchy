"""Pure geometry shared by display settings and focused-monitor scaling."""
import copy
import json
import math
import re
import sys


def size(display):
  width, height = map(int, display['mode'].split('@')[0].split('x'))
  dimensions = (math.floor(width / display['scale'] + 0.5), math.floor(height / display['scale'] + 0.5))
  return dimensions[::-1] if display['transform'] % 2 else dimensions


def relation(a, b):
  """Nearest facing edges with positive overlap on the other axis."""
  aw, ah = size(a)
  bw, bh = size(b)
  if min(a['y'] + ah, b['y'] + bh) > max(a['y'], b['y']):
    if a['x'] + aw <= b['x']:
      return 'right', b['x'] - a['x'] - aw
    if b['x'] + bw <= a['x']:
      return 'left', a['x'] - b['x'] - bw
  if min(a['x'] + aw, b['x'] + bw) > max(a['x'], b['x']):
    if a['y'] + ah <= b['y']:
      return 'below', b['y'] - a['y'] - ah
    if b['y'] + bh <= a['y']:
      return 'above', a['y'] - b['y'] - bh
  return None


def aligned(origin_a, length_a, origin_b, length_b, new_a, new_length_a, new_length_b):
  if origin_a == origin_b:
    return new_a
  if origin_a + length_a == origin_b + length_b:
    return new_a + new_length_a - new_length_b
  if origin_a * 2 + length_a == origin_b * 2 + length_b:
    return math.floor(new_a + (new_length_a - new_length_b) / 2 + 0.5)
  return new_a + origin_b - origin_a


def place(a, b, new_a, new_b, edge):
  side, gap = edge
  aw, ah = size(a)
  bw, bh = size(b)
  nw, nh = size(new_a)
  mw, mh = size(new_b)
  if side in ('left', 'right'):
    x = new_a['x'] + nw + gap if side == 'right' else new_a['x'] - mw - gap
    y = aligned(a['y'], ah, b['y'], bh, new_a['y'], nh, mh)
  else:
    y = new_a['y'] + nh + gap if side == 'below' else new_a['y'] - mh - gap
    x = aligned(a['x'], aw, b['x'], bw, new_a['x'], nw, mw)
  return x, y


def overlaps(a, b):
  aw, ah = size(a)
  bw, bh = size(b)
  return min(a['x'] + aw, b['x'] + bw) > max(a['x'], b['x']) and min(a['y'] + ah, b['y'] + bh) > max(a['y'], b['y'])


def resize(request, name, key, value):
  result = copy.deepcopy(request)
  old = {d['name']: d for d in request['displays']}
  new = {d['name']: d for d in result['displays']}
  if name not in old or key not in ('scale', 'mode', 'transform'):
    raise ValueError('Invalid display resize')
  if key == 'mode':
    if not re.fullmatch(r'[1-9][0-9]*x[1-9][0-9]*@[0-9]+(?:\.[0-9]+)?', value):
      raise ValueError('Invalid display mode')
    new[name][key] = value
  else:
    number = float(value)
    if not math.isfinite(number) or (key == 'scale' and not 1 <= number <= 4) or (key == 'transform' and (not number.is_integer() or not 0 <= number <= 3)):
      raise ValueError('Invalid display resize value')
    new[name][key] = number
  # Hyprland accepts scales in 1/120 steps dividing both physical dimensions.
  width, height = map(int, new[name]['mode'].split('@')[0].split('x'))
  divisor = math.gcd(width * 120, height * 120)
  units = min(divisor, math.floor(new[name]['scale'] * 120 + 0.5))
  while divisor % units:
    units += 1
  new[name]['scale'] = units / 120
  if size(old[name]) == size(new[name]):
    return result

  # Minimum-gap spanning forest avoids using distant monitors as references.
  # Stable laptop/origin anchor; disconnected components keep their coordinates.
  names = sorted(old)
  edges = []
  for i, a in enumerate(names):
    for b in names[i + 1:]:
      edge = relation(old[a], old[b])
      if edge:
        edges.append((edge[1], a, b))
  parents = {n: n for n in names}
  def component(n):
    while parents[n] != n:
      n = parents[n]
    return n
  graph = {n: [] for n in names}
  for _, a, b in sorted(edges):
    ca, cb = component(a), component(b)
    if ca != cb:
      parents[cb] = ca
      graph[a].append(b)
      graph[b].append(a)
  anchors = sorted(names, key=lambda n: (not n.startswith('eDP-'), abs(old[n]['x']) + abs(old[n]['y']), n))
  visited = set()
  for anchor in anchors:
    if anchor in visited:
      continue
    visited.add(anchor)
    queue = [anchor]
    for a in queue:
      for b in graph[a]:
        if b in visited:
          continue
        new[b]['x'], new[b]['y'] = place(old[a], old[b], new[a], new[b], relation(old[a], old[b]))
        visited.add(b)
        queue.append(b)
  # A cycle can be overconstrained after resize. Do not silently break another
  # touching edge or introduce overlaps: ask for explicit arrangement instead.
  for i, a in enumerate(names):
    for b in names[i + 1:]:
      edge = relation(old[a], old[b])
      if edge and edge[1] == 0:
        if relation(new[a], new[b]) != edge or (new[b]['x'], new[b]['y']) != place(old[a], old[b], new[a], new[b], edge):
          raise ValueError('Cannot preserve all touching edges; adjust Arrangement first')
      if overlaps(new[a], new[b]) and not overlaps(old[a], old[b]):
        raise ValueError('Resize would overlap displays; adjust Arrangement first')
  if any(not -32768 <= d[k] <= 32768 for d in new.values() for k in ('x', 'y')):
    raise ValueError('Resize exceeds display coordinate limits')
  return result


if __name__ == '__main__':
  try:
    print(json.dumps(resize(json.load(sys.stdin), *sys.argv[1:])))
  except (ValueError, KeyError, TypeError, ZeroDivisionError) as error:
    print(str(error), file=sys.stderr)
    sys.exit(1)
