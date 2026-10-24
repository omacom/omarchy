#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - "$ROOT" <<'PY'
import importlib.util
import itertools
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("layout", Path(sys.argv[1]) / "default/hypr/monitor-layout.py")
layout = importlib.util.module_from_spec(spec)
spec.loader.exec_module(layout)


def monitor(name, w, h, scale=1, x=0, y=0, **extra):
  return dict(name=name, width=w, height=h, scale=scale, x=x, y=y, refreshRate=60, **extra)


def check(displays):
  for a, b in itertools.combinations(displays, 2):
    assert not layout.overlap(layout.rect(a), layout.rect(b)), (a, b)


def by_name(displays, name):
  return next(m for m in displays if m["name"] == name)


def pass_test(name):
  print("ok - " + name)


stacked = [monitor("DP-1", 3840, 2160, 2.5, 1280, 0), monitor("eDP-1", 2560, 1664, 2, 1536, 864)]
# Test every directed transition, including gradual changes that must not drift.
for start in (1, 1.25, 1.6, 2, 2.5, 3):
  initial = layout.plan(stacked, "DP-1", start)
  for scale in (1, 1.25, 1.6, 2, 2.5, 3):
    result = layout.plan(initial, "DP-1", scale)
    check(result)
    external, laptop = [layout.rect(by_name(result, n)) for n in ("DP-1", "eDP-1")]
    assert laptop[1] == external[1] + external[3]
    assert laptop[0] + laptop[2] == external[0] + external[2]
    assert laptop[0] >= external[0]
    assert by_name(result, "eDP-1")["scale"] == 2
    assert min(external[:2] + laptop[:2]) >= 0
  pass_test(f"stacked: transitions from {start} to all six scales preserve bottom/right edges")

for align in ("top", "center", "bottom"):
  y = {"top": 0, "center": 200, "bottom": 400}[align]
  displays = [monitor("A", 1920, 1200), monitor("B", 1280, 800, x=1920, y=y)]
  for name in ("A", "B"):
    for scale in (1, 1.25, 1.6, 2, 2.5, 3):
      result = layout.plan(displays, name, scale)
      check(result)
      a, b = map(layout.rect, result)
      assert b[0] == a[0] + a[2]
      factor = {"top": 0, "center": 0.5, "bottom": 1}[align]
      assert abs(a[1] + factor * a[3] - b[1] - factor * b[3]) <= 1
  pass_test(f"side-by-side keeps {align} alignment when either output changes")

chain = [monitor("A", 1920, 1080), monitor("B", 1920, 1080, x=1920), monitor("C", 1920, 1080, x=3840)]
for name in ("A", "B", "C"):
  result = layout.plan(chain, name, 2)
  check(result)
  for a, b in zip(result, result[1:]):
    assert b["x"] == a["x"] + layout.rect(a)[2]
pass_test("three-output chain propagates through both neighbours")

solo = [monitor("eDP-1", 2560, 1664, 2, 1536, 864)]
assert layout.rect(layout.plan(solo, "eDP-1", 1.6)[0])[:2] == (1536, 864)
pass_test("single output keeps position")
negative = [monitor("A", 1920, 1080, x=-1920), monitor("B", 1920, 1080)]
result = layout.plan(negative, "A", 2)
check(result)
assert result[0]["x"] == -1920
pass_test("existing negative coordinates remain valid")
rotated = [monitor("A", 1920, 1080, transform=1), monitor("B", 1280, 800, x=1080)]
result = layout.plan(rotated, "A", 2)
assert result[1]["x"] == 540
assert result[0]["transform"] == 1
pass_test("portrait outputs use transformed logical dimensions")
result = layout.plan(chain, "B", 1, "1280x720@75")
check(result)
assert result[2]["x"] == 3200
assert result[1]["refreshRate"] == 75
pass_test("mode resize recomputes the same adjacency graph")

excluded = [*stacked, monitor("off", 0, 0, disabled=True), monitor("mirror", 3840, 2160, mirrorOf="DP-1")]
assert len(layout.plan(excluded, "DP-1", 2)) == 2
for name in ("off", "mirror", "missing"):
  try:
    layout.plan(excluded, name, 2)
    raise AssertionError("should refuse excluded target")
  except ValueError:
    pass
pass_test("disabled/mirrored outputs are excluded and cannot be scale targets")

for displays in ([monitor("A", 1920, 1080), monitor("B", 1920, 1080, x=100)],
                 [monitor("A", 1920, 1080), monitor("B", 1920, 1080, x=1920), monitor("C", 1920, 1080, y=1080), monitor("D", 1920, 1080, x=1920, y=1080)]):
  try:
    layout.plan(displays, "A", 2)
    raise AssertionError("should refuse impossible constraints")
  except ValueError:
    pass
pass_test("overlapping input and conflicting cycles fail before applying")

