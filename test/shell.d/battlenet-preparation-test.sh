#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

python3 - "$ROOT" <<'PY'
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile
import time

root = Path(sys.argv[1])
installer = root / "bin/omarchy-install-gaming-battlenet"
real_tee = shutil.which("tee")


def check(condition, description):
  if not condition:
    raise AssertionError(description)
  print(f"ok - {description}", flush=True)


mock_source = r'''
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

command = Path(sys.argv[1]).name
args = sys.argv[2:]
case = Path(os.environ["BATTLE_TEST_CASE"])

def record(event):
  with (case / "events").open("a") as output:
    output.write(json.dumps(event) + "\n")

if command == "umu-run":
  signal.signal(signal.SIGINT, lambda *_: sys.exit(130))
  preparation = args == ["wineboot", "--init"]
  record({"stage": "prepare" if preparation else "wizard", "args": args,
      "env": {key: os.environ.get(key) for key in
          ("WINEPREFIX", "PROTONPATH", "GAMEID", "PROTON_VERB")}})
  if preparation:
    print("Downloading runtime fixture", flush=True)
    print("Initializing prefix fixture", file=sys.stderr, flush=True)
    (case / "started").touch()
    if os.environ.get("BATTLE_TEST_WAIT"):
      while not (case / "release").exists():
        time.sleep(0.01)
    sys.exit(int(os.environ.get("BATTLE_TEST_PREP_STATUS", "0")))
  assert args == [str(Path.home() / ".cache/omarchy/Battle.net-Setup.exe")], args
  print("Wizard fixture started", flush=True)
elif command == "tee":
  assert args == ["/tmp/omarchy-battlenet-installer.log"], args
  if os.environ.get("BATTLE_TEST_LOG_FAILURE"):
    sys.stdin.buffer.read()
    print("fixture: cannot write installer log", file=sys.stderr)
    sys.exit(74)
  os.execv(os.environ["BATTLE_TEST_REAL_TEE"], ["tee", str(case / "installer.log")])
elif command == "setsid":
  record({"stage": "detach"})
  if os.environ.get("BATTLE_TEST_LAUNCH_FAILURE"):
    sys.exit(71)
  # Keep this test synchronous and redirect its detached log into the fixture.
  # Execute the real shell command so path quoting is exercised as well.
  assert args[0] == "-f", args
  assert args[-1] == "/tmp/omarchy-battlenet-installer.log", args
  args[-1] = str(case / "installer.log")
  sys.exit(subprocess.call(args[1:]))
elif command == "gum":
  record({"stage": "confirm"})
  sys.exit(1)
elif command == "pkill":
  raise AssertionError("declining a retry must not kill prefix processes")
'''

