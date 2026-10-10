#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

OMARCHY_PATH="$ROOT" /usr/bin/python - <<'PY'
import importlib.util
import os
from unittest.mock import patch
import json
import subprocess

# Script-directory imports must not shadow Python's standard typing module.
subprocess.run(["/usr/bin/python", "-c", "import sys; sys.path.insert(0, sys.argv[1]); import typing; from gi.repository import Gio; assert hasattr(typing, 'TYPE_CHECKING')", os.environ["OMARCHY_PATH"] + "/default/input-methods"], check=True)

spec = importlib.util.spec_from_file_location("indicator", os.environ["OMARCHY_PATH"] + "/default/input-methods/indicator.py")
indicator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(indicator)

with patch.object(indicator, "call", side_effect=[
  ("Default",),
  ("us", [("keyboard-us", ""), ("mozc", ""), ("mozc", "")]),
  ("mozc", "Mozc", "", "fcitx_mozc", "あ", "ja", "mozc", True, "", {}),
]):
  state = indicator.snapshot(None)
  assert state == {"methods": ["keyboard-us", "mozc"], "current": "mozc", "name": "Mozc", "label": "あ", "language": "ja"}
print("ok - live state deduplicates modes and reads language independently of the engine label")

def check_cycle(current, methods, expected):
  state = {"current": current, "methods": methods}
  with patch.object(indicator, "snapshot", return_value=state), patch.object(indicator, "call") as call:
    indicator.cycle(None)
    if expected is None:
      call.assert_not_called()
    else:
      assert call.call_args.args[1] == "SetCurrentIM"
      assert call.call_args.args[2].unpack() == (expected,)

check_cycle("keyboard-us", ["keyboard-us", "mozc"], "mozc")
check_cycle("mozc", ["keyboard-us", "mozc"], "keyboard-us")
check_cycle("mozc", ["keyboard-us", "mozc", "hangul"], "hangul")
check_cycle("hangul", ["keyboard-us", "mozc", "hangul"], "keyboard-us")
check_cycle("keyboard-us", ["keyboard-us"], None)
check_cycle("removed", ["keyboard-us", "mozc"], None)
check_cycle("", [], None)
print("ok - input cycling covers Latin, multiple engines, single modes, and stale contexts")

entries = [("keyboard-us", "English", "", "input-keyboard", "en", "en", True),
           ("pinyin", "Pinyin", "", "fcitx-pinyin", "拼", "zh_CN", True)]
live = {"methods": ["keyboard-us", "pinyin"], "current": "", "name": "", "label": "", "language": ""}
selected = []
def fake_call(bus, method, args=None):
  if method == "AvailableInputMethods":
    return (entries,)
  if method == "SetCurrentIM":
    selected.append(args.unpack()[0])
    live["current"] = selected[-1]
    return ()
  raise AssertionError(method)

with patch.object(indicator, "snapshot", side_effect=lambda bus: dict(live)), patch.object(indicator, "call", side_effect=fake_call), patch.object(indicator.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, stdout='{"keyboards": []}')):
  reader = indicator.Indicator(None)
  assert reader.refresh()["current"] == "keyboard-us"
  reader.select_next()
  assert reader.refresh()["current"] == "pinyin"
  assert reader.pending == "pinyin" and selected == []
  reader.select_next()
  assert reader.pending == "keyboard-us"
  reader.select_next()
  live["current"] = "keyboard-us"
  assert reader.refresh()["current"] == "pinyin"
  assert reader.pending == "" and selected == ["pinyin"]
  live["current"] = ""
  reader.select_next()
  live["methods"] = ["pinyin"]
  reader.refresh()
  assert reader.pending == ""
print("ok - desktop clicks update the label, cycle pending choices, and apply once a text context exists")

with patch.object(indicator.Gio, "bus_get_sync", return_value=None), patch.object(indicator, "snapshot", return_value={"methods": ["keyboard-us", "keyboard-fr"], "current": "keyboard-us"}), patch.object(indicator, "call") as call, patch.object(indicator.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, stdout='{"keyboards": []}')) as process:
  indicator.cycle_input()
  assert call.call_args.args[2].unpack() == ("keyboard-fr",)
  assert process.call_count == 1
