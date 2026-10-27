"""Plan scale/mode changes from the old logical rectangles before touching Hyprland.

Uses the shared-edge idea from PR #11854, but propagates sizes through neighbours
and keeps edge/centre alignment rather than only moving the resized output.
"""

from contextlib import contextmanager
import fcntl
import itertools
import json
import math
import os
from pathlib import Path
import re
import time
import subprocess
import signal
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


def lua_rules(displays):
  return "; ".join(f'hl.monitor({{ output = {json.dumps(m["name"])}, mode = "{m["width"]}x{m["height"]}@{m["refreshRate"]}", position = "{m["x"]}x{m["y"]}", scale = {m["scale"]:g}, transform = {m.get("transform", 0)} }})' for m in displays)


IPC_TIMEOUT = 10


class Terminated(Exception):
  def __init__(self, signum):
    self.signum = signum
    super().__init__(f"terminated by signal {signum}")


@contextmanager
def termination_handlers():
  def terminate(signum, frame):
    raise Terminated(signum)
  previous = {n: signal.signal(n, terminate) for n in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP)}
  try:
    yield
  finally:
    for n, handler in previous.items():
      signal.signal(n, handler)


_finishing = False


@contextmanager
def finish_cleanup():
  # Catchable signals during cleanup are deferred until all bounded recovery and
  # temporary-file operations finish. A second TERM must not cut cleanup short.
  global _finishing
  if _finishing:
    yield
    return
  _finishing = True
  pending = []
  previous = {n: signal.signal(n, lambda signum, frame: pending.append(signum))
              for n in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP)}
  try:
    yield
  finally:
    for n, handler in previous.items():
      signal.signal(n, handler)
    _finishing = False
    if pending:
      raise Terminated(pending[0])


def ipc(*args, check=False):
  return subprocess.run(["hyprctl", *args], capture_output=True, text=True,
                        check=check, timeout=IPC_TIMEOUT)


def hypr_eval(code):
  result = ipc("eval", code)
  if result.returncode or result.stdout.strip() not in ("", "ok"):
    raise ValueError("Hyprland rejected layout: " + result.stdout.strip() + result.stderr.strip())


