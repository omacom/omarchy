"""Reconcile Parallels' DRM modes with Hyprland without changing user config."""

import json
import logging
import math
import os
from pathlib import Path
import re
import signal
import socket
import subprocess
from typing import NamedTuple


LOG = logging.getLogger("omarchy.parallels")


class ScalePreference(NamedTuple):
  event: str
  preferred: float
  saved: float


class PendingLayout(NamedTuple):
  monitor: dict
  mode: str
  scale: float
  layout: list
  original: dict
  expected: dict


def parse_mode(value):
  match = re.fullmatch(r"([0-9]{1,5})x([0-9]{1,5})", value)
  if not match:
    raise ValueError("invalid DRM mode")
  width, height = map(int, match.groups())
  if not (0 < width <= 32768 and 0 < height <= 32768):
    raise ValueError("DRM mode outside compositor limits")
  return width, height


def valid_scale(value):
  try:
    scale = float(value)
  except (TypeError, ValueError):
    return None
  return scale if math.isfinite(scale) and 1 <= scale <= 4 else None


def clean_scale(preferred, width, height):
  # Match omarchy-hyprland-monitor-scaling: 1/120 steps and whole logical pixels.
  common = math.gcd(width * 120, height * 120)
  units = min(int(preferred * 120 + 0.5), common)
  while common % units:
    units += 1
  return units / 120


def scale_records(path):
  records = {}
  try:
    with path.open("rb") as stream:
      stream.seek(0, 2)
      stream.seek(max(0, stream.tell() - 65536))
      lines = stream.read().decode("utf-8", errors="replace").splitlines()
  except OSError as error:
    if not isinstance(error, FileNotFoundError):
      LOG.warning("Cannot read monitor scale preferences: %s", error)
    return records
  for line in lines:
    fields = dict(field.split("=", 1) for field in line.split("\t") if "=" in field)
    name = fields.get("monitor", "")
    preferred = (valid_scale(fields.get("preferred")) or valid_scale(fields.get("requested"))
      or valid_scale(fields.get("new")))
    if re.fullmatch(r"Virtual-[0-9]+", name) and preferred is not None:
      records[name] = ScalePreference(line, preferred, valid_scale(fields.get("new")) or preferred)
  return records


def drm_hotplug(payload, sender_pid):
  # Users can send netlink datagrams too. Only kernel-originated DRM changes count.
  fields = payload.split(b"\0")
  return (sender_pid == 0 and fields[0].startswith(b"change@")
    and b"SUBSYSTEM=drm" in fields and b"HOTPLUG=1" in fields)


def notify_ready():
  address = os.environ.get("NOTIFY_SOCKET")
  if address:
    if address.startswith("@"):
      address = "\0" + address[1:]
    with socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM) as connection:
      connection.connect(address)
      connection.sendall(b"READY=1")


def active_outputs(monitors):
  return [monitor for monitor in monitors if not monitor.get("disabled")
    and monitor.get("dpmsStatus") is not False and monitor.get("mirrorOf", "none") == "none"]


def resize_layout(monitors, monitor, mode, scale, transform):
  if len(monitors) == 1:
    return [{"name": monitor["name"], "x": int(monitor.get("x", 0)), "y": int(monitor.get("y", 0))}]
  planner = Path(os.environ["OMARCHY_PATH"]) / "bin/omarchy-hyprland-monitor-layout"
  width, height = parse_mode(mode)
  if transform % 2 != monitor.get("transform", 0) % 2:
    width, height = height, width
  result = subprocess.run(["bash", str(planner), "--plan", "--resized", monitor["name"],
    f"{monitor['width']}x{monitor['height']}", str(monitor["scale"]), f"{width}x{height}", str(scale),
    mode, str(transform)], input=json.dumps(monitors), text=True,
    capture_output=True, check=True, timeout=3)
  layout = json.loads(result.stdout)
  if (not isinstance(layout, list) or len(layout) != len(monitors)
      or {target["name"] for target in layout} != {output["name"] for output in monitors}
      or any(type(target[coordinate]) is not int for target in layout for coordinate in ("x", "y"))):
    raise ValueError("invalid monitor layout plan")
  return layout


