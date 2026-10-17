#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

OMARCHY_PATH="$ROOT" /usr/bin/python - <<'PY'
import copy
import importlib.util
import json
import os
import subprocess
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("indicator", os.environ["OMARCHY_PATH"] + "/default/input-methods/indicator.py")
indicator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(indicator)

keyboards = [{"name": "physical", "layout": "us,ara", "variant": ",", "active_layout_index": 0}]
reader = indicator.Indicator(None)
reader.keyboards = copy.deepcopy(keyboards)
feedback = indicator.InputFeedback(reader)
english = {"methods": ["keyboard-us", "mozc"], "current": "keyboard-us", "language": "en", "name": "English"}
japanese = {**english, "current": "mozc", "language": "ja", "name": "Mozc"}
initial = dict(feedback.observe(english))
assert initial["serial"] == 0 and initial["language"] == "eng"
assert feedback.observe(english) == initial
reader.remember_layout(1)
arabic = dict(feedback.observe(english))
assert arabic["serial"] == 1 and arabic["language"] == "ara"
reader.pending = "mozc"
assert feedback.observe(japanese) == arabic
reader.pending = ""
reader.remember_layout(0)
activated = dict(feedback.observe(japanese))
assert activated["serial"] == 2 and activated["language"] == "ja"
assert feedback.observe(japanese) == activated
assert feedback.observe(english)["serial"] == 3
assert indicator.InputFeedback(reader).observe(english)["serial"] == 0
print("ok - feedback follows confirmed changes once, including external switches, and starts silently")

reader.remember_layout(1)
fallback = dict(feedback.observe({"methods": [], "current": ""}))
assert fallback["language"] == "ara" and fallback["serial"] == 4
assert feedback.observe(english) == fallback
reader.pending = "mozc"
with patch.object(indicator, "keyboard_language", side_effect=ValueError("bad metadata")), patch("builtins.print"):
  reader.pending = ""
  assert feedback.observe(english) == fallback
  reader.pending = "mozc"
  assert feedback.observe(english) == fallback
assert reader.pending == "mozc"
reader.pending = ""
with patch.object(indicator, "layout_languages", side_effect=OSError("unreadable catalog")), patch("builtins.print"):
  assert feedback.observe(english) == fallback
assert reader.pending == ""
print("ok - Fcitx loss uses the compositor layout; cosmetic failures cannot change input or pending choices")

single = indicator.Indicator(None)
single.keyboards = [{"name": "physical", "layout": "us", "main": True, "active_layout_index": 0}]
single_feedback = indicator.InputFeedback(single)
single_feedback.observe(japanese)
assert single_feedback.observe({"methods": [], "current": ""})["language"] == "eng"
with patch.object(indicator.subprocess, "run", side_effect=OSError("no compositor")), patch("builtins.print"):
  assert not single.refresh_layouts()
print("ok - a single layout also recovers from Fcitx loss, and an unavailable compositor is harmless")

live = dict(english)
refuse = [True]
def controller(bus, method, args=None):
  assert method == "SetCurrentIM"
  if not refuse[0]:
    live.update(japanese)
  return ()
def process(args, **kwargs):
  if args == ["hyprctl", "-j", "devices"]:
    return subprocess.CompletedProcess(args, 0, stdout=json.dumps({"keyboards": keyboards}))
  return subprocess.CompletedProcess(args, 0)
reader = indicator.Indicator(None)
reader.keyboards = copy.deepcopy(keyboards)
reader.remember_layout(1)
feedback = indicator.InputFeedback(reader)
feedback.observe(english)
with patch.object(indicator, "snapshot", side_effect=lambda bus: dict(live)), \
     patch.object(indicator, "call", side_effect=controller), \
     patch.object(indicator.subprocess, "run", side_effect=process) as run:
  # Start from Arabic, immediately before Mozc in the native cycle.
  keyboards[0]["active_layout_index"] = 1
  reader.select_next()
  assert reader.pending == "mozc"
  assert feedback.observe(reader.refresh())["serial"] == 0
  refuse[0] = False
  state = reader.refresh()
  assert reader.pending == ""
  assert feedback.observe(state)["serial"] == 1
  assert sum(call.args[0] == ["hyprctl", "-j", "devices"] for call in run.call_args_list) == 1
print("ok - a refused engine is not announced; acknowledgement needs no extra compositor query")

# Events arrive through the reader's existing command pipe.
keyboards[0]["active_layout_index"] = 0
reader = indicator.Indicator(None)
with patch.object(indicator.subprocess, "run", side_effect=process) as run:
  assert reader.refresh_layouts()
  assert run.call_count == 1
  assert not reader.refresh_layouts("physical,English (US)")
  assert run.call_count == 1
  keyboards[0]["active_layout_index"] = 1
  assert reader.refresh_layouts("physical,Arabic")
  assert run.call_count == 2
  assert reader.keyboards[0]["active_layout_index"] == 1
  reader.pending = "mozc"
  run.side_effect = subprocess.TimeoutExpired("hyprctl", 1)
  with patch("builtins.print"):
    assert not reader.refresh_layouts()
  assert reader.pending == "mozc"
  assert reader.keyboards[0]["active_layout_index"] == 1
print("ok - compositor metadata skips known events and isolates query failures from pending input")
PY
