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
  env.pop("HYPRLAND_INSTANCE_SIGNATURE", None)
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
    env.update(WAYLAND_DISPLAY=display, HYPRLAND_INSTANCE_SIGNATURE=signature)
    started = time.monotonic()
    early_frames = 0
    revealed = False
    while time.monotonic() - started < 3:
      elapsed = time.monotonic() - started
      screenshot = stage / "frame.png"
      subprocess.run(["grim", "-c", str(screenshot)], env=env, check=True,
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
      maximum = subprocess.check_output(["magick", str(screenshot), "-format", "%[fx:maxima]", "info:"], text=True)
      if elapsed < 0.8:
        assert maximum == "0", "the cursor appeared in the first compositor frames"
        early_frames += 1
      elif elapsed > 2.5:
        green = subprocess.check_output(["magick", str(screenshot), "-channel", "G", "-separate", "-threshold", "0", "-format", "%[fx:mean*w*h]", "info:"], text=True)
        assert float(green) > 20, "the normal cursor did not return with the desktop"
        revealed = True
    assert early_frames >= 3 and revealed, "both initial startup and reveal must be captured"
  finally:
    os.killpg(compositor.pid, signal.SIGTERM)
    compositor.wait(timeout=10)
    log.close()
PY
pass "a fresh compositor never exposes its cursor before the desktop reveal"
