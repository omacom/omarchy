"""Exercise real dashboard/worker lifecycle with a fake package manager."""
import fcntl
import importlib.util
import os
from pathlib import Path
import pty
import select
import signal
import shutil
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
echo "$*" >>"$FIXTURE/transactions"
"$FIXTURE/bin/interactive-fixture" || exit 1
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
exec "$@"
''')
  # Run these in the worker regardless of whether omarchy-pkg-add uses sudo.
  (mock / "interactive-fixture").write_text('''#!/bin/bash
if [[ $MODE == gum ]]; then
  choice=$(gum choose --header 'Choose setup mode' Standard Custom)
  [[ $choice == Custom ]] || exit 1
  echo gum >"$FIXTURE/answered"
fi
if [[ $MODE == plain ]]; then
  echo 'Enter setup choice'
  read -r choice
  [[ $choice == $'one\\ttwo' ]] || exit 1
  echo plain >"$FIXTURE/answered"
fi
if [[ $MODE == tui ]]; then
  saved=$(stty -g)
  stty -echo -icanon min 1 time 0
  printf '\\033[6n'
  read -rsd R -t 3 response
  stty "$saved"
  [[ $response == $'\\033[1;1' ]] || exit 1
  echo tui >"$FIXTURE/answered"
fi
if [[ $MODE == prompt ]]; then
  printf 'Password: '
  read -rs secret
  echo
  [[ $secret == test-secret ]] || exit 1
  echo prompt >"$FIXTURE/answered"
fi
if [[ $MODE == log ]]; then
  echo 'EARLY OUTPUT TO REVIEW'
  for ((i=0; i<100; i++)); do echo "Output line $i"; done
  echo 'Review output before answering'
  # Emit more than a PTY buffer while the log viewer is still open.
  while [[ ! -f $FIXTURE/viewer-open ]]; do sleep .05; done
  for ((i=0; i<10000; i++)); do echo "Worker remains active $i"; done
  echo 'Enter l to continue'
  read -r choice
  [[ $choice == l && -f $FIXTURE/viewer-open ]] || exit 1
  echo log >"$FIXTURE/answered"
fi
exit 0
''')
  (mock / "xdg-terminal-exec").write_text('''#!/bin/bash
printf '%s\\n' "$@" >"$FIXTURE/viewer-args"
cp "${@: -1}" "$FIXTURE/viewer-log"
touch "$FIXTURE/viewer-open"
for ((i=0; i<200; i++)); do
  [[ -f $FIXTURE/answered ]] && exit 0
  sleep .05
done
exit 1
''')
  for path in mock.iterdir():
    path.chmod(0o755)
  env = dict(os.environ, PATH=f"{mock}:{ROOT}/bin:{os.environ['PATH']}",
             FIXTURE=tmp, TERM="xterm-256color", XDG_STATE_HOME=tmp)

  def run(mode, interactive=False):
    (base / "installed").unlink(missing_ok=True)
    (base / "answered").unlink(missing_ok=True)
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
    log_opened = False
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
        if mode == "log" and b"Review output before answering" in output and not log_opened:
          os.write(master, b"\x07")
          log_opened = True
        if mode == "log" and b"Enter l to continue" in output and not answered:
          os.write(master, b"l\r")
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
      expected = 0 if mode in ("success", "prompt", "tui", "gum", "plain", "log") else 130 if mode == "cancel" else 1
      assert child.returncode == expected, (mode, child.returncode, output)
      assert (b"Example App installed" in output) == (expected == 0), output
      if mode in ("prompt", "tui", "gum", "plain", "log"):
        assert (base / "answered").read_text().strip() == mode, "worker did not validate its input"
        if mode != "tui":
          assert answered, "test never answered the prompt"
      if mode == "tui":
        assert b"\x1b[6n" not in output, "terminal query escaped to host instead of receiving an embedded reply"
      if mode == "prompt" and interactive:
        assert b"Ctrl+G  Full log" in output and b"Interactive terminal" not in output
        assert b"test-secret" not in output, "password leaked to display"
      if interactive:
        assert b"Tab  Setup controls" not in output and b"Ctrl+]  Progress" not in output
        assert b"Total (1/2)" in output, "download output must be visible without toggling views"
        assert b"Interactive terminal" not in output
      if mode == "log":
        assert log_opened and "EARLY OUTPUT TO REVIEW" in (base / "viewer-log").read_text()
        args = (base / "viewer-args").read_text().splitlines()
        assert args[:6] == ["--app-id=org.omarchy.terminal", "--title=Installation log", "-e", "less", "+G", "--"]
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

  assert shutil.which("gum"), "gum is required to exercise the real interactive menu"
  for mode in ("success", "failure", "cancel", "prompt", "tui", "gum", "plain", "log"):
    run(mode, interactive=True)

  # Existing installs must acquire the dependency once, and a failed package
  # transaction must keep the migration pending (nonzero exit).
  migration = ROOT / "migrations/1790611799.sh"
  (base / "installed").unlink()
  (base / "transactions").write_text("")
  for _ in range(2):
    subprocess.run(["bash", "-euo", "pipefail", str(migration)],
                   env=dict(env, MODE="success"), check=True, capture_output=True)
  assert (base / "transactions").read_text().splitlines() == ["-S --noconfirm --needed -- libvterm"]
  (base / "installed").unlink()
  result = subprocess.run(["bash", "-euo", "pipefail", str(migration)],
                          env=dict(env, MODE="failure"), capture_output=True)
  assert result.returncode != 0 and not (base / "installed").exists()
  print("ok - libvterm migration is idempotent and propagates installation failures")

  # Make the real library loader fail only for libvterm, before any worker
  # starts. Verify the original presentation, interactive input, and statuses.
  shim = base / "missing-lib"
  shim.mkdir()
  (shim / "sitecustomize.py").write_text('''import ctypes
