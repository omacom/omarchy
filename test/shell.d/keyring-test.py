"""Only disposable keyrings and a private D-Bus session are used by this test."""

import importlib.util
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import threading
import time
import unittest
from unittest.mock import patch

from gi.repository import Gio, GLib


ROOT = Path(__file__).resolve().parents[2]


def load(name, filename):
  spec = importlib.util.spec_from_file_location(name, ROOT / "default/omarchy" / filename)
  module = importlib.util.module_from_spec(spec)
  spec.loader.exec_module(module)
  return module


keyring = load("keyring", "keyring.py")
pam = load("keyring_pam", "keyring-pam.py")


class PamTests(unittest.TestCase):
  def test_repairs_only_missing_stock_entries_and_is_idempotent(self):
    stock = "#%PAM-1.0\n\n" + "\n".join(pam.STOCK) + "\n"
    for removed in [pam.REMOVED, {pam.STOCK[1]}, {pam.STOCK[5]}, set()]:
      old = "\n".join(line for line in stock.split("\n") if line not in removed)
      fixed = pam.repaired_contents(old)
      self.assertEqual([" ".join(line.split()) for line in fixed.splitlines() if line and not line.startswith("#")], pam.STOCK)
      self.assertEqual(pam.repaired_contents(fixed), fixed)
      self.assertTrue(fixed.startswith("#%PAM-1.0\n\n"))

  def test_custom_order_and_jump_rules_are_not_rewritten(self):
    old = "\n".join(line for line in pam.STOCK if line not in pam.REMOVED)
    for custom in [old.replace("auth include system-login", "auth [success=1 default=ignore] pam_custom.so\nauth include system-login"), old.replace("pam_kwallet5.so", "pam_kwallet6.so"), old.replace("system-login", "custom-login")]:
      with self.assertRaises(ValueError):
        pam.repaired_contents(custom)
    complete_custom = "\n".join(pam.STOCK) + "\nauth required pam_custom.so\n"
    self.assertEqual(pam.repaired_contents(complete_custom), complete_custom)

  def test_atomic_repair_preserves_permissions_and_symlinks_are_refused(self):
    with tempfile.TemporaryDirectory() as temporary:
      path = Path(temporary) / "sddm"
      path.write_text("\n".join(line for line in pam.STOCK if line not in pam.REMOVED) + "\n")
      path.chmod(0o640)
      pam.repair(path)
      self.assertEqual(path.stat().st_mode & 0o777, 0o640)
      self.assertEqual(pam.repaired_contents(path.read_text()), path.read_text())
      link = Path(temporary) / "link"
      link.symlink_to(path)
      with self.assertRaises(ValueError):
        pam.repair(link)


