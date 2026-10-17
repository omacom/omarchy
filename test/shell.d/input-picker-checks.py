"""The bar picker uses the existing input reader and native setup commands."""

import importlib.util
import os
from pathlib import Path
import sys
import tempfile
import subprocess
import time
import unittest
from unittest.mock import Mock, patch

ROOT = Path(os.environ["OMARCHY_PATH"])
sys.path.insert(0, str(ROOT / "default/input-methods"))
spec = importlib.util.spec_from_file_location("indicator", ROOT / "default/input-methods/indicator.py")
indicator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(indicator)


class InputPickerTest(unittest.TestCase):
  def setUp(self):
    self.reader = indicator.Indicator(None)
    self.state = {"methods": ["keyboard-us", "mozc"], "current": "keyboard-us"}
    self.keyboards = [
      {"name": "typing", "address": "one", "layout": "us,fr", "variant": "intl,", "active_layout_index": 0},
      {"name": "consumer", "address": "two", "layout": "us,fr", "variant": "intl,", "active_layout_index": 1},
      {"name": "custom", "address": "three", "layout": "de", "variant": "", "active_layout_index": 0},
    ]
    self.scope = indicator.picker_scope(self.state, self.keyboards)

  def test_rows_include_explicit_variants_and_composition_engines(self):
    rows = indicator.picker_rows(self.state, self.keyboards,
                                 {"us:intl": "English international", "fr": "French"}, {"mozc": "Japanese"})
    self.assertEqual(rows, {"English international\tus:intl": ("keyboard-us", 0),
                            "French\tfr": ("keyboard-us", 1), "Japanese\tmozc": ("mozc", None)})

  def test_incomplete_compositor_replies_do_not_select_an_input(self):
    for output in ('{}', '[]', '{"keyboards": {}}', '{"keyboards": [null]}'):
      result = subprocess.CompletedProcess([], 0, stdout=output)
      with self.subTest(output=output), patch.object(indicator.subprocess, "run", return_value=result), patch.object(
          indicator, "call") as call:
        with self.assertRaisesRegex(ValueError, "could not be read"):
          self.reader.picker_state()
        call.assert_not_called()

  def test_without_fcitx_the_same_layout_choices_are_available(self):
    rows = indicator.picker_rows({}, self.keyboards, {"fr": "French"}, {})
    self.assertEqual(rows["French\tfr"], ("", 1))

  def test_explicit_selection_synchronizes_the_existing_seat_and_keeps_custom_devices(self):
    with patch.object(self.reader, "picker_state", return_value=(self.state, self.keyboards)), patch.object(
        self.reader, "refresh") as refresh, patch.object(indicator.subprocess, "run") as run:
      self.reader.select_choice(("keyboard-us", 1), self.scope)
    commands = [call.args[0] for call in run.call_args_list]
    self.assertEqual(commands, [["hyprctl", "switchxkblayout", "typing", "1"],
                                ["hyprctl", "switchxkblayout", "consumer", "1"]])
    refresh.assert_called_once()

  def test_reconnect_keymap_and_input_group_changes_reject_stale_indices(self):
    for change in ("address", "variant", "methods"):
      state = {**self.state}
      keyboards = [dict(item) for item in self.keyboards]
      if change == "methods":
        state["methods"] = ["keyboard-us", "hangul"]
      else:
        keyboards[0][change] = "changed"
      with self.subTest(change=change), patch.object(self.reader, "picker_state", return_value=(state, keyboards)), patch.object(
          indicator.subprocess, "run") as run:
        with self.assertRaisesRegex(ValueError, "Open the picker again"):
          self.reader.select_choice(("keyboard-us", 1), self.scope)
        run.assert_not_called()

  def test_engine_selection_remains_pending_until_an_application_has_focus(self):
    live = {**self.state, "current": ""}
    entries = [("keyboard-us", "English", "", "", "en", "en"),
               ("mozc", "Japanese", "", "", "ja", "ja")]
    with patch.object(self.reader, "picker_state", return_value=(live, self.keyboards)), patch.object(
        indicator, "snapshot", side_effect=lambda _: dict(live)), patch.object(indicator, "call", return_value=(entries,)) as call:
      self.reader.select_choice(("mozc", None), self.scope)
      self.assertEqual(self.reader.pending, "mozc")
      self.assertFalse(any(item.args[1] == "SetCurrentIM" for item in call.call_args_list))
      live["current"] = "keyboard-us"
      self.reader.refresh()
      self.assertEqual(call.call_args.args[1], "SetCurrentIM")
      self.assertEqual(call.call_args.args[2].unpack(), ("mozc",))

  def menu(self, output, successful=True):
    process = Mock()
    process.communicate_utf8_finish.return_value = (True, output, None)
    process.get_successful.return_value = successful
    return process

  def open(self, process):
    changed = Mock()
    with patch.object(self.reader, "picker_state", return_value=(self.state, self.keyboards)), patch.object(
        indicator, "call", return_value=([("keyboard-us", "English"), ("mozc", "Japanese")],)), patch.object(
        indicator.Gio.Subprocess, "new", return_value=process) as spawn:
      self.reader.open_picker(changed)
      self.reader.open_picker(changed)
      spawn.assert_called_once()
      self.assertIn("✓\tFrench\tfr", spawn.call_args.args[0])
    self.assertIs(self.reader.menu, process)
    return process.communicate_utf8_async.call_args.args[2], changed

  def test_menu_is_asynchronous_and_cancellation_does_not_select_or_save(self):
    process = self.menu("", False)
    finished, changed = self.open(process)
    with patch.object(self.reader, "select_choice") as select:
      finished(process, None)
    select.assert_not_called()
    self.assertIsNone(self.reader.menu)

  def test_editing_reuses_the_upstream_setup_command(self):
    process = self.menu("Edit layouts…\n")
    finished, changed = self.open(process)
    with patch.object(indicator.Gio.Subprocess, "new") as spawn, patch.object(self.reader, "select_choice") as select:
      finished(process, None)
    self.assertEqual(spawn.call_args.args[0], ["omarchy-setup-keyboard"])
    select.assert_not_called()
    changed.assert_called_once()

  def test_menu_selection_is_an_explicit_index_not_a_cycle(self):
    process = self.menu("French\tfr\n")
    finished, changed = self.open(process)
    with patch.object(self.reader, "select_choice") as select:
      finished(process, None)
    select.assert_called_once_with(("keyboard-us", 1), self.scope)
    changed.assert_called_once()

  def test_real_async_process_delivers_a_choice_without_blocking_the_reader(self):
    with tempfile.TemporaryDirectory() as folder:
      command = Path(folder) / "omarchy-menu-select"
      command.write_text("#!/bin/sh\nprintf 'French\\tfr\\n'\n")
      command.chmod(0o700)
      loop = indicator.GLib.MainLoop()
      expired = []
      def timeout():
        expired.append(True)
        loop.quit()
      timer = indicator.GLib.timeout_add(2000, timeout)
      with patch.dict(os.environ, PATH=folder + ":" + os.environ["PATH"]), patch.object(
          self.reader, "picker_state", return_value=(self.state, self.keyboards)), patch.object(
          indicator, "call", return_value=([("keyboard-us", "English"), ("mozc", "Japanese")],)), patch.object(
          self.reader, "select_choice") as select:
        self.reader.open_picker(loop.quit)
        self.assertIsNotNone(self.reader.menu)
        loop.run()
      if not expired:
        indicator.GLib.source_remove(timer)
      self.assertFalse(expired)
      self.assertIsNone(self.reader.menu)
      select.assert_called_once_with(("keyboard-us", 1), self.scope)

  def test_picker_exits_if_its_reader_is_killed_without_cleanup(self):
    with tempfile.TemporaryDirectory() as folder:
      command = Path(folder) / "omarchy-menu-select"
      command.write_text('#!/bin/sh\necho $$ > "$PICKER_PID"\nexec sleep 30\n')
      command.chmod(0o700)
      pid_file = Path(folder) / "picker.pid"
      parent = '''import os, sys, time
from pathlib import Path
sys.path.insert(0, sys.argv[1])
import indicator
reader = indicator.Indicator(None)
reader.picker_state = lambda: ({}, [])
reader.open_picker(lambda: None)
for _ in range(100):
  if Path(os.environ['PICKER_PID']).exists():
    os._exit(0)
  time.sleep(0.02)
os._exit(1)
'''
      environment = {**os.environ, "PATH": folder + ":" + os.environ["PATH"], "PICKER_PID": str(pid_file)}
      subprocess.run([sys.executable, "-B", "-c", parent, str(ROOT / "default/input-methods")],
                     env=environment, check=True, timeout=5)
      pid = int(pid_file.read_text())
      def running():
        try:
          return Path(f"/proc/{pid}/stat").read_text().split(") ", 1)[1][0] != "Z"
        except FileNotFoundError:
          return False
      for _ in range(50):
        if not running():
          break
        time.sleep(0.02)
      alive = running()
      if alive:
        os.kill(pid, 9)
      self.assertFalse(alive, "the picker outlived an abruptly terminated reader")


if __name__ == "__main__":
  unittest.main()
