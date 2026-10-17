"""Plan scale/mode changes from the old logical rectangles before touching Hyprland.

Uses the shared-edge idea from PR #11854, but propagates sizes through neighbours
and keeps edge/centre alignment rather than only moving the resized output.
"""

import itertools
import json
import math
import os
from pathlib import Path
import re
import shutil
import time
import subprocess
import sys
import tempfile


def rounded(value):
  return math.floor(value + 0.5)


def active(monitor):
  return not monitor.get("disabled", False) and monitor.get("mirrorOf", "none") in ("none", "", None)


def rect(monitor):
  width, height = monitor["width"], monitor["height"]
  if monitor.get("transform", 0) % 2:
    width, height = height, width
  return (monitor.get("x", 0), monitor.get("y", 0),
          rounded(width / monitor["scale"]), rounded(height / monitor["scale"]))


def overlap(a, b):
  return all(min(a[i] + a[i + 2], b[i] + b[i + 2]) > max(a[i], b[i]) for i in (0, 1))


def relation(a, b):
  """Direction, gap and cross-axis alignment of b relative to a."""
  candidates = []
  for axis in (0, 1):
    cross = 1 - axis
    shared = min(a[cross] + a[cross + 2], b[cross] + b[cross + 2]) - max(a[cross], b[cross])
    for direction in (1, -1):
      gap = (b[axis] - a[axis] - a[axis + 2] if direction == 1
             else a[axis] - b[axis] - b[axis + 2])
      if gap >= -1:
        # Prefer touching edges with positive shared length, then nearest edges.
        rank = (0 if abs(gap) <= 1 and shared > 0 else 1, max(0, gap), -shared, axis)
        # Equal-size outputs make both edges indistinguishable. Prefer
        # right alignment for stacked screens, top for side-by-side screens.
        alignment = min((1, 0.5, 0) if axis == 1 else (0, 0.5, 1), key=lambda factor: abs(
          b[cross] + factor * b[cross + 2] - a[cross] - factor * a[cross + 2]))
        offset = b[cross] + alignment * b[cross + 2] - a[cross] - alignment * a[cross + 2]
        candidates.append((rank, axis, direction, max(0, gap), alignment, offset))
  if not candidates:
    raise ValueError("Existing monitor rectangles overlap; arrange them before changing scale")
  return min(candidates)


def place(a, size, edge):
  _, axis, direction, gap, alignment, offset = edge
  cross = 1 - axis
  result = [0, 0, *size]
  result[axis] = a[axis] + a[axis + 2] + gap if direction == 1 else a[axis] - size[axis] - gap
  result[cross] = rounded(a[cross] + alignment * a[cross + 2] + offset - alignment * size[cross])
  return tuple(result)


def plan(monitors, name, scale, mode=None):
  displays = [dict(m) for m in monitors if active(m)]
  if not math.isfinite(scale) or not 1 <= scale <= 4:
    raise ValueError("Scale must be between 1 and 4")
  target = next((m for m in displays if m["name"] == name), None)
  if target is None:
    raise ValueError("Monitor is missing, disabled, or mirrored")
  for m in displays:
    if not re.fullmatch(r"[A-Za-z0-9._-]+", m["name"]):
      raise ValueError("Refusing unsafe monitor name")
    if not all(math.isfinite(m[k]) and m[k] > 0 for k in ("width", "height", "scale")):
      raise ValueError("Monitor has no valid mode or scale")
    if not all(math.isfinite(m.get(k, 0)) for k in ("x", "y")) or m.get("transform", 0) not in range(8):
      raise ValueError("Invalid monitor position or transform")
    if not isinstance(m.get("refreshRate"), (int, float)) or not math.isfinite(m["refreshRate"]) or m["refreshRate"] <= 0:
      raise ValueError("Invalid refresh rate")
  old = {m["name"]: rect(m) for m in displays}
  if mode:
    match = re.fullmatch(r"(\d+)x(\d+)@(\d+(?:\.\d+)?)", mode)
    if not match:
      raise ValueError("Mode must be WIDTHxHEIGHT@RATE")
    target["width"], target["height"] = map(int, match.groups()[:2])
    target["refreshRate"] = float(match[3])
    if min(target["width"], target["height"], target["refreshRate"]) <= 0:
      raise ValueError("Invalid mode")
  divisor = math.gcd(target["width"] * 120, target["height"] * 120)
  units = min(rounded(scale * 120), divisor)
  if units <= 0:
    raise ValueError("Invalid scale")
  while divisor % units:
    units += 1
  target["scale"] = units / 120
  sizes = {m["name"]: rect(m)[2:] for m in displays}
  # A minimum spanning tree prefers real shared edges over deliberate gaps.
  # The changed monitor anchors its component; neighbours can move on both axes.
  positions = {name: (*old[name][:2], *sizes[name])}
  while len(positions) < len(displays):
    choices = []
    for a in positions:
      for b in old.keys() - positions.keys():
        edge = relation(old[a], old[b])
        choices.append((edge[0], a, b, edge))
    _, a, b, edge = min(choices)
    positions[b] = place(positions[a], sizes[b], edge)
  # Negative coordinates are valid in Hyprland. Translate only when a resize
  # introduces a negative origin into a previously non-negative layout.
  for axis in (0, 1):
    shift = max(0, -min(p[axis] for p in positions.values())) if min(p[axis] for p in old.values()) >= 0 else 0
    if shift:
      positions = {n: tuple(v + shift if i == axis else v for i, v in enumerate(p)) for n, p in positions.items()}
  for a, b in itertools.combinations(old, 2):
    if overlap(positions[a], positions[b]):
      raise ValueError("Cannot preserve this layout without overlap; arrange monitors first")
    edge = relation(old[a], old[b])
    if edge[0][0] == 0:
      expected = place(positions[a], sizes[b], edge)
      if any(abs(expected[i] - positions[b][i]) > 1 for i in (0, 1)):
        raise ValueError("Conflicting monitor adjacency constraints; arrange monitors first")
  for m in displays:
    m["x"], m["y"] = positions[m["name"]][:2]
  return displays