class StorageTests(unittest.TestCase):
  def test_failed_enrollment_keeps_first_run_and_migration_pending(self):
    with tempfile.TemporaryDirectory() as temporary:
      base = Path(temporary)
      commands = base / "bin"
      commands.mkdir()
      fixture = base / "omarchy/install/user/first-run"
      fixture.mkdir(parents=True)
      for name in ("enable-user-units", "gnome-theme", "gtk-primary-paste", "audio-tuning", "welcome", "wifi"):
        (fixture / (name + ".sh")).write_text(":\n")
      stubs = {
        "omarchy-done": '[[ $1 == check ]] && exit 1\necho "$*" >> "$KEYRING_TEST_MARKERS"\n',
        "omarchy-provision-user": ":\n",
        "omarchy-hook-install": ":\n",
        "omarchy-lifecycle-dispatch": ":\n",
        "omarchy-notification-wait": ":\n",
        "omarchy-setup-security-keyring": 'exit "$KEYRING_TEST_ENROLL_STATUS"\n',
        "sudo": '[[ $* == "/usr/bin/python3 /usr/share/omarchy/default/omarchy/keyring-pam.py" ]]\n',
      }
      for name, source in stubs.items():
        executable = commands / name
        executable.write_text("#!/bin/bash\n" + source)
        executable.chmod(0o755)
      marker = base / "markers"
      environment = {**os.environ, "HOME": str(base / "home"), "PATH": str(commands) + ":" + os.environ["PATH"], "OMARCHY_PATH": str(base / "omarchy"), "KEYRING_TEST_MARKERS": str(marker), "KEYRING_TEST_ENROLL_STATUS": "1"}
      subprocess.run(["bash", str(ROOT / "bin/omarchy-provision-first-run")], env=environment, check=True)
      self.assertFalse(marker.exists())
      log = (base / "home/.local/state/omarchy/first-run.log").read_text()
      self.assertIn("Failed: enroll encrypted application keyring", log)
      migration = ROOT / "migrations/1791640218.sh"
      self.assertNotEqual(subprocess.run(["bash", "-euo", "pipefail", str(migration)], env=environment, capture_output=True).returncode, 0)
      environment["KEYRING_TEST_ENROLL_STATUS"] = "0"
      subprocess.run(["bash", str(ROOT / "bin/omarchy-provision-first-run")], env=environment, check=True)
      self.assertEqual(marker.read_text(), "mark first-run-user\n")
      subprocess.run(["bash", "-euo", "pipefail", str(migration)], env=environment, capture_output=True, check=True)

  def test_install_preserves_existing_keyrings_and_seeds_no_plaintext(self):
    with tempfile.TemporaryDirectory() as temporary:
      environment = {**os.environ, "HOME": temporary, "XDG_DATA_HOME": temporary + "/data"}
      script = ROOT / "install/user/default-keyring.sh"
      subprocess.run(["bash", str(script)], env=environment, check=True)
      directory = Path(temporary) / "data/keyrings"
      self.assertEqual(list(directory.iterdir()), [])
      collection = directory / "Default_keyring.keyring"
      collection.write_bytes(b"[keyring]\nsynthetic-preserved-data")
      alias = directory / "default"
      alias.write_text("Default_keyring\n")
      subprocess.run(["bash", str(script)], env=environment, check=True)
      self.assertEqual(collection.read_bytes(), b"[keyring]\nsynthetic-preserved-data")
      self.assertEqual(alias.read_text(), "Default_keyring\n")
      # GNOME still supports the historical data directory. Creating an empty
      # XDG directory would hide those existing collections from its loader.
      old = Path(temporary) / ".gnome2/keyrings"
      old.parent.mkdir()
      directory.rename(old)
      subprocess.run(["bash", str(script)], env=environment, check=True)
      self.assertFalse(directory.exists())
      self.assertEqual((old / "default").read_text(), "Default_keyring\n")
      with patch.dict(os.environ, environment):
        self.assertEqual(keyring.keyring_directory(), old)

  def test_headless_migration_fails_without_touching_legacy_file(self):
    with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"HOME": temporary, "XDG_DATA_HOME": temporary + "/data", "WAYLAND_DISPLAY": "", "DISPLAY": ""}):
      directory = Path(temporary) / "data/keyrings"
      directory.mkdir(parents=True)
      collection = directory / "Default_keyring.keyring"
      collection.write_bytes(b"[keyring]\nsynthetic-preserved-data")
      before = collection.read_bytes()
      with self.assertRaisesRegex(keyring.EnrollmentError, "graphical desktop"):
        keyring.enroll(migrate=True)
      self.assertEqual(collection.read_bytes(), before)
      collection.write_bytes(keyring.ENCRYPTED_HEADER + b"synthetic-fixture")
      keyring.enroll(migrate=True)

  def test_filename_mapping_and_traversal_rejection(self):
    self.assertEqual(keyring.collection_file(Path("/fixture"), keyring.LEGACY), Path("/fixture/Default_keyring.keyring"))
    self.assertEqual(keyring.collection_file(Path("/fixture"), keyring.ROOT + "/collection/caf_c3_a9"), Path("/fixture/café.keyring"))
    for identifier in ("session", "_2e_2e", "a_2fb", "a_00b"):
      with self.assertRaises(keyring.EnrollmentError):
        keyring.collection_file(Path("/fixture"), keyring.ROOT + "/collection/" + identifier)

  def test_blank_password_is_not_reported_as_encrypted(self):
    with tempfile.TemporaryDirectory() as temporary:
      directory = Path(temporary)
      (directory / "Default_keyring.keyring").write_bytes(b"[keyring]\nsynthetic-data")
      native = keyring.NativeKeyring.__new__(keyring.NativeKeyring)
      native.alias = lambda: keyring.LEGACY
      native.items = lambda _collection: {keyring.LEGACY + "/1"}
      native.call = lambda *_args: ("/test/prompt",)
      native.prompt = lambda _path: None
      with self.assertRaisesRegex(keyring.EnrollmentError, "still unencrypted"):
        native.encrypt(keyring.LEGACY, directory)