load = ctypes.CDLL
def missing(name, *args, **kwargs):
  if name == "libvterm.so.0":
    raise OSError("libvterm.so.0: cannot open shared object file")
  return load(name, *args, **kwargs)
ctypes.CDLL = missing
''')
  (mock / "omarchy-show-logo").write_text("#!/bin/bash\necho 'Original presentation'\n")
  (mock / "omarchy-show-done").write_text('''#!/bin/bash
echo "$1" >"$FIXTURE/done-status"
echo 'Press Enter to close fallback'
read -r _
''')
  (mock / "fallback-worker").write_text('''#!/bin/bash
echo invoked >>"$FIXTURE/invocations"
echo 'Fallback password:'
read -rs secret
[[ $secret == test-secret ]] || exit 99
exit "$WORKER_STATUS"
''')
  for name in ("omarchy-show-logo", "omarchy-show-done", "fallback-worker"):
    (mock / name).chmod(0o755)
  for status in (0, 7, 130):
    (base / "invocations").write_text("")
    (base / "done-status").unlink(missing_ok=True)
    master, slave = pty.openpty()
    before = termios.tcgetattr(slave)
    child = subprocess.Popen(["python3", str(SCRIPT), "--interactive", "--command", "fallback-worker"],
                             stdin=slave, stdout=slave, stderr=slave,
                             env=dict(env, PYTHONPATH=str(shim), WORKER_STATUS=str(status)))
    output = b""
    answered = closed = False
    deadline = time.monotonic() + 5
    try:
      while child.poll() is None and time.monotonic() < deadline:
        if select.select([master], [], [], .1)[0]:
          output += os.read(master, 65536)
        if b"Fallback password:" in output and not answered:
          os.write(master, b"test-secret\n")
          answered = True
        if b"Press Enter to close fallback" in output and not closed:
          os.write(master, b"\n")
          closed = True
      assert child.poll() == status, (status, output)
      assert answered and b"test-secret" not in output
      assert b"Original presentation" in output and b"\x1b[?1049h" not in output
      assert (base / "invocations").read_text().splitlines() == ["invoked"], "fallback ran command more than once"
      if status == 130:
        assert not (base / "done-status").exists()
      else:
        assert closed and (base / "done-status").read_text().strip() == str(status)
      assert termios.tcgetattr(slave) == before
      print(f"ok - missing libvterm: interactive fallback preserves status {status}")
    finally:
      if child.poll() is None:
        child.kill()
        child.wait()
      os.close(master)
      os.close(slave)

  # Non-TTY invocation must preserve ordinary output and the command's status.
  result = subprocess.run(["python3", str(SCRIPT), "--name", "Example", "--packages", "alpha",
                           "--command", "printf 'plain output'; exit 7"], capture_output=True, env=env)
  assert result.returncode == 7 and result.stdout == b"plain output"
  print("ok - redirected output has no terminal escapes and preserves failure status")
