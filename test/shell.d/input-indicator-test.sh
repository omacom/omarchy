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
  assert indicator.cycle_choice({"current": current, "methods": methods}, [])[0] == expected

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

with patch.object(indicator, "snapshot", return_value={"methods": ["keyboard-us", "keyboard-fr"], "current": "keyboard-us"}), patch.object(indicator, "call") as call, patch.object(indicator.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, stdout='{"keyboards": []}')) as process:
  indicator.Indicator(None).select_next()
  assert call.call_args_list[0].args[2].unpack() == ("keyboard-fr",)
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
def reader_cycle(state, keyboards):
  with patch.object(indicator, "snapshot", return_value=dict(state)), patch.object(indicator, "call") as call, patch.object(indicator.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, stdout=json.dumps({"keyboards": keyboards}))) as process:
    indicator.Indicator(None).select_next()
  return call, [command.args[0] for command in process.call_args_list[1:]]

call, commands = reader_cycle({"methods": ["keyboard-us"], "current": "keyboard-us"}, keyboards)
assert commands == indicator.layout_switches(keyboards)
print("ok - keyboard-only input falls back to compositor layouts")
state = {"methods": ["keyboard-us", "mozc", "hangul"], "current": "keyboard-us"}
keyboards[1]["active_layout_index"] = 0
assert indicator.cycle_choice(state, keyboards) == ("keyboard-us", 1)
call, commands = reader_cycle(state, keyboards)
assert commands and all(command[-1] == "1" for command in commands)
assert all(item.args[2].unpack() == ("keyboard-us",) for item in call.call_args_list if item.args[1] == "SetCurrentIM")
keyboards[1]["active_layout_index"] = 1
assert indicator.cycle_choice(state, keyboards) == ("mozc", None)
state["current"] = "mozc"
assert indicator.cycle_choice(state, keyboards) == ("hangul", None)
state["current"] = "hangul"
assert indicator.cycle_choice(state, keyboards) == ("keyboard-us", 0)
call, commands = reader_cycle(state, keyboards)
assert call.call_args_list[0].args[2].unpack() == ("keyboard-us",)
assert all(command[-1] == "0" for command in commands)
print("ok - layouts and composition engines share one cycle and returning to direct input resets the layout")

# Restore the group's base layout before activating an engine, in either direction.
for layouts, variants, primary in [
  ("us,ara", ",", "keyboard-us"),
  ("us,ru", ",", "keyboard-us"),
  ("us,gr", ",", "keyboard-us"),
  ("us,fr", ",", "keyboard-us"),
  ("fr,ara", "oss,", "keyboard-fr-oss"),
  ("jp,ru", ",", "keyboard-jp"),
]:
  for engine in ("mozc", "pinyin", "hangul", "chewing", "cangjie5"):
    for step in (1, -1):
      seat = [
        {"name": "physical", "layout": layouts, "variant": variants, "active_layout_index": 1 if step == 1 else 0},
        {"name": "second keyboard", "layout": layouts, "variant": variants, "active_layout_index": 1 if step == 1 else 0},
        {"name": "custom", "layout": "de,fr", "active_layout_index": 1},
      ]
      state = {"methods": [primary, engine], "current": primary}
      switches = []
      def switch_layout(command, **kwargs):
        if command[:3] == ["hyprctl", "-j", "devices"]:
          return subprocess.CompletedProcess(command, 0, stdout=json.dumps({"keyboards": seat}))
        switches.append(command)
        keyboard = next(item for item in seat if item["name"] == command[2])
        keyboard["active_layout_index"] = int(command[3])
        return subprocess.CompletedProcess(command, 0)
      def activate_engine(bus, method, args=None):
        assert method == "SetCurrentIM" and args.unpack() == (engine,)
        assert all(item["active_layout_index"] == 0 for item in seat[:2]), (layouts, engine, step, seat)
        state["current"] = engine
        return ()
      with (
        patch.object(indicator, "snapshot", side_effect=lambda bus: dict(state)),
        patch.object(indicator, "call", side_effect=activate_engine),
        patch.object(indicator.subprocess, "run", side_effect=switch_layout),
      ):
        reader = indicator.Indicator(None)
        reader.select_next(step)
      assert switches == [["hyprctl", "switchxkblayout", item["name"], "0"] for item in seat[:2]]
      assert state["current"] == engine and reader.pending == ""
      assert seat[2]["active_layout_index"] == 1
print("ok - composition engines start on the configured base layout in either direction")