# Token offsets let us change top-level fields without reformatting Lua, eating
# comments, or mistaking a commented/example/nested rule for an active rule.
TOKEN = re.compile(r'''--\[(=*)\[.*?\]\1\]|--[^\n]*|\[(=*)\[.*?\]\2\]|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|[A-Za-z_][\w]*|\d+(?:\.\d+)?|[^\s]''', re.S)


def tokens(text):
  return [(m.group(), m.start(), m.end()) for m in TOKEN.finditer(text) if not m.group().startswith("--")]


def fields(ts, start):
  depth = 0
  found = {}
  i = start + 1
  while i < len(ts):
    value = ts[i][0]
    if value == "}" and depth == 0:
      return found, i
    if depth == 0 and i + 1 < len(ts) and ts[i + 1][0] == "=":
      key, begin = value, i + 2
      j, nested = begin, 0
      while j < len(ts):
        token = ts[j][0]
        if nested == 0 and token in (",", ";", "}"):
          break
        if token in ("{", "(", "["):
          nested += 1
        elif token in ("}", ")", "]"):
          nested -= 1
        j += 1
      if j == begin or j == len(ts) or nested:
        raise ValueError("Cannot parse monitor rule")
      found[key] = (ts[begin][1], ts[j - 1][2])
      i = j
      continue
    if value in ("{", "(", "["):
      depth += 1
    elif value in ("}", ")", "]"):
      depth -= 1
    i += 1
  raise ValueError("Unclosed monitor rule")


def rewrite(text, displays, name, mode=None):
  ts = tokens(text)
  rules = []
  for i in range(len(ts) - 4):
    if [t[0] for t in ts[i:i + 5]] == ["hl", ".", "monitor", "(", "{"]:
      keys, end = fields(ts, i + 4)
      rules.append((keys, ts[end][1]))
  edits, appended = [], []
  multiple = len(displays) > 1
  for m in displays:
    changes = {}
    if multiple:
      changes["position"] = json.dumps(f'{m["x"]}x{m["y"]}')
    if m["name"] == name:
      changes["scale"] = f'{m["scale"]:g}'
      if mode:
        changes["mode"] = json.dumps(mode)
    matches = []
    for keys, end in rules:
      if "output" not in keys:
        continue
      selector = text[slice(*keys["output"])].strip()
      if selector in (json.dumps(m["name"]), repr(m["name"])) or (m.get("description") and selector in (json.dumps("desc:" + m["description"]), repr("desc:" + m["description"]))):
        matches.append((keys, end))
    if matches:
      for keys, end in matches:
        missing = []
        for key, value in changes.items():
          if key in keys:
            edits.append((*keys[key], value))
          else:
            missing.append(f"{key} = {value}")
        if missing:
          previous = text[:end].rstrip()
          separator = " " if previous.endswith((",", ";", "{")) else ", "
          edits.append((end, end, separator + ", ".join(missing) + " "))
    elif multiple or mode:
      appended.append(f'hl.monitor({{ output = {json.dumps(m["name"])}, mode = {json.dumps(mode if m["name"] == name and mode else "preferred")}, position = "{m["x"]}x{m["y"]}", scale = {m["scale"]:g}, transform = {m.get("transform", 0)} }})')
    else:
      # Keep the existing single-monitor catch-all convention and GDK rounding.
      for i in range(len(ts) - 3):
        if [t[0] for t in ts[i:i + 3]] == ["local", "omarchy_monitor_scale", "="]:
          edits.append((ts[i + 3][1], ts[i + 3][2], f'{m["scale"]:g}'))
        if [t[0] for t in ts[i:i + 3]] == ["local", "omarchy_gdk_scale", "="]:
          edits.append((ts[i + 3][1], ts[i + 3][2], str(rounded(m["scale"]))))
      for keys, _ in rules:
        if "output" in keys and text[slice(*keys["output"])] in ('""', "''") and "scale" in keys:
          value = text[slice(*keys["scale"])]
          if value != "omarchy_monitor_scale":
            edits.append((*keys["scale"], f'{m["scale"]:g}'))
  for start, end, value in sorted(set(edits), reverse=True):
    text = text[:start] + value + text[end:]
  if appended:
    text = text.rstrip() + "\n" + "\n".join(appended) + "\n"
  return text


