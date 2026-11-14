#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

OMARCHY_PATH="$ROOT" python3 - <<'PY'
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

root = Path(os.environ["OMARCHY_PATH"])
sys.path.insert(0, str(root / "default/input-methods"))
spec = importlib.util.spec_from_file_location("input_osd", root / "default/input-methods/osd.py")
osd = importlib.util.module_from_spec(spec)
spec.loader.exec_module(osd)


class MigrationTest(unittest.TestCase):
  def setUp(self):
    self.scratch = tempfile.TemporaryDirectory()
    self.addCleanup(self.scratch.cleanup)
    self.home = Path(self.scratch.name)
    self.config_home = self.home / "config"
    self.config = self.config_home / "fcitx5/config"
    self.config.parent.mkdir(parents=True)
    self.environment = patch.dict(os.environ, {
      "HOME": str(self.home), "XDG_CONFIG_HOME": str(self.config_home),
      "XDG_DATA_HOME": str(self.home / "data"), "FCITX_CONFIG_HOME": ""})
    self.environment.start()
    self.addCleanup(self.environment.stop)
    for target, value in (("owner_environment", None), ("call", ())):
      mock = patch.object(osd, target, return_value=value)
      setattr(self, target, mock.start())
      self.addCleanup(mock.stop)
    bus = patch.object(osd.Gio, "bus_get_sync", return_value=object())
    bus.start()
    self.addCleanup(bus.stop)

  def test_only_notices_change_and_retry_is_a_noop(self):
    before = "# custom keys\n[Hotkey/TriggerKeys]\n0=Alt+space\n\n[Behavior]\nActiveByDefault=True\nShareInputState=No\nShowInputMethodInformation=True\nshowInputMethodInformationWhenFocusIn=True\n\n[Other]\nPageSize=7\n"
    expected = before.replace("ShowInputMethodInformation=True", "ShowInputMethodInformation=False").replace("showInputMethodInformationWhenFocusIn=True", "showInputMethodInformationWhenFocusIn=False")
    self.config.write_text(before)
    profile = self.config.with_name("profile")
    profile.write_text("custom groups and overrides\n")
    candidate = self.config.parent / "conf/classicui.conf"
    candidate.parent.mkdir()
    candidate.write_text("Theme=custom\nVertical Candidate List=True\n")
    osd.migrate()
    self.assertEqual(self.config.read_text(), expected)
    timestamp = self.config.stat().st_mtime_ns
    osd.migrate()
    self.assertEqual(self.config.stat().st_mtime_ns, timestamp)
    self.call.assert_called_once_with(unittest.mock.ANY, "ReloadConfig")
    self.assertEqual(profile.read_text(), "custom groups and overrides\n")
    self.assertEqual(candidate.read_text(), "Theme=custom\nVertical Candidate List=True\n")

  def test_missing_settings_and_header_without_newline(self):
    for before in ("", "[Behavior]", "[Behavior]\nActiveByDefault=False\n", "[Other]\nPageSize=7\n"):
      with self.subTest(before=before):
        after = osd.without_notices(before)
        self.assertEqual(after.count("[Behavior]"), 1)
        self.assertEqual(after.count("ShowInputMethodInformation=False"), 1)
        self.assertEqual(after.count("showInputMethodInformationWhenFocusIn=False"), 1)
        self.assertEqual(osd.without_notices(after), after)

  def test_link_and_mode_are_preserved(self):
    target = self.home / "dotfiles-config"
    target.write_text("[Behavior]\nActiveByDefault=True\n")
    target.chmod(0o600)
    self.config.symlink_to(target)
    osd.migrate()
    self.assertTrue(self.config.is_symlink())
    self.assertEqual(target.stat().st_mode & 0o777, 0o600)
    self.assertIn("ShowInputMethodInformation=False", target.read_text())

  def test_disabled_or_replaced_osd_keeps_native_feedback(self):
    shell = self.config_home / "omarchy/shell.json"
    shell.parent.mkdir()
    shell.write_text(json.dumps({"disabledPlugins": ["omarchy.osd"]}))
    self.config.write_text("[Behavior]\nShowInputMethodInformation=True\n")
    before = self.config.read_bytes()
    osd.migrate()
    self.assertEqual(self.config.read_bytes(), before)
    self.call.assert_not_called()

  def test_live_service_config_override_is_followed(self):
    directory = self.home / "service-config"
    self.owner_environment.return_value = ({"HOME": str(self.home), "FCITX_CONFIG_HOME": str(directory)}, str(self.home))
    osd.migrate()
    self.assertTrue((directory / "config").exists())
    self.assertFalse(self.config.exists())

  def test_offline_migration_persists_for_login(self):
    with patch.object(osd.Gio, "bus_get_sync", side_effect=osd.GLib.Error("no session bus")):
      osd.migrate()
    self.assertIn("ShowInputMethodInformation=False", self.config.read_text())
    self.call.assert_not_called()

  def test_reload_failure_rolls_back_and_can_be_retried(self):
    for original in (None, "[Behavior]\nActiveByDefault=True\n"):
      with self.subTest(original=original):
        self.config.unlink(missing_ok=True)
        if original is not None:
          self.config.write_text(original)
        self.call.side_effect = osd.GLib.Error("reload timed out")
        with self.assertRaises(osd.GLib.Error):
          osd.migrate()
        self.assertEqual(self.config.read_text() if self.config.exists() else None, original)
        self.call.side_effect = None
        osd.migrate()
        self.assertIn("ShowInputMethodInformation=False", self.config.read_text())

  def test_migration_on_private_bus_does_not_activate_fcitx(self):
    service = self.home / "data/dbus-1/services/org.fcitx.Fcitx5.service"
    service.parent.mkdir(parents=True)
    sentinel = self.home / "activated"
    service.write_text(f"[D-BUS Service]\nName=org.fcitx.Fcitx5\nExec=/usr/bin/touch {sentinel}\n")
    environment = dict(os.environ)
    environment.pop("DBUS_SESSION_BUS_ADDRESS", None)
    result = subprocess.run(["dbus-run-session", "--", "bash", "-euo", "pipefail", str(root / "migrations/1792146225.sh")],
                            env=environment, capture_output=True, text=True, timeout=10)
    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
    self.assertFalse(sentinel.exists(), "migration activated the stopped input daemon")
    self.assertIn("ShowInputMethodInformation=False", self.config.read_text())


unittest.main()
PY
