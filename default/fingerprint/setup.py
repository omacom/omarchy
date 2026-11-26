"""Omarchy's fingerprint enrollment window. Only fprintd handles fingerprint data."""
import json
import os
import subprocess
from pathlib import Path

import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gio, GLib, Gtk
from diagram import Diagram
from reader import DEVICE, FINGERS, MANAGER, SERVICE, Reader

PAM = Path("/etc/pam.d/omarchy-lock-fingerprint")
DISABLED = Path.home() / ".local/state/omarchy/toggles/lock-fingerprint-off"
OMARCHY = Path(os.environ["OMARCHY_PATH"])


def read_language():
  config = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
  try:
    code = (config / "omarchy/language").read_text().strip()
    if code and all(part.isalpha() for part in code.split("-")):
      return json.loads((OMARCHY / "default/i18n" / code / "cli.json").read_text())
  except (OSError, ValueError):
    pass
  return {}


translations = read_language()


def tr(key, fallback):
  return translations.get(key, fallback)


LABELS = {
  "right-index-finger": tr("fingerprintApp.rightIndex", "Right index finger"),
  "right-thumb": tr("fingerprintApp.rightThumb", "Right thumb"),
  "right-middle-finger": tr("fingerprintApp.rightMiddle", "Right middle finger"),
  "right-ring-finger": tr("fingerprintApp.rightRing", "Right ring finger"),
  "right-little-finger": tr("fingerprintApp.rightLittle", "Right little finger"),
  "left-index-finger": tr("fingerprintApp.leftIndex", "Left index finger"),
  "left-thumb": tr("fingerprintApp.leftThumb", "Left thumb"),
  "left-middle-finger": tr("fingerprintApp.leftMiddle", "Left middle finger"),
  "left-ring-finger": tr("fingerprintApp.leftRing", "Left ring finger"),
  "left-little-finger": tr("fingerprintApp.leftLittle", "Left little finger"),
}


def label(text, style=None):
  item = Gtk.Label(label=text, wrap=True, xalign=0)
  if style:
    item.add_css_class(style)
  return item


def button(text, action, style=None):
  item = Gtk.Button(label=text)
  item.connect("clicked", lambda *_: action())
  if style:
    item.add_css_class(style)
  return item


def available_before_consent():
  # The platform file also drives omarchy-hw-fingerprint. A platform may
  # advertise a reader as available before the owner has enabled it.
  from glob import glob
  contract = Path("/usr/share/omarchy-platform/fingerprint-readers")
  if contract.is_file():
    for line in contract.read_text().splitlines():
      parts = line.split()
      if len(parts) == 2 and parts[0].startswith("/") and parts[1] == "available":
        for path in glob(parts[0]):
          try:
            if Path(path).read_text().strip() == "available":
              return True
          except OSError:
            continue
  return False


