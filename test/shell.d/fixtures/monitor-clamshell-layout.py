"""Exercise the Bash writer and fixed Lua reader with automatic output placement."""
import fcntl
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path


def lua_value(value):
  if isinstance(value, str):
    return json.dumps(value, ensure_ascii=False)
  return str(value).lower()


def evaluate(code, monitors):
  enabled = [m for m in monitors if not m.get("disabled")]
  values = []
  for monitor in enabled:
    monitor = dict(monitor)
    monitor["refresh_rate"] = monitor.pop("refreshRate")
    values.append("{" + ",".join(f"[{lua_value(k)}]={lua_value(v)}" for k, v in monitor.items()) + "}")
  bridge = "local monitors = {" + ",".join(values) + "}\n" + r'''
hl = {
  get_monitors = function() return monitors end,
  get_monitor = function(name)
    for _, monitor in ipairs(monitors) do
      if monitor.name == name then return monitor end
    end
  end,
  monitor = function(rule)
    print(table.concat({rule.output, rule.position, rule.scale, rule.mode, rule.transform}, "\t"))
  end,
}
'''
  result = subprocess.run(["lua", "-"], input=bridge + code, text=True, capture_output=True, check=True)
  rules = {}
  for line in result.stdout.splitlines():
    name, position, scale, mode, transform = line.split("\t")
    assert name not in rules, "duplicate output rule"
    rules[name] = dict(position=position, scale=float(scale), mode=mode, transform=int(transform))
  return rules


def place(monitors, rules, reload):
  right = 0
  automatic = []
  for monitor in monitors:
    if monitor.get("disabled"):
      continue
    rule = rules.get(monitor["name"])
    if rule:
      width, height, refresh = re.fullmatch(r"(\d+)x(\d+)@([\d.]+)", rule["mode"]).groups()
      monitor.update(width=int(width), height=int(height), refreshRate=float(refresh),
             scale=rule["scale"], transform=rule["transform"])
    if (not rule and reload) or (rule and rule["position"] == "auto"):
      automatic.append(monitor)
    else:
      if rule:
        monitor["x"], monitor["y"] = map(int, rule["position"].split("x"))
      width = monitor["height"] if monitor["transform"] % 2 else monitor["width"]
      right = max(right, monitor["x"] + round(width / monitor["scale"]))
  for monitor in automatic:
    monitor["x"], monitor["y"] = right, 0
    width = monitor["height"] if monitor["transform"] % 2 else monitor["width"]
    right += round(width / monitor["scale"])


def hyprctl(args):
  path = Path(os.environ["OMARCHY_TEST_MONITORS"])
  monitors = json.loads(path.read_text())
  state = Path(os.environ["HOME"]) / ".local/state/omarchy/toggles/hypr"
  rules = {}
  if args == ["monitors", "all", "-j"]:
    print(json.dumps(monitors))
    return
  with open(os.environ["OMARCHY_TEST_LOG"], "a") as log:
    log.write(args[0] + "\n")
  if args[0] == "reload":
    for monitor in monitors:
      if monitor["name"] == "eDP-1":
        monitor["disabled"] = (state / "internal-monitor-clamshell.lua").exists()
    toggle = state / "internal-monitor-position.lua"
    if toggle.exists():
      rules = evaluate("dofile(" + lua_value(str(toggle)) + ")", monitors)
  elif args[0] == "eval":
    rules = evaluate(args[1], monitors)
  elif args[0] != "dispatch":
    raise AssertionError(args)
  if args[0] != "dispatch":
    with open(os.environ["OMARCHY_TEST_LOG"], "a") as log:
      log.write(f"rules {len(rules)}\n")
    place(monitors, rules, args[0] == "reload")
    path.write_text(json.dumps(monitors))