with tempfile.TemporaryDirectory(prefix="omarchy-battlenet-test-") as scratch:
  scratch = Path(scratch)
  mock_bin = scratch / "bin"
  mock_bin.mkdir()
  mock = mock_bin / "fixture.py"
  mock.write_text(mock_source)
  for command in ("umu-run", "tee", "setsid", "gum", "pkill",
          "omarchy-pkg-add", "omarchy-install-gaming-gpu-lib32",
          "curl", "update-desktop-database", "omarchy-i18n"):
    path = mock_bin / command
    path.write_text('#!/bin/bash\nexec python3 "${BATTLE_TEST_MOCK}" "$0" "$@"\n')
    path.chmod(0o755)

  def setup(name, **overrides):
    case = scratch / name
    home = case / "home O'Brien"
    home.mkdir(parents=True)
    env = dict(os.environ, HOME=str(home), OMARCHY_PATH=str(root),
         PATH=f"{mock_bin}:{os.environ['PATH']}",
         BATTLE_TEST_CASE=str(case), BATTLE_TEST_MOCK=str(mock),
         BATTLE_TEST_REAL_TEE=real_tee, **overrides)
    return case, home, env

  def events(case):
    path = case / "events"
    return [json.loads(line) for line in path.read_text().splitlines()] if path.exists() else []

  def run(env):
    return subprocess.run(["bash", str(installer)], env=env, text=True,
               stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=15)

  def wait_for(predicate, process):
    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
      if predicate():
        return
      if process.poll() is not None:
        raise AssertionError(f"installer exited early: {process.returncode}")
      time.sleep(0.01)
    raise AssertionError("timed out waiting for installer output")

  def interactive_case(name, cancel=False):
    case, home, env = setup(name, BATTLE_TEST_WAIT="1")
    output = case / "output"
    with output.open("w") as stream:
      process = subprocess.Popen(["bash", str(installer)], env=env,
                   stdout=stream, stderr=stream, start_new_session=True)
      try:
        wait_for(lambda: "Initializing prefix fixture" in output.read_text(), process)
        check(not any(event["stage"] == "detach" for event in events(case)),
           "wizard launch waits for preparation to finish")
        check("Initializing prefix fixture" in (case / "installer.log").read_text(),
           "preparation output is visible and logged before the process finishes")
        if cancel:
          os.killpg(process.pid, signal.SIGINT)
        else:
          (case / "release").touch()
        status = process.wait(timeout=10)
      finally:
        if process.poll() is None:
          os.killpg(process.pid, signal.SIGKILL)
          process.wait()
    if cancel:
      check(status == 130 and not any(event["stage"] == "detach" for event in events(case)),
         "Ctrl-C cancels preparation with status 130 and never launches the wizard")
      check("Preparation complete." not in output.read_text(), "cancelled preparation does not report completion")
    else:
      check(status == 0, "successful preparation launches the installer")
      calls = [event for event in events(case) if event["stage"] in ("prepare", "wizard")]
      check([event["stage"] for event in calls] == ["prepare", "wizard"]
         and calls[0]["env"] == calls[1]["env"],
         "preparation and wizard share the same environment and preserve quoted paths")
      check("Wizard fixture started" in (case / "installer.log").read_text(),
         "wizard output appends to the preparation log")
      check("Preparation complete. Launching the setup wizard..." in output.read_text()
         and (home / ".local/share/applications/battlenet.desktop").is_file(),
         "successful handoff installs the shortcut and displays the agreed English message")
      check(output.read_text().split("Preparation complete. Launching the setup wizard...", 1)[1].strip() == "",
          "successful handoff has no additional explanatory text")

  interactive_case("success")
  interactive_case("cancel", cancel=True)

  for name, options, expected in (
    ("prepare-failure", {"BATTLE_TEST_PREP_STATUS": "23"}, 23),
    ("log-failure", {"BATTLE_TEST_LOG_FAILURE": "1"}, 74),
    ("launch-failure", {"BATTLE_TEST_LAUNCH_FAILURE": "1"}, 71),
  ):
    case, home, env = setup(name, **options)
    result = run(env)
    check(result.returncode == expected and "Preparation complete." not in result.stdout,
       f"{name} returns failure without reporting completion")
    if name != "launch-failure":
      check(not any(event["stage"] == "detach" for event in events(case))
         and "See /tmp/omarchy-battlenet-installer.log" in result.stdout,
         f"{name} reports the log path and never launches the wizard")

  case, home, env = setup("already-installed")
  launcher = home / "Games/battlenet/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"
  launcher.parent.mkdir(parents=True)
  launcher.touch()
  result = run(env)
  check(result.returncode == 0 and not events(case), "already installed Battle.net skips preparation and wizard launch")

  case, home, env = setup("retry", BATTLE_TEST_PREP_STATUS="23")
  check(run(env).returncode == 23, "failed preparation can be retried")
  prefix = home / "Games/battlenet"
  sentinel = prefix / "keep-me"
  sentinel.touch()
  (case / "events").unlink()
  result = run(env)
  check(result.returncode == 1 and sentinel.exists()
     and [event["stage"] for event in events(case)] == ["confirm"],
     "declining a partial-prefix retry preserves existing files and stops installation")
PY
