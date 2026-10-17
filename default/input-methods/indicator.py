"""Shared input selection and feedback for the shell."""

from collections import Counter
from functools import lru_cache
import json
import os
import re
import subprocess
import sys
from xml.etree import ElementTree

from gi.repository import Gio, GLib


BUS = "org.fcitx.Fcitx5"
INTERFACE = "org.fcitx.Fcitx.Controller1"


def call(bus, method, args=None):
  # Reading the bar must neither activate a stopped service nor wait indefinitely.
  return bus.call_sync(BUS, "/controller", INTERFACE, method, args, None,
                       Gio.DBusCallFlags.NO_AUTO_START, 1000, None).unpack()


def snapshot(bus):
  group = call(bus, "CurrentInputMethodGroup")[0]
  methods = list(dict.fromkeys(item[0] for item in
                              call(bus, "InputMethodGroupInfo", GLib.Variant("(s)", (group,)))[1]))
  info = call(bus, "CurrentInputMethodInfo")
  return {"methods": methods, "current": info[0], "name": info[1], "label": info[4], "language": info[5]}


def layout_keyboard(keyboards):
  typed = [keyboard for keyboard in keyboards if not re.match(
    r"^(hl-virtual-keyboard|power-button|sleep-button|lid-switch|video-bus)", keyboard.get("name", ""))]
  typed = [item for item in typed if len(item.get("layout", "").split(",")) > 1]
  if not typed:
    return None
  # Consumer controls also carry the seat layout. Its frequency keeps an
  # individually configured keyboard from taking over the desktop shortcut.
  counts = Counter(item.get("layout", "") for item in keyboards)
  layout = max((item["layout"] for item in typed), key=lambda layout: counts[layout])
  keyboard = max((item for item in typed if item["layout"] == layout),
                 key=lambda item: item.get("active_layout_index", 0))
  return keyboard


def layout_switches(keyboards, index=None, step=1):
  keyboard = layout_keyboard(keyboards)
  if keyboard is None:
    return []
  layout = keyboard["layout"]
  following = index if index is not None else (keyboard.get("active_layout_index", 0) + step) % len(layout.split(","))
  return [["hyprctl", "switchxkblayout", item["name"], str(following)]
          for item in keyboards if item.get("layout") == layout and item.get("name")]


def cycle_choice(state, keyboards, step=1):
  methods = state.get("methods", [])
  keyboard = layout_keyboard(keyboards)
  primary = next((method for method in methods if method.startswith("keyboard-")), None)
  if keyboard is None or primary is None:
    current = state.get("current")
    if len(methods) > 1 and current in methods:
      return methods[(methods.index(current) + step) % len(methods)], None
    return None, None
  # One direct-input method represents all compositor layouts. Composition
  # engines follow them in the user's configured order.
  choices = []
  for method in methods:
    if method == primary:
      choices.extend((method, index) for index in range(len(keyboard["layout"].split(","))))
    else:
      choices.append((method, None))
  current = state.get("current") or primary
  position = (current, keyboard.get("active_layout_index", 0) if current == primary else None)
  if position not in choices:
    return None, None
  return choices[(choices.index(position) + step) % len(choices)]


@lru_cache(maxsize=1)
def layout_languages():
  result = {}
  for name in ("evdev.xml", "evdev.extras.xml"):
    path = "/usr/share/X11/xkb/rules/" + name
    try:
      layouts = ElementTree.parse(path).findall("./layoutList/layout")
    except FileNotFoundError:
      continue
    except (OSError, ElementTree.ParseError) as error:
      print(f"Input feedback: {error}", file=sys.stderr)
      continue
    for layout in layouts:
      item = layout.find("configItem")
      language = item.findtext("languageList/iso639Id", "")
      result[(item.findtext("name"), "")] = (language, item.findtext("description", ""))
      for variant in layout.findall("./variantList/variant/configItem"):
        result[(item.findtext("name"), variant.findtext("name"))] = (
          variant.findtext("languageList/iso639Id", language), variant.findtext("description", ""))
  return result