class PromptServer:
  """A directed Completed signal on a separate connection, never a GUI mock."""
  def __init__(self, outcome):
    self.outcome = outcome
    self.ready = threading.Event()
    self.dismissed = threading.Event()
    self.thread = threading.Thread(target=self.run, daemon=True)
    self.thread.start()
    if not self.ready.wait(5):
      raise RuntimeError("test prompt service did not start")

  def run(self):
    context = GLib.MainContext.new()
    context.push_thread_default()
    self.loop = GLib.MainLoop.new(context, False)
    connection = Gio.DBusConnection.new_for_address_sync(os.environ["DBUS_SESSION_BUS_ADDRESS"], Gio.DBusConnectionFlags.AUTHENTICATION_CLIENT | Gio.DBusConnectionFlags.MESSAGE_BUS_CONNECTION, None, None)
    self.name = connection.get_unique_name()
    xml = '<node><interface name="org.freedesktop.Secret.Prompt"><method name="Prompt"><arg name="window" type="s" direction="in"/></method><method name="Dismiss"/><signal name="Completed"><arg type="b"/><arg type="v"/></signal></interface></node>'

    def method(_connection, sender, path, interface, name, _parameters, invocation):
      invocation.return_value(GLib.Variant("()", ()))
      if name == "Dismiss":
        self.dismissed.set()
      elif self.outcome != "timeout":
        connection.emit_signal(sender, path, interface, "Completed", GLib.Variant("(bv)", (self.outcome == "cancel", GLib.Variant("o", keyring.LEGACY))))

    registration = connection.register_object("/test/prompt", Gio.DBusNodeInfo.new_for_xml(xml).interfaces[0], method, None, None)
    self.ready.set()
    self.loop.run()
    connection.unregister_object(registration)
    connection.close_sync(None)
    context.pop_thread_default()

  def stop(self):
    self.loop.quit()
    self.thread.join(timeout=5)


class PromptTests(unittest.TestCase):
  def test_directed_completion_cancel_and_bounded_timeout(self):
    for outcome in ("success", "cancel", "timeout"):
      server = PromptServer(outcome)
      try:
        with patch.object(keyring, "SERVICE", server.name), patch.object(keyring, "PROMPT_TIMEOUT_SECONDS", 1):
          native = keyring.NativeKeyring()
          if outcome == "success":
            self.assertEqual(native.prompt("/test/prompt"), keyring.LEGACY)
          else:
            with self.assertRaisesRegex(keyring.EnrollmentError, "cancelled" if outcome == "cancel" else "timed out"):
              native.prompt("/test/prompt")
          if outcome == "timeout":
            self.assertTrue(server.dismissed.wait(1))
      finally:
        server.stop()


