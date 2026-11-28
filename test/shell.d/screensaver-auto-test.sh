#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
if ! python3 -c 'import pyte' >/dev/null 2>&1; then
  skip "automatic screensaver runtime tests require optional python-pyte"
  exit 0
fi

python3 - "$ROOT" <<'PY'
import fcntl
import importlib.util
import os
from pathlib import Path
import pty
import select
import shlex
import signal
import struct
import subprocess
import sys
import tempfile
import termios
import time

root = Path(sys.argv[1])
spec = importlib.util.spec_from_file_location("screensaver_auto", root / "default/omarchy/screensaver-auto.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
for marker in (module.IDLE, module.BUSY):
  for split in range(1, len(marker)):
    parser = module.Markers()
    parts = parser.feed(b"before" + marker[:split]) + parser.feed(marker[split:] + b"after")
    assert b"".join(data for kind, data in parts if kind == "output") == b"beforeafter"
    assert len([kind for kind, _ in parts if kind != "output"]) == 1
print("ok - shell lifecycle markers survive arbitrary PTY read boundaries")

with tempfile.TemporaryDirectory() as directory:
  home = Path(directory)
  tools = home / "bin"
  tools.mkdir()
  engine = tools / "ttfx"
  engine.write_text("#!/bin/bash\nprintf 'ANIMATION\\n'\nsleep .1\n")
  engine.chmod(0o755)
  package = tools / "omarchy-pkg-add"
  package.write_text("#!/bin/bash\nprintf '%s\\n' \"$*\" >> \"$HOME/packages\"\n")
  package.chmod(0o755)
  notify = tools / "omarchy-notification-send"
  notify.write_text("#!/bin/bash\nexit 0\n")
  notify.chmod(0o755)
  art = home / ".config/omarchy/branding/screensaver.txt"
  art.parent.mkdir(parents=True)
  art.write_text("TEST\n")
  (home / ".bashrc").write_text("PS1='READY> '\n")
  flag = home / ".local/state/omarchy/toggles/screensaver-task-on"
  env = dict(os.environ, HOME=directory, OMARCHY_PATH=str(root), XDG_CONFIG_HOME=str(home / ".config"),
             PATH=f"{tools}:{root / 'bin'}:{os.environ['PATH']}")
  toggle = str(root / "bin/omarchy-toggle-screensaver-task")
  subprocess.run([toggle], env=env, check=True)
  assert flag.exists() and (home / "packages").read_text() == "python-pyte\n"
  subprocess.run([toggle], env=env, check=True)
  assert not flag.exists()
  assert (home / "packages").read_text() == "python-pyte\n"
  flag.touch()
  print("ok - toggle installs its optional dependency only when enabling")

  def run_case(command, check, startup=None):
    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))
    original = termios.tcgetattr(slave)
    process = subprocess.Popen(startup or [str(root / "bin/omarchy-screensaver-auto"), "--idle-after", ".2"],
                               stdin=slave, stdout=slave, stderr=slave, env=env)
    output = bytearray()
    def read_for(seconds):
      deadline = time.monotonic() + seconds
      while time.monotonic() < deadline:
        if select.select([master], [], [], .02)[0]:
          output.extend(os.read(master, 65536))
    try:
      read_for(.4)
      assert b"READY>" in output, output
      output.clear()
      os.write(master, command.encode() + b"\r")
      check(master, output, read_for)
      os.write(master, b"exit\r")
      deadline = time.monotonic() + 5
      while process.poll() is None and time.monotonic() < deadline:
        read_for(.05)
      assert process.wait(timeout=1) == 0, output
      assert termios.tcgetattr(slave) == original
      assert not list(home.rglob("*.log"))
    finally:
      if process.poll() is None:
        process.send_signal(signal.SIGTERM)
        process.wait(timeout=3)
      os.close(master)
      os.close(slave)

  def completed(master, output, read_for):
    read_for(1.2)
    assert b"ANIMATION" in output
    assert b"\x1b[?1049h" in output and b"\x1b[?1049l" in output
    assert bytes(output).count(b"TASK-OUT\r\n") == 1
    assert bytes(output).count(b"TASK-DONE\r\n") == 1
    assert b"READY>" in output
  run_case("sleep .4; printf 'TASK-OUT\\n'; sleep .3; printf 'TASK-DONE\\n'", completed)
  print("ok - a normal command automatically animates, restores its output exactly once, and writes no task log")

  def prompt(master, output, read_for):
    read_for(.5)
    assert b"Proceed? [Y/n]" in output and b"ANIMATION" not in output
    os.write(master, b"y\r")
    read_for(.3)
  run_case("read -p 'Proceed? [Y/n] ' answer", prompt)
  print("ok - confirmation prompts remain visible and interactive")

  def activity(master, output, read_for):
    for _ in range(5):
      os.write(master, b"\x1b[<35;10;10M")
      read_for(.08)
    assert b"ANIMATION" not in output
    read_for(.35)
    assert b"ANIMATION" in output
    os.write(master, b"q")
    read_for(.1)
    assert b"\x1b[?1049l" in output
    read_for(.6)
    assert b"SURVIVED\r\n" in output
  run_case("sleep 1; printf 'SURVIVED\\n'", activity)
  print("ok - mouse activity resets inactivity and a key dismisses without cancelling")

  agent = """import os,socket,json,sys,time,tty
s=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM)
s.connect(os.environ['SCREENSAVER_CONTROL_SOCKET'])
def send(state):
 s.sendall((json.dumps({'pid':os.getpid(),'state':state})+'\\n').encode())
sys.stdout.write('\\x1b[?1049h\\x1b[2J\\x1b[HAGENT-WORKING')
sys.stdout.flush()
tty.setraw(0)
send('busy')
time.sleep(.8)
sys.stdout.write('\\x1b[HAGENT-PERMISSION?')
sys.stdout.flush()
send('waiting')
time.sleep(.7)
sys.stdout.write('\\x1b[HAGENT-IDLE')
sys.stdout.flush()
send('idle')
time.sleep(.6)
sys.stdout.write('\\x1b[?1049l')
sys.stdout.flush()
"""
  def agent_events(master, output, read_for):
    read_for(.5)
    assert b"ANIMATION" in output
    read_for(.65)
    assert b"AGENT-PERMISSION?" in output
    count = bytes(output).count(b"ANIMATION")
    read_for(.9)
    assert bytes(output).count(b"ANIMATION") == count
    assert b"AGENT-IDLE" in output
    read_for(.2)
  run_case(shlex.quote(sys.executable) + " -c " + shlex.quote("exec(" + repr(agent) + ")"), agent_events)
  print("ok - agent question and idle events stop animations while the TUI stays open")

  # Exercise the actual rc auto-start boundary, with unrelated init leaves stubbed.
  fake_root = home / "omarchy"
  bash_defaults = fake_root / "default/bash"
  bash_defaults.mkdir(parents=True)
  for name in ("envs", "shell", "aliases", "functions", "init", "inputrc"):
    (bash_defaults / name).write_text("")
  (fake_root / "default/omarchy").symlink_to(root / "default/omarchy", target_is_directory=True)
  env["OMARCHY_PATH"] = str(fake_root)
  (home / ".bashrc").write_text("PS1='READY> '\nsource " + shlex.quote(str(root / "default/bash/rc")) + "\nalias after=\"printf 'USER-ALIAS\\\\n'\"\n")
  def alias_after_rc(master, output, read_for):
    read_for(.4)
    assert b"USER-ALIAS\r\n" in output, output
  run_case("after", alias_after_rc, ["bash", "--rcfile", str(home / ".bashrc"), "-i"])
  print("ok - rc auto-start does not recurse and preserves user configuration after the default rc")
PY
