#!/usr/bin/python3 -B
"""Manage the signed-in user's prints on a specific fprintd reader."""
import json
import sqlite3
import sys
from pathlib import Path

from gi.repository import Gio, GLib

from names import FINGERS, Names
import sudo_pam

SERVICE = "net.reactivated.Fprint"
DEVICE = SERVICE + ".Device"
MANAGER = "/net/reactivated/Fprint/Manager"
APPLE = "Apple secure enclave fingerprint sensor"
LOCK_PAM = Path("/etc/pam.d/omarchy-lock-fingerprint")
LOCK_OFF = Path.home() / ".local/state/omarchy/toggles/lock-fingerprint-off"


def report(data):
  print(json.dumps(data, ensure_ascii=False), flush=True)


class Readers:
  def __init__(self):
    self.bus = Gio.bus_get_sync(Gio.BusType.SYSTEM)
    manager = Gio.DBusProxy.new_sync(self.bus, Gio.DBusProxyFlags.DO_NOT_LOAD_PROPERTIES,
                                     None, SERVICE, MANAGER, SERVICE + ".Manager", None)
    self.owner = manager.get_name_owner()
    if not self.owner:
      raise ValueError("unavailable")
    self.prefix = self.bus.get_guid() + "|" + self.owner
    self.devices = []
    for path in self.call(MANAGER, SERVICE + ".Manager", "GetDevices")[0]:
      props = self.call(path, "org.freedesktop.DBus.Properties", "GetAll", "(s)", DEVICE)[0]
      self.devices.append((path, props))

  def call(self, path, interface, method, signature=None, *args):
    params = GLib.Variant(signature, args) if signature else None
    return self.bus.call_sync(self.owner, path, interface, method, params, None,
                              Gio.DBusCallFlags.ALLOW_INTERACTIVE_AUTHORIZATION, 120000, None).unpack()

  def selected(self, token):
    for path, props in self.devices:
      if token == self.prefix + path:
        return path, props
    raise ValueError("unavailable")

  def fingers(self, path):
    try:
      return self.call(path, DEVICE, "ListEnrolledFingers", "(s)", "")[0]
    except GLib.Error as error:
      if Gio.DBusError.get_remote_error(error) == SERVICE + ".Error.NoEnrolledPrints":
        return []
      raise

  def names(self, path):
    return Names.for_device(self.devices, path, self.prefix)

  def scan(self, path, method, finger, props):
    loop = GLib.MainLoop()
    last = None
    stage = 0
    skip = int(props["name"] == APPLE)
    def signal(bus, sender, object_path, interface, name, params):
      nonlocal last, stage
      if name == "VerifyFingerSelected" and method == "Verify" and finger == "any":
        selected, = params.unpack()
        if selected == "any" or selected in FINGERS:
          print("selected", selected, flush=True)
        return
      if name != method + "Status":
        return
      result, done = params.unpack()
      if done:
        last = result
        loop.quit()
      elif result == "enroll-stage-passed":
        stage += 1
        if stage > skip:
          print("stage", stage - skip, flush=True)
      else:
        reason = {"swipe-too-short": "short", "finger-not-centered": "center",
                  "remove-and-retry": "lift", "too-fast": "fast"}.get(result.split("-", 1)[-1], "again")
        print("retry", reason, flush=True)

    sub = self.bus.signal_subscribe(self.owner, DEVICE, None, path, None,
                                    Gio.DBusSignalFlags.NONE, signal)
    watch = Gio.bus_watch_name_on_connection(self.bus, self.owner, Gio.BusNameWatcherFlags.NONE,
                                             None, lambda *_: loop.quit())
    try:
      self.call(path, DEVICE, method + "Start", "(s)", finger)
      print("step " + method.lower(), flush=True)
      if method == "Enroll":
        print("scan", props["scan-type"], flush=True)
        try:
          count = self.call(path, "org.freedesktop.DBus.Properties", "Get",
                            "(ss)", DEVICE, "num-enroll-stages")[0] - skip
        except GLib.Error:
          count = 0
        if count > 0:
          print("stages", count, flush=True)
      loop.run()
      if last is None:
        raise ValueError("disconnected")
      self.call(path, DEVICE, method + "Stop")
    finally:
      self.bus.signal_unsubscribe(sub)
      Gio.bus_unwatch_name(watch)
    if last != {"Verify": "verify-match", "Enroll": "enroll-completed"}[method]:
      raise ValueError({"verify-no-match": "no-match", "enroll-duplicate": "duplicate",
                        "enroll-data-full": "full", "verify-disconnected": "disconnected",
                        "enroll-disconnected": "disconnected"}.get(last, "stopped"))

  def operate(self, action, token, finger, label=None):
    path, props = self.selected(token)
    if finger not in FINGERS and not (action == "verify" and finger == "any"):
      raise ValueError("unavailable")
    if action == "rename":
      # Editing a local label needs no claim on the sensor or authorization prompt.
      label = label.strip()
      if len(label) > 64 or any(not c.isprintable() for c in label):
        raise ValueError("name")
      saved = self.fingers(path)
      if finger not in saved:
        raise ValueError("unavailable")
      names = self.names(path)
      names.sync(saved)
      names.rename(finger, label)
      return
    self.call(path, DEVICE, "Claim", "(s)", "")
    try:
      saved = self.fingers(path)
      if action == "add":
        if finger in saved or len(saved) >= capacity(props):
          raise ValueError("full" if len(saved) >= capacity(props) else "duplicate")
        self.scan(path, "Enroll", finger, props)
        print("enrolled", flush=True)
        self.scan(path, "Verify", finger, props)
        print("done", flush=True)
      elif not saved or (finger != "any" and finger not in saved):
        raise ValueError("unavailable")
      elif action == "verify":
        self.scan(path, "Verify", finger, props)
        print("matched", flush=True)
      elif action == "remove":
        self.call(path, DEVICE, "DeleteEnrolledFinger", "(s)", finger)
        # fprintd has already deleted the print. Local label housekeeping can
        # be retried when the next snapshot reconciles the enrolled slots.
        try:
          self.names(path).sync(self.fingers(path))
        except (OSError, sqlite3.Error, GLib.Error) as error:
          print(error, file=sys.stderr)
    finally:
      self.call(path, DEVICE, "Release")