@contextmanager
def layout_transaction():
  # This lock only serializes managed-state writers. Owner config and Hyprland's
  # watches are never changed, so independent editors need not take the lock.
  runtime = Path(os.environ.get("XDG_RUNTIME_DIR") or tempfile.gettempdir())
  fd = os.open(runtime / f"omarchy-monitor-layout-{os.getuid()}.lock",
               os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
  with termination_handlers(), os.fdopen(fd, "w") as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    yield lock


def state_path():
  return Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state") / "omarchy/monitor-layout"


def gdk_scale(original, displays):
  return str(rounded(displays[0]["scale"])) if original is not None and len(displays) == 1 and b"omarchy_gdk_scale" in original else None


def read_config(path):
  try:
    return path.read_bytes()
  except FileNotFoundError:
    return None


def live_gdk_scale():
  result = ipc("repl", 'return "GDK_SCALE:" .. (os.getenv("GDK_SCALE") or "")', check=True)
  if not result.stdout.startswith("GDK_SCALE:"):
    raise ValueError("Could not read live GTK scale: " + result.stdout.strip())
  return result.stdout.removeprefix("GDK_SCALE:").removesuffix("\n")


def env_rule(value):
  # Decimal byte escapes are valid Lua for every environment value.
  quoted = "".join(chr(92) + f"{byte:03d}" for byte in value.encode())
  return f'hl.env("GDK_SCALE", "{quoted}")'


def encode_state(original, displays, name):
  # Framed data, never executable Lua. Preserve the owner file's exact bytes;
  # the loader ignores this state when those bytes differ after an owner edit.
  gdk = gdk_scale(original, displays) or "-"
  rows = ["\t".join((m["name"], f'{m["width"]}x{m["height"]}@{m["refreshRate"]:g}',
                       f'{m["x"]}x{m["y"]}', f'{m["scale"]:g}', str(m.get("transform", 0)))) for m in displays]
  return f"OMARCHY_MONITOR_LAYOUT_V1\n{len(original)}\n{gdk}\n".encode() + original + b"\n" + ("\n".join(rows) + "\n").encode()


def publish_state(path, content):
  with finish_cleanup():
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, staged = tempfile.mkstemp(prefix=".monitor-layout-", dir=path.parent)
    try:
      with os.fdopen(fd, "wb") as handle:
        handle.write(content)
      os.replace(staged, path)
    finally:
      if os.path.exists(staged):
        os.unlink(staged)


def clean_scale(monitor, scale):
  divisor = math.gcd(monitor["width"] * 120, monitor["height"] * 120)
  units = min(rounded(scale * 120), divisor)
  while divisor % units:
    units += 1
  return units / 120


def requested_scale(monitor, request):
  if request == "keep":
    return monitor["scale"]
  if request not in ("up", "down"):
    return float(request)
  # Keep the closest preset label for duplicate effective scales.
  presets = {}
  for scale in (1, 1.25, 1.6, 2, 2.5, 3, 4):
    effective = clean_scale(monitor, scale)
    if effective not in presets or abs(scale - effective) < abs(presets[effective] - effective):
      presets[effective] = scale
  values = list(presets)
  index = min(range(len(values)), key=lambda i: abs(values[i] - monitor["scale"]))
  index = max(0, min(len(values) - 1, index + (1 if request == "up" else -1)))
  return presets[values[index]]


def read_state(content, original):
  if not content:
    return []
  try:
    version, length, gdk, rest = content.split(b"\n", 3)
    length = int(length)
    if version != b"OMARCHY_MONITOR_LAYOUT_V1" or not 0 <= length <= 1048576 or rest[:length] != original or rest[length:length + 1] != b"\n":
      return []
    displays = []
    for line in rest[length + 1:].decode().splitlines():
      name, mode, position, scale, transform = line.split("\t")
      match = re.fullmatch(r"(\d+)x(\d+)@(\d+(?:\.\d+)?)", mode)
      pos = re.fullmatch(r"(-?\d+)x(-?\d+)", position)
      if not match or not pos or len(displays) >= 256:
        return []
      displays.append(dict(name=name, width=int(match[1]), height=int(match[2]),
                           refreshRate=float(match[3]), x=int(pos[1]), y=int(pos[2]),
                           scale=float(scale), transform=int(transform)))
    if not displays or len({m["name"] for m in displays}) != len(displays):
      return []
    # Validate every remembered row, not just the requested one.
    for m in displays:
      plan([m], m["name"], m["scale"])
    return displays
  except (ValueError, TypeError, OverflowError):
    return []


def remembered_layout(prior, original, displays):
  remembered = read_state(prior, original)
  names = {m["name"] for m in displays}
  absent = {m["name"] for m in remembered} - names
  if not absent:
    return displays
  common = names & {m["name"] for m in remembered}
  if not common:
    raise ValueError("Saved disconnected layout has no common output; arrange all outputs before saving")
  # Resize the remembered graph, preserving absent outputs' modes/scales and
  # shared edges. A sole-output save must not discard its docked neighbours or
  # blindly append their old coordinates to a differently sized panel.
  for m in sorted(displays, key=lambda m: m["name"]):
    if m["name"] in common:
      old = next(r for r in remembered if r["name"] == m["name"])
      if old.get("transform", 0) != m.get("transform", 0):
        raise ValueError("Reconnect outputs before saving a changed transform")
      remembered = plan(remembered, m["name"], m["scale"],
                        f'{m["width"]}x{m["height"]}@{m["refreshRate"]}')
  anchor = next(m for m in displays if m["name"] == min(common))
  previous = next(m for m in remembered if m["name"] == anchor["name"])
  dx, dy = anchor["x"] - previous["x"], anchor["y"] - previous["y"]
  for m in displays:
    if m["name"] in common:
      projected = next(r for r in remembered if r["name"] == m["name"])
      if abs(projected["x"] + dx - m["x"]) > 1 or abs(projected["y"] + dy - m["y"]) > 1:
        raise ValueError("Connected outputs no longer match the remembered graph; reconnect all outputs before saving")
  merged = displays + [dict(m, x=m["x"] + dx, y=m["y"] + dy) for m in remembered if m["name"] in absent]
  if len(merged) > 256:
    raise ValueError("Monitor state exceeds supported size")
  for a, b in itertools.combinations(merged, 2):
    if overlap(rect(a), rect(b)):
      raise ValueError("Remembered disconnected layout overlaps; reconnect outputs before saving")
  return merged


def apply(monitors, name, scale, config, mode=None):
  with layout_transaction():
    # Caller snapshots only select the intended connector. All geometry and
    # relative stepping must be resolved after waiting for preceding writers.
    fresh = json.loads(ipc("monitors", "-j", check=True).stdout)
    target = next((m for m in fresh if m["name"] == name and active(m)), None)
    if target is None:
      raise ValueError("Monitor is missing, disabled, or mirrored")
    return apply_guarded(fresh, name, requested_scale(target, scale), config, mode)


def verify_layout(displays, settled=False):
  stable = 0
  for attempt in range(10):
    readback = ipc("monitors", "-j", check=True)
    actual = {m["name"]: m for m in json.loads(readback.stdout) if active(m)}
    if set(actual) == {m["name"] for m in displays} and all(
        actual[m["name"]]["width"] == m["width"] and actual[m["name"]]["height"] == m["height"]
        and rect(actual[m["name"]]) == rect(m)
        and abs(actual[m["name"]]["scale"] - m["scale"]) < 0.0001
        and actual[m["name"]].get("transform", 0) == m.get("transform", 0)
        and abs(actual[m["name"]]["refreshRate"] - m["refreshRate"]) < 1
        for m in displays):
      stable += 1
      if stable >= (2 if settled else 1):
        return
    else:
      stable = 0
    time.sleep(0.05)
  raise ValueError("Final live geometry differs from saved layout (concurrent reload or topology change); scale save cancelled")


def apply_guarded(monitors, name, scale, config, mode=None):
  displays = plan(monitors, name, scale, mode)
  path = Path(config).resolve()
  original = read_config(path)
  if len(original or b"") > 1048576 or len(displays) > 256:
    raise ValueError("Monitor state exceeds supported size")
  saved = state_path()
  prior = saved.read_bytes() if original is not None and saved.exists() else None
  persisted = remembered_layout(prior, original, displays) if original is not None else displays
  gdk = gdk_scale(original, persisted)
  previous_gdk = None
  if gdk is not None:
    previous_gdk = live_gdk_scale()
  option = ipc("getoption", "misc.disable_autoreload", "-j", check=True)
  disabled = json.loads(option.stdout).get("bool")
  if not isinstance(disabled, bool):
    raise ValueError("Could not read Hyprland auto-reload policy")
  changed_live = False
  publishing = False
  try:
    changed_live = True
    hypr_eval(lua_rules(displays) + ("; " + env_rule(gdk) if gdk is not None else ""))
    verify_layout(displays)
    if read_config(path) != original:
      raise ValueError("Owner monitor config changed; scale save cancelled")
    # Only helper-owned state is replaced. An owner save at this very boundary
    # cannot be overwritten: the owner file is never a replacement destination.
    if original is not None:
      publishing = True
      committed = encode_state(original, persisted, name)
      publish_state(saved, committed)
    if read_config(path) != original:
      raise ValueError("Owner monitor config changed during publication; scale save cancelled")
    # A reload already in progress can have consumed the previous record and
    # undo the earlier live eval. The unwatched publication does not apply it.
    # Observe AFTER publication, including a second matching sample to catch
    # a previous-record reload completing between the first two observations.
    # This is a bounded live witness, not serialization of future config edits.
    verify_layout(displays, settled=True)
    if gdk is not None and live_gdk_scale() != gdk:
      raise ValueError("Final live GTK scale differs from saved scale; scale save cancelled")
    if (publishing and saved.read_bytes() != committed) or read_config(path) != original:
      raise ValueError("Monitor state/config changed during final verification; scale save cancelled")
  except Exception:
    with finish_cleanup():
      recovery_failed = False
      if publishing:
        try:
          if prior is None:
            saved.unlink(missing_ok=True)
          else:
            publish_state(saved, prior)
        except OSError as error:
          recovery_failed = True
          print(f"Could not restore saved monitor state: {error}; remove {saved} before reloading", file=sys.stderr)
      if changed_live:
        try:
          if disabled:
            # Respect an intentional disabled-auto-reload policy. No full reload
            # is introduced; the owner file is retained for their explicit reload.
            hypr_eval(lua_rules([m for m in monitors if active(m)]))
            print("Scale save cancelled; prior auto-reload-disabled policy preserved; owner edits await explicit reload", file=sys.stderr)
          else:
            result = ipc("reload")
            if result.returncode or result.stdout.strip() not in ("", "ok"):
              raise ValueError(result.stdout.strip() + result.stderr.strip())
            print("Scale save cancelled; reloaded current owner configuration", file=sys.stderr)
        except (ValueError, OSError, subprocess.SubprocessError) as error:
          recovery_failed = True
          print(f"Monitor recovery failed: {error}; inspect {saved}, then run hyprctl reload when the compositor responds", file=sys.stderr)
      if changed_live and previous_gdk is not None:
        try:
          hypr_eval(env_rule(previous_gdk))
        except (ValueError, OSError, subprocess.SubprocessError) as error:
          recovery_failed = True
          print(f"GTK scale recovery failed: {error}", file=sys.stderr)
      if recovery_failed:
        print("Monitor recovery incomplete; no success reported", file=sys.stderr)
    raise
  return next(m["scale"] for m in displays if m["name"] == name)


CLAMSHELL_TIMEOUT = 30


def reconcile_clamshell():
  with layout_transaction():
    script = str(Path(os.environ["OMARCHY_PATH"]) / "bin/omarchy-hyprland-monitor-clamshell")
    # Keep the lock in this supervisor, never in shell descendants. A session
    # boundary lets timeout/signal cleanup kill every outstanding helper/IPC
    # before the lock is handed to the next writer.
    child = None
    try:
      # Do not let a catchable signal land after fork but before the child has
      # been assigned to the cleanup owner.
      with finish_cleanup():
        child = subprocess.Popen(["/bin/bash", script, "--layout-locked"], start_new_session=True)
      result = child.wait(timeout=CLAMSHELL_TIMEOUT)
      if result:
        raise subprocess.CalledProcessError(result, child.args)
    finally:
      if child is not None:
        with finish_cleanup():
          try:
            os.killpg(child.pid, signal.SIGKILL)
          except ProcessLookupError:
            pass
          child.wait(timeout=IPC_TIMEOUT)


if __name__ == "__main__":
  try:
    if sys.argv[1] == "--clamshell":
      reconcile_clamshell()
      sys.exit(0)
    if sys.argv[1] == "--saved-monitor":
      config, name = Path(sys.argv[2]), sys.argv[3]
      saved = state_path()
      rows = read_state(saved.read_bytes() if saved.exists() else None, config.read_bytes())
      row = next((m for m in rows if m["name"] == name), None)
      if row:
        print(f'{row["scale"]:g}\t{row["x"]}x{row["y"]}\t{row["width"]}x{row["height"]}@{row["refreshRate"]:g}\t{row.get("transform", 0)}')
      sys.exit(0)
    print(f'{apply(json.load(sys.stdin), sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4] if len(sys.argv) > 4 and sys.argv[4] else None):g}')
  except Terminated as error:
    print(f"Monitor layout change interrupted: {error}", file=sys.stderr)
    sys.exit(128 + error.signum)
  except (ValueError, KeyError, OSError, TypeError, subprocess.SubprocessError) as error:
    print(f"Monitor layout change failed: {error}", file=sys.stderr)
    sys.exit(1)
