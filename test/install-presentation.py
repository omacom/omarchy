"""Exercise real dashboard/worker lifecycle with a fake package manager."""
import fcntl
import importlib.util
import os
from pathlib import Path
import pty
import select
import signal
import struct
import subprocess
import sys
import tempfile
import termios
import time

ROOT = Path(__file__).resolve().parents[1]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / "default/install-presentation"))
SCRIPT = ROOT / "default/install-presentation/dashboard.py"
spec = importlib.util.spec_from_file_location("dashboard", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

p = module.Progress()
p.feed(":: Retrieving packages...")
assert p.target == 30
for _ in range(50):
  p.feed("unrecognized download output")
assert p.target == 30, "unknown output must not advance work"
p.feed(" Total (1/2) 5 MiB 1 MiB/s 00:05 [#####     ] 50%")
assert 30 < p.target < 120
download_target = p.target
p.feed(" alpha 5 MiB 1 MiB/s 00:05 [##########] 100%")
assert p.target == download_target, "single-file completion is not total download completion"
p.feed("(1/2) installing alpha")
first = p.target
p.feed("(2/2) installing beta")
assert first < p.target < 380
p.feed(":: Running post-transaction hooks...")
assert p.target < 380
assert module.clean("hello\033]0;injected\x07\033[31m world") == "hello world"
print("ok - progress follows work and reserves completion for successful exit")

with tempfile.TemporaryDirectory() as tmp:
  base = Path(tmp)
  mock = base / "bin"
  mock.mkdir()
  (mock / "pacman").write_text('''#!/bin/bash
if [[ $1 == -Q ]]; then test -f "$FIXTURE/installed"; exit; fi
[[ $MODE == cancel ]] && trap 'echo interrupted; exit 130' INT
echo ':: Retrieving packages...'
printf ' Total (1/2) 5 MiB 1 MiB/s 00:05 [#####     ] 50%%\\r'
sleep .2
echo '(1/2) installing alpha'
sleep .2
if [[ $MODE == failure ]]; then echo 'error: signature could not be verified'; exit 1; fi
if [[ $MODE == cancel ]]; then
  while true; do sleep .1; done
fi
echo '(2/2) installing beta'
echo ':: Running post-transaction hooks...'
touch "$FIXTURE/installed"
''')
  (mock / "sudo").write_text('''#!/bin/bash
printf '%s\\n' "$*" >>"$FIXTURE/sudo.log"
if [[ $1 == -v ]]; then
  echo 'Authentication visible'
  [[ $MODE == denied ]] && exit 1
  exit 0
fi
if [[ $1 == -n ]]; then shift; fi
if [[ $MODE == gum ]]; then
  choice=$(gum choose --header 'Choose setup mode' Standard Custom)
  [[ $choice == Custom ]] || exit 1
fi
if [[ $MODE == plain ]]; then
  echo 'Enter setup choice'
  read -r choice
  [[ $choice == $'one\\ttwo' ]] || exit 1
fi
if [[ $MODE == tui ]]; then
  printf '\\033[6n'
  read -rsd R response
fi
if [[ $MODE == prompt ]]; then
  printf 'Password: '
  read -rs secret
  echo
  [[ $secret == test-secret ]] || exit 1
fi
exec "$@"
''')
  for path in mock.iterdir():
    path.chmod(0o755)
  env = dict(os.environ, PATH=f"{mock}:{ROOT}/bin:{os.environ['PATH']}",
             FIXTURE=tmp, TERM="xterm-256color", XDG_STATE_HOME=tmp)

  def run(mode, interactive=False):
    (base / "installed").unlink(missing_ok=True)
    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 42, 90, 0, 0))
    before = termios.tcgetattr(slave)
    def session():
      os.setsid()
      fcntl.ioctl(0, termios.TIOCSCTTY, 0)
    child = subprocess.Popen(["python3", str(SCRIPT), "--name", "Example App", "--packages", "alpha beta",
                              "--command", "omarchy-pkg-add alpha beta"] + (["--interactive"] if interactive else []),
                             stdin=slave, stdout=slave, stderr=slave, preexec_fn=session,
                             env=dict(env, MODE=mode))
    output = b""
    interrupted = False
    answered = False
    closed = False
    resized = False
    deadline = time.monotonic() + 12
    try:
      while child.poll() is None and time.monotonic() < deadline:
        if select.select([master], [], [], .1)[0]:
          output += os.read(master, 65536)
        if mode == "plain" and b"Enter setup choice" in output and not answered:
          os.write(master, b"one\ttwo\r")
          answered = True
        if mode == "gum" and b"Choose setup mode" in output and not answered:
          os.write(master, b"\x1b[B\r")
          answered = True
        if mode == "tui" and b"\x1b[6n" in output and not answered:
          os.write(master, b"\x1b[1;1R")
          answered = True
        if mode == "prompt" and b"Password:" in output and not answered:
          os.write(master, b"test-secret\r")
          answered = True
        if b"Installing packages" in output and not resized:
          fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 22, 55, 0, 0))
          if not interactive:
            os.write(master, b"d")
          resized = True
        if mode == "cancel" and b"Installing packages" in output and not interrupted:
          os.write(master, b"\x03")
          interrupted = True
        if b"Enter  Close" in output and not closed:
          os.write(master, b"\r")
          closed = True
      assert child.poll() is not None, (mode, output.decode(errors="replace"))
      while select.select([master], [], [], .1)[0]:
        output += os.read(master, 65536)
      expected = 0 if mode in ("success", "prompt", "tui", "gum", "plain") else 130 if mode == "cancel" else 1
      assert child.returncode == expected, (mode, child.returncode, output)
      assert (b"Example App installed" in output) == (mode in ("success", "prompt", "tui", "gum", "plain")), output
      if mode == "prompt" and interactive and os.geteuid() != 0:
        assert b"Use the controls above" in output and b"Interactive terminal" not in output
        assert b"test-secret" not in output, "password leaked to display"
      if interactive:
        assert b"Tab  Setup controls" not in output and b"Ctrl+]  Progress" not in output
        assert b"Total (1/2)" in output, "download output must be visible without toggling views"
        assert b"Interactive terminal" not in output
      if mode == "gum" and os.geteuid() != 0:
        assert answered and b"Use the controls above" in output
      if mode == "denied":
        assert b"authorization was not completed" in output and b"\x1b[?1049h" not in output
        assert not (base / "installed").exists()
      else:
        assert b"\x1b[?1049l" in output and b"\x1b[?25h" in output
      assert termios.tcgetattr(slave) == before, "terminal mode was not restored"
      logs = list((base / "omarchy/installs").glob("*.log"))
      assert logs and all(path.stat().st_mode & 0o077 == 0 for path in logs)
      assert all("Authentication visible" not in path.read_text() and "test-secret" not in path.read_text() for path in logs)
      print(f"ok - {mode}: real worker, exit status, private logs, resize, terminal restoration")
    finally:
      if child.poll() is None:
        os.killpg(child.pid, signal.SIGKILL)
        child.wait()
      os.close(master)
      os.close(slave)

  for mode in ("success", "failure", "cancel"):
    run(mode)
  if os.geteuid() != 0:
    run("denied")

  for mode in ("success", "failure", "cancel", "prompt", "tui", "gum", "plain"):
    run(mode, interactive=True)

  # Non-TTY invocation must preserve ordinary output and the command's status.
  result = subprocess.run(["python3", str(SCRIPT), "--name", "Example", "--packages", "alpha",
                           "--command", "printf 'plain output'; exit 7"], capture_output=True, env=env)
  assert result.returncode == 7 and result.stdout == b"plain output"
  print("ok - redirected output has no terminal escapes and preserves failure status")
