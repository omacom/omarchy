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

# Plymouth lets go only once the theme's fade has reached black on every display it can read, or
# once the fade has had its time.
HANDOFF="$ROOT/bin/omarchy-plymouth-handoff" python3 - <<'PY' || fail "the handoff lets go of the splash once it has faded to black"
import importlib.machinery, importlib.util, os, time
loader = importlib.machinery.SourceFileLoader("handoff", os.environ["HANDOFF"])
spec = importlib.util.spec_from_loader(loader.name, loader)
m = importlib.util.module_from_spec(spec)
loader.exec_module(m)

panel, external = ("card1", 39), ("card1", 40)
m.FADE, m.FADE_TIMEOUT, m.FADE_INTERVAL = 0.2, 0.4, 0.01
asked = []
m.plymouth = lambda *args: asked.append(args) or True
m.scanout = lambda cards: {panel: 46, external: 47, ("card0", 51): 0}
cards = {"card1": 3, "card0": 4}

polls = {"n": 0}
def darkening(fd, crtc, fb):
  polls["n"] += 1
  return polls["n"] > 6
m.dark = darkening
assert m.fade_to_black(cards), "both displays reach black"
assert asked == [("update", "--status=omarchy-session")], asked

m.dark = lambda fd, crtc, fb: fb == 46
started = time.monotonic()
assert not m.fade_to_black(cards), "one display never darkens: an older theme"
assert 0.35 < time.monotonic() - started < 1, "a fade that never ends is waited for no longer than its timeout"

m.dark = lambda fd, crtc, fb: None if fb == 47 else True
assert m.fade_to_black(cards), "a display that can't be read is not waited for"

m.dark = lambda fd, crtc, fb: None
started = time.monotonic()
assert not m.fade_to_black(cards), "no display can be read"
assert 0.15 < time.monotonic() - started < 0.35, "with nothing to read, the fade is given its usual length"

m.plymouth = lambda *args: False
started = time.monotonic()
assert not m.fade_to_black(cards) and time.monotonic() - started < 0.1, "a Plymouth that refuses the status is not waited for"
PY
pass "the handoff lets go of the splash once it has faded to black"

# Omarchy's greeter and its uwsm session ask for the display; anything else gets it once the splash
# has faded, before SDDM starts.
HANDOFF="$ROOT/bin/omarchy-plymouth-handoff" python3 - <<'PY' || fail "the handoff lets only Omarchy's greeter and uwsm session ask for the display"
import importlib.machinery, importlib.util, os, socket, tempfile, threading, time
loader = importlib.machinery.SourceFileLoader("handoff", os.environ["HANDOFF"])
spec = importlib.util.spec_from_loader(loader.name, loader)
m = importlib.util.module_from_spec(spec)
loader.exec_module(m)

sessions, local = tempfile.mkdtemp(), tempfile.mkdtemp()
def session(directory, name, exec_line):
  with open(f"{directory}/{name}.desktop", "w") as f:
    f.write(f"[Desktop Entry]\nName={name}\n{exec_line}\n")
session(sessions, "omarchy", "Exec=uwsm start -g -1 -e -D Hyprland hyprland.desktop")
session(sessions, "hyprland-uwsm", "Exec=uwsm start -e -D Hyprland hyprland.desktop")
session(sessions, "hyprland", "Exec=/usr/bin/start-hyprland")
session(sessions, "plasma", "Exec=uwsm start -e -D KDE plasma.desktop")
session(local, "hyprland", "Exec=uwsm start -e -D Hyprland hyprland.desktop")
greeter = {"General/DisplayServer": "wayland", "Wayland/CompositorCommand": "start-hyprland -- --config /usr/share/sddm/hyprland.lua",
           "Wayland/SessionDir": f"{local},{sessions}"}
auto = {**greeter, "Autologin/User": "me"}
assert m.gated(greeter), "Omarchy's greeter asks"
assert not m.gated({**greeter, "General/DisplayServer": "x11"}), "an X11 greeter never runs the Wayland command"
assert not m.gated({**greeter, "Wayland/CompositorCommand": "weston --shell=kiosk"}), "another greeter never asks"
assert m.gated({**auto, "Autologin/Session": "omarchy.desktop"})
assert m.gated({**auto, "Autologin/Session": "hyprland-uwsm"})
assert not m.gated({**auto, "Autologin/Session": "plasma.desktop"}), "another desktop under uwsm never asks"
assert not m.gated({**auto, "Autologin/Session": "hyprland", "Wayland/SessionDir": sessions}), "Hyprland without uwsm never asks"
assert m.gated({**auto, "Autologin/Session": "hyprland"}), "the first directory's session is the one SDDM starts"
assert not m.gated({**auto, "Autologin/Session": "missing"})
assert not m.gated({**auto, "Autologin/Session": "../omarchy"})
assert not m.gated({**greeter, "Autologin/Session": "omarchy.desktop"}), "a session without a user does not autologin"
assert not m.gated({k: v for k, v in auto.items() if not k.startswith("General")} | {"Autologin/Session": "omarchy.desktop"}), "a failed autologin falls back to a greeter that never asks"

# Whoever asks waits until the socket closes, which the handoff does once Plymouth has let go.
path = tempfile.mkdtemp() + "/handoff.sock"
m.SOCKET = path
server = m.listen()
returned = []
def ask():
  with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as c:
    c.connect(path); c.sendall(b"release\n")
    try:
      c.recv(64)
    except OSError:
      pass
  returned.append(time.monotonic())
asker = threading.Thread(target=ask); asker.start()
time.sleep(0.3)
assert not returned, "the asker waits while Plymouth holds the display"
released = time.monotonic()
m.close(server)
asker.join(timeout=2)
assert returned and returned[0] - released < 0.5, "closing the socket releases the asker"
assert not os.path.exists(path), "the socket is gone, so a later asker does not wait"
PY
pass "the handoff lets only Omarchy's greeter and uwsm session ask for the display"