class Window(Gtk.ApplicationWindow):
  def __init__(self, app):
    super().__init__(application=app, title=tr("fingerprintApp.appTitle", "Fingerprint Setup"))
    self.set_default_size(500, 565)
    self.set_icon_name("auth-fingerprint-symbolic")
    self.reader = None
    self.generation = 0
    self.bus = None
    self.selected = ""
    self.lift_timer = 0
    self.scroller = Gtk.ScrolledWindow(hscrollbar_policy=Gtk.PolicyType.NEVER)
    self.set_child(self.scroller)
    self.connect("close-request", self.close_scan)
    self.pam_watch = Gio.File.new_for_path(str(PAM.parent)).monitor_directory(Gio.FileMonitorFlags.NONE, None)
    self.pam_watch.connect("changed", self.pam_changed)
    self.refresh()

  def pam_changed(self, monitor, file, other, event):
    if not self.reader and any(f and f.get_basename() == PAM.name for f in (file, other)):
      self.refresh()

  def close_scan(self, *_):
    self.generation += 1
    if self.lift_timer:
      GLib.source_remove(self.lift_timer)
      self.lift_timer = 0
    if self.reader:
      self.reader.cancel()
      self.reader = None
    return False

  def page(self, title, description, icon=True):
    self.box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, halign=Gtk.Align.CENTER, valign=Gtk.Align.CENTER)
    self.box.set_size_request(360, -1)
    for edge in ("top", "bottom", "start", "end"):
      getattr(self.box, "set_margin_" + edge)(28)
    self.scroller.set_child(self.box)
    image = Gtk.Image.new_from_icon_name("auth-fingerprint-symbolic")
    image.set_pixel_size(54)
    image.set_halign(Gtk.Align.START)
    if icon:
      self.box.append(image)
    self.box.append(label(title, "title-1"))
    self.box.append(label(description, "dim-label"))

  def refresh(self, notice=""):
    self.close_scan()
    generation = self.generation
    self.page(tr("fingerprintApp.appTitle", "Fingerprint Setup"), tr("fingerprintApp.reading", "Reading your fingerprint reader…"))
    if available_before_consent():
      self.unavailable(tr("fingerprintApp.consent", "This Mac needs your permission to enable Touch ID."))
      return
    try:
      self.address = Gio.dbus_address_get_for_bus_sync(Gio.BusType.SYSTEM, None)
      self.bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
    except GLib.Error as error:
      self.unavailable(error.message)
      return
    def load():
      # Discovery is read-only. Do it off the UI thread: starting fprintd or
      # waking a USB reader can take several seconds.
      try:
        devices = self.query(MANAGER, SERVICE + ".Manager", "GetDevices")[0]
        readers = []
        for path in devices:
          props = self.query(path, "org.freedesktop.DBus.Properties", "GetAll",
                             GLib.Variant("(s)", (DEVICE,)))[0]
          readers.append((path, props))
        if not readers:
          GLib.idle_add(deliver, [], [], None)
          return
        path = next((p for p, _ in readers if p == self.selected), readers[0][0])
        fingers = self.list_fingers(path)
        # PAM is shared, but enrollment and the unlock preference belong
        # to this account. Keep existing unlocks on other attached readers.
        configured = PAM.exists() and (bool(fingers) or any(
          self.list_fingers(other) for other, _ in readers if other != path))
        # Running shells can predate the per-account opt-out after an update.
        # Only offer it when the lock that will handle the scan supports it.
        try:
          probe = subprocess.run(["omarchy-shell", "lock", "status"], capture_output=True, timeout=2)
          preferences = json.loads(probe.stdout).get("fingerprintPreferenceSupported", False)
        except (OSError, ValueError, subprocess.TimeoutExpired):
          preferences = False
        GLib.idle_add(deliver, readers, fingers, path, preferences, configured)
      except GLib.Error as error:
        GLib.idle_add(failed, error.message)
    def failed(message):
      if generation == self.generation:
        self.unavailable(message)
      return False
    def deliver(readers, fingers, path, preferences=False, configured=False):
      if generation != self.generation:
        return False
      if readers:
        self.selected = path
        self.already_configured = configured
        self.home(readers, fingers, notice, preferences)
      else:
        self.unavailable(notice or tr("fingerprintApp.openLid", "Open the laptop lid or connect a fingerprint reader, then try again."))
      return False
    from threading import Thread
    Thread(target=load, daemon=True).start()

  def list_fingers(self, path):
    try:
      return self.query(path, DEVICE, "ListEnrolledFingers", GLib.Variant("(s)", ("",)))[0]
    except GLib.Error as error:
      if Gio.DBusError.get_remote_error(error) == SERVICE + ".Error.NoEnrolledPrints":
        return []
      raise

  def query(self, path, interface, method, args=None):
    return self.bus.call_sync(SERVICE, path, interface, method, args, None,
                              Gio.DBusCallFlags.NONE, 15000, None).unpack()

  def terminal(self, command):
    # Package installation and the platform's consent hook use a real terminal.
    # Enrollment stays in this window and belongs to the desktop account.
    try:
      proc = Gio.Subprocess.new(["xdg-terminal-exec", "--title=Fingerprint Setup", "-e", *command],
                                Gio.SubprocessFlags.NONE)
      proc.wait_async(None, lambda *_: self.refresh())
    except GLib.Error as error:
      self.unavailable(error.message)

  def unavailable(self, message):
    self.page(tr("fingerprintApp.setupReader", "Set up your reader"), message)
    self.box.append(button(tr("fingerprintApp.retry", "Check again"), self.refresh, "suggested-action"))
    self.box.append(button(tr("fingerprintApp.prepare", "Prepare fingerprint reader…"), lambda: self.terminal(
      ["/bin/bash", str(Path(__file__).with_name("prepare-reader"))])))
    self.box.append(button(tr("fingerprintApp.close", "Close"), self.close))

  def home(self, readers, fingers, notice, preferences):
    props = dict(readers)[self.selected]
    self.swipe = props.get("scan-type") == "swipe"
    self.page(tr("fingerprintApp.touchId", "Touch ID") if "apple" in props["name"].lower() else tr("fingerprintApp.fingerprints", "Fingerprints"), props["name"])
    if len(readers) > 1:
      picker = Gtk.DropDown.new_from_strings([p["name"] for _, p in readers])
      picker.set_selected([path for path, _ in readers].index(self.selected))
      def choose_reader(widget, _prop):
        self.selected = readers[widget.get_selected()][0]
        self.refresh()
      picker.connect("notify::selected", choose_reader)
      self.box.append(picker)
    if notice:
      self.box.append(label(notice, "accent"))
    self.box.append(label(tr("fingerprintApp.saved", "Saved fingerprints"), "heading"))
    if fingers:
      for finger in fingers:
        row = Gtk.Box(spacing=12)
        row.append(Gtk.Image.new_from_icon_name("auth-fingerprint-symbolic"))
        name = label(LABELS.get(finger, finger))
        name.set_hexpand(True)
        row.append(name)
        row.append(button(tr("fingerprintApp.verify", "Verify"), lambda slot=finger: self.scan("Verify", slot)))
        self.box.append(row)
    else:
      self.box.append(label(tr("fingerprintApp.empty", "No fingerprints enrolled yet.")))
    available = [finger for finger in FINGERS if finger not in fingers]
    if available:
      self.box.append(label(tr("fingerprintApp.addFinger", "Add a finger"), "heading"))
      choice = Gtk.DropDown.new_from_strings([LABELS[f] for f in available])
      self.box.append(choice)
      self.box.append(button(tr("fingerprintApp.enrollSelected", "Enroll selected finger"), lambda: self.scan(
        "Enroll", available[choice.get_selected()]), "suggested-action"))
    if fingers:
      self.box.append(Gtk.Separator())
      self.box.append(label(tr("fingerprintApp.screenUnlock", "Screen unlock"), "heading"))
      enabled = PAM.exists() and (not preferences or not DISABLED.exists())
      self.box.append(label(tr("fingerprintApp.passwordFallback", "Fingerprint unlock is on. Your password also works.") if enabled else
                            tr("fingerprintApp.useSaved", "Use an enrolled finger to unlock your Omarchy session.")))
      if enabled and preferences:
        self.box.append(button(tr("fingerprintApp.turnOff", "Turn off fingerprint unlock"), self.disable))
      elif not enabled:
        self.box.append(button(tr("fingerprintApp.enableUnlock", "Enable fingerprint unlock…"), lambda: self.scan("Verify", "any", True)))
    self.box.append(button(tr("fingerprintApp.done", "Done"), self.close))

  def disable(self):
    try:
      DISABLED.parent.mkdir(parents=True, exist_ok=True)
      DISABLED.touch()
    except OSError as error:
      self.refresh(str(error))
      return
    self.refresh()

  def enable(self):
    try:
      DISABLED.unlink(missing_ok=True)
    except OSError as error:
      self.refresh(str(error))
      return
    if PAM.exists():
      self.refresh(tr("fingerprintApp.enabled", "Fingerprint unlock enabled."))
    else:
      self.page(tr("fingerprintApp.enableTitle", "Enable screen unlock"), tr("fingerprintApp.confirmAdmin", "Confirm the administrator prompt to configure the Omarchy lock screen."))
      self.terminal([str(OMARCHY / "bin/omarchy-apply-lock")])
      self.box.append(button(tr("fingerprintApp.refreshUnlock", "Check unlock settings"), self.refresh))

  def scan(self, mode, finger, unlock=False):
    # Enrollment alone does not opt a new account into desktop unlock, even
    # if another account already configured the machine-wide PAM service.
    if mode == "Enroll" and not self.already_configured:
      try:
        DISABLED.parent.mkdir(parents=True, exist_ok=True)
        DISABLED.touch()
      except OSError as error:
        self.refresh(str(error))
        return
    self.close_scan()
    generation = self.generation
    self.page(tr("fingerprintApp.enrollTitle", "Add a fingerprint") if mode == "Enroll" else tr("fingerprintApp.verifyTitle", "Verify fingerprint"),
              LABELS.get(finger, tr("fingerprintApp.useAny", "Use any saved finger")), icon=False)
    diagram = Diagram()
    self.box.append(diagram)
    touch = tr("fingerprintApp.swipe", "Swipe your finger across the reader.") if self.swipe else tr("fingerprintApp.touch", "Touch the sensor.")
    hint = label(touch, "title-2")
    self.box.append(hint)
    self.box.append(button(tr("fingerprintApp.cancel", "Cancel"), self.refresh))
    def clear_timer():
      if self.lift_timer:
        GLib.source_remove(self.lift_timer)
        self.lift_timer = 0
    def next_touch():
      self.lift_timer = 0
      if generation == self.generation:
        hint.set_text(tr("fingerprintApp.touchAgain", "Touch again after lifting.") if not self.swipe else touch)
      return False
    def update(result, detail, finished):
      if generation != self.generation:
        return
      clear_timer()
      if finished:
        self.reader = None
        if result == "enroll-completed":
          diagram.complete = True
          diagram.queue_draw()
          hint.set_text(tr("fingerprintApp.added", "Fingerprint added"))
          self.box.get_last_child().set_visible(False)
          self.box.append(button(tr("fingerprintApp.continue", "Continue"), self.refresh, "suggested-action"))
        elif result == "verify-match":
          if unlock:
            self.enable()
          else:
            self.refresh(tr("fingerprintApp.matched", "Fingerprint matched."))
        else:
          self.refresh(detail or self.explain(result))
      elif result == "finger-down":
        diagram.present = True
        diagram.queue_draw()
        hint.set_text(touch if self.swipe else tr("fingerprintApp.hold", "Hold your finger on the sensor."))
      elif result in ("finger-up", "finger-needed"):
        diagram.present = False
        diagram.queue_draw()
        hint.set_text(touch)
      elif result == "enroll-stage-passed":
        diagram.samples += 1
        diagram.queue_draw()
        hint.set_text(tr("fingerprintApp.lift", "Lift your finger.") if not self.swipe else tr("fingerprintApp.swipeAgain", "Swipe again."))
        # Some readers only emit stage results. Give a two-part instruction
        # without claiming that the finger was physically removed.
        if not self.swipe:
          self.lift_timer = GLib.timeout_add(1100, next_touch)
      else:
        hint.set_text(self.explain(result))
    try:
      self.reader = Reader(self.address, self.selected, update)
      self.reader.start(mode, finger)
    except GLib.Error as error:
      self.refresh(error.message)

  @staticmethod
  def explain(result):
    for suffix, message in {
      "too-fast": tr("fingerprintApp.tooFast", "Move more slowly and try again."),
      "not-centered": tr("fingerprintApp.center", "Center your finger on the reader and try again."),
      "swipe-too-short": tr("fingerprintApp.swipeLonger", "Swipe the whole fingertip across the reader."),
      "remove-and-retry": tr("fingerprintApp.removeAndRetry", "Lift your finger fully, then try again."),
      "retry-scan": tr("fingerprintApp.moveFingertip", "Try again, moving your fingertip slightly."),
      "duplicate": tr("fingerprintApp.duplicate", "That finger is already enrolled."),
      "no-match": tr("fingerprintApp.noMatch", "That finger did not match. Unlock settings were left as they were."),
      "data-full": tr("fingerprintApp.storageFull", "The reader has no room for another fingerprint."),
      "disconnected": tr("fingerprintApp.disconnected", "The reader disconnected. Reconnect it and try again."),
      "failed": tr("fingerprintApp.stopped", "The scan stopped. Try again when the reader is ready.")
    }.items():
      if result.endswith(suffix):
        return message
    return tr("fingerprintApp.reported", "Reader reported %1.").replace("%1", result)


def activate(app):
  window = app.get_active_window() or Window(app)
  window.present()


if __name__ == "__main__":
  app = Gtk.Application(application_id="org.omarchy.FingerprintSetup")
  app.connect("activate", activate)
  raise SystemExit(app.run())
