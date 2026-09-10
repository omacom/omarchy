#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

export OMARCHY_PATH="$ROOT"
export PYTHONDONTWRITEBYTECODE=1

python3 <<'PY'
import curses
import importlib.util
import os
from pathlib import Path
import pty
import select
import signal
import struct
import subprocess
import tempfile
import termios
import time
import fcntl
from unittest.mock import patch

root = Path(os.environ["ROOT"])
spec = importlib.util.spec_from_file_location("doctrine", root / "default/omarchy/doctrine.py")
doctrine = importlib.util.module_from_spec(spec)
spec.loader.exec_module(doctrine)
principles = doctrine.load_principles()

def check(condition, description):
  if not condition:
    raise SystemExit("not ok - " + description)
  print("ok - " + description)

def command(*args):
  return subprocess.run([str(root / "bin/omarchy"), "doctrine", *args], capture_output=True, text=True)

short = command()
full = command("--full")
check(short.returncode == full.returncode == 0 and "\x1b" not in short.stdout + full.stdout,
      "redirected output stays plain and does not start the reader")
check(len(principles) == 10 and all(title in short.stdout for title, _, _ in principles),
      "the short form includes all ten principles")
check(all(" ".join(body.split()) in " ".join(full.stdout.split()) for _, body, _ in principles),
      "full output preserves every principle's explanation")
single = command("10")
check(principles[9][0] in single.stdout and principles[0][0] not in single.stdout
      and single.stdout.rstrip().endswith("#youre-somebody-now"),
      "a direct principle prints only that explanation and its canonical anchor")
for args in [("0",), ("11",), ("--invalid",), ("--full", "extra")]:
  result = command(*args)
  check(result.returncode == 2 and not result.stdout, "invalid arguments are rejected: " + " ".join(args))

class Screen:
  def __init__(self, rows, cols):
    self.rows, self.cols = rows, cols
    self.cells = {}
  def getmaxyx(self):
    return self.rows, self.cols
  def erase(self):
    self.cells = {}
  def addnstr(self, y, x, text, width, style):
    assert 0 <= y < self.rows and 0 <= x < self.cols
    assert x + len(text[:width]) < self.cols
    for offset, character in enumerate(text[:width]):
      assert (y, x + offset) not in self.cells, "overlapping content"
      self.cells[y, x + offset] = character
  def refresh(self):
    pass

def reader(rows, cols, mode="index"):
  instance = doctrine.Reader.__new__(doctrine.Reader)
  instance.screen = Screen(rows, cols)
  instance.principles = principles
  instance.mode, instance.selected, instance.scroll = mode, 0, 0
  instance.max_scroll, instance.links, instance.notice = 0, [], ""
  instance.accent = curses.A_BOLD
  return instance

for rows, cols in [(12, 30), (20, 48), (24, 80), (30, 102), (40, 120)]:
  for mode in ("index", "read", "full"):
    instance = reader(rows, cols, mode)
    for number in range(10):
      instance.select(number)
      instance.draw()
  check(True, f"all reader views fit {cols}×{rows} without overlap")

instance = reader(24, 80, "full")
instance.draw()
instance.move(10000)
check(instance.scroll == instance.max_scroll and instance.scroll > 0,
      "the full doctrine scrolls to the end without overshooting")
instance.action("index")
instance.select(-1)
check(instance.selected == 9 and instance.scroll == 0,
      "returning to the index and wrapping selection reset scroll")
instance.action("read")
instance.screen.rows, instance.screen.cols = 20, 48
instance.draw()
instance.screen.rows, instance.screen.cols = 40, 120
instance.draw()
check(instance.selected == 9, "resizing preserves the selected principle")

with tempfile.TemporaryDirectory() as scratch:
  scratch = Path(scratch)
  log = scratch / "browser-url"
  browser = scratch / "omarchy-launch-browser"
  browser.write_text('#!/bin/bash\nprintf "%s" "$1" > "$DOCTRINE_BROWSER_LOG"\n')
  browser.chmod(0o755)
  with patch.dict(os.environ, PATH=str(scratch) + ":" + os.environ["PATH"], DOCTRINE_BROWSER_LOG=str(log)):
    check(command("--web").returncode == 0 and log.read_text() == doctrine.WEBSITE,
          "--web opens the canonical website through the Omarchy browser launcher")
    instance.action("web")
    check(log.read_text() == principles[9][2], "the website action opens the selected principle's anchor")
    instance.draw()
    y, x, _, _ = next(link for link in instance.links if link[3] == "web")
    with patch.object(curses, "getmouse", return_value=(0, x, y, 0, curses.BUTTON1_PRESSED)):
      instance.mouse()
    check(log.read_text() == principles[9][2], "clicking the website link opens the selected principle")
    instance.action("full")
    instance.action("web")
    check(log.read_text() == doctrine.WEBSITE, "the full reader opens the whole website")

instance = reader(24, 80)
instance.draw()
y, x, _, _ = next(link for link in instance.links if link[3] == 2)
with patch.object(curses, "getmouse", return_value=(0, x, y, 0, curses.BUTTON1_PRESSED)):
  instance.mouse()
check(instance.selected == 2 and instance.mode == "read", "clicking a principle opens its explanation in a narrow terminal")

def terminal_session(interrupt=False):
  pid, master = pty.fork()
  if pid == 0:
    os.environ["TERM"] = "xterm-256color"
    os.execvp("bash", ["bash", "-c", '''
before=$(stty -g)
"$ROOT/bin/omarchy" doctrine
result=$?
after=$(stty -g)
[[ $before == "$after" ]] || exit 91
exit "$result"
'''])
  output = bytearray()
  def receive(seconds):
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
      ready, _, _ = select.select([master], [], [], max(0, deadline - time.monotonic()))
      if ready:
        try:
          chunk = os.read(master, 65536)
        except OSError:
          break
        if not chunk:
          break
        output.extend(chunk)
  try:
    fcntl.ioctl(master, termios.TIOCSWINSZ, struct.pack("HHHH", 30, 120, 0, 0))
    receive(0.5)
    check(b"DOCTRINE" in output, "the real terminal reader starts")
    if interrupt:
      os.write(master, b"\x03")
    else:
      os.write(master, b"j\rf")
      receive(0.2)
      fcntl.ioctl(master, termios.TIOCSWINSZ, struct.pack("HHHH", 20, 48, 0, 0))
      os.killpg(pid, signal.SIGWINCH)
      receive(0.2)
      os.write(master, b" \x1b")
      receive(0.1)
      os.write(master, b"q")
    receive(1)
    completed, status = os.waitpid(pid, os.WNOHANG)
    check(completed == pid, "the terminal reader exits promptly")
    check(os.waitstatus_to_exitcode(status) == (130 if interrupt else 0),
          "terminal settings are restored after " + ("Ctrl-C" if interrupt else "navigation, resize, and quit"))
    check(b"\x1b[?1049l" in output, "the reader restores the original terminal screen")
  finally:
    try:
      os.killpg(pid, signal.SIGKILL)
    except ProcessLookupError:
      pass
    os.close(master)

terminal_session()
terminal_session(interrupt=True)
PY
