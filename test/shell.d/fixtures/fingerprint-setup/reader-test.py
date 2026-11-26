"""Exercise the real enrollment client against a private fprintd D-Bus service."""
import os
from pathlib import Path
import sys
import unittest

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

sys.path.insert(0, str(Path(__file__).resolve().parents[4] / "default/fingerprint"))
from reader import DEVICE, SERVICE, Reader

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

  def scan(self, mode, finger):
    results = []
    loop = GLib.MainLoop()
    def update(status, detail, done):
      results.append(status)
      if done:
        loop.quit()
    reader = Reader(os.environ["DBUS_SESSION_BUS_ADDRESS"], PATH, update)
    timeout = GLib.timeout_add_seconds(4, lambda: loop.quit())
    reader.start(mode, finger)
    loop.run()
    GLib.source_remove(timeout)
    self.assertTrue(reader.closed, results)
    return results

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


if __name__ == "__main__":
  unittest.main()
