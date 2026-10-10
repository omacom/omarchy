"""Live Fcitx state for the existing keyboard layout widget."""

from collections import Counter
import json
import os
import re
import subprocess
import sys

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


class Indicator:
  def __init__(self, bus):
    self.bus = bus
    self.pending = ""
    self.last = ""
    self.entries = {}

  def select_next(self, step=1):
    devices = subprocess.run(["hyprctl", "-j", "devices"], check=True, text=True, capture_output=True)
    keyboards = json.loads(devices.stdout).get("keyboards", [])
    try:
      state = snapshot(self.bus)
    except GLib.Error:
      # Without Fcitx, Super+I still cycles the compositor layouts.
      for command in layout_switches(keyboards, step=step):
        subprocess.run(command, check=True, capture_output=True)
      return
    methods = state["methods"]
    current = self.pending or state["current"] or self.last
    state["current"] = current if current in methods else next(iter(methods), "")
    following, index = cycle_choice(state, keyboards, step)
    if following is None:
      return
    self.pending = following
    for command in layout_switches(keyboards, index) if index is not None else []:
      subprocess.run(command, check=True, capture_output=True)
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


def watch(bus):
  previous = None
  indicator = Indicator(bus)
  loop = GLib.MainLoop()
  buffer = ""
  timer = 0

  def refresh():
    nonlocal previous
    try:
      state = indicator.refresh()
    except GLib.Error:
      indicator.pending = ""
      indicator.last = ""
      state = {"methods": [], "current": "", "name": "", "language": ""}
    line = json.dumps(state, ensure_ascii=False)
    if line != previous:
      print(line, flush=True)
      previous = line

  def poll():
    nonlocal timer
    refresh()
    timer = GLib.timeout_add(50 if indicator.pending else 500, poll)
    return GLib.SOURCE_REMOVE

  def command(source, condition):
    nonlocal buffer, timer
    data = os.read(sys.stdin.fileno(), 4096)
    if not data:
      loop.quit()
      return GLib.SOURCE_REMOVE
    buffer += data.decode()
    while "\n" in buffer:
      line, buffer = buffer.split("\n", 1)
      if line in ("cycle", "cycle back"):
        try:
          indicator.select_next(-1 if line == "cycle back" else 1)
        except (GLib.Error, OSError, ValueError, subprocess.CalledProcessError):
          indicator.pending = ""
        refresh()
    GLib.source_remove(timer)
    timer = GLib.timeout_add(50 if indicator.pending else 500, poll)
    return GLib.SOURCE_CONTINUE

  # Fcitx's controller has no current-method-changed signal. Keep one bus
  # connection open instead of spawning a command on every poll. Polling also
  # follows per-application input contexts and recovers after service restarts.
  GLib.io_add_watch(sys.stdin, GLib.IO_IN | GLib.IO_HUP, command)
  poll()
  loop.run()


if __name__ == "__main__":
  try:
    watch(Gio.bus_get_sync(Gio.BusType.SESSION, None))
  except (GLib.Error, OSError, ValueError, subprocess.CalledProcessError) as error:
    raise SystemExit(str(error))
