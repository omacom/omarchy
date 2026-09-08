import contextlib
import importlib.util
import io
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(sys.argv.pop(1))
spec = importlib.util.spec_from_file_location("iwd_import", ROOT / "install/helpers/iwd-networks.py")
importer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(importer)
GLib, NM = importer.GLib, importer.NM


class IwdImportTest(unittest.TestCase):
  def setUp(self):
    self.temporary = tempfile.TemporaryDirectory()
    self.addCleanup(self.temporary.cleanup)
    self.root = Path(self.temporary.name)
    self.iwd = self.root / "iwd"
    self.nm = self.root / "nm"
    self.runtime = self.root / "runtime"
    self.vendor = self.root / "vendor"
    for directory in (self.iwd, self.nm, self.runtime, self.vendor):
      directory.mkdir(mode=0o700)
    self.directories = [self.nm, self.runtime, self.vendor]
    self.log = io.StringIO()

  def source(self, ssid=b"Home", suffix=".psk", secret="test-password", settings=None):
    keyfile = GLib.KeyFile()
    if secret is not None:
      keyfile.set_string("Security", "Passphrase", secret)
    for key, value in (settings or {}).items():
      keyfile.set_string("Settings", key, value)
    path = self.iwd / ("=" + ssid.hex() + suffix)
    path.write_text(keyfile.to_data()[0])
    return path

  def run_import(self):
    with contextlib.redirect_stdout(self.log), contextlib.redirect_stderr(self.log):
      return importer.import_networks(self.iwd, self.directories, self.nm)

  def load(self, path):
    connection = NM.keyfile_read(importer.read_keyfile(path), str(path.parent),
      NM.KeyfileHandlerFlags.NONE, None, None)
    connection.normalize()
    self.assertTrue(connection.verify())
    self.assertTrue(connection.verify_secrets())
    return connection

  def connections(self):
    return [self.load(path) for path in self.nm.glob("*.nmconnection")]

  def test_no_legacy_store_is_a_noop(self):
    self.iwd.rmdir()
    self.assertEqual(self.run_import(), 0)
    self.assertEqual(list(self.nm.iterdir()), [])

  def test_open_psk_hidden_and_autoconnect(self):
    self.source()
    self.source(b"Cafe", ".open", None, {"Hidden": "1", "AutoConnect": "0"})
    self.assertEqual(self.run_import(), 2)
    profiles = {c.get_id(): c for c in self.connections()}
    self.assertEqual(profiles["Home"].get_setting_wireless_security().props.psk, "test-password")
    self.assertTrue(profiles["Home"].get_setting_connection().props.autoconnect)
    self.assertIsNone(profiles["Cafe"].get_setting_wireless_security())
    self.assertTrue(profiles["Cafe"].get_setting_wireless().props.hidden)
    self.assertFalse(profiles["Cafe"].get_setting_connection().props.autoconnect)

  def test_verbatim_iwd_filename(self):
    self.source().rename(self.iwd / "Home Network_5G.psk")
    self.run_import()
    self.assertEqual(self.connections()[0].get_setting_wireless().props.ssid.get_data(), b"Home Network_5G")

  def test_binary_and_unusual_ssids_round_trip_through_libnm(self):
    ssids = [b"65;66;", b"cafe/guest", b"line\nbreak", b"nul\0ssid",
             b"binary\xff", "café ☕".encode(), b" " * 32, b"#;=\\"]
    for ssid in ssids:
      self.source(ssid)
    self.assertEqual(self.run_import(), len(ssids))
    self.assertEqual({bytes(c.get_setting_wireless().props.ssid.get_data())
                      for c in self.connections()}, set(ssids))

  def test_password_escaping_and_precedence(self):
    secret = " leading\\slash;#=percent% trailing "
    path = self.source(secret=secret)
    keyfile = importer.read_keyfile(path)
    keyfile.set_string("Security", "PreSharedKey", "a" * 64)
    keyfile.set_string("Security", "SAE-PT-19", "cached-key-material")
    path.write_text(keyfile.to_data()[0])
    self.run_import()
    self.assertEqual(self.connections()[0].get_setting_wireless_security().props.psk, secret)
    self.assertNotIn(secret, self.log.getvalue())
    self.assertNotIn("cached-key-material", self.log.getvalue())

  def test_derived_psk_without_passphrase(self):
    path = self.source(secret=None)
    path.write_text("[Security]\nPreSharedKey=" + "A2" * 32 + "\n")
    self.run_import()
    self.assertEqual(self.connections()[0].get_setting_wireless_security().props.psk, "A2" * 32)

  def test_repeat_import_preserves_files_and_sources(self):
    source = self.source()
    source_bytes = source.read_bytes()
    self.run_import()
    original = {path: (path.read_bytes(), path.stat().st_mtime_ns) for path in self.nm.iterdir()}
    self.assertEqual(self.run_import(), 0)
    self.assertEqual({path: (path.read_bytes(), path.stat().st_mtime_ns)
                      for path in self.nm.iterdir()}, original)
    self.assertEqual(source.read_bytes(), source_bytes)
    self.assertTrue(all(stat.S_IMODE(path.stat().st_mode) == 0o600 for path in original))

  def test_existing_ssids_match_even_with_different_names_and_security(self):
    for index, directory in enumerate(self.directories):
      ssid = f"Existing {index}".encode()
      source = self.source(ssid, ".open", None)
      existing = importer.convert_profile(source, ssid)
      existing.get_setting_connection().props.id = "Renamed connection"
      importer.write_profile(existing, directory)
      source.unlink()
      self.source(ssid, secret="older-password")
    original = {p: p.read_bytes() for d in self.directories for p in d.iterdir()}
    self.assertEqual(self.run_import(), 0)
    self.assertEqual({p: p.read_bytes() for d in self.directories for p in d.iterdir()}, original)

  def test_personal_profile_takes_priority_over_old_open_profile(self):
    self.source()
    self.source(suffix=".open", secret=None)
    self.assertEqual(self.run_import(), 1)
    self.assertIsNotNone(self.connections()[0].get_setting_wireless_security())

  def test_enterprise_and_custom_policies_are_not_downgraded(self):
    self.source(b"Campus", ".8021x", None)
    self.source(b"WPA3", settings={"DisabledTransitionModes": "personal"})
    self.source(b"PMF", settings={"TransitionDisable": "true"})
    self.source(b"MAC", settings={"AddressOverride": "02:00:00:00:00:01"})
    static = self.source(b"Static")
    static.write_text(static.read_text() + "\n[IPv4]\nAddress=192.0.2.10\n")
    self.assertEqual(self.run_import(), 0)
    self.assertEqual(list(self.nm.iterdir()), [])
    self.assertIn("5 require manual setup", self.log.getvalue())

  def test_unsupported_or_invalid_secure_profile_never_falls_back_to_open(self):
    self.source(b"Enterprise", ".8021x", None)
    self.source(b"Enterprise", ".open", None)
    self.source(b"Broken", secret="bad")
    self.source(b"Broken", ".open", None)
    with self.assertRaises(ValueError):
      self.run_import()
    self.assertEqual(list(self.nm.iterdir()), [])

  def test_invalid_profiles_fail_without_printing_secrets(self):
    for name, content in {
      "=zz.psk": "[Security]\nPassphrase=do-not-log-me\n",
      "Missing.psk": "[Security]\nPreSharedKey=invalid-secret\n",
      "Short.psk": "[Security]\nPassphrase=short\n",
      "Broken.psk": "[Security]\ndo-not-log-this-invalid-line\n",
      "Boolean.open": "[Settings]\nHidden=maybe\n",
    }.items():
      (self.iwd / name).write_text(content)
    with self.assertRaises(ValueError):
      self.run_import()
    self.assertEqual(list(self.nm.iterdir()), [])
    self.assertIn("5 failed", self.log.getvalue())
    for secret in ("do-not-log", "invalid-secret", "short"):
      self.assertNotIn(secret, self.log.getvalue())

  def test_symlink_and_fifo_sources_are_not_read(self):
    secret = self.root / "unrelated"
    secret.write_text("[Security]\nPassphrase=not-an-iwd-profile\n")
    (self.iwd / "Symlink.psk").symlink_to(secret)
    os.mkfifo(self.iwd / "Fifo.psk")
    with self.assertRaises(ValueError):
      self.run_import()
    self.assertEqual(list(self.nm.iterdir()), [])
    self.assertNotIn("not-an-iwd-profile", self.log.getvalue())

  def test_unreadable_existing_store_aborts_before_any_import(self):
    self.source()
    (self.nm / "broken.nmconnection").write_text("do-not-print-this-secret")
    with self.assertRaises(GLib.Error):
      self.run_import()
    self.assertEqual(len(list(self.nm.iterdir())), 1)
    self.assertEqual(self.log.getvalue(), "")

  def test_failed_write_remains_retryable_and_cleans_staging_file(self):
    self.source()
    with patch.object(importer.os, "link", side_effect=OSError("secret must not be printed")):
      with self.assertRaises(ValueError):
        self.run_import()
    self.assertEqual(list(self.nm.iterdir()), [])
    self.assertNotIn("secret must not", self.log.getvalue())
    self.assertEqual(self.run_import(), 1)

  def test_existing_file_is_never_overwritten(self):
    source = self.source()
    connection = importer.convert_profile(source, b"Home")
    destination = self.nm / ("omarchy-iwd-" + connection.get_uuid() + ".nmconnection")
    unrelated = self.root / "unrelated"
    destination.symlink_to(unrelated)
    with self.assertRaises(OSError):
      self.run_import()
    self.assertTrue(destination.is_symlink())
    self.assertFalse(unrelated.exists())

  def test_writable_connection_directory_is_refused(self):
    self.source()
    self.nm.chmod(0o777)
    with self.assertRaises(ValueError):
      self.run_import()
    self.assertEqual(list(self.nm.iterdir()), [])

  def test_partial_failure_keeps_successful_imports_and_can_be_retried(self):
    self.source(b"Good")
    broken = self.source(b"Broken", secret="bad")
    with self.assertRaises(ValueError):
      self.run_import()
    self.assertEqual([c.get_id() for c in self.connections()], ["Good"])
    broken.unlink()
    self.source(b"Broken")
    self.assertEqual(self.run_import(), 1)
    self.assertEqual({c.get_id() for c in self.connections()}, {"Good", "Broken"})

  def run_main(self, statuses):
    # Exercise the entry point's service behavior without requiring root or
    # changing the machine running the test. Conversion uses the real libnm.
    with patch.object(importer.os, "geteuid", return_value=0), \
         patch.object(importer, "import_networks", return_value=0), \
         patch.object(importer.subprocess, "run", side_effect=[
           subprocess.CompletedProcess([], status) for status in statuses
         ]) as run, \
         contextlib.redirect_stdout(self.log), contextlib.redirect_stderr(self.log):
      status = importer.main()
    return status, [call.args[0] for call in run.call_args_list]

  def test_offline_import_does_not_start_or_restart_network_services(self):
    status, calls = self.run_main([3])
    self.assertEqual(status, 0)
    self.assertEqual(calls, [["systemctl", "is-active", "--quiet", "NetworkManager.service"]])

  def test_active_manager_reloads_without_activating_a_connection(self):
    status, calls = self.run_main([0, 0])
    self.assertEqual(status, 0)
    self.assertEqual(calls, [
      ["systemctl", "is-active", "--quiet", "NetworkManager.service"],
      ["nmcli", "connection", "reload"],
    ])

  def test_reload_failure_is_reported_and_retry_reloads_even_without_new_imports(self):
    self.assertEqual(self.run_main([0, 1])[0], 1)
    self.assertIn("Retry 'omarchy network import iwd'", self.log.getvalue())
    status, calls = self.run_main([0, 0])
    self.assertEqual(status, 0)
    self.assertEqual(calls[-1], ["nmcli", "connection", "reload"])


if __name__ == "__main__":
  unittest.main()
