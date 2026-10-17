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


rubra = [monitor("DP-1", 3840, 2160, 2.5, 1280, 0), monitor("eDP-1", 2560, 1664, 2, 1536, 864)]
# Test every directed transition, including gradual changes that must not drift.
for start in (1, 1.25, 1.6, 2, 2.5, 3):
  initial = layout.plan(rubra, "DP-1", start)
  for scale in (1, 1.25, 1.6, 2, 2.5, 3):
    result = layout.plan(initial, "DP-1", scale)
    check(result)
    dell, laptop = [layout.rect(by_name(result, n)) for n in ("DP-1", "eDP-1")]
    assert laptop[1] == dell[1] + dell[3]
    assert laptop[0] + laptop[2] == dell[0] + dell[2]
    assert laptop[0] >= dell[0]
    assert by_name(result, "eDP-1")["scale"] == 2
    assert min(dell[:2] + laptop[:2]) >= 0
  pass_test(f"rubra: transitions from {start} to all six scales preserve bottom/right edges")

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

excluded = [*rubra, monitor("off", 0, 0, disabled=True), monitor("mirror", 3840, 2160, mirrorOf="DP-1")]
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
result = layout.plan(rubra, "DP-1", 2)
rewritten = layout.rewrite(text, result, "DP-1")
assert "scale = 2, -- owner comment" in rewritten
assert 'position = "1920x1080", scale = omarchy_monitor_scale, bitdepth = 10' in rewritten
assert 'position = "fake", scale = 9' in rewritten
assert 'bitdepth = 10, cm = { enabled = true }' in rewritten
assert layout.rewrite(rewritten, result, "DP-1") == rewritten
pass_test("Lua persistence keeps comments, expressions on neighbours, nested fields and formatting")
text_desc = 'hl.monitor({ output = "desc:Dell", scale = 2.5 })\n'
result[0]["description"] = "Dell"
assert layout.rewrite(text_desc, result, "DP-1").count('desc:Dell') == 1
assert 'output = "DP-1"' not in layout.rewrite(text_desc, result, "DP-1")
pass_test("description rules update instead of gaining shadow rules")

# Exercise transactional apply without a compositor. Check live eval/readback,
# resolved symlink publication, mode/permission retention and failure rollback.
with tempfile.TemporaryDirectory() as directory:
  path = Path(directory) / "real.lua"
  link = Path(directory) / "monitors.lua"
  path.write_text(text)
  path.chmod(0o640)
  link.symlink_to(path)
  calls = []
  desired = layout.plan(rubra, "DP-1", 2)
  def run(args, **kwargs):
    calls.append(args)
    return subprocess.CompletedProcess(args, 0, json.dumps(desired) if args[1] == "monitors" else "ok\n", "")
  with patch.object(layout.subprocess, "run", run):
    assert layout.apply(rubra, "DP-1", 2, link) == 2
  assert link.is_symlink() and path.stat().st_mode & 0o777 == 0o640
  assert path.read_text() == layout.rewrite(text, desired, "DP-1")
  assert len([c for c in calls if c[1] == "eval"]) == 1
  assert len(list(path.parent.glob(".monitors-*"))) == 0
  pass_test("apply stages and publishes once, preserves symlinks/permissions, checks live geometry")
  original = path.read_text()
  calls.clear()
  def rejected(args, **kwargs):
    calls.append(args)
    return subprocess.CompletedProcess(args, 0, "error: invalid rule" if len(calls) == 1 else "ok", "")
  with patch.object(layout.subprocess, "run", rejected):
    try:
      layout.apply(rubra, "DP-1", 2, link)
      raise AssertionError("expected eval failure")
    except ValueError:
      pass
  assert path.read_text() == original and len(calls) == 2
  assert not list(path.parent.glob(".monitors-*"))
  pass_test("eval rejection preserves config and restores old live rules")
  def snapped(args, **kwargs):
    calls.append(args)
    return subprocess.CompletedProcess(args, 0, json.dumps(rubra) if args[1] == "monitors" else "ok", "")
  calls.clear()
  with patch.object(layout.subprocess, "run", snapped), patch.object(layout.time, "sleep"):
    try:
      layout.apply(rubra, "DP-1", 2, link)
      raise AssertionError("expected readback failure")
    except ValueError:
      pass
  assert path.read_text() == original and calls[-1][1] == "eval"
  pass_test("snapped geometry is not persisted and old live rules are restored")
  calls.clear()
  with patch.object(layout.subprocess, "run", run), patch.object(layout.os, "replace", side_effect=OSError("injected rename failure")):
    try:
      layout.apply(rubra, "DP-1", 2, link)
      raise AssertionError("expected publication failure")
    except OSError:
      pass
  assert path.read_text() == original and len([c for c in calls if c[1] == "eval"]) == 2
  assert not list(path.parent.glob(".monitors-*"))
  pass_test("failed publication keeps config bytes and rolls live layout back")
  calls.clear()
  def concurrent(args, **kwargs):
    response = run(args, **kwargs)
    if args[1] == "monitors":
      path.write_text(original + "-- concurrent owner edit\n")
    return response
  with patch.object(layout.subprocess, "run", concurrent):
    try:
      layout.apply(rubra, "DP-1", 2, link)
      raise AssertionError("expected concurrent-edit refusal")
    except ValueError:
      pass
  assert path.read_text() == original + "-- concurrent owner edit\n"
  assert len([c for c in calls if c[1] == "eval"]) == 2
  pass_test("concurrent owner edit is retained and old live layout restored")

PY