def pending_outputs(monitors, pending):
  # Undo only positions attributable to our partial move. Keep live neighbor
  # modes, scales, rotations and new outputs instead of waiting for old values.
  outputs = []
  for monitor in monitors:
    output = dict(monitor)
    original = pending.original.get(monitor["name"])
    expected = pending.expected.get(monitor["name"])
    if original and expected:
      position = (monitor.get("x", 0), monitor.get("y", 0))
      if position in ((original.get("x", 0), original.get("y", 0)), (expected["x"], expected["y"])):
        output.update(x=original.get("x", 0), y=original.get("y", 0))
      if monitor["name"] == pending.monitor["name"]:
        output.update((field, original.get(field, 0)) for field in ("width", "height", "scale", "transform"))
    outputs.append(output)
  return outputs


def layout_matches(monitors, expected):
  actual = {monitor["name"]: monitor for monitor in active_outputs(monitors)}
  if actual.keys() != expected.keys():
    return False
  return all(all(actual[name].get(field, 0) == target.get(field, 0)
    for field in ("width", "height", "x", "y", "transform"))
    and math.isclose(actual[name]["scale"], target["scale"], abs_tol=0.001)
    for name, target in expected.items())


def layout_overlaps(monitors):
  bounds = []
  for monitor in monitors:
    width = math.floor(monitor["width"] / monitor["scale"] + 0.5)
    height = math.floor(monitor["height"] / monitor["scale"] + 0.5)
    if monitor.get("transform", 0) % 2:
      width, height = height, width
    bounds.append((monitor.get("x", 0), monitor.get("y", 0), width, height))
  return any(left < other_left + other_width and other_left < left + width
    and top < other_top + other_height and other_top < top + height
    for index, (left, top, width, height) in enumerate(bounds)
    for other_left, other_top, other_width, other_height in bounds[index + 1:])


class Hyprland:
  def __init__(self, socket_path):
    self.socket_path = str(socket_path)

  def request(self, command):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
      connection.settimeout(3)
      connection.connect(self.socket_path)
      connection.sendall(command.encode())
      response = bytearray()
      while True:
        chunk = connection.recv(65536)
        if not chunk:
          break
        response.extend(chunk)
        if len(response) > 1048576:
          raise ValueError("oversized Hyprland IPC response")
    return response.decode()

  def monitors(self):
    monitors = json.loads(self.request("j/monitors all"))
    if not isinstance(monitors, list):
      raise ValueError("invalid Hyprland monitor response")
    return monitors

  def configure(self, monitor, mode, scale, layout):
    # Apply in the planner's order: move neighbors away before growing, and
    # shrink before closing gaps. Only the resized output changes mode/scale.
    rules = []
    for target in layout:
      rule = {"output": target["name"], "position": f"{target['x']}x{target['y']}"}
      if target["name"] == monitor["name"]:
        rule.update(mode=mode, scale=scale, transform=int(monitor.get("transform", 0)))
      fields = ", ".join(f"{key} = {json.dumps(value)}" for key, value in rule.items())
      rules.append(f"hl.monitor({{{fields}}})")
    response = self.request("eval " + " ".join(rules)).strip()
    if response != "ok":
      raise ValueError(f"Hyprland rejected monitor rule: {response}")


