#!/usr/bin/python3
"""Shared installation presentation with an embedded interactive terminal."""
import argparse
import collections
import errno
import fcntl
import os
from pathlib import Path
import re
import pty
import shlex
import select
import shutil
import signal
import subprocess
import struct
import sys
import tempfile
import termios
import time
import tty
import unicodedata
from palette import colors
from terminal import Terminal

CSI = "\033["
RESET = CSI + "0m"
DIM = CSI + "2m"
ACCENT, WHITE, RED = colors()
if "NO_COLOR" in os.environ:
  RESET = DIM = ACCENT = WHITE = RED = ""
ANSI = re.compile(r"\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)|\x1b\[[0-?]*[ -/]*[@-~]")


def clean(text):
  return "".join(c for c in ANSI.sub("", text) if not unicodedata.category(c).startswith("C"))


def fit(text, width):
  result, size = "", 0
  for c in clean(text):
    cell = 0 if unicodedata.combining(c) else 2 if unicodedata.east_asian_width(c) in "WF" else 1
    if size + cell > width:
      break
    result += c
    size += cell
  return result, size


class Progress:
  """Milestones, not a time estimate. The last cell requires successful exit."""
  def __init__(self):
    self.target = 1
    self.phase = "Preparing installation"

  def feed(self, line):
    target = self.target
    if "Retrieving packages" in line:
      target, self.phase = 30, "Downloading packages"
    elif self.target < 120 and re.search(r"\bTotal\b.*\d+%", line):
      percent = int(re.search(r"(\d+)%", line).group(1))
      target = 30 + 89 * min(percent, 100) // 100
    elif any(word in line for word in ("checking keys in keyring", "checking package integrity", "loading package files", "checking for file conflicts", "checking available disk space")):
      target, self.phase = 120, "Checking packages"
    elif match := re.search(r"\((\d+)/(\d+)\) (?:installing|upgrading|reinstalling|downgrading) ", line):
      current, total = map(int, match.groups())
      if 0 < current <= total:
        # Starting package N proves N-1 finished, not N.
        target = 150 + 180 * (current - 1) // total
        self.phase = "Installing packages"
    elif "Running post-transaction hooks" in line:
      target, self.phase = 350, "Finishing setup"
    self.target = max(self.target, target)


