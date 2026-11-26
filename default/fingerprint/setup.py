"""Omarchy's fingerprint enrollment window. Only fprintd handles fingerprint data."""
import json
import os
import sqlite3
import subprocess
from pathlib import Path

import gi
gi.require_version("Gtk", "4.0")
gi.require_version("Gdk", "4.0")
from gi.repository import Gdk, Gio, GLib, Gtk, Pango
from diagram import Diagram
from names import Names
from reader import APPLE_READER, DEVICE, FINGERS, MANAGER, SERVICE, Reader, ScanGuide, enrollment_capacity

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


def numbered(number):
  return tr("fingerprintApp.numbered", "Finger %1").replace("%1", str(number))


def icon_button(icon, title, action):
  item = Gtk.Button(icon_name=icon, tooltip_text=title)
  item.update_property([Gtk.AccessibleProperty.LABEL], [title])
  item.add_css_class("flat")
  item.connect("clicked", lambda *_: action())
  return item


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
    self.set_default_size(480, 560)
    self.add_css_class("fingerprint-setup")
    self.set_icon_name("auth-fingerprint-symbolic")
    self.reader = None
    self.generation = 0
    self.bus = None
    self.selected = ""
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
    if self.reader:
      self.reader.cancel()
      self.reader = None
    return False

  def page(self, title, description="", guide=False):
    self.box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14, valign=Gtk.Align.CENTER)
    for edge in ("top", "bottom", "start", "end"):
      getattr(self.box, "set_margin_" + edge)(28)
    self.scroller.set_child(self.box)
    header = Gtk.Box(spacing=14, halign=Gtk.Align.CENTER if guide else Gtk.Align.FILL)
    self.box.append(header)
    if not guide:
      glyph = Diagram(compact=True)
      header.append(glyph)
    titles = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3, hexpand=not guide)
    header.append(titles)
    for text, style in ((title, "title-1"), (description, "dim-label")):
      if text:
        line = label(text, style)
        if guide:
          line.set_xalign(.5)
        titles.append(line)

  def close_button(self):
    close = button(tr("fingerprintApp.done", "Done"), self.close, "flat")
    close.set_halign(Gtk.Align.END)
    self.box.append(close)

  def refresh(self, notice=""):
    self.close_scan()
    generation = self.generation
    self.page(tr("fingerprintApp.appTitle", "Fingerprint Setup"), tr("fingerprintApp.reading", "Reading your fingerprint reader…"))
    self.needs_consent = available_before_consent()
    consent = tr("fingerprintApp.consent", "This Mac needs your permission to enable Touch ID.")
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
          if not (self.needs_consent and props["name"] == APPLE_READER):
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
        self.unavailable(consent if self.needs_consent else message)
      return False
    def deliver(readers, fingers, path, preferences=False, configured=False):
      if generation != self.generation:
        return False
      if readers:
        self.selected = path
        self.already_configured = configured
        self.home(readers, fingers, notice, preferences)
      else:
        message = consent if self.needs_consent else tr("fingerprintApp.openLid", "Open the laptop lid or connect a fingerprint reader, then try again.")
        self.unavailable(notice or message)
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
    self.box.append(self.prepare_button())
    self.close_button()

  def prepare_button(self):
    return button(tr("fingerprintApp.prepare", "Prepare fingerprint reader…"), lambda: self.terminal(
      ["/bin/bash", str(Path(__file__).with_name("prepare-reader"))]))

  def group(self, title):
    heading = label(title, "heading")
    heading.set_margin_top(12)
    self.box.append(heading)
    rows = Gtk.ListBox(selection_mode=Gtk.SelectionMode.NONE)
    rows.add_css_class("boxed-list")
    self.box.append(rows)
    return rows

  def home(self, readers, fingers, notice, preferences):
    props = dict(readers)[self.selected]
    name = props["name"]
    apple = name == APPLE_READER
    self.capacity = enrollment_capacity(name)
    self.swipe = props.get("scan-type") == "swipe"
    self.page(tr("fingerprintApp.touchId", "Touch ID") if apple else tr("fingerprintApp.fingerprints", "Fingerprints"),
              tr("fingerprintApp.builtIn", "Built-in fingerprint reader") if apple else name)
    if len(readers) > 1:
      picker = Gtk.DropDown.new_from_strings([p["name"] for _, p in readers])
      picker.set_selected([path for path, _ in readers].index(self.selected))
      def choose_reader(widget, _prop):
        self.selected = readers[widget.get_selected()][0]
        self.refresh()
      picker.connect("notify::selected", choose_reader)
      self.box.append(picker)
    # fprintd identifies the model by name. Only disambiguate with the device
    # path if two attached readers actually present the same name.
    key = name if sum(p["name"] == name for _, p in readers) == 1 else name + "|" + self.selected
    self.names = Names(key)
    try:
      self.prints = self.names.sync(fingers)
    except (sqlite3.Error, OSError) as error:
      self.prints = {slot: (i, None) for i, slot in enumerate(sorted(fingers), 1)}
      notice = str(error)
    if notice:
      self.box.append(label(notice))
    rows = self.group(tr("fingerprintApp.saved", "Saved fingerprints"))
    for slot, (number, custom) in sorted(self.prints.items(), key=lambda pair: pair[1][0]):
      row = Gtk.Box(spacing=8)
      row.add_css_class("fingerprint-row")
      glyph = Gtk.Image.new_from_icon_name("auth-fingerprint-symbolic")
      glyph.set_pixel_size(22)
      row.append(glyph)
      display_name = custom or numbered(number)
      title = label(display_name)
      title.set_wrap(False)
      title.set_ellipsize(Pango.EllipsizeMode.END)
      title.set_hexpand(True)
      row.append(title)
      row.append(icon_button("document-edit-symbolic", tr("fingerprintApp.editNamed", "Edit %1").replace("%1", display_name),
                             lambda slot=slot: self.edit(slot)))
      verify = button(tr("fingerprintApp.verify", "Verify"), lambda slot=slot: self.scan("Verify", slot), "flat")
      verify.update_property([Gtk.AccessibleProperty.LABEL], [tr("fingerprintApp.verifyNamed", "Verify %1").replace("%1", display_name)])
      row.append(verify)
      rows.append(row)
    slot = next((slot for slot in FINGERS if slot not in self.prints), None)
    if slot and len(set(fingers)) < self.capacity:
      add = button(tr("fingerprintApp.add", "Add fingerprint"), lambda: self.scan("Enroll", slot), "suggested-action")
      add.set_halign(Gtk.Align.START)
      if not fingers:
        empty = label(tr("fingerprintApp.empty", "No fingerprints enrolled yet."))
        empty.add_css_class("fingerprint-row")
        rows.append(empty)
      self.box.append(add)
    else:
      full = tr("fingerprintApp.full", "All %1 fingerprint slots are in use.").replace("%1", str(self.capacity))
      self.box.append(label(full, "heading"))
      self.box.append(label(tr("fingerprintApp.replace", "To replace a fingerprint, select its pencil and choose Remove fingerprint.")))
    if fingers:
      security = self.group(tr("fingerprintApp.screenUnlock", "Screen unlock"))
      row = Gtk.Box(spacing=12)
      row.add_css_class("fingerprint-row")
      labels = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3, hexpand=True)
      labels.append(label(tr("fingerprintApp.useUnlock", "Unlock with a fingerprint")))
      labels.append(label(tr("fingerprintApp.password", "You can also use your password."), "dim-label"))
      row.append(labels)
      enabled = PAM.exists() and (not preferences or not DISABLED.exists())
      if preferences or not enabled:
        switch = Gtk.Switch(active=enabled, valign=Gtk.Align.CENTER)
        switch.update_property([Gtk.AccessibleProperty.LABEL], [tr("fingerprintApp.useUnlock", "Unlock with a fingerprint")])
        def toggle(widget, state):
          if state:
            self.scan("Verify", "any", True)
          else:
            self.disable()
          return True
        switch.connect("state-set", toggle)
        row.append(switch)
      else:
        row.append(label(tr("fingerprintApp.on", "On")))
      security.append(row)
    if self.needs_consent:
      self.box.append(self.prepare_button())
    self.close_button()

  def name_editor(self, slot, number, custom, enrolled=False):
    title = tr("fingerprintApp.name", "Fingerprint name")
    entry = Gtk.Entry(text=custom or numbered(number), max_length=64, activates_default=False)
    entry.update_property([Gtk.AccessibleProperty.LABEL], [title])
    self.box.append(label(title, "heading"))
    self.box.append(entry)
    def save():
      text = entry.get_text().strip()
      try:
        self.names.rename(slot, None if text == numbered(number) else text)
      except (sqlite3.Error, OSError) as error:
        self.refresh(str(error))
        return
      self.refresh()
    entry.connect("activate", lambda *_: save())
    actions = Gtk.Box(spacing=8, halign=Gtk.Align.END)
    if not enrolled:
      actions.append(button(tr("fingerprintApp.cancel", "Cancel"), self.refresh, "flat"))
    confirm = tr("fingerprintApp.done", "Done") if enrolled else tr("fingerprintApp.save", "Save")
    actions.append(button(confirm, save, "suggested-action"))
    self.box.append(actions)
    return entry

  def edit(self, slot):
    self.close_scan()
    self.page(tr("fingerprintApp.edit", "Edit fingerprint"))
    entry = self.name_editor(slot, *self.prints[slot])
    remove = button(tr("fingerprintApp.remove", "Remove fingerprint…"), lambda: self.confirm_remove(slot), "flat")
    remove.set_halign(Gtk.Align.START)
    self.box.append(remove)
    entry.grab_focus()
    entry.select_region(0, -1)

  def confirm_remove(self, slot):
    number, custom = self.prints[slot]
    title = tr("fingerprintApp.confirmRemove", "Remove %1?").replace("%1", custom or numbered(number))
    self.page(title, tr("fingerprintApp.removeBody", "This fingerprint will be removed from the reader. You can enroll it again later."))
    actions = Gtk.Box(spacing=8, halign=Gtk.Align.END)
    cancel = button(tr("fingerprintApp.cancel", "Cancel"), self.refresh)
    actions.append(cancel)
    actions.append(button(tr("fingerprintApp.removeConfirm", "Remove fingerprint"), lambda: self.remove(slot), "destructive-action"))
    self.box.append(actions)
    cancel.grab_focus()

  def remove(self, slot):
    self.close_scan()
    generation = self.generation
    self.page(tr("fingerprintApp.removing", "Removing fingerprint…"))
    def done(result, detail, finished):
      if generation != self.generation or not finished:
        return
      self.reader = None
      if result == "removed":
        self.refresh(tr("fingerprintApp.removed", "Fingerprint removed."))
      else:
        self.show_failure(tr("fingerprintApp.removeFailed", "Couldn’t remove the fingerprint"), detail or self.explain(result))
    try:
      self.reader = Reader(self.address, self.selected, done)
      self.reader.start("Delete", slot)
    except GLib.Error as error:
      self.close_scan()
      self.show_failure(tr("fingerprintApp.removeFailed", "Couldn’t remove the fingerprint"), error.message)

  def show_failure(self, title, message, retry=None):
    self.page(title, message)
    if retry:
      again = button(tr("fingerprintApp.retryVerify", "Try verification again"), retry, "suggested-action")
      again.set_halign(Gtk.Align.START)
      self.box.append(again)
    back = button(tr("fingerprintApp.backToSaved", "Back to fingerprints"), self.refresh)
    back.set_halign(Gtk.Align.START)
    self.box.append(back)
    back.grab_focus()

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
    used = {number for number, _ in self.prints.values()}
    number = next(n for n in range(1, len(used) + 2) if n not in used)
    number, custom = self.prints.get(finger, (number, None))
    self.page(tr("fingerprintApp.enrollTitle", "Add a fingerprint") if mode == "Enroll" else tr("fingerprintApp.verifyTitle", "Verify fingerprint"),
              tr("fingerprintApp.useAny", "Use any saved finger") if finger == "any" else custom or numbered(number), guide=True)
    diagram = Diagram()
    self.box.append(diagram)
    touch = tr("fingerprintApp.swipe", "Swipe your finger across the reader.") if self.swipe else tr("fingerprintApp.touch", "Touch the sensor.")
    hint = Gtk.Label(label=touch, wrap=True, justify=Gtk.Justification.CENTER, accessible_role=Gtk.AccessibleRole.STATUS)
    hint.add_css_class("title-2")
    self.box.append(hint)
    count = Gtk.Label(label=tr("fingerprintApp.angle", "Vary the angle slightly with each touch.") if mode == "Enroll" and not self.swipe else "")
    count.add_css_class("dim-label")
    self.box.append(count)
    cancel = button(tr("fingerprintApp.cancel", "Cancel"), self.refresh, "flat")
    cancel.set_halign(Gtk.Align.CENTER)
    self.box.append(cancel)
    failure_title = tr("fingerprintApp.notAdded", "Fingerprint wasn’t added") if mode == "Enroll" else tr("fingerprintApp.notVerified", "Couldn’t verify the fingerprint")
    retry = (lambda: self.scan(mode, finger, unlock)) if mode == "Verify" else None
    guide = ScanGuide()
    def update(result, detail, finished):
      if generation != self.generation:
        return
      if finished:
        self.reader = None
        if result in ("enroll-completed", "verify-match"):
          diagram.complete = True
          diagram.queue_draw()
          count.set_visible(False)
          cancel.set_visible(False)
        if result == "enroll-completed":
          hint.set_text(tr("fingerprintApp.added", "Fingerprint added"))
          try:
            self.prints = self.names.sync([finger], prune=False)
          except (sqlite3.Error, OSError) as error:
            self.refresh(str(error))
            return
          self.name_editor(finger, *self.prints[finger], enrolled=True)
        elif result == "verify-match":
          if unlock:
            self.enable()
          else:
            hint.set_text(tr("fingerprintApp.matched", "Fingerprint matched."))
            back = button(tr("fingerprintApp.backToSaved", "Back to fingerprints"), self.refresh, "suggested-action")
            back.set_halign(Gtk.Align.CENTER)
            self.box.append(back)
            back.grab_focus()
        else:
          self.show_failure(failure_title, detail or self.explain(result), retry)
      else:
        last_prompt = guide.prompt
        prompt = guide.update(result)
        if prompt == last_prompt and result != "enroll-stage-passed":
          return
        diagram.samples, diagram.present = guide.samples, guide.present
        diagram.queue_draw()
        if prompt == "retouch":
          hint.set_text(tr("fingerprintApp.retouch", "Lift, then touch again.") if not self.swipe else tr("fingerprintApp.swipeAgain", "Swipe again."))
          count.set_text(tr("fingerprintApp.scans", "Scans accepted: %1").replace("%1", str(guide.samples)))
          count.announce(f"{count.get_text()}. {hint.get_text()}", Gtk.AccessibleAnnouncementPriority.MEDIUM)
        elif prompt == "touch" or (prompt == "hold" and self.swipe):
          hint.set_text(touch)
        elif prompt == "hold":
          hint.set_text(tr("fingerprintApp.hold", "Hold your finger on the sensor."))
        else:
          hint.set_text(self.explain(prompt))
    try:
      self.reader = Reader(self.address, self.selected, update)
      self.reader.start(mode, finger, self.capacity)
    except GLib.Error as error:
      self.close_scan()
      self.show_failure(failure_title, error.message, retry)

  @staticmethod
  def explain(result):
    for suffix, message in {
      "unknown-error": tr("fingerprintApp.readerError", "The reader couldn’t finish this scan. Lift your finger before trying again."),
      "too-fast": tr("fingerprintApp.tooFast", "Move more slowly and try again."),
      "not-centered": tr("fingerprintApp.center", "Center your finger on the reader and try again."),
      "swipe-too-short": tr("fingerprintApp.swipeLonger", "Swipe the whole fingertip across the reader."),
      "remove-and-retry": tr("fingerprintApp.removeAndRetry", "Lift your finger fully, then try again."),
      "retry-scan": tr("fingerprintApp.moveFingertip", "Try again, moving your fingertip slightly."),
      "duplicate": tr("fingerprintApp.duplicate", "That finger is already enrolled."),
      "no-match": tr("fingerprintApp.noMatch", "That finger did not match. Unlock settings were left as they were."),
      "data-full": tr("fingerprintApp.storageFull", "The reader is full. Remove a saved fingerprint to make room."),
      "disconnected": tr("fingerprintApp.disconnected", "The reader disconnected. Reconnect it and try again."),
      "failed": tr("fingerprintApp.stopped", "The scan stopped. Try again when the reader is ready.")
    }.items():
      if result.endswith(suffix):
        return message
    return tr("fingerprintApp.reported", "Reader reported %1.").replace("%1", result)


def activate(app):
  if not app.get_active_window():
    css = Gtk.CssProvider()
    css.load_from_data(b"""
      .fingerprint-setup .dim-label { opacity: .80; }
      .fingerprint-row { padding: 10px 12px; }
      list.boxed-list { border-radius: 12px; background-color: alpha(@theme_fg_color, .055); }
      list.boxed-list > row { border-bottom: 1px solid alpha(@theme_fg_color, .09); }
      list.boxed-list > row:last-child { border-bottom: 0; }
    """)
    Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
  window = app.get_active_window() or Window(app)
  window.present()


if __name__ == "__main__":
  app = Gtk.Application(application_id="org.omarchy.FingerprintSetup")
  app.connect("activate", activate)
  raise SystemExit(app.run())