for current, step, target in [("mozc", 1, "hangul"), ("hangul", -1, "mozc")]:
  seat = [{"name": "physical", "layout": "us,ara", "active_layout_index": 1}]
  state = {"methods": ["keyboard-us", "mozc", "hangul"], "current": current}
  devices = subprocess.CompletedProcess([], 0, stdout=json.dumps({"keyboards": seat}))
  with (
    patch.object(indicator, "snapshot", return_value=state),
    patch.object(indicator, "call") as call,
    patch.object(indicator.subprocess, "run", return_value=devices) as process,
  ):
    indicator.Indicator(None).select_next(step)
  commands = [command.args[0] for command in process.call_args_list[1:]]
  assert commands == [["hyprctl", "switchxkblayout", "physical", "0"]]
  assert call.call_args_list[0].args[2].unpack() == (target,)
print("ok - cycling between engines also restores the base layout")

state = {"methods": ["keyboard-us", "mozc"], "current": "keyboard-us"}
seat = [{"name": "physical", "layout": "us,ara", "active_layout_index": 1}]
devices = subprocess.CompletedProcess([], 0, stdout=json.dumps({"keyboards": seat}))
with (
  patch.object(indicator, "snapshot", return_value=state),
  patch.object(indicator, "call") as call,
  patch.object(indicator.subprocess, "run", side_effect=[devices, subprocess.CalledProcessError(1, "hyprctl")]),
):
  try:
    indicator.Indicator(None).select_next()
  except subprocess.CalledProcessError:
    pass
  else:
    raise AssertionError("a failed layout reset must not activate the engine")
  call.assert_not_called()
print("ok - a failed layout reset prevents engine activation")

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
  assert keyboards[0]["active_layout_index"] == 0
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
with patch.object(indicator.GLib, "MainLoop", return_value=loop), patch.object(indicator.GLib, "io_add_watch", side_effect=register), patch.object(indicator.GLib, "timeout_add", return_value=1), patch.object(indicator.GLib, "source_remove"), patch.object(indicator.os, "read", return_value=b"cycle\n"), patch.object(indicator, "snapshot", return_value=state), patch.object(indicator.subprocess, "run", side_effect=[subprocess.CalledProcessError(1, "hyprctl"), subprocess.CompletedProcess([], 0, stdout='{"keyboards": []}')]), patch.object(indicator, "call") as call, patch.object(indicator, "follow"), patch("builtins.print"):
  indicator.watch(None)
  assert call.call_args.args[1] == "SetCurrentIM"
print("ok - a failed compositor query leaves the bar click reader alive for the next request")

keyboards = [{"name": "physical", "layout": "us,dk", "active_layout_index": 0}]
with patch.object(indicator, "snapshot", side_effect=indicator.GLib.Error("no fcitx")), patch.object(indicator.subprocess, "run", side_effect=fake_process):
  indicator.Indicator(None).select_next()
  assert keyboards[0]["active_layout_index"] == 1
print("ok - the shortcut reader cycles compositor layouts when Fcitx is unavailable")

keyboards = [{"name": "physical", "layout": "us,dk", "active_layout_index": 0}]
state = {"methods": ["keyboard-us", "mozc", "hangul"], "current": "keyboard-us"}
assert indicator.cycle_choice(state, keyboards) == ("keyboard-us", 1)
assert indicator.cycle_choice(state, keyboards, -1) == ("hangul", None)
state["current"] = "mozc"
assert indicator.cycle_choice(state, keyboards, -1) == ("keyboard-us", 1)
assert indicator.cycle_choice({"methods": ["keyboard-us", "mozc", "hangul"], "current": "keyboard-us"}, [], -1) == ("hangul", None)
assert indicator.layout_switches(keyboards, step=-1)[0][-1] == "1"
print("ok - cycling back walks the same choices in reverse")

# The reader in a real GLib loop, against a real profile file: Fcitx itself is
# replaced by `live`, which a configuration change edits before saving.
import sys
import tempfile
scratch = tempfile.TemporaryDirectory()
config_home = scratch.name + "/config"
os.makedirs(config_home + "/fcitx5")

# Saved the way Fcitx and configure.py save it: a new file renamed over the old.
def save():
  path = config_home + "/fcitx5/profile"
  with open(path + ".tmp", "w") as file:
    file.write("[Groups/0]\nName=Default\n# " + ",".join(live["methods"]) + "\n")
  os.replace(path + ".tmp", path)

live = {"methods": ["keyboard-us"], "current": "keyboard-us", "name": "English", "label": "en", "language": "en"}
save()
groups = ["Default"]
timers, reader, reads, failures, group_failures = [], {}, [0], [0], [0]
real_timeout = indicator.GLib.timeout_add
real_io_add_watch = indicator.GLib.io_add_watch

