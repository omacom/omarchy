"""Regression fixtures for acceptance cleanup and notification attribution."""

from pathlib import Path
import runpy
import subprocess
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
state = runpy.run_path(str(ROOT / "test/acceptance.d/input-method-state.py"))
notifications = runpy.run_path(str(ROOT / "test/acceptance.d/input-method-notifications.py"))


class AcceptanceHelpers(unittest.TestCase):
  def setUp(self):
    self.temp = tempfile.TemporaryDirectory()
    self.addCleanup(self.temp.cleanup)
    self.root = Path(self.temp.name)

  def test_nested_linked_settings_restore_targets_links_and_modes(self):
    config = self.root / "fcitx5"
    config.mkdir()
    target = self.root / "dotfiles-config"
    target.write_text("custom switching keys")
    target.chmod(0o600)
    link = config / "config"
    link.symlink_to("../dotfiles-config")
    profile = config / "profile"
    profile.write_text("custom input methods")
    snapshot = self.root / "snapshot"
    state["backup"](snapshot, [config])
    target.write_text("test keys")
    target.chmod(0o644)
    profile.write_text("test methods")
    (config / "new-engine.conf").write_text("created by test")
    state["restore"](snapshot)
    self.assertTrue(link.is_symlink())
    self.assertEqual(link.readlink(), Path("../dotfiles-config"))
    self.assertEqual(target.read_text(), "custom switching keys")
    self.assertEqual(target.stat().st_mode & 0o777, 0o600)
    self.assertEqual(profile.read_text(), "custom input methods")
    self.assertFalse((config / "new-engine.conf").exists())

  def test_directory_links_and_external_font_preferences_are_restored(self):
    target = self.root / "dotfiles"
    target.mkdir()
    (target / "profile").write_text("original")
    config = self.root / "fcitx5"
    config.symlink_to(target)
    font_target = self.root / "font-preference"
    font_target.write_text("original font")
    font = self.root / "font.conf"
    font.symlink_to(font_target)
    snapshot = self.root / "snapshot"
    state["backup"](snapshot, [config, font])
    (target / "profile").write_text("changed")
    font_target.write_text("test font")
    state["restore"](snapshot)
    self.assertTrue(config.is_symlink())
    self.assertTrue(font.is_symlink())
    self.assertEqual((target / "profile").read_text(), "original")
    self.assertEqual(font_target.read_text(), "original font")

  def test_missing_targets_and_paths_remain_missing(self):
    absent = self.root / "absent"
    target = self.root / "missing-target"
    link = self.root / "dangling"
    link.symlink_to(target)
    snapshot = self.root / "snapshot"
    state["backup"](snapshot, [absent, link])
    absent.mkdir()
    (absent / "test").write_text("new")
    target.write_text("created through link")
    state["restore"](snapshot)
    self.assertFalse(absent.exists())
    self.assertTrue(link.is_symlink())
    self.assertFalse(target.exists())

  def test_failed_restore_still_restarts_the_service(self):
    script = (ROOT / "test/acceptance.d/input-methods-test.sh").read_text()
    cleanup = "cleanup() {" + script.split("cleanup() {", 1)[1].split("\n}\ntrap cleanup", 1)[0] + "\n}"
    commands = """
notification_monitor=""
work=$1
close_windows() { :; }
systemctl() { printf '%s\n' "$*" >> "$work/service.log"; }
python() { return 1; }
busctl() { :; }
"""
    result = subprocess.run(["bash", "-ec", commands + cleanup + "\ncleanup", "test", str(self.root)], capture_output=True, text=True)
    self.assertEqual(result.returncode, 1)
    self.assertIn("start omarchy-fcitx5.service", (self.root / "service.log").read_text())
    self.assertIn("snapshot retained", result.stderr)

  def test_unchanged_link_targets_are_not_rewritten(self):
    target = self.root / "read-only-config"
    target.write_text("unchanged")
    target.chmod(0o444)
    link = self.root / "config"
    link.symlink_to(target)
    snapshot = self.root / "snapshot"
    state["backup"](snapshot, [link])
    with patch.object(Path, "unlink", side_effect=PermissionError("read-only")):
      state["restore"](snapshot)
    self.assertTrue(link.is_symlink())
    self.assertEqual(target.read_text(), "unchanged")

  def test_new_parent_directories_are_removed(self):
    service = self.root / "dbus-1/services/org.fcitx.Fcitx5.service"
    snapshot = self.root / "snapshot"
    state["backup"](snapshot, [service])
    service.parent.mkdir(parents=True)
    service.write_text("created by setup")
    state["restore"](snapshot)
    self.assertFalse((self.root / "dbus-1").exists())

  def test_notifications_follow_process_ownership_across_restarts(self):
    def call(sender, app, body):
      return f'''method call time=1 sender={sender} -> destination=org.freedesktop.Notifications serial=1 path=/org/freedesktop/Notifications; interface=org.freedesktop.Notifications; member=Notify
   string "{app}"
   uint32 0
   string "icon"
   string "summary"
   string "{body}"
'''
    reminder = call(":1.99", "Fcitx", "unrelated reminder")
    first = call(":1.42", "Input Method", "input setup prompt")
    second = call(":1.43", "拼音", "cloud input prompt")
    changed = '''signal time=2 sender=org.freedesktop.DBus -> destination=(null destination) serial=2 path=/org/freedesktop/DBus; interface=org.freedesktop.DBus; member=NameOwnerChanged
   string "org.fcitx.Fcitx5"
   string ":1.42"
   string ":1.43"
'''
    selected = list(notifications["input_notifications"](reminder + first + changed + second, ":1.42"))
    self.assertEqual(selected, [first, second])
    self.assertEqual(list(notifications["input_notifications"](reminder, ":1.42")), [])
    self.assertEqual(list(notifications["input_notifications"]("", ":1.42")), [])



if __name__ == "__main__":
  unittest.main()