class ResizeBridge:
  def __init__(self, compositor, drm_path, scale_log):
    self.compositor = compositor
    self.drm_path = Path(drm_path)
    self.scale_log = Path(scale_log)
    self.preferences = {}
    self.audit_records = {}
    self.last_verified = {}
    self.pending_layout = None

  def apply_pending_layout(self):
    pending = self.pending_layout
    self.compositor.configure(pending.monitor, pending.mode, pending.scale, pending.layout)
    if not layout_matches(self.compositor.monitors(), pending.expected):
      return False
    self.pending_layout = None
    return True

  def reconcile(self, reasons):
    records = scale_records(self.scale_log)
    successful = True
    pending = self.pending_layout
    names = [output.get("name", "") for output in active_outputs(self.compositor.monitors())]
    if pending and pending.monitor["name"] in names:
      names.remove(pending.monitor["name"])
      names.insert(0, pending.monitor["name"])
    else:
      pending = self.pending_layout = None
    for name in names:
      monitors = self.compositor.monitors()
      monitor = next((output for output in monitors if output.get("name") == name), None)
      if monitor is None:
        continue
      name = monitor.get("name", "")
      if (not re.fullmatch(r"Virtual-[0-9]+", name) or monitor.get("disabled")
          or monitor.get("dpmsStatus") is False or monitor.get("mirrorOf", "none") != "none"):
        continue
      try:
        connectors = list(self.drm_path.glob(f"card*-{name}"))
        if len(connectors) != 1:
          raise ValueError(f"expected one DRM connector for {name}, found {len(connectors)}")
        with connectors[0].joinpath("modes").open() as modes:
          mode = modes.readline(80).strip()
        width, height = parse_mode(mode)
        current_scale = valid_scale(monitor.get("scale")) or 1
        record = records.get(name)
        new_preference = record and self.audit_records.get(name) != record.event
        if name not in self.preferences:
          preferred = current_scale
          if record and monitor.get("width", 0) > 0 and monitor.get("height", 0) > 0:
            effective = clean_scale(record.preferred, monitor["width"], monitor["height"])
            if (math.isclose(effective, current_scale, abs_tol=0.001)
                or math.isclose(record.saved, current_scale, abs_tol=0.001)):
              preferred = record.preferred
          self.preferences[name] = preferred
        elif new_preference:
          self.preferences[name] = record.preferred
        elif "config" in reasons and monitor.get("width", 0) > 0 and monitor.get("height", 0) > 0:
          effective = clean_scale(self.preferences[name], monitor["width"], monitor["height"])
          # Scaling controls persist the rounded result, not necessarily the
          # requested scale. Reloading that result must not erase the preference.
          saved_result = (record and math.isclose(self.preferences[name], record.preferred, abs_tol=0.001)
            and math.isclose(current_scale, record.saved, abs_tol=0.001))
          if not math.isclose(effective, current_scale, abs_tol=0.001) and not saved_result:
            self.preferences[name] = current_scale
        if record:
          self.audit_records[name] = record.event

        scale = clean_scale(self.preferences[name], width, height)
        unfinished = pending and name == pending.monitor["name"]
        if (unfinished or (monitor.get("width"), monitor.get("height")) != (width, height)
            or not math.isclose(current_scale, scale, abs_tol=0.001)):
          outputs = active_outputs(monitors)
          planning = pending_outputs(outputs, pending) if unfinished else outputs
          origin = next(output for output in planning if output["name"] == name)
          layout = resize_layout(planning, origin, mode, scale, monitor.get("transform", 0))
          expected = {output["name"]: dict(output) for output in outputs}
          for target in layout:
            expected[target["name"]].update(x=target["x"], y=target["y"])
          expected[name].update(width=width, height=height, scale=scale)
          if layout_overlaps(expected.values()):
            raise ValueError("resize would leave overlapping monitors")
          self.pending_layout = PendingLayout(monitor, mode, scale, layout,
            {output["name"]: dict(output) for output in planning}, expected)
          if not self.apply_pending_layout():
            return False
        verified = (mode, scale)
        if self.last_verified.get(name) != verified:
          LOG.info("%s: verified %s at %gx (preferred %gx)", name, mode, scale, self.preferences[name])
          self.last_verified[name] = verified
      except (OSError, ValueError, KeyError, StopIteration, subprocess.SubprocessError) as error:
        LOG.warning("%s: %s", name, error)
        if pending and name == pending.monitor["name"]:
          return False
        successful = False
    return successful