def keyboard_language(keyboard):
  index = keyboard.get("active_layout_index", 0)
  layouts = keyboard.get("layout", "").split(",")
  variants = keyboard.get("variant", "").split(",")
  layout = layouts[index]
  variant = variants[index] if index < len(variants) else ""
  language, name = layout_languages().get((layout, variant), ("", layout))
  return {"key": layout + ":" + variant, "language": language, "name": name}


class InputFeedback:
  """Presentation metadata only; failures here must never alter input selection."""

  def __init__(self, indicator):
    self.indicator = indicator
    self.message = {"session": f"{os.getpid()}:{GLib.get_monotonic_time()}", "serial": 0}

  def observe(self, state):
    try:
      # A queued or refused selection is not an activation acknowledgement.
      if self.indicator.pending:
        return self.message
      current = state.get("current", "")
      primary = next((method for method in state.get("methods", []) if method.startswith("keyboard-")), "")
      keyboard = layout_keyboard(self.indicator.keyboards)
      if keyboard is None:
        keyboard = next((item for item in self.indicator.keyboards if item.get("main")), None)
      if keyboard and (not current or current == primary):
        selection = keyboard_language(keyboard)
      elif current:
        selection = {"key": current, "language": state.get("language", ""), "name": state.get("name", "")}
      else:
        return self.message
      if selection["key"] != self.message.get("key"):
        serial = self.message["serial"] + ("key" in self.message)
        self.message = {"session": self.message["session"], "serial": serial, **selection}
    except Exception as error:
      # Cosmetic metadata is deliberately outside the input error handler.
      print(f"Input feedback: {error}", file=sys.stderr)
    return self.message


class Indicator:
  def __init__(self, bus):
    self.bus = bus
    self.pending = ""
    self.last = ""
    self.entries = {}
    self.keyboards = []

  def remember_layout(self, index):
    keyboard = layout_keyboard(self.keyboards)
    if keyboard:
      for item in self.keyboards:
        if item.get("layout") == keyboard["layout"]:
          item["active_layout_index"] = index

  def refresh_layouts(self, event=None):
    try:
      if event is not None:
        name, _, description = event.partition(",")
        device = next((item for item in self.keyboards if item.get("name") == name), None)
        # Native cycling already knows the layout it just applied.
        if device and description == keyboard_language(device)["name"]:
          return False
      devices = subprocess.run(["hyprctl", "-j", "devices"], check=True, text=True, capture_output=True, timeout=1)
      self.keyboards = json.loads(devices.stdout).get("keyboards", [])
      return True
    except Exception as error:
      # Layout metadata is cosmetic; never clear a queued selection here.
      print(f"Input feedback: {error}", file=sys.stderr)
      return False

  def select_next(self, step=1):
    devices = subprocess.run(["hyprctl", "-j", "devices"], check=True, text=True, capture_output=True)
    keyboards = json.loads(devices.stdout).get("keyboards", [])
    self.keyboards = keyboards
    try:
      state = snapshot(self.bus)
    except GLib.Error:
      # Without Fcitx, Super+I still cycles the compositor layouts.
      for command in layout_switches(keyboards, step=step):
        subprocess.run(command, check=True, capture_output=True)
      keyboard = layout_keyboard(keyboards)
      if keyboard:
        self.remember_layout((keyboard.get("active_layout_index", 0) + step) % len(keyboard["layout"].split(",")))
      return
    methods = state["methods"]
    current = self.pending or state["current"] or self.last
    state["current"] = current if current in methods else next(iter(methods), "")
    following, index = cycle_choice(state, keyboards, step)
    if following is None:
      return
    applied = None
    self.pending = following
    for command in layout_switches(keyboards, index) if index is not None else []:
      subprocess.run(command, check=True, capture_output=True)
      applied = index if index is not None else 0
    if applied is not None:
      self.remember_layout(applied)
    self.refresh()

  def refresh(self):
    state = snapshot(self.bus)
    methods = state["methods"]
    if self.pending not in methods:
      self.pending = ""
    if self.pending and state["current"]:
      # Before the first application gains focus Fcitx has no input context.
      # Retain the click until it has one, without changing startup defaults.
      call(self.bus, "SetCurrentIM", GLib.Variant("(s)", (self.pending,)))
      state = snapshot(self.bus)
      if state["current"] == self.pending:
        self.pending = ""
    if state["current"]:
      self.last = state["current"]
    else:
      chosen = self.pending or (self.last if self.last in methods else "") or next(iter(methods), "")
      if chosen not in self.entries:
        self.entries = {entry[0]: entry for entry in call(self.bus, "AvailableInputMethods")[0]}
      entry = self.entries.get(chosen)
      if entry:
        state.update(current=entry[0], name=entry[1], label=entry[4], language=entry[5])
    return state

  def switchable(self, methods):
    # With one keyboard method in one group the reading cannot change until the
    # configuration does, and Fcitx saves that to the profile being watched. A
    # lone composition engine still toggles, and steps aside in password fields.
    if len(methods) > 1 or not all(method.startswith("keyboard-") for method in methods):
      return True
    return len(call(self.bus, "InputMethodGroups")[0]) > 1