class Dashboard:
  def __init__(self, name):
    self.name = clean(name)
    path = Path(__file__).with_name("snake.path")
    cells = [tuple(map(int, line.split())) for line in path.read_text().splitlines()]
    if len(cells) != 380 or len(set(cells)) != 380 or any(not (0 <= r < 30 and 0 <= c < 30) for r, c in cells):
      raise ValueError("Invalid installer snake path")
    self.order = {cell: index for index, cell in enumerate(cells)}
    self.progress = Progress()
    self.length = 1
    self.details = False
    self.lines = collections.deque(maxlen=4)
    self.previous = {}
    self.size = None
    self.status = None
    self.cancelled = False
    self.child = None
    self.original = None
    self.last_render = 0
    self.cancel_requested = False
    self.terminating = False
    self.installing = True
    self.terminal_mode = False
    self.pty_fd = None
    self.terminal = None
    self.log_viewer = None
    self.log_error = False

  def open_live_log(self):
    # A separate terminal leaves the worker's PTY draining and its prompts
    # intact while the user reads earlier output. In less, F follows new output.
    if self.log_viewer is None or self.log_viewer.poll() is not None:
      try:
        self.log_viewer = subprocess.Popen(
          ["xdg-terminal-exec", "--app-id=org.omarchy.terminal", "--title=Installation log",
           "-e", "less", "+G", "--", self.log_path],
          stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
          start_new_session=True)
        self.log_error = False
      except OSError:
        # A log-window failure must not interrupt an installation transaction.
        self.log_error = True

  def restore(self):
    if self.original is not None:
      termios.tcsetattr(sys.stdin, termios.TCSADRAIN, self.original)
      sys.stdout.write(RESET + CSI + "?25h" + CSI + "?1049l")
      sys.stdout.flush()
      self.original = None

  def enter(self):
    self.original = termios.tcgetattr(sys.stdin)
    tty.setcbreak(sys.stdin.fileno())
    sys.stdout.write(CSI + "?1049h" + CSI + "?25l" + CSI + "2J")
    self.previous = {}

  def request_cancel(self, signum=signal.SIGINT, *_):
    # A signal can arrive inside Popen.poll(), which holds a non-reentrant
    # lock. Signal handlers only set flags; process operations happen later.
    self.cancel_requested = True
    self.terminating = signum in (signal.SIGTERM, signal.SIGHUP)

  def cancel(self):
    if self.child and self.child.poll() is None and not self.cancelled:
      self.cancelled = True
      # sudo relays this to pacman, which gets to clean up its transaction.
      try:
        if self.pty_fd is not None:
          os.write(self.pty_fd, b"\x03")
        else:
          os.killpg(self.child.pid, signal.SIGINT)
      except ProcessLookupError:
        pass

  def embedded_geometry(self):
    cols, rows = shutil.get_terminal_size()
    top = 10 if rows < 33 or cols < 46 else 25
    top = min(top, max(3, rows - 6))
    width = max(1, min(100, cols - 8))
    return top, max(1, (cols - width) // 2 + 1), max(1, rows - 3 - top), width

  def render(self):
    cols, rows = shutil.get_terminal_size()
    if self.size != (cols, rows):
      sys.stdout.write(CSI + "2J")
      self.previous = {}
      self.size = cols, rows
    success = self.status == 0
    failed = self.status is not None and self.status != 0
    if success:
      self.progress.target = 380
    if not failed:
      self.length = min(self.progress.target, self.length + 6)
    screen = {}

    def line(row, text, color="", center=True):
      if 1 <= row <= rows:
        text, width = fit(text, max(0, cols - 4) if center else max(0, min(58, cols - 4)))
        col = max(1, (cols - width) // 2 + 1) if center else max(2, (cols - 58) // 2)
        screen[row] = f"{CSI}{row};{col}H{color}{text}{RESET}"

    line(2, "OMARCHY", DIM)
    compact = rows < 33 or cols < 46
    embedded = self.terminal is not None
    expanded = self.details or failed or embedded
    height = (7 if compact else 23) + (6 if expanded else 0)
    top = (4 if compact else 3) if embedded else max(4, (rows - height) // 2)
    if not compact:
      color = RED if failed else ACCENT
      blink = self.status is None and int(time.monotonic() * 2) % 2 == 1
      for r in range(15):
        chunks = []
        for c in range(30):
          a = self.order.get((r * 2, c), 999)
          b = self.order.get((r * 2 + 1, c), 999)
          upper = a < self.length and not (blink and a == self.length - 1)
          lower = b < self.length and not (blink and b == self.length - 1)
          glyph = "█" if upper and lower else "▀" if upper else "▄" if lower else " "
          head = self.status is None and self.length - 1 in (a, b)
          chunks.append((WHITE if head else color) + glyph)
        screen[top + r] = f"{CSI}{top+r};{max(1, (cols-30)//2+1)}H" + "".join(chunks) + RESET
      progress_row = top + 16
    else:
      progress_row = top
    percent = (self.length - 1) * 100 // 379
    label = "100%" if self.length == 380 and success else f"~{min(percent, 99)}%"
    line(progress_row, label, ACCENT if success else RED if failed else WHITE)
    title_row = progress_row + 2
    title = f"{self.name} installed" if success else "Installation cancelled" if failed and self.cancelled else "Installation stopped" if failed else f"Installing {self.name}"
    if not self.installing:
      title = f"{self.name} complete" if success else f"{self.name} stopped" if failed else self.name
    subtitle = "Ready to use" if success else f"Installer exited with status {self.status}" if failed else "Cancelling — waiting for the installer" if self.cancelled else self.progress.phase
    line(title_row, title, ACCENT if success else RED if failed else WHITE)
    line(title_row + 2, subtitle, DIM)
    if embedded:
      area_top, area_left, area_rows, area_cols = self.embedded_geometry()
      line(area_top - 1, "─" * area_cols, DIM)
      for index, contents in enumerate(self.terminal.lines()):
        screen[area_top + index] = f"{CSI}{area_top + index};{area_left}H{contents}"
    elif expanded:
      line(title_row + 4, "─" * min(58, max(0, cols - 8)), DIM)
      # Reserve the footer even in small terminal windows.
      available = max(0, min(4, rows - 4 - (title_row + 5)))
      for i, log in enumerate(list(self.lines)[-available:] if available else []):
        line(title_row + 5 + i, log, DIM, center=False)
    footer = "Enter  Close   ·   L  Full log" if self.status is not None else "Ctrl+G  Full log   ·   Ctrl+C  Cancel" if embedded else "Ctrl+C  Cancel"
    if self.log_error and self.status is None:
      footer = "Log window unavailable   ·   Ctrl+C  Cancel"
    line(rows - 3, footer + ("" if embedded else "   ·   D  Hide details" if expanded else "   ·   D  Show details"), DIM)
    if failed:
      line(rows - 1, "Full log is saved locally", DIM)
    output = []
    for row in sorted(set(screen) | set(self.previous)):
      value = screen.get(row, "")
      if self.previous.get(row) != value:
        output.append(f"{CSI}{row};1H{CSI}2K" + value)
    if self.terminal_mode:
      row, col = self.terminal.cursor()
      output.append(f"{CSI}{area_top + row};{area_left + col}H{CSI}?25" + ("h" if self.terminal.visible else "l"))
    else:
      output.append(CSI + "?25l")
    sys.stdout.write("".join(output))
    sys.stdout.flush()
    self.previous = screen

  def run_interactive(self, command):
    """Keep output and input in one embedded terminal throughout the task."""
    log_dir = Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state"))) / "omarchy/installs"
    log_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
    fd, self.log_path = tempfile.mkstemp(prefix="install-", suffix=".log", dir=log_dir)
    master, slave = pty.openpty()
    self.pty_fd = master
    env = dict(os.environ, LC_ALL="C.UTF-8")
    for key in ("OMARCHY_INSTALL_NAME", "OMARCHY_INSTALL_PACKAGES", "OMARCHY_INSTALL_AUTHENTICATED"):
      env.pop(key, None)
    pending = b""
    eof = False
    terminal_size = None
    old_signals = {s: signal.signal(s, self.request_cancel) for s in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP)}

    def resize():
      nonlocal terminal_size
      size = shutil.get_terminal_size()
      if size != terminal_size:
        _, _, height, width = self.embedded_geometry()
        self.terminal.resize(height, width)
        fcntl.ioctl(master, termios.TIOCSWINSZ, struct.pack("HHHH", height, width, 0, 0))
        terminal_size = size

    def child_session():
      os.setsid()
      fcntl.ioctl(0, termios.TIOCSCTTY, 0)

    try:
      with os.fdopen(fd, "w", encoding="utf-8") as log:
        resize()
        self.enter()
        self.terminal_mode = True
        tty.setraw(sys.stdin.fileno())
        self.child = subprocess.Popen(["bash", "-c", command], stdin=slave, stdout=slave, stderr=slave,
                                      env=env, preexec_fn=child_session)
        os.close(slave)
        slave = None
        while True:
          if self.cancel_requested:
            self.cancel()
          resize()
          ready, _, _ = select.select([sys.stdin] + ([] if eof else [master]), [], [], .1)
          if master in ready:
            try:
              data = os.read(master, 65536)
            except OSError as error:
              if error.errno != errno.EIO:
                raise
              data = b""
            if data:
              responses = self.terminal.feed(data)
              if responses:
                os.write(master, responses)
              pending += data
              parts = re.split(b"[\r\n]", pending)
              pending = parts.pop()
              for part in parts:
                text = clean(part.decode("utf-8", errors="replace"))
                if text:
                  log.write(text + "\n")
                  log.flush()
                  self.lines.append(text)
                  self.progress.feed(text)
              if len(pending) > 65536:
                pending = pending[-65536:]
            else:
              eof = True
              if pending:
                text = clean(pending.decode("utf-8", errors="replace"))
                log.write(text + "\n")
                self.lines.append(text)
          if eof and self.child.poll() is not None:
            self.status = self.child.returncode
            if self.terminal_mode:
              tty.setcbreak(sys.stdin.fileno())
              self.terminal_mode = False
            if self.terminating:
              break
          if sys.stdin in ready:
            key = os.read(sys.stdin.fileno(), 4096)
            if not key:
              self.cancel()
              break
            if self.terminal_mode:
              # Reserve Ctrl+G for log access. Ordinary L, tabs and escape
              # sequences still reach the worker, which controls password echo.
              parts = key.split(b"\x07")
              for index, part in enumerate(parts):
                if index:
                  self.open_live_log()
                if b"\x03" in part:
                  self.cancelled = True
                if part:
                  os.write(master, part)
            elif self.status is not None and key in (b"\r", b"\n", b"q", b"\x1b"):
              break
            elif key.lower() == b"l" and self.status is not None:
              self.restore()
              subprocess.run(["less", "--", self.log_path])
              self.enter()
          if time.monotonic() - self.last_render >= .1:
            self.render()
            self.last_render = time.monotonic()
    finally:
      if self.child is not None and self.child.poll() is None:
        self.cancel()
        self.child.wait()
      self.restore()
      if slave is not None:
        os.close(slave)
      os.close(master)
      if self.terminal is not None:
        self.terminal.close()
      self.pty_fd = None
      for sig, handler in old_signals.items():
        signal.signal(sig, handler)
    return 130 if self.cancelled else self.child.returncode

  def run(self, command):
    log_dir = Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state"))) / "omarchy/installs"
    log_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
    fd, self.log_path = tempfile.mkstemp(prefix="install-", suffix=".log", dir=log_dir)
    env = dict(os.environ, LC_ALL="C", OMARCHY_INSTALL_AUTHENTICATED="1")
    env.pop("OMARCHY_INSTALL_NAME", None)
    env.pop("OMARCHY_INSTALL_PACKAGES", None)
    pending = b""
    eof = False
    old_signals = {s: signal.signal(s, self.request_cancel) for s in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP)}
    try:
      with os.fdopen(fd, "w", encoding="utf-8") as log:
        self.enter()
        # Keep the controlling tty for sudo's tty-scoped credential cache,
        # but give the worker its own process group for cancellation.
        self.child = subprocess.Popen(["bash", "-c", command], stdin=subprocess.DEVNULL,
                                      stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                      env=env, process_group=0)
        def consume(raw):
          text = clean(raw.decode("utf-8", errors="replace"))
          if text:
            log.write(text + "\n")
            log.flush()
            self.lines.append(text)
            self.progress.feed(text)

        while True:
          if self.cancel_requested:
            self.cancel()
          readers = [sys.stdin]
          if not eof:
            readers.append(self.child.stdout)
          ready, _, _ = select.select(readers, [], [], .1)
          if self.child.stdout in ready:
            data = os.read(self.child.stdout.fileno(), 65536)
            if data:
              pending += data
              parts = re.split(b"[\r\n]", pending)
              pending = parts.pop()
              for part in parts:
                consume(part)
              if len(pending) > 65536:
                consume(pending)
                pending = b""
            else:
              eof = True
              consume(pending)
              pending = b""
          if eof and self.child.poll() is not None:
            self.status = self.child.returncode
            if self.terminating:
              break
          if sys.stdin in ready:
            key = os.read(sys.stdin.fileno(), 1).lower()
            if key == b"d":
              self.details = not self.details
            elif key == b"l" and self.status is not None:
              self.restore()
              subprocess.run(["less", "--", self.log_path])
              self.enter()
            elif key in (b"\r", b"\n", b"q", b"\x1b") and self.status is not None:
              break
            elif key == b"":
              self.cancel()
              break
          if time.monotonic() - self.last_render >= .1:
            self.render()
            self.last_render = time.monotonic()
    finally:
      if self.child is not None and self.child.poll() is None:
        self.cancel()
        self.child.wait()
      self.restore()
      for sig, handler in old_signals.items():
        signal.signal(sig, handler)
    return 130 if self.cancelled else self.child.returncode


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("--name", default="")
  parser.add_argument("--interactive", action="store_true")
  parser.add_argument("--packages", default="")
  parser.add_argument("--command", required=True)
  args = parser.parse_args()
  if not args.name:
    words = shlex.split(args.command)
    command_name = Path(words[0]).name if words else "Task"
    parts = command_name.removeprefix("omarchy-").split("-")
    args.name = " ".join(part for part in parts if part not in ("install", "setup", "editor", "service", "gaming", "ai"))
    if len(words) > 1:
      args.name += " " + " ".join(words[1:])
    args.name = args.name.replace("-", " ").title() or "Setup"
  packages = args.packages.split()
  # Redirected output remains a regular command. Authentication also stays
  # entirely outside the dashboard and its logs.
  if not sys.stdin.isatty() or not sys.stdout.isatty() or os.environ.get("TERM", "dumb") == "dumb":
    return subprocess.call(["bash", "-c", args.command])
  if args.interactive:
    dashboard = Dashboard(args.name)
    dashboard.installing = "install" in args.command.lower() or "omarchy-pkg" in args.command
    _, _, height, width = dashboard.embedded_geometry()
    try:
      dashboard.terminal = Terminal(height, width)
    except OSError:
      # Updates can start before the libvterm migration has run. Preserve the
      # original terminal presentation without retrying a started command.
      os.execvp("bash", ["bash", "-c", '''omarchy-show-logo
bash -c "$1"
code=$?
if (( code != 130 )); then omarchy-show-done "$code"; fi
exit "$code"
''', "omarchy-presentation", args.command])
    return dashboard.run_interactive(args.command)
  missing = subprocess.call(["omarchy-pkg-missing", *packages]) == 0
  if missing and os.geteuid() != 0:
    print(f"Installing {clean(args.name)}\n")
    status = subprocess.call(["sudo", "-v"])
    if status:
      print("Installation cancelled: authorization was not completed.")
      return status
  dashboard = Dashboard(args.name)
  return dashboard.run(args.command)


if __name__ == "__main__":
  sys.exit(main())
