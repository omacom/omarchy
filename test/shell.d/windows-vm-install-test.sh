#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

python3 - <<'PY'
import json
import os
from pathlib import Path
import signal
import subprocess
import tempfile
import time

root = Path(os.environ["ROOT"])
with tempfile.TemporaryDirectory(prefix="omarchy-windows-install-") as scratch:
  scratch = Path(scratch)
  home = scratch / "home"
  applications = home / ".local/share/applications"
  applications.mkdir(parents=True)
  mock_bin = scratch / "bin"
  mock_bin.mkdir()
  browser_state = scratch / "browser.json"
  browser_stop = scratch / "stop"
  installer_done = scratch / "installed"

  def executable(name, body):
    path = mock_bin / name
    path.write_text(body)
    path.chmod(0o755)
    return path

  browser = executable("test-browser", '''#!/usr/bin/env python3
import json, os, sys, time
from pathlib import Path
if "--help" in sys.argv:
  sys.exit(0)
state_file = Path(os.environ["TEST_BROWSER_STATE"])
pending_state = state_file.with_suffix(".tmp")
pending_state.write_text(json.dumps({
  "pid": os.getpid(), "pgid": os.getpgrp(),
  "fds": [os.readlink(f"/proc/self/fd/{fd}") for fd in range(3)]
}))
pending_state.replace(state_file)
print("browser-output-must-not-reach-installer", flush=True)
print("browser-errors-must-not-reach-installer", file=sys.stderr, flush=True)
while not Path(os.environ["TEST_BROWSER_STOP"]).exists():
  time.sleep(0.02)
''')
  applications.joinpath("test-browser.desktop").write_text(f"[Desktop Entry]\nExec={browser} %U\n")
  executable("xdg-settings", "#!/bin/bash\nprintf '%s\\n' test-browser.desktop\n")
  executable("xdg-open", '#!/bin/bash\nexec test-browser "$@"\n')
  executable("uwsm-app", '#!/bin/bash\nshift\nexec "$@"\n')

  # Model the external service manager, not the browser launcher under test:
  # it starts the requested command independently with disconnected stdio.
  executable("systemd-run", '''#!/usr/bin/env python3
import subprocess, sys
args = sys.argv[1:]
while args and args[0].startswith("--"):
  args.pop(0)
subprocess.Popen(args, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                 stderr=subprocess.DEVNULL, start_new_session=True)
''')

  # Exercise the real install flow and real omarchy-launch-browser. Only the
  # interactive setup, package installation, and VM provisioning are stubbed.
  driver = '''
set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null
check_prerequisites() { :; }
omarchy-pkg-add() { :; }
available_storage_gb() { echo 128; }
write_compose() { :; }
priv() { [[ $1 == up ]]; }
sleep() { :; }
timedatectl() { echo UTC; }
gum() {
  case "$1" in
    choose)
      for arg in "$@"; do
        if [[ $arg == --selected=* ]]; then printf '%s\\n' "${arg#*=}"; return; fi
      done
      ;;
    input)
      case "$*" in
        *username*) echo alice ;;
        *password*) echo test-password ;;
        *) echo 2 ;;
      esac
      ;;
    confirm|style) return 0 ;;
  esac
}
install_windows
status=$?
((status == 0)) || exit "$status"
: > "$TEST_INSTALLER_DONE"
'''
  env = dict(os.environ, HOME=str(home), PATH=f"{mock_bin}:{root / 'bin'}:{os.environ['PATH']}",
             OMARCHY_WINDOWS_DIR=str(scratch / "runtime"), HYPRLAND_INSTANCE_SIGNATURE="",
             TEST_BROWSER_STATE=str(browser_state), TEST_BROWSER_STOP=str(browser_stop),
             TEST_INSTALLER_DONE=str(installer_done))
  process = subprocess.Popen(["bash", "-c", driver], env=env, stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE, text=True, start_new_session=True)
  try:
    try:
      stdout, stderr = process.communicate(timeout=5)
    except subprocess.TimeoutExpired:
      raise SystemExit("not ok - installer waits for the progress browser to exit")
    if process.returncode or not installer_done.exists():
      raise SystemExit(f"not ok - installer did not complete: {stdout}\n{stderr}")
    deadline = time.monotonic() + 5
    while not browser_state.exists() and time.monotonic() < deadline:
      time.sleep(0.02)
    if not browser_state.exists():
      raise SystemExit("not ok - progress browser did not start")
    state = json.loads(browser_state.read_text())
    os.kill(state["pid"], 0)
    if state["pgid"] == process.pid or state["fds"] != ["/dev/null"] * 3:
      raise SystemExit("not ok - progress browser remains attached to the installer terminal")
    if "browser-output-must-not-reach-installer" in stdout or "browser-errors-must-not-reach-installer" in stderr:
      raise SystemExit("not ok - browser diagnostics leaked into installer output")
    print("ok - installer completes while the progress browser remains alive and detached")
  finally:
    browser_stop.touch()
    if process.poll() is None:
      os.killpg(process.pid, signal.SIGKILL)
      process.communicate()
    if browser_state.exists():
      try:
        os.kill(json.loads(browser_state.read_text())["pid"], signal.SIGTERM)
      except ProcessLookupError:
        pass
PY