print("ok - the shortcut cycles Fcitx keyboard methods without requiring a bar widget")

keyboards = [
  {"name": "power-button", "layout": "us,fr", "active_layout_index": 1},
  {"name": "physical keyboard", "layout": "us,fr", "active_layout_index": 0},
  {"name": "consumer-control", "layout": "us,fr", "active_layout_index": 0},
  {"name": "custom", "layout": "de", "active_layout_index": 0},
]
expected = [["hyprctl", "switchxkblayout", item["name"], "1"] for item in keyboards[:3]]
assert indicator.layout_switches(keyboards) == expected
assert indicator.layout_switches([keyboards[-1]] + keyboards[:-1]) == expected
assert indicator.layout_switches([{ "name": "custom-first", "layout": "us,de,fr", "active_layout_index": 2 }] + keyboards) == expected
keyboards[1]["active_layout_index"] = 1
assert all(command[-1] == "0" for command in indicator.layout_switches(keyboards))
assert indicator.layout_switches([{ "name": "physical", "layout": "fr" }]) == []
assert indicator.layout_switches([]) == []
print("ok - layout switching synchronizes matching devices, wraps, and preserves device-specific layouts")

import json
import subprocess
with patch.object(indicator.Gio, "bus_get_sync", return_value=None), patch.object(indicator, "snapshot", return_value={"methods": ["keyboard-us"], "current": "keyboard-us"}), patch.object(indicator.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, stdout=json.dumps({"keyboards": keyboards}))) as process:
  indicator.cycle_input()
  assert process.call_args_list[0].args[0] == ["hyprctl", "-j", "devices"]
  assert [call.args[0] for call in process.call_args_list[1:]] == indicator.layout_switches(keyboards)
print("ok - keyboard-only input falls back to compositor layouts")
with patch.object(indicator.Gio, "bus_get_sync", side_effect=indicator.GLib.Error("no bus")), patch.object(indicator.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, stdout=json.dumps({"keyboards": keyboards}))) as process:
  indicator.cycle_input()
  assert [call.args[0] for call in process.call_args_list[1:]] == indicator.layout_switches(keyboards)
print("ok - compositor layouts switch even when the Fcitx bus is unavailable")
state = {"methods": ["keyboard-us", "mozc", "hangul"], "current": "keyboard-us"}
keyboards[1]["active_layout_index"] = 0
assert indicator.cycle_choice(state, keyboards) == ("keyboard-us", 1)
with patch.object(indicator.Gio, "bus_get_sync", return_value=None), patch.object(indicator, "snapshot", return_value=state), patch.object(indicator, "call") as call, patch.object(indicator.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, stdout=json.dumps({"keyboards": keyboards}))) as process:
  indicator.cycle_input()
  call.assert_not_called()
  assert all(command.args[0][-1] == "1" for command in process.call_args_list[1:])
  assert len(process.call_args_list) > 1
keyboards[1]["active_layout_index"] = 1
assert indicator.cycle_choice(state, keyboards) == ("mozc", None)
state["current"] = "mozc"
assert indicator.cycle_choice(state, keyboards) == ("hangul", None)
state["current"] = "hangul"
assert indicator.cycle_choice(state, keyboards) == ("keyboard-us", 0)
with patch.object(indicator.Gio, "bus_get_sync", return_value=None), patch.object(indicator, "snapshot", return_value=state), patch.object(indicator, "call") as call, patch.object(indicator.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, stdout=json.dumps({"keyboards": keyboards}))) as process:
  indicator.cycle_input()
  assert call.call_args.args[2].unpack() == ("keyboard-us",)
  assert all(command.args[0][-1] == "0" for command in process.call_args_list[1:])
print("ok - layouts and composition engines share one cycle and returning to direct input resets the layout")

