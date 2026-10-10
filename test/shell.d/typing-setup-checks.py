import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(os.environ["OMARCHY_PATH"])
sys.path.insert(0, str(ROOT / "default/input-methods"))
spec = importlib.util.spec_from_file_location("typing_setup", ROOT / "default/input-methods/typing_setup.py")
typing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(typing)


class TypingSetupTest(unittest.TestCase):
  def test_variants_and_installer_binding_safety(self):
    self.assertEqual(typing.keyboard_values(["us:intl", "fr"]), ("us,fr", "intl,"))
    self.assertEqual(typing.keyboard_values(["ru:phonetic"]), ("us,ru", ",phonetic"))
    self.assertEqual(typing.keyboard_values(["ru:phonetic", "us"]), ("us,ru", ",phonetic"))
    with self.assertRaises(ValueError):
      typing.keyboard_values([])

  def test_keyboard_catalog_uses_installer_choices(self):
    catalog = typing.keyboard_catalog()
    self.assertEqual(catalog["us"], "English (US)")
    self.assertEqual(catalog["gb"], "English (UK)")
    self.assertEqual(catalog["us:colemak"], "English (US, Colemak)")
    self.assertEqual(catalog["ch"], "German (Switzerland)")
    self.assertEqual(catalog["la"], "Lao")
    # Converted as the installer does.
    self.assertEqual(catalog["fr"], "French")
    self.assertEqual(catalog["bg:phonetic"], "Bulgarian")
    self.assertEqual(catalog["cz:qwerty"], "Czech")
    self.assertNotIn("az", catalog)
    self.assertEqual(catalog["latam"], "Spanish (Latin American)")
    self.assertNotIn("us:intl", catalog)
    self.assertLess(len(catalog), 60)

  def test_readding_input_keeps_its_original_override(self):
    self.assertEqual(typing.input_items([["keyboard-us", ""]], ["mozc"], {"mozc": "jp"}),
                     [["keyboard-us", ""], ["mozc", "jp"]])
    self.assertEqual(typing.input_items([["keyboard-us", ""], ["mozc", "us"]], ["mozc"], {"mozc": "jp"}),
                     [["keyboard-us", ""], ["mozc", "us"]])

  def test_input_deselection_keeps_keyboard_and_selected_overrides(self):
    items = [["keyboard-us", ""], ["mozc", "jp"], ["hangul", ""], ["custom", "de"]]
    self.assertEqual(typing.input_items(items, ["custom", "mozc"]), [["keyboard-us", ""], ["mozc", "jp"], ["custom", "de"]])
    self.assertEqual(typing.input_items(items, []), [["keyboard-us", ""]])

  def test_input_changes_keep_the_switching_order(self):
    items = [["keyboard-us", ""], ["mozc", ""], ["keyboard-fr", ""], ["hangul", ""]]
    self.assertEqual(typing.input_items(items, ["mozc"]), [["keyboard-us", ""], ["mozc", ""], ["keyboard-fr", ""]])
    self.assertEqual(typing.input_items(items, ["pinyin", "hangul", "mozc"]), items + [["pinyin", ""]])

  def test_failed_input_save_leaves_fonts_alone(self):
    with tempfile.TemporaryDirectory() as temporary:
      before = ("Default", "us", [["keyboard-us", ""]])
      with patch.dict(os.environ, {"XDG_CONFIG_HOME": temporary}), patch.object(typing.setup, "live_group", return_value=before), patch.object(typing.setup, "available_methods", return_value=[["mozc", "Mozc"]]), patch.object(typing, "set_inputs", side_effect=RuntimeError("rejected")):
        with self.assertRaises(RuntimeError):
          typing.save_inputs(["mozc"])
      self.assertFalse((Path(temporary) / "fontconfig/conf.d/50-omarchy-input-method.conf").exists())

  def test_an_engine_installed_after_fcitx_started_loads_on_selection(self):
    group = ("Default", "us", [["keyboard-us", ""]])
    present = subprocess.CompletedProcess([], 0)
    with patch.object(typing.setup, "live_group", return_value=group), patch.object(typing.setup, "available_methods", return_value=[]), patch.object(typing.subprocess, "run", return_value=present), patch.object(typing.setup, "run") as run, patch.object(typing.setup, "wait_ready") as ready, patch.object(typing, "set_inputs") as save, patch.object(typing.setup, "font_default"):
      typing.save_inputs(["mozc"])
    run.assert_called_once_with(["omarchy-restart-xcompose"])
    ready.assert_called_once_with("mozc")
    self.assertEqual(save.call_args.args[3], [["keyboard-us", ""], ["mozc", ""]])

  def test_an_uninstalled_engine_names_its_package_without_restarting(self):
    absent = subprocess.CompletedProcess([], 1)
    with patch.object(typing.setup, "live_group", return_value=("Default", "us", [["keyboard-us", ""]])), patch.object(typing.setup, "available_methods", return_value=[]), patch.object(typing.subprocess, "run", return_value=absent), patch.object(typing.setup, "run") as run, patch.object(typing, "set_inputs") as save:
      with self.assertRaisesRegex(RuntimeError, "Install fcitx5-mozc to use Japanese"):
        typing.save_inputs(["mozc"])
    run.assert_not_called()
    save.assert_not_called()

  def test_command_line_addition_appends_once(self):
    group = ("Default", "us", [["keyboard-us", ""], ["hangul", ""]])
    with patch.object(typing.setup, "live_group", return_value=group), patch.object(typing, "save_inputs") as save:
      typing.add_input("mozc")
      save.assert_called_once_with(["hangul", "mozc"])
      typing.add_input("hangul")
      save.assert_called_once()

  def test_failed_font_write_restores_the_input_group(self):
    before = [["keyboard-us", ""]]
    with patch.object(typing.setup, "live_group", return_value=("Default", "us", before)), patch.object(typing.setup, "available_methods", return_value=[["mozc", "Mozc"]]), patch.object(typing, "set_inputs"), patch.object(typing.setup, "font_default", side_effect=OSError("read-only")), patch.object(typing.setup, "live_set") as setter:
      with self.assertRaises(OSError):
        typing.save_inputs(["mozc"])
    setter.assert_called_once_with("Default", "us", before)

  def test_cancellation_does_not_change_input_settings(self):
    with patch.object(typing.setup, "live_group", return_value=("Default", "us", [["keyboard-us", ""]])), patch.object(typing, "input_catalog", return_value=({"mozc": "Japanese"}, {"mozc": "Japanese"})), patch.object(typing, "choose", return_value=None), patch.object(typing.setup, "live_set") as setter:
      self.assertFalse(typing.configure_inputs())
      setter.assert_not_called()

  def test_failed_input_save_restores_the_original_group(self):
    before = [["keyboard-us", ""], ["mozc", "jp"]]
    after = [["keyboard-us", ""]]
    with patch.object(typing.setup, "run"), patch.object(typing.setup, "live_set") as setter, patch.object(typing.setup, "live_group", return_value=("Default", "us", before)):
      with self.assertRaises(RuntimeError):
        typing.set_inputs("Default", "us", before, after)
      self.assertEqual(setter.call_args_list[-1].args, ("Default", "us", before))

  def test_picker_preselects_current_entries_and_returns_empty_selection(self):
    result = subprocess.CompletedProcess([], 0, stdout="[]")
    with patch.object(typing.subprocess, "run", return_value=result) as process:
      self.assertIsNone(typing.choose("Inputs", {"mozc": "Japanese", "hangul": "Korean"}, ["hangul"], "input"))
      args = process.call_args.args[0]
      self.assertEqual(args[2], "\tKorean")
      self.assertIn("--multiple", args)
      self.assertEqual(args[args.index("--change-key") + 1], "typing:input")
      self.assertEqual(args[-2:], ["--selected", "Korean"])

  def test_apply_rejects_unknown_values(self):
    with self.assertRaises(ValueError):
      typing.apply_selection("input", {"catalog": {"mozc": "Japanese"}}, ["unknown"])

  def test_immediate_selection_removes_an_input_and_accepts_keyboard_only(self):
    with patch.object(typing, "save_inputs") as save, patch("builtins.print"):
      typing.apply_selection("input", {"catalog": {"mozc": "Japanese", "hangul": "Korean"}}, ["Japanese"])
      save.assert_called_once_with(["mozc"], None)
      typing.apply_selection("input", {"catalog": {"mozc": "Japanese"}}, [])
      self.assertEqual(save.call_args.args, ([], None))

  def test_keyboard_checks_reflect_normalized_selection(self):
    with patch.object(typing, "save_keyboard"), patch.object(typing, "keyboard_selection", return_value=["us", "ru"]), patch("builtins.print") as output:
      typing.apply_selection("keyboard", {"catalog": {"us": "English", "ru": "Russian"}}, ["Russian"])
      self.assertEqual(json.loads(output.call_args.args[0]), ["English", "Russian"])

  def test_keyboard_override_failure_preserves_symlink_and_restores_settings(self):
    with tempfile.TemporaryDirectory() as temporary:
      config = Path(temporary)
      target = config / "actual-layouts"
      target.write_text("XKBLAYOUT=de\n")
      target.chmod(0o600)
      path = config / "omarchy/keyboard-layouts"
      path.parent.mkdir()
      path.symlink_to(target)
      before = ("Default", "us", [["keyboard-us", ""], ["mozc", "jp"]])
      with patch.dict(os.environ, {"XDG_CONFIG_HOME": str(config)}), patch.object(typing.setup, "live_group", return_value=before), patch.object(typing.setup, "run", return_value=""), patch.object(typing, "keyboard_selection", return_value=["de"]), patch.object(typing.setup, "live_set") as setter:
        with self.assertRaisesRegex(RuntimeError, "override"):
          typing.save_keyboard(["us", "fr"])
      self.assertTrue(path.is_symlink())
      self.assertEqual(target.read_text(), "XKBLAYOUT=de\n")
      self.assertEqual(target.stat().st_mode & 0o777, 0o600)
      setter.assert_not_called()

  def test_keyboard_save_aligns_fcitx_and_preserves_language_overrides(self):
    with tempfile.TemporaryDirectory() as temporary:
      before = ("Default", "us", [["keyboard-us", ""], ["mozc", "jp"]])
      after = ("Default", "fr", [["keyboard-fr", ""], ["mozc", "jp"]])
      with patch.dict(os.environ, {"XDG_CONFIG_HOME": temporary}), patch.object(typing.setup, "live_group", side_effect=[before, after]), patch.object(typing.setup, "run", return_value=""), patch.object(typing, "keyboard_selection", return_value=["fr", "us:intl"]), patch.object(typing.setup, "live_set") as setter:
        typing.save_keyboard(["fr", "us:intl"])
      self.assertEqual(setter.call_args.args, after)
      self.assertEqual((Path(temporary) / "omarchy/keyboard-layouts").read_text(), "XKBLAYOUT=fr,us\nXKBVARIANT=,intl\n")


if __name__ == "__main__":
  unittest.main()
