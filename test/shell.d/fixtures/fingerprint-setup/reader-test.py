"""Exercise the real enrollment client against a private fprintd D-Bus service."""
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

sys.path.insert(0, str(Path(__file__).resolve().parents[4] / "default/fingerprint"))
from names import Names
import sudo_pam
from reader import APPLE_READER, DEVICE, SERVICE, Reader, ScanGuide, enrollment_capacity

PATH = "/net/reactivated/Fprint/Device/0"
PROPS = "org.freedesktop.DBus.Properties"


class Device(dbus.service.Object):
  def __init__(self, bus):
    self.fingers = ["right-index-finger"]
    self.calls = []
    self.selected = ""
    self.hold = False
    super().__init__(dbus.service.BusName(SERVICE, bus), PATH)

  @dbus.service.method(DEVICE, in_signature="s")
  def Claim(self, user):
    assert user == ""
    self.calls.append("claim")

  @dbus.service.method(DEVICE, in_signature="s", out_signature="as")
  def ListEnrolledFingers(self, user):
    assert user == ""
    return self.fingers

  @dbus.service.method(DEVICE, in_signature="s")
  def DeleteEnrolledFinger(self, finger):
    self.calls.append("delete " + str(finger))
    self.fingers.remove(finger)

  @dbus.service.signal(PROPS, signature="sa{sv}as")
  def PropertiesChanged(self, interface, changed, invalidated):
    pass

  @dbus.service.signal(DEVICE, signature="sb")
  def EnrollStatus(self, result, done):
    pass

  @dbus.service.signal(DEVICE, signature="sb")
  def VerifyStatus(self, result, done):
    pass

  @dbus.service.method(DEVICE, in_signature="s")
  def EnrollStart(self, finger):
    self.calls.append("enroll " + str(finger))
    self.selected = str(finger)
    if not self.hold:
      GLib.idle_add(self.samples)

  def samples(self):
    self.PropertiesChanged(DEVICE, {"finger-needed": dbus.Boolean(True)}, [])
    self.PropertiesChanged(DEVICE, {"finger-present": dbus.Boolean(True)}, [])
    self.EnrollStatus("enroll-stage-passed", False)
    self.PropertiesChanged(DEVICE, {"finger-present": dbus.Boolean(False)}, [])
    self.fingers.append(self.selected)
    self.EnrollStatus("enroll-completed", True)
    return False

  @dbus.service.method(DEVICE, in_signature="s")
  def VerifyStart(self, finger):
    self.calls.append("verify " + str(finger))
    GLib.idle_add(self.VerifyStatus, "verify-match", True)

  @dbus.service.method(DEVICE)
  def VerifyStop(self):
    self.calls.append("verify stop")

  @dbus.service.method(DEVICE)
  def EnrollStop(self):
    self.calls.append("enroll stop")

  @dbus.service.method(DEVICE)
  def Release(self):
    self.calls.append("release")


class ReaderTest(unittest.TestCase):
  @classmethod
  def setUpClass(cls):
    DBusGMainLoop(set_as_default=True)
    cls.bus = dbus.SessionBus()
    cls.device = Device(cls.bus)

  def scan(self, mode, finger, **kwargs):
    results = []
    loop = GLib.MainLoop()
    def update(status, detail, done):
      results.append(status)
      if done:
        loop.quit()
    reader = Reader(os.environ["DBUS_SESSION_BUS_ADDRESS"], PATH, update)
    timeout = GLib.timeout_add_seconds(4, lambda: loop.quit())
    reader.start(mode, finger, **kwargs)
    loop.run()
    GLib.source_remove(timeout)
    self.assertTrue(reader.closed, results)
    return results

  def test_full_apple_reader_can_replace_only_the_chosen_print(self):
    original = list(self.device.fingers)
    self.addCleanup(setattr, self.device, "fingers", original)
    self.device.fingers = ["right-index-finger", "left-index-finger", "left-middle-finger"]
    capacity = enrollment_capacity(APPLE_READER)
    self.assertEqual(self.scan("Enroll", "right-thumb", capacity=capacity), ["enroll-data-full"])
    self.assertEqual(self.device.calls[-2:], ["claim", "release"])
    self.assertEqual(self.scan("Delete", "left-index-finger"), ["removed"])
    self.assertEqual(self.device.calls[-3:], ["claim", "delete left-index-finger", "release"])
    self.assertEqual(self.device.fingers, ["right-index-finger", "left-middle-finger"])
    self.assertEqual(self.scan("Enroll", "right-thumb", capacity=capacity)[-1], "enroll-completed")
    self.assertEqual(self.scan("Enroll", "left-thumb", capacity=enrollment_capacity("USB reader"))[-1], "enroll-completed")

  def test_new_finger_preserves_existing_and_uses_reader_completion(self):
    self.assertEqual(self.scan("Enroll", "left-index-finger"),
      ["finger-needed", "finger-down", "enroll-stage-passed", "finger-up", "enroll-completed"])
    self.assertEqual(self.device.calls[-4:], ["claim", "enroll left-index-finger", "enroll stop", "release"])
    self.assertEqual(self.device.fingers, ["right-index-finger", "left-index-finger"])
    self.assertEqual(self.scan("Verify", "left-index-finger"), ["verify-match"])
    self.assertEqual(self.device.calls[-4:], ["claim", "verify left-index-finger", "verify stop", "release"])

  def test_occupied_slot_is_never_started(self):
    self.assertEqual(self.scan("Enroll", "right-index-finger"), ["enroll-duplicate"])
    self.assertEqual(self.device.calls[-2:], ["claim", "release"])


