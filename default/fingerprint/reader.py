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
  """Present the contact and scan results in the order the user acts on them."""

  def __init__(self, changed, press_enrollment):
    self.changed = changed
    self.press_enrollment = press_enrollment
    self.samples = 0
    self.present = None
    self.prompt = "touch"
    self.hold_started = 0
    self.next_prompt = None
    self.source = 0

  def cancel(self):
    if self.source:
      GLib.source_remove(self.source)
    self.source = 0
    self.next_prompt = None

  def show(self, prompt):
    self.cancel()
    self.prompt = prompt
    if prompt == "hold":
      self.hold_started = GLib.get_monotonic_time()
    self.changed(self)
    if self.present is False and prompt not in ("touch", "hold"):
      self.after_release()

  def after(self, delay, prompt):
    self.cancel()
    self.next_prompt = prompt
    def elapsed():
      self.source = 0
      self.show(prompt)
      return GLib.SOURCE_REMOVE
    self.source = GLib.timeout_add(delay, elapsed)

  def after_release(self):
    # A reader can briefly deassert contact while rearming under a finger.
    if not self.source:
      self.after(500, "touch")

  def update(self, event):
    if event == "finger-needed":
      # A request for a finger is not a contact measurement.
      return
    if event == "enroll-stage-passed":
      self.samples += 1
      cue = "lift" if self.press_enrollment and self.present is not None else "retouch"
      if cue == "lift" and self.prompt == "hold":
        # A fast capture can report contact and acceptance in the same GTK
        # frame. Give the hold cue time to be read before asking for a lift.
        held_ms = (GLib.get_monotonic_time() - self.hold_started) // 1000
        if held_ms < 500:
          self.after(500 - held_ms, cue)
          return
      self.show(cue)
    elif event in ("finger-down", "finger-up"):
      self.present = event == "finger-down"
      if self.next_prompt == "lift":
        return
      if self.present:
        self.cancel()
        if self.prompt == "touch":
          self.show("hold")
      elif self.prompt == "hold" and not self.press_enrollment:
        self.show("touch")
      elif self.prompt != "touch":
        # The release may precede the accepted-scan event.
        self.after_release()
    else:
      self.show(event)


class Reader:
  def __init__(self, address, owner, path, status):
    self.bus = Gio.DBusConnection.new_for_address_sync(
      address, Gio.DBusConnectionFlags.AUTHENTICATION_CLIENT | Gio.DBusConnectionFlags.MESSAGE_BUS_CONNECTION, None, None)
    self.bus.set_exit_on_close(False)
    self.service = owner
    self.path, self.status, self.closed = path, status, False
    self.claimed = False
    self.mode = None
    self.props = self.bus.signal_subscribe(
      self.service, "org.freedesktop.DBus.Properties", "PropertiesChanged", path, DEVICE,
      Gio.DBusSignalFlags.NONE, self.properties)
    self.owner = Gio.bus_watch_name_on_connection(self.bus, self.service, Gio.BusNameWatcherFlags.NONE,
      None, lambda *_: self.finish("disconnected", "", None) if not self.closed else None)
    self.subscription = self.bus.signal_subscribe(
      self.service, DEVICE, None, path, None, Gio.DBusSignalFlags.NONE, self.signal)

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
    self.bus.call(self.service, self.path, DEVICE, method, args, None,
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
    if self.mode == "Verify" and signal == "VerifyFingerSelected":
      self.status("verify-finger-selected", params.unpack()[0], False)
      return
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