# Run the reader's cadences at a fifth of their length; timers keeps the
# requested intervals, which is what the cadence assertions check.
def timeout(interval, fn):
  timers.append(interval)
  return real_timeout(max(1, round(interval * 0.2)), fn)

def register_reader(source, *args):
  # GLib's own loop.run() watches a signal pipe through the same call.
  if source is not sys.stdin:
    return real_io_add_watch(source, *args)
  reader["read"] = args[-1]
  return 1

# The shell closing stdin is what ends the reader.
def close_stdin():
  with patch.object(indicator.os, "read", return_value=b""):
    reader["read"](None, None)

def snapshot(bus):
  reads[0] += 1
  if failures[0]:
    failures[0] -= 1
    raise indicator.GLib.Error("timed out")
  return dict(live, methods=list(live["methods"]))

def fake_call(bus, method, args=None):
  assert method == "InputMethodGroups", method
  if group_failures[0]:
    group_failures[0] -= 1
    raise indicator.GLib.Error("timed out")
  return (list(groups),)

# GLib swallows exceptions raised in callbacks, so keep them for the end.
errors = []
def step(seconds, then):
  def run():
    try:
      then()
    except Exception as error:
      errors.append(error)
      close_stdin()
    return False
  real_timeout(int(seconds * 1000), run)

state_lines = []
def output(line, flush=False):
  state_lines.append(json.loads(line))

def methods():
  return state_lines[-1]["methods"]

def scenario():
  # One method in one group: the startup read is all, until the profile changes.
  def single_method_settled():
    assert [line["methods"] for line in state_lines] == [["keyboard-us"]], state_lines
    assert 500 not in timers and 50 not in timers, timers
    live["methods"] = ["keyboard-us", "mozc"]
    save()
    step(0.2, after_save)
  def after_save():
    assert methods() == ["keyboard-us", "mozc"], state_lines
    assert 500 in timers, timers
    live["current"] = "mozc"
    step(0.25, after_switch)
  def after_switch():
    # With two methods, a switch made inside an application is read on the next poll.
    assert state_lines[-1]["current"] == "mozc", state_lines
    # A save while polling replaces the poll rather than starting a second one.
    save()
    step(0.15, count_polls)
  def count_polls():
    reads[0] = 0
    step(0.4, polls_counted)
  def polls_counted():
    assert reads[0] <= 5, f"{reads[0]} reads in 0.4 s"
    live["methods"], live["current"] = ["keyboard-us"], "keyboard-us"
    save()
    step(0.2, back_to_one)
  def back_to_one():
    assert methods() == ["keyboard-us"], state_lines
    # A read that fails while the service runs is retried rather than left blank.
    failures[0] = 1
    save()
    step(0.2, after_failed_read)
  def after_failed_read():
    assert methods() == [], state_lines
    step(0.6, recovered)
  def recovered():
    assert methods() == ["keyboard-us"], state_lines
    # A group count that times out keeps the reading on the bar.
    group_failures[0] = 1
    save()
    step(0.2, after_failed_group_count)
  def after_failed_group_count():
    assert methods() == ["keyboard-us"], state_lines
    close_stdin()
  step(0.3, single_method_settled)

os.environ.pop("FCITX_CONFIG_HOME", None)
with patch.dict(os.environ, {"XDG_CONFIG_HOME": config_home}), \
     patch.object(indicator, "snapshot", side_effect=snapshot), \
     patch.object(indicator, "call", side_effect=fake_call), \
     patch.object(indicator.Gio, "bus_watch_name_on_connection", return_value=1), \
     patch.object(indicator.GLib, "io_add_watch", side_effect=register_reader), \
     patch.object(indicator.GLib, "timeout_add", side_effect=timeout), \
     patch("builtins.print", side_effect=output):
  step(0, scenario)
  step(8, lambda: errors.append(AssertionError("timed out")) or close_stdin())
  indicator.watch(None)
assert not errors, errors
print("ok - one input method is read once and again on a profile save, and several are polled for switches")
print("ok - an event during polling replaces the poll, a failed read is retried, and a failed group count keeps the reading")

# A profile linked into dotfiles is saved by replacing the link's target, which
# the watch on the target sees.
os.makedirs(scratch.name + "/dotfiles")
os.replace(config_home + "/fcitx5/profile", scratch.name + "/dotfiles/profile")
os.symlink("../../dotfiles/profile", config_home + "/fcitx5/profile")
linked = []
with patch.dict(os.environ, {"XDG_CONFIG_HOME": config_home}):
  context = indicator.GLib.MainContext.new()
  context.push_thread_default()
  profile_watch = indicator.ProfileWatch(lambda: linked.append("changed"))
  import time
  def pump(seconds):
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
      context.iteration(False)
      time.sleep(0.01)
  # Let events from setting up the link go by first.
  pump(0.3)
  linked.clear()
  with open(scratch.name + "/dotfiles/profile.tmp", "w") as file:
    file.write("[Groups/0]\n")
  os.replace(scratch.name + "/dotfiles/profile.tmp", scratch.name + "/dotfiles/profile")
  pump(0.3)
  context.pop_thread_default()