class EventLoop:
  RETRIES = (100, 200, 400, 800, 1600)

  def __init__(self, bridge, instance_path, state_directory):
    # Keep the policy importable in headless tests; the desktop supplies PyGObject.
    import gi
    gi.require_version("GLibUnix", "2.0")
    from gi.repository import Gio, GLib, GLibUnix

    self.GLib = GLib
    self.bridge = bridge
    self.loop = GLib.MainLoop()
    self.pending = set()
    self.timeout_id = 0
    self.attempt = 0
    self.connection_failed = False
    self.ready = False
    self.startup_failed = False
    self.buffer = b""
    self.netlink = socket.socket(socket.AF_NETLINK, socket.SOCK_DGRAM, 15)
    self.netlink.bind((0, 1))
    self.netlink.setblocking(False)
    self.events = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    self.events.connect(str(instance_path / ".socket2.sock"))
    self.events.setblocking(False)
    conditions = GLib.IO_IN | GLib.IO_HUP | GLib.IO_ERR
    GLib.io_add_watch(self.netlink.fileno(), GLib.PRIORITY_DEFAULT, conditions, self.drm_event)
    GLib.io_add_watch(self.events.fileno(), GLib.PRIORITY_DEFAULT, conditions, self.hyprland_event)
    state_directory.mkdir(parents=True, exist_ok=True)
    self.scale_monitor = Gio.File.new_for_path(str(state_directory)).monitor_directory(
      Gio.FileMonitorFlags.WATCH_MOVES, None)
    self.scale_monitor.connect("changed", self.scale_event)
    self.bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
    self.bus.signal_subscribe("org.freedesktop.login1", "org.freedesktop.login1.Manager",
      "PrepareForSleep", "/org/freedesktop/login1", None, Gio.DBusSignalFlags.NONE, self.sleep_event)
    for signal_number in (signal.SIGTERM, signal.SIGINT):
      GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, signal_number, self.stop)

  def stop(self, user_data=None):
    self.loop.quit()
    return False

  def enqueue(self, reason):
    self.pending.add(reason)
    self.attempt = 0
    if self.timeout_id:
      self.GLib.source_remove(self.timeout_id)
    self.timeout_id = self.GLib.timeout_add(100, self.flush)

  def flush(self):
    self.timeout_id = 0
    try:
      successful = self.bridge.reconcile(self.pending)
    except (OSError, ValueError, KeyError) as error:
      LOG.warning("Hyprland is not ready: %s", error)
      successful = False
    if successful:
      if not self.ready:
        notify_ready()
        self.ready = True
      self.pending.clear()
    elif self.attempt < len(self.RETRIES):
      self.timeout_id = self.GLib.timeout_add(self.RETRIES[self.attempt], self.flush)
      self.attempt += 1
    else:
      LOG.warning("Resize did not settle; waiting for the next display or config event")
      self.pending.clear()
      if not self.ready:
        self.startup_failed = True
        self.loop.quit()
    return False

  def drm_event(self, source, condition):
    if condition & (self.GLib.IO_HUP | self.GLib.IO_ERR):
      self.connection_failed = True
      self.loop.quit()
      return False
    while True:
      try:
        payload, sender = self.netlink.recvfrom(65536)
      except BlockingIOError:
        break
      if drm_hotplug(payload, sender[0]):
        self.enqueue("hotplug")
    return True

  def hyprland_event(self, source, condition):
    if condition & (self.GLib.IO_HUP | self.GLib.IO_ERR):
      self.connection_failed = True
      self.loop.quit()
      return False
    try:
      payload = self.events.recv(65536)
    except BlockingIOError:
      return True
    if not payload:
      self.connection_failed = True
      self.loop.quit()
      return False
    self.buffer += payload
    while b"\n" in self.buffer:
      line, self.buffer = self.buffer.split(b"\n", 1)
      event = line.split(b">>", 1)[0]
      if event == b"configreloaded":
        self.enqueue("config")
      elif event in (b"monitoradded", b"monitoraddedv2", b"monitorremoved", b"monitorremovedv2"):
        self.enqueue("hotplug")
    if len(self.buffer) > 131072:
      self.buffer = b""
    return True

  def scale_event(self, monitor, changed_file, other_file, event_type):
    if changed_file.get_basename() == "scaling":
      self.enqueue("scale")

  def sleep_event(self, connection, sender, object_path, interface, signal_name, parameters, user_data=None):
    if parameters.unpack() == (False,):
      self.enqueue("resume")

  def run(self):
    self.enqueue("startup")
    try:
      self.loop.run()
    finally:
      self.netlink.close()
      self.events.close()
      self.scale_monitor.cancel()
    if self.connection_failed or self.startup_failed:
      raise ConnectionError("Display event connection closed or initial resize could not be verified")


def main():
  logging.basicConfig(level=logging.INFO, format="%(message)s")
  runtime = Path(os.environ["XDG_RUNTIME_DIR"])
  signature = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
  if not re.fullmatch(r"[A-Za-z0-9_-]+", signature):
    raise ValueError("invalid Hyprland instance signature")
  instance_path = runtime / "hypr" / signature
  state_directory = Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state") / "omarchy/monitors"
  bridge = ResizeBridge(Hyprland(instance_path / ".socket.sock"),
    Path("/sys/class/drm"), state_directory / "scaling")
  EventLoop(bridge, instance_path, state_directory).run()


if __name__ == "__main__":
  main()