keyboards = [{"name": "physical", "layout": "us,dk", "active_layout_index": 0}]
live = {"methods": ["keyboard-us", "pinyin"], "current": "", "name": "", "label": "", "language": ""}
selected.clear()
def fake_process(command, **kwargs):
  if command[:3] == ["hyprctl", "-j", "devices"]:
    return subprocess.CompletedProcess(command, 0, stdout=json.dumps({"keyboards": keyboards}))
  keyboards[0]["active_layout_index"] = int(command[-1])
  return subprocess.CompletedProcess(command, 0, stdout="")
with patch.object(indicator, "snapshot", side_effect=lambda bus: dict(live)), patch.object(indicator, "call", side_effect=fake_call), patch.object(indicator.subprocess, "run", side_effect=fake_process):
  reader = indicator.Indicator(None)
  reader.last = "removed-engine"
  reader.select_next()
  assert keyboards[0]["active_layout_index"] == 1
  reader.select_next()
  assert reader.pending == "pinyin" and selected == []
  assert reader.refresh()["current"] == "pinyin"
  live["current"] = "keyboard-us"
  reader.refresh()
  assert selected == ["pinyin"] and reader.pending == ""
  reader.select_next()
  assert keyboards[0]["active_layout_index"] == 0
  assert selected[-1] == "keyboard-us"
print("ok - mixed-layout bar clicks queue an engine without focus and apply it when a text field gains focus")

from unittest.mock import Mock
callback = {}
def register(source, flags, fn):
  callback["read"] = fn
  return 1
def exercise():
  assert callback["read"](None, None) == indicator.GLib.SOURCE_CONTINUE
  assert callback["read"](None, None) == indicator.GLib.SOURCE_CONTINUE
state = {"methods": ["keyboard-us", "pinyin"], "current": "keyboard-us", "name": "English", "label": "en", "language": "en"}
loop = Mock()
loop.run.side_effect = exercise
with patch.object(indicator.GLib, "MainLoop", return_value=loop), patch.object(indicator.GLib, "io_add_watch", side_effect=register), patch.object(indicator.GLib, "timeout_add", return_value=1), patch.object(indicator.GLib, "source_remove"), patch.object(indicator.os, "read", return_value=b"cycle\n"), patch.object(indicator, "snapshot", return_value=state), patch.object(indicator.subprocess, "run", side_effect=[subprocess.CalledProcessError(1, "hyprctl"), subprocess.CompletedProcess([], 0, stdout='{"keyboards": []}')]), patch.object(indicator, "call") as call, patch("builtins.print"):
  indicator.watch(None)
  assert call.call_args.args[1] == "SetCurrentIM"
print("ok - a failed compositor query leaves the bar click reader alive for the next request")

keyboards = [{"name": "physical", "layout": "us,dk", "active_layout_index": 0}]
with patch.object(indicator, "snapshot", side_effect=indicator.GLib.Error("no fcitx")), patch.object(indicator.subprocess, "run", side_effect=fake_process):
  indicator.Indicator(None).select_next()
  assert keyboards[0]["active_layout_index"] == 1
print("ok - the shortcut reader cycles compositor layouts when Fcitx is unavailable")

PY

stubs=$(mktemp -d)
trap 'rm -rf "$stubs"' EXIT
calls="$stubs/calls"
cat >"$stubs/omarchy-shell" <<'SH'
#!/bin/bash
echo "shell $*" >>"$CALLS"
echo "$SHELL_REPLY"
SH
cat >"$stubs/python" <<'SH'
#!/bin/bash
echo "python ${*##*/}" >>"$CALLS"
SH
chmod +x "$stubs/omarchy-shell" "$stubs/python"

CALLS=$calls SHELL_REPLY=ok PATH="$stubs:$PATH" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-input-method" cycle
[[ $(<"$calls") == "shell shell cycleInput" ]] || fail "Super+I goes through the shell's reader" "$(<"$calls")"
pass "Super+I goes through the shell's reader, which retains a choice made without focus"

: >"$calls"
CALLS=$calls SHELL_REPLY="" PATH="$stubs:$PATH" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-input-method" cycle
[[ $(<"$calls") == $'shell shell cycleInput\npython indicator.py cycle' ]] || fail "Super+I switches directly without the shell" "$(<"$calls")"
pass "Super+I switches directly when the shell does not answer"