assert linked, "a save through a linked profile is seen"
print("ok - a profile linked into dotfiles is watched at its target")

with patch.dict(os.environ, {"XDG_CONFIG_HOME": "/xdg", "FCITX_CONFIG_HOME": "/fcitx"}):
  assert indicator.profile_path() == "/fcitx/profile"
  del os.environ["FCITX_CONFIG_HOME"]
  assert indicator.profile_path() == "/xdg/fcitx5/profile"
print("ok - the watched profile follows Fcitx's FCITX_CONFIG_HOME override")

# The profile is the one the Fcitx process saves, whose environment a service
# drop-in can set without the shell knowing; the watch moves there when the
# bus name gains an owner.
os.makedirs(scratch.name + "/daemon/fcitx")
daemon = subprocess.Popen(["sleep", "30"], cwd=scratch.name,
                          env={"HOME": scratch.name, "FCITX_CONFIG_HOME": "daemon/fcitx"})
class OwnerBus:
  def call_sync(self, name, path, interface, method, args, *rest):
    assert method == "GetConnectionUnixProcessID" and args.unpack() == (indicator.BUS,)
    return indicator.GLib.Variant("(u)", (daemon.pid,))
try:
  owner = indicator.owner_environment(OwnerBus())
  assert indicator.profile_path(owner) == scratch.name + "/daemon/fcitx/profile", indicator.profile_path(owner)
  appeared, watched = {}, []
  real_new_for_path = indicator.Gio.File.new_for_path
  def watch_name(bus, name, flags, on_appeared, on_vanished):
    appeared["callback"] = on_appeared
    return 1
  def recording_new_for_path(path):
    watched.append(path)
    return real_new_for_path(path)
  with patch.object(indicator.Gio, "bus_watch_name_on_connection", side_effect=watch_name), \
       patch.object(indicator.Gio.File, "new_for_path", side_effect=recording_new_for_path):
    indicator.follow(OwnerBus(), lambda: None, lambda present: None)
    appeared["callback"]()
  assert watched[-1] == scratch.name + "/daemon/fcitx/profile", watched
finally:
  daemon.kill()
  daemon.wait()
print("ok - the watch follows the profile of the process that owns Fcitx's bus name")

scratch.cleanup()

groups.append("Second")
with patch.object(indicator, "call", return_value=(groups,)):
  assert indicator.Indicator(None).switchable(["keyboard-us"])
  groups.pop()
  assert not indicator.Indicator(None).switchable(["keyboard-us"])
  assert indicator.Indicator(None).switchable(["keyboard-us", "mozc"])
  assert indicator.Indicator(None).switchable(["pinyin"])
print("ok - a second group or a lone composition engine keeps polling, since neither switch has a signal")

PY

stubs=$(mktemp -d)
trap 'rm -rf "$stubs"' EXIT
calls="$stubs/calls"
cat >"$stubs/omarchy-shell" <<'SH'
#!/bin/bash
echo "shell $*" >>"$CALLS"
echo "$SHELL_REPLY"
SH
chmod +x "$stubs/omarchy-shell"

CALLS=$calls SHELL_REPLY=ok PATH="$stubs:$PATH" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-input-method" cycle
[[ $(<"$calls") == "shell shell cycleInput next" ]] || fail "Super+I goes through the shell's reader" "$(<"$calls")"
pass "Super+I goes through the shell's reader, which retains a choice made without focus"

if CALLS=$calls SHELL_REPLY="not running" PATH="$stubs:$PATH" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-input-method" cycle 2>/dev/null; then
  fail "Super+I reports a missing input reader"
fi
pass "Super+I reports a missing input reader instead of silently doing nothing"

: >"$calls"
CALLS=$calls SHELL_REPLY=ok PATH="$stubs:$PATH" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-input-method" cycle back
[[ $(<"$calls") == "shell shell cycleInput back" ]] || fail "Super+Shift+I cycles back" "$(<"$calls")"
if CALLS=$calls PATH="$stubs:$PATH" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-input-method" cycle sideways 2>/dev/null; then
  fail "an unknown cycle direction is rejected"
fi
pass "Super+Shift+I cycles back through the shell, and other directions are rejected"
