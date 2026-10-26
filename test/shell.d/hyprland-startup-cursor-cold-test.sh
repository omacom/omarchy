#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_compositor "cold compositor cursor startup"
require_command Hyprland
require_command quickshell
require_command grim
require_command magick
require_command python3

python3 <<'PY'
import os
import pathlib
import signal
import subprocess
import tempfile
import time

root = pathlib.Path(os.environ["ROOT"])
with tempfile.TemporaryDirectory() as directory:
  stage = pathlib.Path(directory)
  home = stage / "home"
  home.mkdir()
  (stage / "release").write_text("")
  (stage / "bin").mkdir()
  launcher = stage / "bin/omarchy-theme-bg-boot-intro"
  launcher.write_text("#!/bin/bash\nexit 0\n")
  launcher.chmod(0o755)
  for name in ("Commons", "services"):
    (stage / name).symlink_to(root / "shell" / name)
  fixture = root / "test/shell.d/fixtures/startup-cursor"
  (stage / "shell.qml").write_text((fixture / "shell.qml").read_text())
  env = os.environ.copy()
  env.update(HOME=str(home), OMARCHY_PATH=str(root), CURSOR_TEST_STAGE=str(stage),
         PATH=str(stage / "bin") + ":" + env["PATH"], AQ_BACKEND="wayland",
         HYPRLAND_NO_SD_VARS="1", HYPRLAND_NO_SD_NOTIFY="1", GSETTINGS_BACKEND="memory",
         XCURSOR_THEME="Adwaita", XCURSOR_PATH="/usr/share/icons:/usr/share/pixmaps", XCURSOR_SIZE="24", HYPRCURSOR_SIZE="24")
  parent_signature = env.pop("HYPRLAND_INSTANCE_SIGNATURE", None)
  env.pop("HYPRCURSOR_THEME", None)
  log = open(stage / "compositor.log", "w")
  compositor = subprocess.Popen(["Hyprland", "--config", str(fixture / "hyprland.lua")],
                  env=env, stdout=log, stderr=log, start_new_session=True)
  try:
    deadline = time.monotonic() + 5
    while not (stage / "session").exists():
      assert compositor.poll() is None, "cold compositor exited before startup"
      assert time.monotonic() < deadline, "cold compositor never started"
      time.sleep(0.005)
    display, signature = (stage / "session").read_text().splitlines()
    parent_env = env.copy()
    if parent_signature:
      parent_env["HYPRLAND_INSTANCE_SIGNATURE"] = parent_signature
    env.update(WAYLAND_DISPLAY=display, HYPRLAND_INSTANCE_SIGNATURE=signature)
    # Capture immediately, including before Quickshell loads its cover. The
    # fixture cannot reveal while grim or magick is busy taking these frames.
    deadline = time.monotonic() + 5
    for sample in range(3):
      assert time.monotonic() < deadline, "initial compositor captures timed out"
      screenshot = stage / "frame.png"
      subprocess.run(["grim", "-c", str(screenshot)], env=env, check=True,
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=5)
      maximum = subprocess.check_output(["magick", str(screenshot), "-format", "%[fx:maxima]", "info:"], text=True, timeout=5)
      assert maximum == "0", "the cursor appeared in the first compositor frames"

    def wait_phase(expected):
      deadline = time.monotonic() + 5
      while not (stage / "phase").exists() or (stage / "phase").read_text() != expected:
        assert compositor.poll() is None and time.monotonic() < deadline, "startup never reached " + expected
        time.sleep(0.01)

    wait_phase("holding")
    subprocess.run(["hyprctl", "reload"], env=env, check=True, capture_output=True, timeout=5)
    subprocess.run(["hyprctl", "eval", "assert(omarchy_startup_cursor_pending, 'reload lost the pending cursor reveal')"],
             env=env, check=True, capture_output=True, timeout=5)
    (stage / "release").write_text("reveal")
    wait_phase("revealed")
    # The nested compositor only renders its cursor once a pointer is
    # inside it, and a headless or parked real pointer may never be:
    # bring the real pointer into the nested window first, then place
    # the nested cursor clear of the edges (the parent warp lands it
    # wherever the window's scaling puts it).
    clients = subprocess.check_output(["hyprctl", "clients", "-j"], env=parent_env, text=True, timeout=5)
    import json
    for client in json.loads(clients):
      if client.get("pid") == compositor.pid:
        x = client["at"][0] + client["size"][0] // 2
        y = client["at"][1] + client["size"][1] // 2
        subprocess.run(["hyprctl", "eval", f"hl.dispatch(hl.dsp.cursor.move({{ x = {x}, y = {y} }}))"], env=parent_env, check=True, capture_output=True, timeout=5)
        break
    subprocess.run(["hyprctl", "eval", "hl.dispatch(hl.dsp.cursor.move({ x = 100, y = 100 }))"], env=env, check=True, capture_output=True, timeout=5)
    # Cursor visibility is polled by the compositor independently of the fade.
    deadline = time.monotonic() + 5
    seen = False
    while time.monotonic() < deadline:
      subprocess.run(["grim", "-c", str(screenshot)], env=env, check=True,
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=5)
      green = subprocess.check_output(["magick", str(screenshot), "-channel", "G", "-separate", "-threshold", "0", "-format", "%[fx:mean*w*h]", "info:"], text=True, timeout=5)
      if float(green) > 20:
        seen = True
        break
      time.sleep(0.05)
    if not seen:
      # A Wayland-backend nested compositor may never composite its
      # cursor into screencopy frames (the parent renders it), so fall
      # back to the compositor's own restored state: pending cleared,
      # cursor visible again, normal theme back.
      subprocess.run(["hyprctl", "eval", "assert(not omarchy_startup_cursor_pending, 'cursor reveal still pending')"],
               env=env, check=True, capture_output=True, timeout=5)
      subprocess.run(["hyprctl", "eval", "assert(hl.get_config('cursor.invisible') == false, 'cursor still invisible')"],
               env=env, check=True, capture_output=True, timeout=5)
      subprocess.run(["hyprctl", "eval", "assert(os.getenv('XCURSOR_THEME') ~= 'omarchy-startup', 'blank cursor theme still active')"],
               env=env, check=True, capture_output=True, timeout=5)
  except Exception:
    print((stage / "compositor.log").read_text())
    raise
  finally:
    os.killpg(compositor.pid, signal.SIGTERM)
    compositor.wait(timeout=10)
    log.close()
PY
pass "a fresh compositor never exposes its cursor before the desktop reveal"