class SetupTest(unittest.TestCase):
  def test_sudo_opt_in_round_trip_keeps_other_methods_and_password_fallback(self):
    original = (b"#%PAM-1.0\nauth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2\n"
                b"auth\tinclude\tsystem-auth\naccount include system-auth\nsession include system-auth\n")
    with tempfile.TemporaryDirectory() as tmp:
      path = Path(tmp) / "sudo"
      path.write_bytes(original)
      self.assertFalse(sudo_pam.enabled(path))
      sudo_pam.configure(path, True)
      active = path.read_bytes()
      self.assertTrue(sudo_pam.enabled(path))
      self.assertIn(sudo_pam.GATE + b"\n" + sudo_pam.FINGERPRINT + b"\nauth\tinclude", active)
      sudo_pam.configure(path, True)
      self.assertEqual(path.read_bytes(), active)
      sudo_pam.configure(path, False)
      self.assertEqual(path.read_bytes(), original)

      # Older Omarchy puts the same two rules ahead of the PAM header.
      path.write_bytes(sudo_pam.GATE + b"\n" + sudo_pam.FINGERPRINT + b"\n" + original)
      self.assertTrue(sudo_pam.enabled(path))
      sudo_pam.configure(path, False)
      self.assertEqual(path.read_bytes(), original)
      custom = original + b"Auth required pam_access.so\n"
      path.write_bytes(custom)
      self.assertIsNone(sudo_pam.enabled(path))
      with self.assertRaises(ValueError):
        sudo_pam.configure(path, True)
      self.assertEqual(path.read_bytes(), custom)

  def test_rearming_preserves_lift_until_release_then_guides_the_next_press(self):
    loop = GLib.MainLoop()
    prompts = []
    def changed(guide):
      prompts.append(guide.prompt)
      loop.quit()
    def next_cue(expected):
      timeout = GLib.timeout_add_seconds(3, loop.quit)
      loop.run()
      self.assertEqual(prompts[-1], expected)
      GLib.source_remove(timeout)

    guide = ScanGuide(changed, press_enrollment=True)
    self.addCleanup(guide.cancel)
    for stage in (1, 2):
      guide.update("finger-down")
      # Real fprintd can deassert contact just before the accepted sample.
      guide.update("finger-up")
      guide.update("enroll-stage-passed")
      self.assertEqual(prompts[-1], "hold")
      next_cue("lift")
      for event in ("finger-needed", "finger-down"):
        guide.update(event)
      self.assertEqual(prompts[-1], "lift")
      guide.update("finger-up")
      next_cue("touch")
      self.assertEqual(guide.samples, stage)
    self.assertEqual(prompts, ["hold", "lift", "touch"] * 2)

    guide.update("enroll-remove-and-retry")
    guide.update("finger-down")
    self.assertEqual(prompts[-1], "enroll-remove-and-retry")

  def test_reader_without_contact_reports_keeps_the_combined_instruction(self):
    guide = ScanGuide(lambda _: None, press_enrollment=True)
    guide.update("enroll-stage-passed")
    guide.update("finger-needed")
    self.assertEqual(guide.prompt, "retouch")
    self.assertIsNone(guide.next_prompt)

  def test_renamed_finger_survives_reordering_and_a_freed_slot_starts_fresh(self):
    with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, XDG_DATA_HOME=tmp):
      store = Names("Built-in")
      first, second = "right-index-finger", "left-thumb"
      self.assertEqual(store.sync([first]), {first: (1, None)})
      store.sync([second, first])
      store.rename(second, "Trackpad hand")
      self.assertEqual(Names("Built-in").sync([second]), {second: (2, "Trackpad hand")})
      self.assertEqual(store.sync([second, first])[first], (1, None))
      self.assertEqual(Names("External").sync([second]), {second: (1, None)})


if __name__ == "__main__":
  unittest.main()