def owner_environment(bus):
  """The environment and working directory of the process that owns Fcitx's bus name.

  The profile is wherever that process saves it, which a service drop-in can
  move without the shell's own environment knowing.
  """
  try:
    pid = bus.call_sync("org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus",
                        "GetConnectionUnixProcessID", GLib.Variant("(s)", (BUS,)), None,
                        Gio.DBusCallFlags.NONE, 1000, None).unpack()[0]
    with open(f"/proc/{pid}/environ", "rb") as file:
      items = file.read().decode(errors="replace").split("\0")
    environment = dict(item.split("=", 1) for item in items if "=" in item)
    return environment, os.readlink(f"/proc/{pid}/cwd")
  except (GLib.Error, OSError, ValueError):
    return None


def profile_path(owner=None):
  # Fcitx's own lookup: FCITX_CONFIG_HOME, else $XDG_CONFIG_HOME/fcitx5, cleaned
  # lexically the way Fcitx cleans it before any link is followed. A relative
  # path is relative to the working directory.
  environment, cwd = owner or (os.environ, os.getcwd())
  home = environment.get("HOME") or os.path.expanduser("~")
  if environment.get("FCITX_CONFIG_HOME"):
    directory = os.path.join(cwd, environment["FCITX_CONFIG_HOME"])
  else:
    # A relative XDG_CONFIG_HOME is relative to the home directory.
    directory = os.path.join(home, environment.get("XDG_CONFIG_HOME") or ".config", "fcitx5")
  return os.path.join(os.path.normpath(directory), "profile")


class ProfileWatch:
  """Calls changed() whenever the profile Fcitx saves its configuration to changes.

  The file is located once per Fcitx process, from that process's environment.
  The watch follows renamed saves; inotify resolves a linked directory when the
  watch is added, so relinking the dotfiles while Fcitx runs is picked up at
  its next start.
  """

  def __init__(self, changed):
    self.changed = changed
    self.monitors = []
    self.bind(None)

  def bind(self, owner):
    for monitor in self.monitors:
      monitor.cancel()
    # A profile linked into dotfiles is saved by replacing the link's target.
    path = profile_path(owner)
    self.monitors = [Gio.File.new_for_path(watched).monitor_file(Gio.FileMonitorFlags.WATCH_MOVES, None)
                     for watched in dict.fromkeys([path, os.path.realpath(path)])]
    for monitor in self.monitors:
      monitor.connect("changed", lambda *_: self.changed())