text = '''-- hl.monitor({ output = "DP-1", position = "fake", scale = 9 })
local omarchy_monitor_scale = 2
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale, bitdepth = 10 })
hl.monitor({
  mode = "preferred"; output = 'DP-1'; scale = custom_scale + 1, -- owner comment
  position = "1280x0", transform = 0, bitdepth = 10, cm = { enabled = true }
})
hl.monitor({ output = "eDP-1", mode = "preferred", position = "1536x864", scale = omarchy_monitor_scale, bitdepth = 10 })
'''
# Test publication without touching owner files or suppressing config watches.
with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {"XDG_STATE_HOME": directory, "XDG_RUNTIME_DIR": directory}):
  path = Path(directory) / "real.lua"
  link = Path(directory) / "monitors.lua"
  path.write_text(text)
  path.chmod(0o640)
  link.symlink_to(path)
  original = path.read_bytes()
  calls = []
  desired = layout.plan(stacked, "DP-1", 2)
  def run(args, **kwargs):
    calls.append(args)
    assert kwargs["timeout"] == 10
    out = json.dumps({"bool": False}) if args[1] == "getoption" else json.dumps(stacked if not any(c[1] == "eval" for c in calls) else desired) if args[1] == "monitors" else "ok"
    return subprocess.CompletedProcess(args, 0, out, "")
  with patch.object(layout.subprocess, "run", run):
    assert layout.apply(stacked, "DP-1", 2, link) == 2
  saved = layout.state_path()
  assert link.is_symlink() and path.stat().st_mode & 0o777 == 0o640 and path.read_bytes() == original
  assert saved.read_bytes() == layout.encode_state(original, desired, "DP-1")
  assert not any("disable_autoreload =" in c[-1] or c[1] in ("reload", "keyword") for c in calls)
  assert not list(saved.parent.glob(".monitor-layout-*"))
  pass_test("scale save changes only managed data; owner symlinks/bytes/modes and all config watches remain intact")
  prior = saved.read_bytes()
  for failure in ("eval", "snap", "publish", "timeout"):
    calls.clear()
    def failed(args, **kwargs):
      response = run(args, **kwargs)
      if args[1] == "eval" and failure == "eval": response.stdout = "error: rejected"
      if args[1] == "monitors" and failure == "snap": response.stdout = json.dumps(stacked)
      if args[1] == "monitors" and failure == "timeout": raise subprocess.TimeoutExpired(args, kwargs["timeout"])
      return response
    def publish_fail(p, content):
      raise OSError("injected publication failure")
    from contextlib import nullcontext
    publication = patch.object(layout, "publish_state", publish_fail) if failure == "publish" else nullcontext()
    with patch.object(layout.subprocess, "run", failed), patch.object(layout.time, "sleep"), publication:
      try:
        layout.apply(stacked, "DP-1", 2, link)
        raise AssertionError("expected failure")
      except (ValueError, OSError, subprocess.SubprocessError):
        pass
    assert path.read_bytes() == original and saved.read_bytes() == prior
    assert calls[-1][1] == ("monitors" if failure == "timeout" else "reload")
    pass_test(f"{failure} failure preserves owner/saved bytes and performs bounded current-config recovery")
  owner = original + b"-- owner publication-boundary edit\n"
  replace = layout.os.replace
  def concurrent(src, dst):
    path.write_bytes(owner)
    replace(src, dst)
  calls.clear()
  with patch.object(layout.subprocess, "run", run), patch.object(layout.os, "replace", concurrent):
    try:
      layout.apply(stacked, "DP-1", 2, link)
      raise AssertionError("expected owner-edit conflict")
    except ValueError:
      pass
  assert path.read_bytes() == owner and saved.read_bytes() == prior and calls[-1][1] == "reload"
  pass_test("publication-boundary owner save is preserved and reloaded; no success or overwrite")
  path.write_bytes(original)
  calls.clear()
  def before_save(args, **kwargs):
    response = run(args, **kwargs)
    if args[1] == "monitors" and any(c[1] == "eval" for c in calls): path.write_bytes(owner)
    return response
  with patch.object(layout.subprocess, "run", before_save):
    try: layout.apply(stacked, "DP-1", 2, link)
    except ValueError: pass
    else: raise AssertionError("expected conflict")
  assert path.read_bytes() == owner and calls[-1][1] == "reload" and saved.read_bytes() == prior
  pass_test("prepublication owner edit retains normal watches and exceptional reload recovery")
  path.write_bytes(original)
  def disabled(args, **kwargs):
    response = before_save(args, **kwargs)
    if args[1] == "getoption": response.stdout = json.dumps({"bool": True})
    return response
  calls.clear()
  with patch.object(layout.subprocess, "run", disabled):
    try: layout.apply(stacked, "DP-1", 2, link)
    except ValueError: pass
    else: raise AssertionError("expected conflict")
  assert path.read_bytes() == owner and not any(c[1] == "reload" for c in calls)
  assert not any("disable_autoreload =" in c[-1] for c in calls)
  pass_test("pre-existing disabled-auto-reload policy is preserved on conflict")
  path.write_bytes(original)
  unrelated = Path(directory) / "input.lua"
  unrelated.write_text("-- old input config\n")
  calls.clear()
  def unrelated_edit(args, **kwargs):
    response = run(args, **kwargs)
    if args[1] == "monitors": unrelated.write_text("-- owner input edit\n")
    return response
  with patch.object(layout.subprocess, "run", unrelated_edit):
    layout.apply(stacked, "DP-1", 2, link)
  assert unrelated.read_text() == "-- owner input edit\n" and path.read_bytes() == original
  assert not any("disable_autoreload =" in c[-1] or c[1] == "reload" for c in calls)
  pass_test("unrelated owner config edits retain their normal watch events; helper performs no watch suppression")

PY
