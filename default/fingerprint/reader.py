"""A single fprintd claim, owned by the signed-in user and released between scans."""
from gi.repository import Gio, GLib

SERVICE = "net.reactivated.Fprint"
MANAGER = "/net/reactivated/Fprint/Manager"
DEVICE = SERVICE + ".Device"
FINGERS = [side + "-" + finger for side in ("right", "left") for finger in
           ("index-finger", "thumb", "middle-finger", "ring-finger", "little-finger")]


APPLE_READER = "Apple secure enclave fingerprint sensor"


def enrollment_capacity(reader_name):
  # Apple's Aurora driver uses one SEP user context with three slots
  # (drivers/soc/apple/bio.rs, SEP_USER_CAPACITY). fprintd exposes ten
  # finger names, but does not expose the device's physical capacity.
  return 3 if reader_name == APPLE_READER else len(FINGERS)


class ScanGuide:
  """Keep the lift cue through brief contact changes as a reader rearms."""

  def __init__(self, changed):
    self.changed = changed
    self.samples = 0
    self.present = None
    self.prompt = "touch"
    self.release_source = 0

  def cancel(self):
    if self.release_source:
      GLib.source_remove(self.release_source)
      self.release_source = 0

  def released(self):
    self.release_source = 0
    self.prompt = "touch"
    self.changed(self)
    return GLib.SOURCE_REMOVE

  def update(self, event):
    previous = self.prompt
    if event in ("finger-down", "finger-up", "finger-needed"):
      # A request to place a finger can arrive while it is still down.
      if event != "finger-needed":
        self.present = event == "finger-down"
      if self.prompt in ("touch", "hold"):
        self.prompt = "hold" if self.present else "touch"
    else:
      self.cancel()
      if event == "enroll-stage-passed":
        self.samples += 1
        self.prompt = "retouch"
      else:
        self.prompt = event

    # A release can arrive on either side of the stage result. Only a
    # sustained absence ends the lift or retry cue. Readers without contact
    # reports keep the combined instruction until the next scan result.
    if self.present is False and self.prompt not in ("touch", "hold"):
      if not self.release_source:
        self.release_source = GLib.timeout_add(500, self.released)
    else:
      self.cancel()
    if self.prompt != previous or event == "enroll-stage-passed":
      self.changed(self)


class Reader:
  def __init__(self, address, path, status):
    self.bus = Gio.DBusConnection.new_for_address_sync(
      address, Gio.DBusConnectionFlags.AUTHENTICATION_CLIENT | Gio.DBusConnectionFlags.MESSAGE_BUS_CONNECTION, None, None)
    self.bus.set_exit_on_close(False)
    self.path, self.status, self.closed = path, status, False
    self.claimed = False
    self.mode = None
    self.props = self.bus.signal_subscribe(
      SERVICE, "org.freedesktop.DBus.Properties", "PropertiesChanged", path, DEVICE,
      Gio.DBusSignalFlags.NONE, self.properties)
    self.owner = Gio.bus_watch_name_on_connection(self.bus, SERVICE, Gio.BusNameWatcherFlags.NONE,
      None, lambda *_: self.finish("disconnected", "", None) if not self.closed else None)
    self.subscription = self.bus.signal_subscribe(
      SERVICE, DEVICE, None, path, None, Gio.DBusSignalFlags.NONE, self.signal)

  def call(self, method, args, done):
    def reply(bus, result):
      if self.closed:
        return
      try:
        value = bus.call_finish(result).unpack()
      except GLib.Error as error:
        done(None, error)
      else:
        done(value, None)
    self.bus.call(SERVICE, self.path, DEVICE, method, args, None,
                  Gio.DBusCallFlags.ALLOW_INTERACTIVE_AUTHORIZATION, 120000, None, reply)

  def start(self, mode, finger, capacity=len(FINGERS)):
    self.mode = mode
    def claimed(_, error):
      if error:
        self.done("error", error.message)
        return
      self.claimed = True
      # Check while holding the claim. Someone else may have enrolled this
      # slot between opening the window and clicking Add.
      if mode == "Delete":
        self.call("DeleteEnrolledFinger", GLib.Variant("(s)", (finger,)),
                  lambda _, error: self.done("error", error.message) if error else self.done("removed", ""))
      elif mode == "Enroll":
        self.call("ListEnrolledFingers", GLib.Variant("(s)", ("",)), listed)
      else:
        begin()
    def listed(reply, error):
      if error and Gio.DBusError.get_remote_error(error) != SERVICE + ".Error.NoEnrolledPrints":
        self.done("error", error.message)
      elif reply and finger in reply[0]:
        self.done("enroll-duplicate", "")
      elif reply and len(set(reply[0])) >= capacity:
        self.done("enroll-data-full", "")
      else:
        begin()
    def begin():
      self.call(mode + "Start", GLib.Variant("(s)", (finger,)),
                lambda _, error: self.done("error", error.message) if error else None)
    self.call("Claim", GLib.Variant("(s)", ("",)), claimed)

  def properties(self, bus, sender, path, interface, signal, params):
    if not self.mode or self.closed:
      return
    _, properties, _ = params.unpack()
    if "finger-present" in properties:
      self.status("finger-down" if properties["finger-present"] else "finger-up", "", False)
    elif properties.get("finger-needed"):
      self.status("finger-needed", "", False)

  def signal(self, bus, sender, path, interface, signal, params):
    if not self.mode or signal != self.mode + "Status":
      return
    result, finished = params.unpack()
    if finished:
      mode, self.mode = self.mode, None
      self.call(mode + "Stop", None, lambda _, error: self.done(result, ""))
    else:
      self.status(result, "", False)

  def done(self, result, detail):
    self.mode = None
    if self.claimed:
      self.claimed = False
      self.call("Release", None, lambda _, error: self.finish(result, detail, error))
    else:
      self.finish(result, detail, None)

  def finish(self, result, detail, error):
    self.cancel()
    self.status("error" if error else result, error.message if error else detail, True)

  def cancel(self):
    if self.closed:
      return
    self.closed = True
    Gio.bus_unwatch_name(self.owner)
    self.bus.signal_unsubscribe(self.props)
    self.bus.signal_unsubscribe(self.subscription)
    # fprintd releases all operations owned by a disappearing D-Bus client,
    # including a Claim or Start that is still waiting for authorization.
    self.bus.close(None, None)
