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
source_root = pathlib.Path(os.environ.get("CURSOR_TEST_SOURCE_ROOT", str(root)))
reload_during_reveal = os.environ.get("CURSOR_TEST_RELOAD_DURING_REVEAL") == "1"
evidence = os.environ.get("CURSOR_TEST_EVIDENCE_DIR")
if evidence:
  evidence = pathlib.Path(evidence)
  evidence.mkdir(parents=True, exist_ok=True)
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
  env.update(HOME=str(home), OMARCHY_PATH=str(source_root), CURSOR_TEST_STAGE=str(stage),
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
    # Only the cursor has green in it. The cover is black and the desktop
    # magenta, which can show at part opacity while its panel fades in.
    screenshot = stage / "frame.png"
    frames = []
    def cursor_pixels():
      subprocess.run(["grim", "-c", str(screenshot)], env=env, check=True,
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=5)
      if evidence:
        frame = evidence / ("frame-%03d.png" % len(frames))
        frame.write_bytes(screenshot.read_bytes())
        frames.append((frame.name, time.monotonic()))
      green = subprocess.check_output(["magick", str(screenshot), "-channel", "G", "-separate", "-threshold", "0", "-format", "%[fx:mean*w*h]", "info:"], text=True, timeout=5)
      return float(green)

    # Capture immediately, including before Quickshell loads its cover. The
    # fixture cannot reveal while grim or magick is busy taking these frames.
    deadline = time.monotonic() + 5
    for sample in range(3):
      assert time.monotonic() < deadline, "initial compositor captures timed out"
      assert cursor_pixels() == 0, "the cursor appeared in the first compositor frames"
    if evidence:
      (evidence / "hidden.png").write_bytes(screenshot.read_bytes())

    def wait_phase(expected):
      deadline = time.monotonic() + 5
      while not (stage / "phase").exists() or (stage / "phase").read_text() != expected:
        assert compositor.poll() is None and time.monotonic() < deadline, "startup never reached " + expected
        time.sleep(0.01)

    wait_phase("holding")
    # Reload after hyprland.start has reset the application cursor theme. A
    # fresh Lua state must retain the pending reveal and the original settings.
    subprocess.run(["hyprctl", "reload"], env=env, check=True, timeout=5,
             stdout=subprocess.DEVNULL)
    subprocess.run(["hyprctl", "eval", 'local f = assert(io.open(os.getenv("CURSOR_TEST_STAGE") .. "/pending", "w")); f:write(tostring(omarchy_startup_cursor_pending)); f:close()'],
             env=env, check=True, timeout=5, stdout=subprocess.DEVNULL)
    assert (stage / "pending").read_text() == "true", "reload after application startup lost the pending reveal"
    (stage / "release").write_text("reveal")
    if reload_during_reveal:
      deadline = time.monotonic() + 5
      while not (stage / "redraw-held").exists():
        assert compositor.poll() is None and time.monotonic() < deadline, "never reached the held redraw window"
        time.sleep(0.01)
      capture = pathlib.Path(env["XDG_RUNTIME_DIR"]) / ("omarchy-startup-cursor-" + signature + ".state")
      assert capture.exists(), "the held redraw must still have its saved settings"
      subprocess.run(["hyprctl", "reload"], env=env, check=True, timeout=5, stdout=subprocess.DEVNULL)
      (stage / "redraw-reloaded").write_text("resume")
      subprocess.run(["hyprctl", "eval", 'local f = assert(io.open(os.getenv("CURSOR_TEST_STAGE") .. "/pending", "w")); f:write(tostring(omarchy_startup_cursor_pending) .. "\\n" .. tostring(omarchy_startup_cursor and omarchy_startup_cursor.xcursor)); f:close()'],
               env=env, check=True, timeout=5, stdout=subprocess.DEVNULL)
      assert (stage / "pending").read_text() == "true\nAdwaita", "reload during redraw lost the pending reveal or original theme"
    wait_phase("revealed")
    # The nested compositor only renders its cursor once a pointer is
    # inside it, and a headless or parked real pointer may never be:
    # bring the real pointer into the nested window first, then place
    # the nested cursor clear of the edges (the parent warp lands it
    # wherever the window's scaling puts it).
    import json
    def place_pointer():
      clients = subprocess.check_output(["hyprctl", "clients", "-j"], env=parent_env, text=True, timeout=5)
      for client in json.loads(clients):
        if client.get("pid") == compositor.pid:
          x = client["at"][0] + client["size"][0] // 2
          y = client["at"][1] + client["size"][1] // 2
          subprocess.run(["hyprctl", "eval", f"hl.dispatch(hl.dsp.cursor.move({{ x = {x}, y = {y} }}))"], env=parent_env, check=True, capture_output=True, timeout=5)
          break
      subprocess.run(["hyprctl", "eval", "hl.dispatch(hl.dsp.cursor.move({ x = 100, y = 100 }))"], env=env, check=True, capture_output=True, timeout=5)
    place_pointer()
    # Cursor visibility is polled by the compositor independently of the fade.
    # Losing the redraw timer must recover through the production 15s fallback.
    deadline = time.monotonic() + (20 if reload_during_reveal else 5)
    while True:
      if cursor_pixels() > 20:
        break
      if time.monotonic() >= deadline:
        subprocess.run(["hyprctl", "eval", 'local f = assert(io.open(os.getenv("CURSOR_TEST_STAGE") .. "/failure-state", "w")); f:write("pending=" .. tostring(omarchy_startup_cursor_pending) .. " invisible=" .. tostring(hl.get_config("cursor.invisible")) .. " phase=" .. tostring(os.getenv("OMARCHY_STARTUP_CURSOR")) .. " theme=" .. tostring(os.getenv("XCURSOR_THEME"))); f:close()'], env=env, check=True, timeout=5, stdout=subprocess.DEVNULL)
        raise AssertionError("the normal cursor did not return with the desktop: " + (stage / "failure-state").read_text())
    if evidence:
      (evidence / "revealed.png").write_bytes(screenshot.read_bytes())
    subprocess.run(["hyprctl", "eval", 'local f = assert(io.open(os.getenv("CURSOR_TEST_STAGE") .. "/done", "w")); f:write(tostring(omarchy_startup_cursor_pending) .. "\\n" .. tostring(os.getenv("OMARCHY_STARTUP_CURSOR"))); f:close()'],
             env=env, check=True, timeout=5, stdout=subprocess.DEVNULL)
    if source_root == root:
      assert (stage / "done").read_text() == "false\n" + signature + ":done", "visible cursor must finish the instance phase"
    capture = pathlib.Path(env["XDG_RUNTIME_DIR"]) / ("omarchy-startup-cursor-" + signature + ".state")
    assert not capture.exists(), "completed redraw left a stale capture"
    subprocess.run(["hyprctl", "reload"], env=env, check=True, timeout=5, stdout=subprocess.DEVNULL)
    subprocess.run(["hyprctl", "eval", 'local f = assert(io.open(os.getenv("CURSOR_TEST_STAGE") .. "/healthy", "w")); f:write(tostring(omarchy_startup_cursor_pending) .. "\\n" .. tostring(hl.get_config("cursor.invisible"))); f:close()'],
             env=env, check=True, timeout=5, stdout=subprocess.DEVNULL)
    assert (stage / "healthy").read_text() == "false\nfalse", "a healthy reload restarted cursor hiding"
    # Re-enter the nested surface after reload; its parent-side placement or
    # pointer focus can change independently of the cursor being tested.
    place_pointer()
    # Wait for a rendered frame after reload rather than sampling its transition.
    deadline = time.monotonic() + 5
    while cursor_pixels() <= 20:
      if time.monotonic() >= deadline:
        position = subprocess.check_output(["hyprctl", "cursorpos"], env=env, text=True, timeout=5).strip()
        raise AssertionError("a healthy reload left the restored cursor invisible; cursorpos=" + position + "; state=" + (stage / "healthy").read_text())
    if evidence:
      # Keep the captured frames and their actual intervals as a short recording.
      timeline = evidence / "frames.ffconcat"
      with timeline.open("w") as output:
        output.write("ffconcat version 1.0\n")
        for index, (name, timestamp) in enumerate(frames):
          duration = frames[index + 1][1] - timestamp if index + 1 < len(frames) else 1
          output.write("file '%s'\nduration %.6f\n" % (name, duration))
        output.write("file '%s'\n" % frames[-1][0])
      subprocess.run(["ffmpeg", "-v", "error", "-y", "-safe", "0", "-i", str(timeline), "-vf", "pad=ceil(iw/2)*2:ceil(ih/2)*2", "-pix_fmt", "yuv420p", str(evidence / "reveal.mp4")], check=True, timeout=30)
    print("cursor visible; phase done; snapshot removed; healthy reload preserved visibility; redraw reload=" + str(reload_during_reveal))
  except Exception:
    print((stage / "compositor.log").read_text())
    raise
  finally:
    # Stop Quickshell before its compositor: losing the display makes it abort,
    # and the crash watcher reports that abort as a crash.
    subprocess.run(["pkill", "-TERM", "-f", "quickshell -p " + str(stage)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline and subprocess.run(["pgrep", "-f", "quickshell -p " + str(stage)], stdout=subprocess.DEVNULL).returncode == 0:
      time.sleep(0.05)
    os.killpg(compositor.pid, signal.SIGTERM)
    compositor.wait(timeout=10)
    log.close()
PY
pass "a fresh compositor never exposes its cursor before the desktop reveal"