def capacity(props):
  return 3 if props["name"] == APPLE else len(FINGERS)


def snapshot(token):
  data = {"readers": [], "reader": "", "prints": [], "capacity": 0,
          "lockPam": LOCK_PAM.exists(), "lock": LOCK_PAM.exists() and not LOCK_OFF.exists(),
          "sudo": {True: "on", False: "off", None: "custom"}[sudo_pam.enabled()]}
  try:
    readers = Readers()
    data["readers"] = [{"token": readers.prefix + path, "name": props["name"]}
                       for path, props in readers.devices]
    if not token:
      token = readers.prefix + readers.call(MANAGER, SERVICE + ".Manager", "GetDefaultDevice")[0]
    path, props = readers.selected(token)
    saved = readers.fingers(path)
    try:
      rows = readers.names(path).sync(saved)
      data["canRename"] = True
    except (OSError, sqlite3.Error) as error:
      print(error, file=sys.stderr)
      rows = {slot: (i, None) for i, slot in enumerate(FINGERS, 1) if slot in saved}
      data["canRename"] = False
    data.update(reader=token, capacity=capacity(props), scanType=props["scan-type"],
                prints=sorted(({"slot": slot, "number": number, "name": name or ""}
                               for slot, (number, name) in rows.items()), key=lambda row: row["number"]))
  except (ValueError, GLib.Error):
    data["error"] = "unavailable"
  report(data)


if __name__ == "__main__":
  args = sys.argv[1:]
  try:
    if args[:1] == ["list"] and len(args) in (1, 2):
      snapshot(args[1] if len(args) == 2 else "")
    elif ((len(args) == 3 and args[0] in ("add", "remove", "verify"))
          or (len(args) == 4 and args[0] == "rename")):
      Readers().operate(*args)
    else:
      sys.exit(2)
  except (ValueError, GLib.Error, OSError, sqlite3.Error) as error:
    print(error, file=sys.stderr)
    reason = str(error) if isinstance(error, ValueError) else "stopped"
    if isinstance(error, GLib.Error):
      remote = Gio.DBusError.get_remote_error(error)
      if remote == "org.freedesktop.PolicyKit1.Error.Cancelled":
        sys.exit(126)
      if remote in (SERVICE + ".Error.PermissionDenied", "org.freedesktop.DBus.Error.AccessDenied",
                    "org.freedesktop.PolicyKit1.Error.NotAuthorized"):
        reason = "denied"
    print("fail", reason, flush=True)
    sys.exit(3 if reason == "no-match" else 1)
