import argparse
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(os.environ["OMARCHY_PATH"])
spec = importlib.util.spec_from_file_location("input_setup", ROOT / "default/input-methods/configure.py")
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)


class InputMethodTest(unittest.TestCase):
  def test_pinyin_defaults_suppress_cloud_prompt(self):
    setup.defaults(self.config, fresh=True)
    pinyin = setup.values((self.config / "fcitx5/conf/pinyin.conf").read_text())
    self.assertEqual(pinyin["FirstRun"], "False")
    self.assertEqual(pinyin["CloudPinyinEnabled"], "False")

  def test_pinyin_prompt_suppression_preserves_existing_preferences(self):
    pinyin = self.config / "fcitx5/conf/pinyin.conf"
    pinyin.parent.mkdir(parents=True)
    pinyin.write_text("FirstRun=True\nCloudPinyinEnabled=True\nPageSize=7\n")
    setup.defaults(self.config)
    self.assertEqual(pinyin.read_text(), "FirstRun=False\nCloudPinyinEnabled=True\nPageSize=7\n")

  def setUp(self):
    self.temporary = tempfile.TemporaryDirectory()
    self.addCleanup(self.temporary.cleanup)
    self.home = Path(self.temporary.name)
    self.config = self.home / "config"
    self.vconsole = self.home / "vconsole"
    self.preference = self.home / "preference"
    self.vconsole.write_text("XKBLAYOUT=us\n")
    self.preference.write_text("INPUT_METHOD=none\n")
    env = {"XDG_CONFIG_HOME": str(self.config), "XDG_DATA_HOME": str(self.home / "data"), "OMARCHY_VCONSOLE": str(self.vconsole), "OMARCHY_INPUT_SELECTION": str(self.preference)}
    self.environment = patch.dict(os.environ, env)
    self.environment.start()
    self.addCleanup(self.environment.stop)
    self.process = patch.object(setup.subprocess, "run", return_value=subprocess.CompletedProcess([], 1, stdout="", stderr=""))
    self.process.start()
    self.addCleanup(self.process.stop)

  def seed(self, method=None):
    if method:
      self.preference.write_text(f"INPUT_METHOD={method}\n")
    setup.configure(argparse.Namespace(seed=True, defaults=False))

  def test_every_installer_engine_is_seeded_and_inactive(self):
    for method in ("mozc", "hangul", "pinyin", "chewing"):
      with self.subTest(method=method):
        profile = self.config / "fcitx5/profile"
        profile.unlink(missing_ok=True)
        self.preference.write_text(f"INPUT_METHOD={method}\nXKB_LAYOUT={'kr' if method == 'hangul' else ''}\n")
        self.seed()
        data = setup.sections(profile.read_text())
        self.assertEqual(data["Groups/0"]["DefaultIM"], method)
        self.assertEqual(data["Groups/0/Items/1"]["Name"], method)
        self.assertEqual(data["Groups/0/Items/0"]["Name"], "keyboard-kr" if method == "hangul" else "keyboard-us")
        keys = setup.sections((self.config / "fcitx5/config").read_text())
        self.assertEqual(keys["Behavior"]["ActiveByDefault"], "False")
        self.assertNotIn("Control+space", keys["Hotkey/TriggerKeys"].values())
        self.assertEqual(set(keys["Hotkey/TriggerKeys"].values()), {"Zenkaku_Hankaku", "Hangul"})

  def test_vconsole_variants_quotes_and_japanese_without_preference(self):
    self.preference.unlink()
    self.vconsole.write_text('XKBLAYOUT="jp" # JIS\n')
    self.assertEqual(setup.selection(), ("mozc", "jp"))
    self.vconsole.write_text("XKBLAYOUT='de'\nXKBVARIANT=nodeadkeys\n")
    self.seed()
    self.assertIn("Default Layout=de-nodeadkeys", (self.config / "fcitx5/profile").read_text())
    self.vconsole.write_text("XKBLAYOUT=ru\nXKBVARIANT=phonetic\n")
    self.assertEqual(setup.selection(), ("none", "us"))

  def test_rerun_preserves_custom_multilingual_profile(self):
    self.seed("mozc")
    profile = self.config / "fcitx5/profile"
    original = profile.read_bytes() + b"\n# custom configuration\n"
    profile.write_bytes(original)
    self.seed("hangul")
    self.assertEqual(profile.read_bytes(), original)

  def test_stock_profile_is_repaired_but_custom_single_keyboard_is_not(self):
    self.seed()
    self.vconsole.write_text("XKBLAYOUT=fr\n")
    self.seed()
    profile = self.config / "fcitx5/profile"
    self.assertIn("keyboard-fr", profile.read_text())
    self.seed("mozc")
    self.assertNotIn("Name=mozc", profile.read_text())

  def test_existing_shortcuts_and_addon_options_are_preserved(self):
    path = self.config / "fcitx5/config"
    setup.atomic_write(path, "# user's keys\n[Hotkey/TriggerKeys]\n0=Alt+space\n\n[Behavior]\nActiveByDefault=True\n")
    quickphrase = self.config / "fcitx5/conf/quickphrase.conf"
    setup.atomic_write(quickphrase, "[TriggerKey]\n\n")
    setup.defaults(self.config, fresh=True)
    config = setup.sections(path.read_text())
    self.assertEqual(config["Hotkey/TriggerKeys"], {"0": "Alt+space"})
    self.assertEqual(config["Behavior"], {"ActiveByDefault": "True"})
    self.assertEqual(quickphrase.read_text(), "[TriggerKey]\n\n")

  def test_ctrl_space_is_removed_from_every_trigger_list(self):
    path = self.config / "fcitx5/config"
    setup.atomic_write(path, "[Hotkey/TriggerKeys]\n0=Alt+space\n1=Control+space\n2=Hangul\n\n[Behavior]\nActiveByDefault=True\n")
    setup.defaults(self.config)
    config = setup.sections(path.read_text())
    self.assertEqual(config["Hotkey/TriggerKeys"], {"0": "Alt+space", "1": "Hangul"})
    self.assertEqual(config["Behavior"], {"ActiveByDefault": "True"})

  def test_generated_stock_shortcuts_are_repaired(self):
    path = self.config / "fcitx5/config"
    setup.atomic_write(path, "[Hotkey/TriggerKeys]\n0=Control+space\n1=Zenkaku_Hankaku\n2=Hangul\n\n[Hotkey/EnumerateGroupForwardKeys]\n0=Super+space\n")
    setup.defaults(self.config, fresh=True)
    config = setup.sections(path.read_text())
    self.assertEqual(config["Hotkey/EnumerateGroupForwardKeys"], {})
    self.assertNotIn("Control+space", config["Hotkey/TriggerKeys"].values())

  def test_inherited_hotkeys_keep_fcitx_defaults_except_the_ctrl_space_toggle(self):
    path = self.config / "fcitx5/config"
    setup.atomic_write(path, "[Behavior]\nActiveByDefault=True\n")
    setup.defaults(self.config, fresh=False)
    self.assertEqual(path.read_text(), "[Behavior]\nActiveByDefault=True\n\n[Hotkey/TriggerKeys]\n0=Zenkaku_Hankaku\n1=Hangul\n")
    self.assertFalse(setup.defaults(self.config, fresh=False))

  def test_lao_preference_keeps_a_latin_fcitx_keyboard(self):
    self.preference.write_text("INPUT_METHOD=none\nXKB_LAYOUT=la\n")
    self.assertEqual(setup.selection(), ("none", "us"))

  def test_korean_preference_yields_to_a_later_keyboard_change(self):
    self.preference.write_text("INPUT_METHOD=hangul\nXKB_LAYOUT=kr\n")
    self.assertEqual(setup.selection(), ("hangul", "kr"))
    for layout, variant, expected in [("de", "nodeadkeys", "de-nodeadkeys"), ("us", "intl", "us-intl")]:
      self.vconsole.write_text(f"XKBLAYOUT={layout}\nXKBVARIANT={variant}\n")
      self.assertEqual(setup.selection(), ("hangul", expected))

  def test_seed_in_a_live_desktop_is_a_harmless_retry(self):
    self.seed()
    profile = self.config / "fcitx5/profile"
    original = profile.read_bytes()
    with patch.object(setup.subprocess, "run", return_value=subprocess.CompletedProcess([], 0)):
      self.seed("mozc")
    self.assertEqual(profile.read_bytes(), original)

  def test_failed_seed_rolls_back_so_it_can_be_retried(self):
    with patch.object(setup, "defaults", side_effect=OSError("disk full")):
      with self.assertRaises(OSError):
        self.seed("mozc")
    self.assertFalse((self.config / "fcitx5/profile").exists())
    self.seed("mozc")
    self.assertIn("Name=mozc", (self.config / "fcitx5/profile").read_text())

  def test_readiness_checks_the_dbus_array_payload_and_group(self):
    available = json.dumps({"data": [[["mozc", "Mozc", "", "", "", "ja", False]]]})
    with patch.object(setup, "run", return_value=available), patch.object(setup, "live_group", return_value=("Default", "us", [["keyboard-us", ""]])):
      setup.wait_ready("mozc")

  def test_migration_without_a_bus_keeps_written_activation_and_defaults(self):
    self.seed()
    with patch.object(setup, "run", side_effect=subprocess.CalledProcessError(1, "busctl")):
      setup.configure(argparse.Namespace(seed=False, defaults=True))
    self.assertTrue((self.home / "data/dbus-1/services/org.fcitx.Fcitx5.service").exists())

  def test_live_migration_without_a_bus_does_not_restart_or_rewrite_profile(self):
    self.seed()
    profile = self.config / "fcitx5/profile"
    original = profile.read_bytes()
    with patch.object(setup.subprocess, "run", return_value=subprocess.CompletedProcess([], 0)), patch.object(setup, "run", side_effect=subprocess.CalledProcessError(1, "busctl")) as calls:
      setup.configure(argparse.Namespace(seed=False, defaults=True))
    self.assertEqual(profile.read_bytes(), original)
    self.assertFalse(any(call.args[0] == ["omarchy-restart-xcompose"] for call in calls.call_args_list))

  def test_migration_does_not_add_an_engine_the_old_daemon_cannot_load(self):
    self.seed()
    self.vconsole.write_text("XKBLAYOUT=jp\n")
    self.preference.write_text("INPUT_METHOD=mozc\n")
    old = ("Default", "us", [["keyboard-us", ""]])
    new = ("Default", "jp", [["keyboard-jp", ""]])
    with patch.object(setup.subprocess, "run", return_value=subprocess.CompletedProcess([], 0)), patch.object(setup, "live_group", side_effect=[old, new]), patch.object(setup, "available_methods", return_value=[]), patch.object(setup, "live_set") as setter:
      setup.configure(argparse.Namespace(seed=False, defaults=True))
    self.assertEqual(setter.call_args.args, new)

  def test_custom_keyboard_overrides_are_not_stock(self):
    self.assertFalse(setup.stock_profile(setup.profile_text("de", "none").replace("keyboard-de", "keyboard-us")))
    self.assertFalse(setup.stock_profile(setup.profile_text("us", "none").replace("Layout=\n", "Layout=ru\n")))

  def test_atomic_updates_keep_symlinks_and_modes(self):
    target = self.home / "real-config"
    target.write_text("before")
    target.chmod(0o600)
    link = self.home / "link"
    link.symlink_to(target)
    setup.atomic_write(link, "after")
    self.assertTrue(link.is_symlink())
    self.assertEqual(target.read_text(), "after")
    self.assertEqual(target.stat().st_mode & 0o777, 0o600)

  def test_input_preferences_are_data_and_invalid_values_fail(self):
    self.preference.write_text("INPUT_METHOD=$(touch /tmp/should-not-exist)\n")
    with self.assertRaises(ValueError):
      self.seed()

  def test_font_fallback_does_not_replace_existing_preference(self):
    setup.font_default(self.config, "mozc")
    font = self.config / "fontconfig/conf.d/50-omarchy-input-method.conf"
    self.assertIn("Noto Sans CJK JP", font.read_text())
    self.assertIn("Noto Sans Mono CJK JP", font.read_text())
    original = font.read_bytes()
    setup.font_default(self.config, "hangul")
    self.assertEqual(font.read_bytes(), original)


if __name__ == "__main__":
  unittest.main()