def tests(root):
  with tempfile.TemporaryDirectory() as temporary:
    temporary = Path(temporary)
    home = temporary / "home"
    state = home / ".local/state/omarchy/toggles/hypr"
    config = home / ".config/hypr/monitors.lua"
    config.parent.mkdir(parents=True)
    stub = temporary / "bin"
    stub.mkdir()
    commands = {"hyprctl": f'exec python3 "{Path(__file__).resolve()}" hyprctl "$@"',
          "mv": r'''/usr/bin/mv "$@" || exit
case ${*: -1} in
  */internal-monitor-position|*/internal-monitor-position-pending)
    if [[ ${OMARCHY_TEST_CAPTURE_RELOAD:-0} == "1" && -f $HOME/.local/state/omarchy/toggles/hypr/internal-monitor-position.lua ]]; then
      printf 'capture-reload\n' >>"$OMARCHY_TEST_LOG"
      hyprctl reload
    fi
    ;;
esac''',
          "omarchy-hyprland-monitor-laptop": "echo eDP-1",
          "omarchy-hyprland-monitor-external-active": "exit 0",
          "omarchy-hw-clamshell": '[[ ${OMARCHY_TEST_CLOSED:-0} == "1" ]]',
          "omarchy-hyprland-monitor-internal": "exit 0",
          "omarchy-hyprland-monitor-internal-mirror": "exit 0"}
    for name, content in commands.items():
      path = stub / name
      path.write_text("#!/bin/bash\n" + content + "\n")
      path.chmod(0o755)
    data = temporary / "monitors.json"
    log = temporary / "calls.log"
    env = dict(os.environ, HOME=str(home), PATH=str(stub) + ":" + os.environ["PATH"],
         OMARCHY_TEST_MONITORS=str(data), OMARCHY_TEST_LOG=str(log))
    script = root / "bin/omarchy-hyprland-monitor-clamshell"
    panel = dict(name="eDP-1", description="Laptop", serial="", width=1920, height=1080,
          scale=2, transform=0, refreshRate=60, x=0, y=0, disabled=False)
    external = dict(name="HDMI-A-1", description="External", make="Acme", model="Monitor", serial="serial", width=1280,
            height=800, scale=1, transform=0, refreshRate=60, x=960, y=0, disabled=False)

    def reset(monitors=None):
      shutil.rmtree(state, ignore_errors=True)
      config.write_text('local omarchy_monitor_scale = "auto"\nhl.monitor({ output = "", scale = omarchy_monitor_scale })\n\n')
      data.write_text(json.dumps(monitors or [external, panel]))
      log.write_text("")

    def run(closed=False, capture_reload=False):
      subprocess.run([str(script)], env=dict(env, OMARCHY_TEST_CLOSED="1" if closed else "0",
        OMARCHY_TEST_CAPTURE_RELOAD="1" if capture_reload else "0"), check=True)

    def reload():
      subprocess.run([str(stub / "hyprctl"), "reload"], env=env, check=True)

    def current():
      return json.loads(data.read_text())

    def same(expected):
      assert current() == expected, (current(), expected)
      assert int(re.findall(r"rules (\d+)", log.read_text())[-1]) == len(expected), "every output needs an explicit rule"
      assert (state / "internal-monitor-position.lua").exists(), "arrangement toggle must exist"

    def passed(label):
      print("ok - " + label, flush=True)

    # Reload exactly after publishing the second dock's snapshot, while the
    # previous cycle's toggle still exists. It must not consume the new record.
    for x, y, ex in [(0, 0, 960), (1280, 0, 0), (0, 800, 0)]:
      reset([dict(external, x=ex), dict(panel, x=x, y=y)])
      expected = current()
      run(True)
      run()
      same(expected)
      log.write_text("")
      run(True, capture_reload=True)
      assert "capture-reload" in log.read_text(), "reload must land during snapshot publication"
      run()
      same(expected)
      reload()
      same(expected)
      passed(f"external reload during dock preserves the next restore at {x}x{y}")

    # Identical outputs must work even when no external can anchor an offset.
    twin = dict(external, name="DP-1", serial="", x=2240)
    reset([dict(external, serial=""), twin, panel])
    expected = current()
    run(True)
    assert (state / "internal-monitor-position-pending").exists(), "identical outputs need a snapshot"
    run()
    same(expected)
    passed("exact snapshots restore identical external monitors without serials")

    for x, y, ex in [(0, 0, 960), (1280, 0, 0), (0, 800, 0), (-960, -540, 0)]:
      reset([dict(external, x=ex), dict(panel, x=x, y=y)])
      expected = current()
      for cycle in range(2):
        run(True)
        assert current()[1]["disabled"], "dock must disable the panel"
        run()
        same(expected)
        for _ in range(3):
          reload()
          same(expected)
      passed(f"exact layout {x}x{y} survives two dock cycles and repeated reloads")

    # The right-hand layout already matches auto. Rule counts must still
    # reject missing/empty code instead of accepting a vacuous success.
    for missing in (False, True):
      reset([dict(external, x=0), dict(panel, x=1280)])
      expected = current()
      run(True)
      run()
      toggle = state / "internal-monitor-position.lua"
      toggle.unlink() if missing else toggle.write_text("")
      reload()
      try:
        same(expected)
      except AssertionError:
        pass
      else:
        raise AssertionError("missing/empty toggle must fail the layout assertions")
    passed("right-hand placement checks reject missing and empty toggles")

    reset()
    run(True)
    pending = state / "internal-monitor-position-pending"
    captured = pending.read_bytes()
    assert pending.stat().st_mode & 0o777 == 0o600
    assert not (state / "internal-monitor-position").exists(), "docked snapshots must remain unarmed"
    run(True)
    assert pending.read_bytes() == captured, "disabled polls must retain the snapshot"
    run()
    persisted = state / "internal-monitor-layout"
    assert not pending.exists() and persisted.read_bytes() == captured
    assert not (state / "internal-monitor-position").exists(), "restoration must consume the armed record"
    assert persisted.stat().st_mode & 0o777 == 0o600
    passed("private atomic snapshot survives docked polls and is consumed unchanged")

    # Exact restoration deliberately undoes moves made while docked.
    reset()
    expected = current()
    run(True)
    moved = current()
    moved[0]["x"] = 2500
    data.write_text(json.dumps(moved))
    run()
    same(expected)
    passed("undock restores pre-dock coordinates after externals move while docked")

    reset()
    expected = current()
    run(True)
    log.write_text("")
    with (state / "internal-monitor-clamshell.lock").open("w") as lock:
      fcntl.flock(lock, fcntl.LOCK_EX)
      callers = [subprocess.Popen([str(script)], env=dict(env, OMARCHY_TEST_CLOSED="0")) for _ in range(2)]
      time.sleep(0.1)
      assert not log.read_text(), "callers must wait for the transaction lock"
      fcntl.flock(lock, fcntl.LOCK_UN)
      for caller in callers:
        assert caller.wait(timeout=10) == 0
    assert log.read_text().splitlines().count("reload") == 1
    same(expected)
    passed("concurrent undocks share one capture/reload/restore transaction")

    reset()
    state.mkdir(parents=True)
    (state / "internal-monitor-disable.lua").touch()
    run(True)
    assert not (state / "internal-monitor-position-pending").exists()
    assert not (state / "internal-monitor-scale").exists()
    passed("manual disable prevents clamshell capture")

    reset([external, dict(panel, x=0.5)])
    run(True)
    assert not (state / "internal-monitor-position-pending").exists()
    passed("non-integer compositor coordinates are never captured")

    reset()
    config.write_text('hl.monitor({ output = "eDP-1", position = "0x0", scale = "auto" })\n')
    run(True)
    run()
    assert not (state / "internal-monitor-position.lua").exists()
    assert not (state / "internal-monitor-position-pending").exists()
    passed("explicit panel positions take precedence over saved layouts")

    for scale, width in [(1.3333334, 1440), (1.6666666, 1152)]:
      reset([dict(external, x=width), dict(panel, scale=scale)])
      expected = current()
      run(True)
      run()
      same(expected)
      reload()
      same(expected)
    passed("fractional scales restore touching output edges without overlap")

    reset([dict(external, x=720, transform=1), dict(panel, width=1280, height=720, scale=1, transform=1)])
    expected = current()
    run(True)
    run()
    same(expected)
    reload()
    same(expected)
    passed("snapshot rules preserve non-preferred modes and both output rotations")

    for key, value in [("name", "DP-2"), ("serial", "different"), ("description", "Other"),
             ("width", 3840), ("height", 2160), ("scale", 2),
             ("transform", 1), ("refreshRate", 120), ("removed", None), ("added", None)]:
      reset()
      run(True)
      monitors = current()
      if key == "removed":
        monitors.pop(0)
      elif key == "added":
        monitors.append(dict(external, name="DP-2"))
      else:
        monitors[0][key] = value
      data.write_text(json.dumps(monitors))
      run()
      assert not any((state / name).exists() for name in
             ["internal-monitor-position-pending", "internal-monitor-position", "internal-monitor-layout", "internal-monitor-position.lua"]), key
    passed("changed connectors, identities, geometry and output sets discard pending snapshots")

    for key, value in [("x", 200), ("y", 200), ("scale", 2), ("width", 3840), ("serial", "different")]:
      reset()
      run(True)
      run()
      monitors = current()
      monitors[0][key] = value
      data.write_text(json.dumps(monitors))
      reload()
      assert not (state / "internal-monitor-position.lua").exists(), key
    passed("manual moves and monitor changes retire persisted layouts on reload")

    for flag in ["internal-monitor-disable", "internal-monitor-mirror", "internal-monitor-clamshell"]:
      reset()
      run(True)
      run()
      (state / (flag + ".lua")).touch()
      reload()
      assert not (state / "internal-monitor-position.lua").exists(), flag
    passed("manual disable, mirror and clamshell toggles take precedence")

    for docked in [False, True]:
      reset()
      run(True)
      if not docked:
        run()
      config.write_text(config.read_text().replace('"auto"', '3'))
      run()
      assert not (state / "internal-monitor-position.lua").exists()
      assert not (state / "internal-monitor-position-pending").exists()
      assert not (state / "internal-monitor-layout").exists()
    passed("config edits during docking or before scale correction discard the original snapshot")

    for corruption in ["version", "count", "columns", "coordinate", "dimension", "scale", "overlap", "config", "missing"]:
      reset()
      run(True)
      lines = pending.read_text().splitlines(keepends=True)
      if corruption == "version":
        lines[0] = "99\n"
      elif corruption == "count":
        lines[2] = "1e99\n"
      elif corruption == "columns":
        lines[3] = "unsafe code();\n"
      elif corruption in ["coordinate", "dimension", "scale", "overlap"]:
        fields = lines[3].rstrip("\n").split("\t")
        index = {"coordinate": 7, "dimension": 3, "scale": 5, "overlap": 7}[corruption]
        fields[index] = "0" if corruption in ["scale", "overlap"] else "1e99"
        lines[3] = "\t".join(fields) + "\n"
      elif corruption == "config":
        lines.append("changed\n")
      pending.write_text("".join(lines))
      if corruption == "missing":
        pending.unlink()
      before = len(log.read_text())
      run()
      counts = re.findall(r"^rules (\d+)$", log.read_text()[before:], re.MULTILINE)
      assert counts and all(int(count) == 0 for count in counts), f"{corruption} emitted rules: {counts}"
      assert not (state / "internal-monitor-position.lua").exists(), corruption
    passed("unsafe, incomplete, overlapping and unsupported records never apply")


if __name__ == "__main__":
  if len(sys.argv) > 1 and sys.argv[1] == "hyprctl":
    hyprctl(sys.argv[2:])
  else:
    tests(Path(os.environ["OMARCHY_PATH"]))