class NativeDaemonTests(unittest.TestCase):
  def test_native_reencryption_preserves_alias_items_and_synthetic_secret(self):
    daemon = os.environ.get("OMARCHY_TEST_KEYRING_DAEMON") or shutil.which("gnome-keyring-daemon")
    if not daemon:
      self.skipTest("gnome-keyring-daemon unavailable; provide OMARCHY_TEST_KEYRING_DAEMON for isolated integration")
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    occupied = bus.call_sync("org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "NameHasOwner", GLib.Variant("(s)", (keyring.SERVICE,)), None, Gio.DBusCallFlags.NONE, 1000, None).unpack()[0]
    self.assertFalse(occupied, "refuse to test against any existing Secret Service")
    with tempfile.TemporaryDirectory() as temporary:
      directory = Path(temporary) / "data/keyrings"
      directory.mkdir(parents=True, mode=0o700)
      runtime = Path(temporary) / "run"
      runtime.mkdir(mode=0o700)
      collection_file = directory / "Default_keyring.keyring"
      collection_file.write_text("[keyring]\ndisplay-name=Default keyring\nctime=1\nmtime=0\nlock-on-idle=false\nlock-after=false\n")
      alias_file = directory / "default"
      alias_file.write_text("Default_keyring\n")
      alias_bytes = alias_file.read_bytes()
      environment = {**os.environ, "HOME": temporary, "XDG_DATA_HOME": str(Path(temporary) / "data"), "XDG_CONFIG_HOME": str(Path(temporary) / "config"), "XDG_RUNTIME_DIR": str(runtime)}
      with open(Path(temporary) / "daemon.log", "w") as log:
        process = subprocess.Popen([daemon, "--foreground", "--components=secrets", "--control-directory=" + str(runtime / "keyring")], env=environment, stdout=log, stderr=log)
        try:
          native = keyring.NativeKeyring()
          for attempt in range(50):
            try:
              self.assertEqual(native.alias(), keyring.LEGACY)
              break
            except GLib.Error:
              if process.poll() is not None:
                self.fail("disposable keyring daemon exited")
              time.sleep(0.1)
          else:
            self.fail("disposable keyring daemon did not acquire its bus name")
          _output, session = native.call(keyring.ROOT, keyring.SERVICE_INTERFACE, "OpenSession", "(sv)", ("plain", GLib.Variant("s", "")))
          # Check the standard native creation signature and the lowercase
          # login identifier used for PAM, without interacting with a real GUI.
          properties = {keyring.COLLECTION + ".Label": GLib.Variant("s", "login")}
          missing, create_prompt = native.call(keyring.ROOT, keyring.SERVICE_INTERFACE, "CreateCollection", "(a{sv}s)", (properties, ""))
          self.assertEqual(missing, "/")
          native.call(create_prompt, keyring.PROMPT, "Dismiss")
          self.assertFalse((directory / "login.keyring").exists())
          created = native.call(keyring.ROOT, keyring.INTERNAL, "CreateWithMasterPassword", "(a{sv}(oayays))", (properties, (session, [], list(b"synthetic-login-password"), "text/plain")))[0]
          self.assertEqual(created, keyring.ROOT + "/collection/login")
          self.assertEqual(keyring.storage_format(directory / "login.keyring"), "encrypted")
          native.unlock(keyring.LEGACY)
          synthetic_secret = b"OMARCHY_TEST_SYNTHETIC_NOT_A_REAL_SECRET"
          item, prompt = native.call(keyring.LEGACY, keyring.COLLECTION, "CreateItem", "(a{sv}(oayays)b)", ({"org.freedesktop.Secret.Item.Label": GLib.Variant("s", "Synthetic regression fixture"), "org.freedesktop.Secret.Item.Attributes": GLib.Variant("a{ss}", {"omarchy-test": "synthetic"})}, (session, [], list(synthetic_secret), "text/plain"), False))
          self.assertEqual(prompt, "/")
          before_items = native.items(keyring.LEGACY)
          before_bytes = collection_file.read_bytes()

          # Exercise actual ChangeWithPrompt plus cancellation, with no GUI or
          # password transfer. A cancelled prompt leaves the native file intact.
          prompt = native.call(keyring.ROOT, keyring.INTERNAL, "ChangeWithPrompt", "(o)", (keyring.LEGACY,))[0]
          self.assertNotEqual(prompt, "/")
          native.call(prompt, keyring.PROMPT, "Dismiss")
          self.assertEqual(collection_file.read_bytes(), before_bytes)

          # A headless test cannot drive GNOME's secure GUI. Use the daemon's
          # native password-change backend with synthetic in-memory test values
          # to verify preservation and the helper's postconditions independently.
          def synthetic_completion(prompt):
            native.call(prompt, keyring.PROMPT, "Dismiss")
            native.call(keyring.ROOT, keyring.INTERNAL, "ChangeWithMasterPassword", "(o(oayays)(oayays))", (keyring.LEGACY, (session, [], [], "text/plain"), (session, [], list(b"synthetic-test-only-password"), "text/plain")))

          native.prompt = synthetic_completion
          native.encrypt(keyring.LEGACY, directory)
          self.assertEqual(keyring.storage_format(collection_file), "encrypted")
          self.assertNotIn(synthetic_secret, collection_file.read_bytes())
          self.assertEqual(alias_file.read_bytes(), alias_bytes)
          self.assertEqual(native.items(keyring.LEGACY), before_items)
          stored = native.call(item, "org.freedesktop.Secret.Item", "GetSecret", "(o)", (session,))[0]
          self.assertEqual(bytes(stored[2]), synthetic_secret)
          native.call(keyring.ROOT, keyring.SERVICE_INTERFACE, "Lock", "(ao)", ([keyring.LEGACY],))
          native.call(keyring.ROOT, keyring.INTERNAL, "UnlockWithMasterPassword", "(o(oayays))", (keyring.LEGACY, (session, [], list(b"synthetic-test-only-password"), "text/plain")))
          stored = native.call(item, "org.freedesktop.Secret.Item", "GetSecret", "(o)", (session,))[0]
          self.assertEqual(bytes(stored[2]), synthetic_secret)
        finally:
          process.terminate()
          try:
            process.wait(timeout=5)
          except subprocess.TimeoutExpired:
            process.kill()
            process.wait()


if __name__ == "__main__":
  unittest.main(verbosity=2)