def follow(bus, changed, presence):
  # Fcitx sends no signal when its configuration or current method changes
  # (Controller1's InputMethodGroupsChanged stays silent for group edits and
  # switches alike), so follow the service's bus name for restarts and the
  # profile it saves every configuration change to.
  profile = ProfileWatch(changed)

  def owner(present):
    presence(present)
    if present:
      profile.bind(owner_environment(bus))
    changed()
  name = Gio.bus_watch_name_on_connection(bus, BUS, Gio.BusNameWatcherFlags.NONE,
                                          lambda *_: owner(True), lambda *_: owner(False))
  return [name, profile]


def watch(bus):
  previous = None
  indicator = Indicator(bus)
  feedback = InputFeedback(indicator)
  loop = GLib.MainLoop()
  buffer = ""
  timer = 0
  settle = 0
  polling = False
  failed = False
  present = True

  def refresh():
    nonlocal previous, polling, failed
    try:
      state = indicator.refresh()
    except GLib.Error:
      failed = True
      indicator.pending = ""
      indicator.last = ""
      # Keep the configured cadence: a timed-out call is not a configuration
      # change, and a vanished service is followed by its bus name.
      state = {"methods": [], "current": "", "name": "", "language": ""}
    else:
      # A failed group count keeps the reading and the last cadence.
      try:
        polling = indicator.switchable(state["methods"])
        failed = False
      except GLib.Error:
        failed = True
    line = json.dumps({**state, "switch": feedback.observe(state)}, ensure_ascii=False)
    if line != previous:
      print(line, flush=True)
      previous = line

  # Only a pending click or a group with methods to switch between needs
  # reading again on a timer; everything else waits for an event. A failed
  # read of a running service is retried, since nothing else would correct it.
  def schedule():
    nonlocal timer
    if timer:
      GLib.source_remove(timer)
      timer = 0
    if indicator.pending:
      timer = GLib.timeout_add(50, poll)
    elif polling:
      timer = GLib.timeout_add(500, poll)
    elif failed and present:
      timer = GLib.timeout_add(2000, poll)

  def poll():
    nonlocal timer
    timer = 0
    refresh()
    schedule()
    return GLib.SOURCE_REMOVE

  # A save arrives as several file events, and a restarting service as a
  # vanish and an appear; read once they settle.
  def changed():
    nonlocal settle
    if settle:
      GLib.source_remove(settle)
    settle = GLib.timeout_add(200, settled)

  def settled():
    nonlocal settle
    settle = 0
    refresh()
    schedule()
    return GLib.SOURCE_REMOVE

  def presence(running):
    nonlocal present
    present = running

  def command(source, condition):
    nonlocal buffer
    data = os.read(sys.stdin.fileno(), 4096)
    if not data:
      loop.quit()
      return GLib.SOURCE_REMOVE
    buffer += data.decode(errors="replace")
    while "\n" in buffer:
      line, buffer = buffer.split("\n", 1)
      if line in ("cycle", "cycle back"):
        try:
          indicator.select_next(-1 if line == "cycle back" else 1)
        except (GLib.Error, OSError, ValueError, subprocess.CalledProcessError):
          indicator.pending = ""
        refresh()
      elif line == "layouts" or line.startswith("layout "):
        try:
          if indicator.refresh_layouts(json.loads(line[7:]) if line.startswith("layout ") else None):
            changed()
        except ValueError:
          pass
    schedule()
    return GLib.SOURCE_CONTINUE

  # Fcitx's controller has no current-method-changed signal, so a group with
  # more than one method is still read every 500 ms, over one kept-open bus
  # connection. That follows per-application input contexts and trigger keys
  # pressed inside applications.
  GLib.io_add_watch(sys.stdin, GLib.IO_IN | GLib.IO_HUP, command)
  # Held for as long as the loop runs.
  watchers = follow(bus, changed, presence)  # noqa: F841
  indicator.refresh_layouts()
  poll()
  loop.run()


if __name__ == "__main__":
  try:
    watch(Gio.bus_get_sync(Gio.BusType.SESSION, None))
  except (GLib.Error, OSError, ValueError, subprocess.CalledProcessError) as error:
    raise SystemExit(str(error))
