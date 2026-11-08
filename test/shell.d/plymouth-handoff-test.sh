#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

# Quitting Plymouth while a display still shows its frame blanks that display
# until the compositor reaches it, so the handoff waits for every one.
HANDOFF="$ROOT/bin/omarchy-plymouth-handoff" python3 - <<'PY' || fail "the handoff waits until every display Plymouth lit has been drawn over"
import importlib.machinery, importlib.util, os
loader = importlib.machinery.SourceFileLoader("handoff", os.environ["HANDOFF"])
spec = importlib.util.spec_from_loader(loader.name, loader)
module = importlib.util.module_from_spec(spec)
loader.exec_module(module)
handoff = module.handoff

panel, external, dark = ("card1", 39), ("card1", 40), ("card0", 51)
splash = {panel: 46, external: 47}

assert handoff(splash, {panel: 46, external: 47}) == (False, False), "nothing drawn yet"
assert handoff(splash, {panel: 52, external: 47}) == (True, False), "one display still shows the splash"
assert handoff(splash, {panel: 52, external: 0}) == (True, True), "a display the compositor turned off no longer shows it"
assert handoff(splash, {panel: 0, external: 0}) == (False, False), "displays turned off are not a compositor's frame"
assert handoff(splash, {external: 53}) == (True, False), "a display that couldn't be read still counts as the splash"
assert handoff(splash, {panel: 52, external: 53}) == (True, True), "both drawn over"
assert handoff({}, {dark: 0}) == (False, False), "a text splash: nothing drawn yet"
assert handoff({}, {dark: 60}) == (True, True), "a text splash: the compositor's first frame"
PY
pass "the handoff waits until every display Plymouth lit has been drawn over"

# The compositor asks for the display (default/hypr/plymouth-release.lua), and
# the handoff reads where Plymouth's bar stood so the compositor carries it on.
HANDOFF="$ROOT/bin/omarchy-plymouth-handoff" python3 - <<'PY' || fail "the handoff reads Plymouth's bar and waits for an Omarchy compositor to ask"
import importlib.machinery, importlib.util, os, struct, tempfile, zlib
loader = importlib.machinery.SourceFileLoader("handoff", os.environ["HANDOFF"])
spec = importlib.util.spec_from_loader(loader.name, loader)
m = importlib.util.module_from_spec(spec)
loader.exec_module(m)

# omarchy.script's curve, 0.7 * (1 - (1 - t / 15)^2), read back.
for t in (0.0, 1.0, 3.5, 9.0):
  p = 0.7 * (1 - (1 - t / 15) ** 2)
  assert abs(m.elapsed_for(p) - t) < 1e-9, t
assert m.elapsed_for(0.7) == 15 and m.elapsed_for(0.95) == 15, "a full bar is past the curve's end"

# Plymouth's layout() for the theme's images, at device scale 1 and 2.
theme = tempfile.mkdtemp()
def png(name, w, h):
  ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
  with open(f"{theme}/{name}", "wb") as f:
    f.write(b"\x89PNG\r\n\x1a\n" + struct.pack(">I", 13) + b"IHDR" + ihdr + struct.pack(">I", zlib.crc32(b"IHDR" + ihdr)))
png("logo.png", 800, 188); png("entry.png", 286, 48); png("progress_box.png", 300, 10); png("progress_bar.png", 300, 10)
assert m.bar_geometry(1280, 800, 1, theme) == (490, 558, 300), m.bar_geometry(1280, 800, 1, theme)
assert m.bar_geometry(2560, 1600, 2, theme) == (980, 1116, 600), m.bar_geometry(2560, 1600, 2, theme)
assert m.device_scale(2880, 1800, 286, 179) == 2 and m.device_scale(1280, 800, 320, 200) == 1 and m.device_scale(3840, 2160, 160, 90) == 1

# The filled run along the bar's middle row.
bg, bar, box = (30, 30, 45), (205, 214, 244), (49, 50, 68)
row = [bg] * 490 + [bar] * 67 + [box] * 233 + [bg] * 490
assert m.bar_fill(row, 490, 300, bg) == 67
assert m.bar_fill([bg] * 1280, 490, 300, bg) is None, "no bar drawn: no password was asked"
assert m.bar_fill(row[:490] + [bar] * 300 + row[790:], 490, 300, bg) == 300

# Sampled from a frame's rows: a bar at the computed scale, the other scale tried by the caller, and
# geometry that falls outside a small display is no bar rather than an error.
def frame(width, height, rows):
  return lambda y: b"".join(bytes((c[2], c[1], c[0], 0)) for c in rows.get(y, [bg] * width))
corner = bytes((bg[2], bg[1], bg[0], 0))
assert abs(m.sample_bar(frame(1280, 800, {558: row}), corner, 1280, 800, 1, theme) - 67.5 / 300) < 1e-9
assert m.sample_bar(frame(1280, 800, {558: row}), corner, 1280, 800, 2, theme) is None, "at scale 2 the bar sits elsewhere"
assert m.sample_bar(frame(640, 240, {}), corner, 640, 240, 1, theme) is None, "the bar's row is off a small display"

# Only a compositor that runs Omarchy's config asks; any other takes the display as SDDM starts.
home = tempfile.mkdtemp()
os.makedirs(f"{home}/.config/hypr")
with open(f"{home}/.config/hypr/hyprland.lua", "w") as f:
  f.write('dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")\nrequire("default.hypr.omarchy")\n')
auto = {"Autologin/User": "me", "Autologin/Session": "omarchy.desktop"}
assert m.gated(auto, home)
assert m.gated({**auto, "Autologin/Session": "hyprland-uwsm"}, home)
assert not m.gated({**auto, "Autologin/Session": "plasma.desktop"}, home), "another desktop"
with open(f"{home}/.config/hypr/hyprland.lua", "w") as f:
  f.write('dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")\n')
assert not m.gated(auto, home), "a Hyprland config without Omarchy's defaults never asks"
greeter = {"General/DisplayServer": "wayland", "Wayland/CompositorCommand": "start-hyprland -- --config /usr/share/sddm/hyprland.lua"}
assert m.gated(greeter, home), "Omarchy's greeter asks"
assert not m.gated({**greeter, "General/DisplayServer": "x11"}, home), "an X11 greeter never runs the Wayland command"
assert not m.gated({"General/DisplayServer": "wayland", "Wayland/CompositorCommand": "weston --shell=kiosk"}, home)

# The release: only the expected user's "release" ends the wait; anyone else is turned away and the
# wait goes on, and nobody asking ends it.
import socket, threading
path = tempfile.mkdtemp() + "/handoff.sock"
m.SOCKET = path
server = m.listen()
def ask(message, delay=0.0):
  def run():
    import time; time.sleep(delay)
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as c:
      c.connect(path); c.sendall(message)
      try:
        c.recv(64)
      except OSError:
        pass
  t = threading.Thread(target=run); t.start(); return t
stray = ask(b"hello")
real = ask(b"release\n", 0.3)
client = m.wait_for_release(server, {os.getuid()}, timeout=5)
assert client is not None, "the compositor's request after a stray connection"
client.sendall(b"released\n"); client.close(); stray.join(); real.join()
ask(b"release\n").join(timeout=0)
assert m.wait_for_release(server, {os.getuid() + 1}, timeout=1) is None, "another user's request is not the compositor's"
assert m.wait_for_release(server, {os.getuid()}, timeout=0.3) is None, "nobody asks"
server.close()
PY
pass "the handoff reads Plymouth's bar and waits for an Omarchy compositor to ask"
