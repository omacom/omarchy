"""A private fprintd peer for the native Qt client tests."""
import os
from pathlib import Path
import sys
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

SERVICE = "net.reactivated.Fprint"
DEVICE = SERVICE + ".Device"
PATH = "/net/reactivated/Fprint/Device/0"
PROPS = "org.freedesktop.DBus.Properties"


class Device(dbus.service.Object):
  def __init__(self, bus):
    self.fingers = ["right-index-finger"]
    self.calls = []
    self.selected = ""
    self.hold = False
    self.verdict = "verify-match"
    super().__init__(dbus.service.BusName(SERVICE, bus), PATH)

  @dbus.service.method(PROPS, in_signature="s", out_signature="a{sv}")
  def GetAll(self, interface):
    return {"name": "Apple secure enclave fingerprint sensor", "scan-type": "press"}

  @dbus.service.method(DEVICE, in_signature="s", sender_keyword="sender")
  def Claim(self, user, sender=None):
    self.last_client = sender
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

  @dbus.service.signal(DEVICE, signature="s")
  def VerifyFingerSelected(self, finger):
    pass

  @dbus.service.method(DEVICE, in_signature="s")
  def VerifyStart(self, finger):
    self.calls.append("verify " + str(finger))
    if finger == "any":
      self.VerifyFingerSelected(self.fingers[0])
    GLib.idle_add(self.VerifyStatus, self.verdict, True)

  @dbus.service.method(DEVICE)
  def VerifyStop(self):
    self.calls.append("verify stop")

  @dbus.service.method(DEVICE)
  def EnrollStop(self):
    self.calls.append("enroll stop")

  @dbus.service.method(DEVICE)
  def Release(self):
    self.calls.append("release")



class Manager(dbus.service.Object):
  @dbus.service.method(SERVICE + ".Manager", out_signature="ao")
  def GetDevices(self):
    return [PATH]

class Controls(dbus.service.Object):
  @dbus.service.method("test.Fingerprint", in_signature="asbs")
  def Reset(self, fingers, hold, verdict):
    device.fingers = list(fingers)
    device.hold = bool(hold)
    device.verdict = verdict
    device.calls.clear()

  @dbus.service.method("test.Fingerprint", out_signature="s")
  def LastClient(self):
    return device.last_client

  @dbus.service.method("test.Fingerprint", out_signature="as")
  def Calls(self):
    return device.calls

if __name__ == "__main__":
  DBusGMainLoop(set_as_default=True)
  bus = dbus.SessionBus()
  device = Device(bus)
  manager = Manager(bus, "/net/reactivated/Fprint/Manager")
  controls = Controls(bus, "/test")
  Path(sys.argv[1]).touch()
  GLib.MainLoop().run()
