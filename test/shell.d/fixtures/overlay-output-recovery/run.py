"""Exercise the production OverlayWindow in an isolated nested compositor."""

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time


NAMESPACE = "omarchy-overlay-recovery-test"


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("root", type=Path)
  parser.add_argument("--overlay", type=Path, help="implementation for a negative-control run")
  parser.add_argument("--artifacts", type=Path, help="retain logs, states and screenshots")
  parser.add_argument("--zero-output-open", action="store_true", help="leave the overlay open during the zero-output interval")
  args = parser.parse_args()
  source = args.overlay or args.root / "shell/Ui/OverlayWindow.qml"
  processes = []
  history = []

  # Keep Unix socket paths short, even when the checkout is deeply nested.
  with tempfile.TemporaryDirectory(prefix="ovl-", dir="/tmp") as temporary:
    directory = Path(temporary)
    logs = args.artifacts or directory / "artifacts"
    logs.mkdir(parents=True, exist_ok=True)
    config = directory / "hyprland.lua"
    config.write_text(
      'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })\n'
      'hl.config({ animations = { enabled = false }, xwayland = { enabled = false } })\n'
    )
    fixture = directory / "fixture"
    (fixture / "Ui").mkdir(parents=True)
    shutil.copyfile(Path(__file__).with_name("shell.qml"), fixture / "shell.qml")
    shutil.copyfile(source, fixture / "Ui/OverlayWindow.qml")
    (fixture / "Ui/qmldir").write_text("module qs.Ui\nOverlayWindow 1.0 OverlayWindow.qml\n")

    env = os.environ.copy()
    display = Path(env["WAYLAND_DISPLAY"])
    if not display.is_absolute():
      display = Path(env["XDG_RUNTIME_DIR"]) / display
    env.update(WAYLAND_DISPLAY=str(display), XDG_RUNTIME_DIR=str(directory), AQ_DRM_DEVICES="/dev/null")
    env.pop("HYPRLAND_INSTANCE_SIGNATURE", None)
    env["QS_DISABLE_FILE_WATCHER"] = "1"

    def run(command, check=True):
      result = subprocess.run(command, env=env, capture_output=True, text=True, timeout=5)
      history.append({"command": command, "status": result.returncode, "stdout": result.stdout, "stderr": result.stderr})
      if check and result.returncode:
        raise AssertionError(f"{command}: {result.stdout}{result.stderr}")
      return result.stdout.strip()

    def wait_for(description, query, predicate, timeout=5):
      deadline = time.monotonic() + timeout
      last = None
      while time.monotonic() < deadline:
        last = query()
        if predicate(last):
          return last
        time.sleep(0.05)
      raise AssertionError(f"{description}: last state {last}")

    def monitors():
      return json.loads(run(["hyprctl", "-j", "monitors"]))

    def ipc(method):
      # -- is needed because show also names a qs ipc subcommand.
      return run(["quickshell", "ipc", "-p", str(fixture), "call", "--", "fixture", method])

    def state():
      return json.loads(ipc("state"))

    def layers():
      found = []
      for monitor, data in json.loads(run(["hyprctl", "-j", "layers"])).items():
        for level, entries in data["levels"].items():
          for entry in entries:
            if entry["namespace"] == NAMESPACE:
              found.append({**entry, "monitor": monitor, "level": int(level)})
      return found

    def surface(monitor, shown):
      return wait_for(
        f"{'shown' if shown else 'parked'} surface on {monitor}", layers,
        lambda entries: len(entries) == 1 and entries[0]["monitor"] == monitor
          and entries[0]["level"] == (3 if shown else 1)
          and ((entries[0]["w"] > 1 and entries[0]["h"] > 1) if shown
               else entries[0]["w"] == entries[0]["h"] == 1),
      )[0]

    def pass_check(description):
      print(f"ok - {description}", flush=True)

    def check(condition, description):
      if not condition:
        raise AssertionError(description)

    def create(name):
      # Wayland outputs use the parent's supported buffer modifiers. Headless
      # outputs can fail allocation on NVIDIA in a nested compositor.
      run(["hyprctl", "output", "create", "wayland", name])
      wait_for(f"output {name} is active", monitors,
               lambda entries: any(m["name"] == name and m["width"] > 0 and m["height"] > 0 for m in entries))
      wait_for(f"Qt lists output {name}", state,
               lambda value: any(s["name"] == name and s["width"] > 0 and s["height"] > 0 for s in value["screens"]))

    def focus(name):
      run(["hyprctl", "dispatch", f"hl.dsp.focus({{ monitor = {json.dumps(name)} }})"])
      wait_for(f"focus reaches {name}", state, lambda value: value["focusedMonitor"] == name)

    def keyboard():
      previous = state()["keyCount"]
      run(["wtype", "-k", "a"])
      wait_for("recovered overlay receives keyboard input", state,
               lambda value: value["keyCount"] == previous + 1 and value["keyboardFocus"] == 1)

    def snapshot(name, monitor):
      if args.artifacts and shutil.which("grim"):
        run(["grim", "-o", monitor, str(logs / f"{name}.png")])

    initial = None
    try:
      with (logs / "hyprland.log").open("w") as log:
        compositor = subprocess.Popen(["Hyprland", "--config", str(config)], env=env,
                                      stdout=log, stderr=log)
      processes.append(compositor)
      instance = wait_for("nested compositor IPC socket", lambda: list((directory / "hypr").glob("*/.socket.sock")), bool)
      env["HYPRLAND_INSTANCE_SIGNATURE"] = instance[0].parent.name
      sockets = wait_for("nested Wayland socket", lambda: [p for p in directory.glob("wayland-*") if p.is_socket()], bool)
      env["WAYLAND_DISPLAY"] = sockets[0].name
      initial = wait_for("initial nested output", monitors,
                         lambda entries: any(m["width"] > 0 and m["height"] > 0 for m in entries))[0]["name"]
      check(not run(["hyprctl", "configerrors"]), "nested compositor config has errors")
      with (logs / "fixture.log").open("w") as log:
        shell = subprocess.Popen(["quickshell", "-p", str(fixture), "--no-color"], env=env,
                                 stdout=log, stderr=log)
      processes.append(shell)
      wait_for("fixture IPC is ready", lambda: run(
        ["quickshell", "ipc", "-p", str(fixture), "call", "--", "fixture", "state"], check=False),
        lambda output: output.startswith('{"shown":'))
      surface(initial, False)
      check(state()["keyboardFocus"] == 0, "parked overlay takes keyboard focus")
      pass_check("initial overlay parks at 1x1 without keyboard focus")

      for shown in [False, True]:
        for cycle in range(3):
          ipc("park")
          name = f"overlay-{int(shown)}-{cycle}"
          create(name)
          focus(name)
          ipc("show")
          # Moving to a live output during show is separately tracked by
          # #13562. Give that existing behavior one park/show before testing
          # output removal so it cannot mask the recovery regression.
          wait_for("overlay targets removable output", state, lambda value: value["screen"] == name)
          ipc("park")
          surface(name, False)
          if shown:
            ipc("show")
            surface(name, True)
          run(["hyprctl", "output", "remove", name])
          surface(initial, shown)
          if not shown:
            check(state()["keyboardFocus"] == 0, "recovered parked overlay takes keyboard focus")
            ipc("show")
            surface(initial, True)
          keyboard()
          snapshot(f"recovered-{int(shown)}-{cycle}", initial)
          check(shell.poll() is None, "fixture exited during recovery")
          pass_check(f"cycle {cycle + 1}: {'open' if shown else 'parked'} overlay recovers on remaining output and receives input")

      for shown in [args.zero_output_open]:
        ipc("show" if shown else "park")
        surface(initial, shown)
        run(["hyprctl", "eval", f"hl.monitor({{ output = {json.dumps(initial)}, disabled = true }})"])
        wait_for("all outputs disappeared", monitors,
                 lambda entries: all(m["width"] == 0 or m["height"] == 0 for m in entries))
        # Hyprland may retain an unusable 0x0 surface on its FALLBACK monitor.
        # That is not a real output and must not count as recovered.
        wait_for("no usable surface while all outputs are gone", layers,
                 lambda entries: all(e["monitor"] == "FALLBACK" and e["w"] == e["h"] == 0 for e in entries))
        before = state()["visibilityChanges"]
        time.sleep(0.3)
        check(state()["visibilityChanges"] == before, "remap loops while no real output exists")
        run(["hyprctl", "reload"])
        wait_for("output returns after zero-output interval", monitors,
                 lambda entries: any(m["name"] == initial and m["width"] > 0 and m["height"] > 0 for m in entries))
        surface(initial, shown)
        if not shown:
          ipc("show")
          surface(initial, True)
        keyboard()
        snapshot(f"zero-output-recovered-{int(shown)}", initial)
        pass_check(f"{'open' if shown else 'parked'} overlay recovers after all outputs disappear without a remap loop")

      before = state()["visibilityChanges"]
      time.sleep(0.3)
      check(state()["visibilityChanges"] == before, "recovered overlay remaps continuously")
      check(shell.poll() is None and compositor.poll() is None, "a process restarted or exited")
      pass_check("recovered surfaces remain stable in the same fixture and compositor processes")
      return 0
    except (AssertionError, subprocess.SubprocessError, ValueError) as error:
      print(f"not ok - overlay output recovery: {error}", flush=True)
      if args.artifacts and initial and shutil.which("grim"):
        try:
          run(["grim", "-o", initial, str(logs / "failure.png")], check=False)
        except subprocess.SubprocessError:
          pass
      for filename in ["fixture.log", "hyprland.log"]:
        if (logs / filename).exists():
          print((logs / filename).read_text()[-4000:], flush=True)
      return 1
    finally:
      (logs / "commands.json").write_text(json.dumps(history, indent=2) + "\n")
      for compositor_log in (directory / "hypr").glob("*/hyprland.log"):
        shutil.copyfile(compositor_log, logs / "compositor.log")
      for process in reversed(processes):
        if process.poll() is None:
          process.terminate()
          try:
            process.wait(timeout=5)
          except subprocess.TimeoutExpired:
            process.kill()
            process.wait(timeout=5)


if __name__ == "__main__":
  raise SystemExit(main())
