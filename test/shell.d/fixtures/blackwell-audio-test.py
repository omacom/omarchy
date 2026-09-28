import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(os.environ["ROOT"])
sys.dont_write_bytecode = True
SOURCES = ROOT / "default/hardware/blackwell-audio"
spec = importlib.util.spec_from_file_location("profile", SOURCES / "profile.py")
profile = importlib.util.module_from_spec(spec)
spec.loader.exec_module(profile)


class CompatibilityTest(unittest.TestCase):
  def setUp(self):
    self.temporary = tempfile.TemporaryDirectory(prefix="omarchy-blackwell-test-")
    self.addCleanup(self.temporary.cleanup)
    self.root = Path(self.temporary.name)
    self.config = self.root / "config"
    self.state = self.root / "state/omarchy/blackwell-audio/state.json"
    self.system = self.root / "etc"
    self.subject = profile.Profile(self.config, self.state, SOURCES, self.system)
    self.output = io.StringIO()
    self.redirect = contextlib.redirect_stdout(self.output)
    self.redirect.__enter__()
    self.addCleanup(self.redirect.__exit__, None, None, None)

  def write(self, path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)
    return path

  def hardware(self):
    sysfs = self.root / "sys"
    cpuinfo = self.write(self.root / "cpuinfo", "model name : AMD Ryzen 9 7950X3D 16-Core Processor\n")
    for name, value in {
      "class/dmi/id/board_vendor": "Gigabyte Technology Co., Ltd.",
      "class/dmi/id/board_name": "B650I AORUS ULTRA",
      "class/dmi/id/bios_version": "F42",
      "bus/pci/devices/0000:99:00.0/vendor": "0x10de",
      "bus/pci/devices/0000:99:00.0/device": "0x2c34",
      "bus/pci/devices/0000:99:00.0/class": "0x030000",
      "bus/usb/devices/7-8/idVendor": "1038",
      "bus/usb/devices/7-8/idProduct": "12e0",
    }.items():
      self.write(sysfs / name, value + "\n")
    return sysfs, cpuinfo

  def invoke(self, action, hardware=True, packages=None, uid=1000, kernel=profile.KERNEL):
    versions = profile.PACKAGES if packages is None else packages
    original_plan = profile.Profile.plan
    with patch.dict(os.environ, {"XDG_CONFIG_HOME": str(self.config), "XDG_STATE_HOME": str(self.root / "state")}), \
         patch("sys.argv", ["profile.py", action]), \
         patch.object(profile, "hardware_matches", return_value=hardware), \
         patch.object(profile, "package_versions", return_value=versions), \
         patch.object(profile.platform, "release", return_value=kernel), \
         patch.object(profile.os, "geteuid", return_value=uid), \
         patch.object(profile.Profile, "plan", lambda instance: original_plan(self.subject)):
      return profile.main()

  def test_hardware_match_is_slot_independent_and_narrow(self):
    sysfs, cpuinfo = self.hardware()
    self.assertTrue(profile.hardware_matches(sysfs, cpuinfo))
    for relative in (
      "class/dmi/id/board_vendor", "class/dmi/id/board_name", "class/dmi/id/bios_version",
      "bus/pci/devices/0000:99:00.0/vendor", "bus/pci/devices/0000:99:00.0/device",
      "bus/pci/devices/0000:99:00.0/class", "bus/usb/devices/7-8/idVendor",
      "bus/usb/devices/7-8/idProduct",
    ):
      path = sysfs / relative
      before = path.read_text()
      path.write_text("different\n")
      self.assertFalse(profile.hardware_matches(sysfs, cpuinfo), relative)
      path.write_text(before)
    cpuinfo.write_text("another CPU")
    self.assertFalse(profile.hardware_matches(sysfs, cpuinfo))
    self.assertFalse(profile.hardware_matches(self.root / "missing", cpuinfo))

  def test_package_epoch_and_release_are_normalized(self):
    packages = "\n".join(f"{name} {'1:' if name == 'pipewire' else ''}{version}-1" for name, version in profile.PACKAGES.items())
    with patch.object(profile.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, packages, "")):
      self.assertEqual(profile.package_versions(), profile.PACKAGES)
    with patch.object(profile.subprocess, "run", return_value=subprocess.CompletedProcess([], 1, "", "")):
      self.assertEqual(profile.package_versions(), {})

  def test_automatic_nonmatch_has_no_writes(self):
    self.assertEqual(self.invoke("auto", hardware=False), 0)
    for package in profile.PACKAGES:
      changed = dict(profile.PACKAGES, **{package: "new-version"})
      self.assertEqual(self.invoke("auto", packages=changed), 0)
    self.assertFalse(self.config.exists())
    self.assertFalse(self.state.parent.exists())

  def test_installed_old_kernel_is_not_a_running_kernel_match(self):
    self.assertEqual(self.invoke("auto", kernel="7.2.5-3-omarchy"), 0)
    self.assertFalse(self.config.exists())
    self.assertFalse(self.state.parent.exists())

  def test_root_cannot_apply_user_configuration(self):
    self.assertEqual(self.invoke("auto", uid=0), 0)
    self.assertFalse(self.config.exists())
    self.assertFalse(self.state.exists())

  def test_automatic_match_applies_and_honors_opt_out(self):
    self.assertEqual(self.invoke("auto"), 0)
    self.assertEqual(self.subject.load()["status"], "on")
    self.assertEqual(self.invoke("off"), 0)
    self.assertEqual(self.invoke("auto"), 0)
    self.assertEqual(self.subject.load()["status"], "off")
    self.assertFalse((self.config / profile.FILES[2]).exists())

  def test_apply_is_idempotent_and_rollback_is_exact(self):
    flags = self.write(self.config / "chromium-flags.conf", "# mine\n--enable-features=TouchpadOverscrollHistoryNavigation,Unrelated\n--disable-features=Other\n--custom-flag=value")
    flags.chmod(0o640)
    original = profile.snapshot(flags)
    self.subject.apply()
    installed = profile.snapshot(flags)
    state = self.state.read_bytes()
    self.subject.apply()
    self.assertEqual(profile.snapshot(flags), installed)
    self.assertEqual(self.state.read_bytes(), state)
    self.assertIn("TouchpadOverscrollHistoryNavigation,Unrelated,WaylandLinuxDrmSyncobj", installed["text"])
    self.assertIn("--disable-features=Other,AcceleratedVideoDecodeLinuxZeroCopyGL", installed["text"])
    self.assertIn("--custom-flag=value\n--", installed["text"])
    self.assertNotIn("ignore-gpu-blocklist", installed["text"])
    self.subject.off()
    self.assertEqual(profile.snapshot(flags), original)
    for relative in profile.FILES[:2]:
      self.assertFalse((self.config / relative).exists())
    self.subject.apply(automatic=True)
    self.assertEqual(profile.snapshot(flags), original)
    self.subject.apply()
    self.assertEqual(profile.snapshot(flags), installed)

  def test_rollback_without_original_browser_file(self):
    self.subject.apply()
    self.subject.off()
    self.subject.off()
    for relative in profile.FILES:
      self.assertFalse((self.config / relative).exists())

  def test_rollback_preserves_original_line_endings(self):
    flags = self.write(self.config / profile.FILES[2], "")
    original = b"# custom\r\n--my-flag=value\r\n"
    flags.write_bytes(original)
    self.subject.apply()
    self.subject.off()
    self.assertEqual(flags.read_bytes(), original)

  def test_opt_out_before_install_is_honored(self):
    self.subject.off()
    self.subject.apply(automatic=True)
    self.assertFalse(self.config.exists())

  def test_subsequent_edits_are_never_overwritten(self):
    self.subject.apply()
    flags = self.config / profile.FILES[2]
    flags.write_text(flags.read_text() + "--user-change\n")
    before = {path: profile.snapshot(self.config / path) for path in profile.FILES}
    for action in (self.subject.apply, self.subject.off):
      with self.assertRaises(profile.Conflict):
        action()
      self.assertEqual({path: profile.snapshot(self.config / path) for path in profile.FILES}, before)
    self.assertTrue(self.state.exists())

  def test_existing_audio_tuning_skips_whole_bundle(self):
    for index, (base, text) in enumerate((
      ("pipewire", "default.clock.min-quantum = 64"),
      ("wireplumber", "api.alsa.disable-tsched = false"),
    )):
      path = self.write(self.config / base / f"{base}.conf.d/99-custom-{index}.conf", text)
      with self.assertRaises(profile.Conflict):
        self.subject.apply()
      self.assertEqual(path.read_text(), text)
      self.assertFalse(self.state.exists())
      path.unlink()
    self.write(self.system / "pipewire/pipewire.conf", "default.clock.rate = 96000")
    with self.assertRaises(profile.Conflict):
      self.subject.apply()
    self.assertFalse(self.state.exists())

  def test_unrelated_audio_rules_are_preserved(self):
    unrelated = self.write(self.config / "wireplumber/wireplumber.conf.d/50-custom.conf", "api.alsa.soft-mixer = true\n# api.alsa.headroom = 128\n")
    before = unrelated.read_bytes()
    self.subject.apply()
    self.subject.off()
    self.assertEqual(unrelated.read_bytes(), before)

  def test_chromium_conflicts_and_duplicate_flags_are_preserved(self):
    for text in (
      "--use-angle=vulkan\n", "--ozone-platform=x11\n",
      "--use-gl=angle\n--use-gl=desktop\n",
      "--enable-features=VaapiVideoDecoder\n",
      "--disable-features=WaylandLinuxDrmSyncobj\n",
      "--enable-features=WaylandLinuxDrmSyncobj:custom/value\n",
      "--use-angle=gl --custom\n", "--use-angle=gl # custom\n",
      "--disable-gpu\n", "--disable-gpu-compositing\n", "--enable-accelerated-video-decode\n",
      "--custom='unterminated\n",
      "'--enable-features=Custom:parameter/a value'\n",
    ):
      with self.assertRaises(profile.Conflict, msg=text):
        profile.chromium_flags(text)

  def test_chromium_already_present_flags_are_not_duplicated(self):
    first = profile.chromium_flags("--enable-features=Unrelated\n")
    self.assertEqual(profile.chromium_flags(first), first)
    self.assertEqual(first.count("WaylandLinuxDrmSyncobj"), 1)
    self.assertEqual(first.count("--disable-accelerated-video-decode"), 1)

  def test_symlinks_and_nonfiles_are_preserved(self):
    target = self.write(self.root / "dotfiles/browser-flags", "--mine\n")
    self.config.mkdir()
    flags = self.config / profile.FILES[2]
    flags.symlink_to(target)
    with self.assertRaises(profile.Conflict):
      self.subject.apply()
    self.assertEqual(target.read_text(), "--mine\n")
    flags.unlink()
    flags.mkdir()
    with self.assertRaises(profile.Conflict):
      self.subject.apply()
    self.assertFalse(self.state.exists())

  def test_linked_parent_is_preserved(self):
    destination = self.root / "dotfiles"
    destination.mkdir()
    self.config.mkdir()
    (self.config / "pipewire").symlink_to(destination)
    with self.assertRaises(profile.Conflict):
      self.subject.apply()
    self.assertEqual(list(destination.iterdir()), [])

  def test_interrupted_apply_has_recoverable_state(self):
    original_writer = profile.atomic_write
    def fail_second_config(path, *args, **kwargs):
      if path == self.config / profile.FILES[1]:
        raise OSError("simulated disk error")
      return original_writer(path, *args, **kwargs)
    with patch.object(profile, "atomic_write", side_effect=fail_second_config):
      with self.assertRaises(OSError):
        self.subject.apply()
    self.assertEqual(self.subject.load()["status"], "applying")
    self.subject.apply()
    self.assertEqual(self.subject.load()["status"], "on")
    self.subject.off()
    for relative in profile.FILES:
      self.assertFalse((self.config / relative).exists())

  def test_rollback_works_after_hardware_or_version_change(self):
    self.subject.apply()
    self.assertEqual(self.invoke("off", hardware=False, packages={}, kernel="new-kernel"), 0)
    self.assertFalse((self.config / profile.FILES[2]).exists())

  def test_deleted_managed_file_is_not_silently_recreated(self):
    self.subject.apply()
    path = self.config / profile.FILES[0]
    path.unlink()
    with self.assertRaises(profile.Conflict):
      self.subject.apply()
    self.assertFalse(path.exists())

  def test_interrupted_rollback_can_be_completed(self):
    flags = self.write(self.config / profile.FILES[2], "--custom\n")
    self.subject.apply()
    original_writer = profile.atomic_write
    def fail_browser_restore(path, *args, **kwargs):
      if path == flags:
        raise OSError("simulated disk error")
      return original_writer(path, *args, **kwargs)
    with patch.object(profile, "atomic_write", side_effect=fail_browser_restore):
      with self.assertRaises(OSError):
        self.subject.off()
    self.assertEqual(self.subject.load()["status"], "removing")
    with self.assertRaises(profile.Conflict):
      self.subject.apply()
    self.subject.off()
    self.assertEqual(flags.read_text(), "--custom\n")

  def test_state_cannot_redirect_restore_outside_profile(self):
    self.subject.apply()
    data = self.subject.load()
    data["files"]["../unrelated"] = data["files"][profile.FILES[0]]
    self.state.write_text(json.dumps(data))
    with self.assertRaises(profile.Conflict):
      self.subject.off()

  def test_templates_only_change_output_scheduling(self):
    text = (SOURCES / "wireplumber.conf").read_text()
    self.assertIn("alsa_output.usb-SteelSeries_Arctis_Nova_Pro_Wireless-00.analog-stereo", text)
    self.assertNotIn("alsa_input", text)
    self.assertEqual(text.count("api.alsa.disable-tsched = true"), 1)
    self.assertIn("default.clock.min-quantum = 1024", (SOURCES / "pipewire.conf").read_text())

  def test_install_and_migration_call_same_automatic_entrypoint(self):
    stubdir = self.root / "bin"
    log = self.root / "calls"
    stub = self.write(stubdir / "omarchy-setup-blackwell-audio", '#!/bin/bash\nprintf "%s\\n" "$*" >> "$CALLS"\n')
    stub.chmod(0o755)
    env = dict(os.environ, PATH=f"{stubdir}:{os.environ['PATH']}", CALLS=str(log))
    for relative in ("install/user/hardware/fix-blackwell-audio.sh", "migrations/1789574960.sh"):
      subprocess.run(["bash", "-euo", "pipefail", str(ROOT / relative)], env=env, check=True, capture_output=True)
    self.assertEqual(log.read_text(), "auto\nauto\n")
    self.assertIn('run_logged "$OMARCHY_INSTALL/user/hardware/fix-blackwell-audio.sh"', (ROOT / "install/user/all.sh").read_text())


unittest.main(verbosity=2)