def lua_rules(displays):
  return "; ".join(f'hl.monitor({{ output = {json.dumps(m["name"])}, mode = "{m["width"]}x{m["height"]}@{m["refreshRate"]}", position = "{m["x"]}x{m["y"]}", scale = {m["scale"]:g}, transform = {m.get("transform", 0)} }})' for m in displays)


def apply(monitors, name, scale, config, mode=None):
  displays = plan(monitors, name, scale, mode)
  # Resolve symlinks and replace once: the file watcher must never reload a
  # mixture of old positions and new scales. Stage before changing live state.
  path = Path(config).resolve()
  staged = None
  changed_live = False
  original = path.read_text() if path.exists() else None
  try:
    if original is not None:
      content = rewrite(original, displays, name, mode)
      fd, staged = tempfile.mkstemp(prefix=".monitors-", dir=path.parent)
      with os.fdopen(fd, "w") as handle:
        handle.write(content)
      shutil.copystat(path, staged)
      attributes = path.stat()
      os.chown(staged, attributes.st_uid, attributes.st_gid)
    changed_live = True
    result = subprocess.run(["hyprctl", "eval", lua_rules(displays)], capture_output=True, text=True)
    if result.returncode or result.stdout.strip() not in ("", "ok"):
      raise ValueError("Hyprland rejected layout: " + result.stdout.strip() + result.stderr.strip())
    # A successful eval can still snap an unavailable mode/scale. Never save
    # geometry computed for a rectangle the compositor did not actually use.
    for attempt in range(10):
      readback = subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True, check=True)
      actual = {m["name"]: m for m in json.loads(readback.stdout) if active(m)}
      if all(m["name"] in actual and rect(actual[m["name"]]) == rect(m)
             and abs(actual[m["name"]]["scale"] - m["scale"]) < 0.0001
             and actual[m["name"]].get("transform", 0) == m.get("transform", 0)
             and abs(actual[m["name"]]["refreshRate"] - m["refreshRate"]) < 1
             for m in displays):
        break
      time.sleep(0.05)
    else:
      raise ValueError("Compositor geometry differs from requested layout")
    if staged:
      if path.read_text() != original:
        raise ValueError("Monitor config changed concurrently; retry")
      os.replace(staged, path)
      staged = None
  except Exception:
    if changed_live:
      rollback = subprocess.run(["hyprctl", "eval", lua_rules([m for m in monitors if active(m)])], capture_output=True, text=True)
      if rollback.returncode or rollback.stdout.strip() not in ("", "ok"):
        print("Warning: could not restore the old live layout", file=sys.stderr)
    raise
  finally:
    if staged:
      os.unlink(staged)
  return next(m["scale"] for m in displays if m["name"] == name)


if __name__ == "__main__":
  try:
    print(f'{apply(json.load(sys.stdin), sys.argv[1], float(sys.argv[2]), sys.argv[3], sys.argv[4] if len(sys.argv) > 4 and sys.argv[4] else None):g}')
  except (ValueError, KeyError, OSError, TypeError, subprocess.SubprocessError) as error:
    print(f"Monitor layout change failed: {error}", file=sys.stderr)
    sys.exit(1)
