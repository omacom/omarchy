"""Keep terminal tasks interactive; overlay animations only while unattended.

pyte is used through its public interface to restore text TUI contents. The
separately installed python-pyte package is LGPL-3.0; no library code is vendored.
"""
import argparse
import codecs
import copy
from contextlib import ExitStack
import errno
import fcntl
import json
import os
from pathlib import Path
import pty
import re
import select
import shutil
import signal
import socket
import struct
import subprocess
import sys
import tempfile
import termios
import time
import tty

import pyte

IDLE = b"\x1b]777;OMARCHY_SCREENSAVER_IDLE\x07"
BUSY = b"\x1b]777;OMARCHY_SCREENSAVER_BUSY\x07"
MOUSE = re.compile(rb"\x1b\[<\d+;\d+;\d+[Mm]")
PROMPT = re.compile(r"(?:\[(?:y/n|yes/no)[^\]]*\]|(?:password|passphrase)[^\n]*:|(?:allow|approve|permission)[^\n]*\?|\?\s*$)", re.I)


def complete_output(data):
  """Do not inject overlay controls inside split child ANSI/UTF-8 sequences."""
  position = 0
  while True:
    start = data.find(b"\x1b", position)
    if start < 0:
      break
    if start + 1 == len(data):
      return data[:start], data[start:]
    kind = data[start + 1]
    if kind == ord("["):
      end = start + 2
      while end < len(data) and not 0x40 <= data[end] <= 0x7e:
        end += 1
      if end == len(data):
        return data[:start], data[start:]
      position = end + 1
    elif kind in b"]P_X^":
      endings = []
      end = data.find(b"\x1b\\", start + 2)
      if end >= 0:
        endings.append(end + 2)
      if kind == ord("]"):
        end = data.find(b"\x07", start + 2)
        if end >= 0:
          endings.append(end + 1)
      if not endings:
        return data[:start], data[start:]
      position = min(endings)
    else:
      end = start + 1
      while end < len(data) and 0x20 <= data[end] <= 0x2f:
        end += 1
      if end == len(data):
        return data[:start], data[start:]
      position = end + 1
  for start in range(max(0, len(data) - 3), len(data)):
    lead = data[start]
    length = 2 if 0xc2 <= lead <= 0xdf else 3 if 0xe0 <= lead <= 0xef else 4 if 0xf0 <= lead <= 0xf4 else 0
    if length and len(data) - start < length and all(0x80 <= byte <= 0xbf for byte in data[start + 1:]):
      return data[:start], data[start:]
  return data, b""


class Display(pyte.Screen):
  fields = ("buffer", "cursor", "margins", "tabstops", "savepoints", "mode")

  def __init__(self, *args):
    self.alternate = False
    self.normal = None
    self.mouse = set()
    super().__init__(*args)

  def set_mode(self, *modes, **kwargs):
    if kwargs.get("private"):
      self.mouse.update(set(modes) & {1000, 1002, 1003, 1006})
      if (1049 in modes or 1047 in modes) and not self.alternate:
        self.normal = {field: copy.deepcopy(getattr(self, field)) for field in self.fields}
        super().reset()
        self.alternate = True
    super().set_mode(*modes, **kwargs)

  def reset_mode(self, *modes, **kwargs):
    if kwargs.get("private"):
      self.mouse.difference_update(modes)
      if (1049 in modes or 1047 in modes) and self.alternate:
        for field, value in self.normal.items():
          setattr(self, field, value)
        self.normal = None
        self.alternate = False
    super().reset_mode(*modes, **kwargs)

  def redraw(self):
    result = ["\x1b[?7l\x1b[0m\x1b[2J"]
    colors = {"black": 0, "red": 1, "green": 2, "brown": 3, "blue": 4, "magenta": 5, "cyan": 6, "white": 7}
    colors.update({"bright" + name: code + 60 for name, code in list(colors.items())})
    for row in range(self.lines):
      result.append(f"\x1b[{row + 1};1H")
      previous = None
      for column in range(self.columns):
        cell = self.buffer[row][column]
        style = (cell.fg, cell.bg, cell.bold, cell.italics, cell.underscore, cell.reverse, cell.strikethrough)
        if style != previous:
          codes = ["0"]
          for value, offset, channel in ((cell.fg, 30, 38), (cell.bg, 40, 48)):
            if value in colors:
              codes.append(str(offset + colors[value]))
            elif re.fullmatch(r"[0-9a-fA-F]{6}", value):
              codes.append(f"{channel};2;{int(value[:2], 16)};{int(value[2:4], 16)};{int(value[4:], 16)}")
          codes.extend(str(code) for enabled, code in zip(style[2:], (1, 3, 4, 7, 9)) if enabled)
          result.append("\x1b[" + ";".join(codes) + "m")
          previous = style
        result.append(cell.data)
    result.append("\x1b[0m" + ("\x1b[?7h" if (7 << 5) in self.mode else "\x1b[?7l"))
    result.append(f"\x1b[{self.cursor.y + 1};{self.cursor.x + 1}H")
    result.append("\x1b[?25l" if self.cursor.hidden else "\x1b[?25h")
    return "".join(result).encode()


class Markers:
  def __init__(self):
    self.pending = b""

  def feed(self, data):
    data = self.pending + data
    data, self.pending = complete_output(data)
    parts = re.split(b"(" + re.escape(IDLE) + b"|" + re.escape(BUSY) + b")", data)
    return [("idle" if part == IDLE else "busy" if part == BUSY else "output", part) for part in parts if part]


def shell_environment(shell, directory):
  env = dict(os.environ, OMARCHY_TASK_SCREENSAVER_ACTIVE="1")
  if shell == "zsh":
    env["OMARCHY_SCREENSAVER_ORIGINAL_ZDOTDIR"] = os.environ.get("ZDOTDIR") or str(Path.home())
    env["OMARCHY_SCREENSAVER_ZDOTDIR"] = directory
    env["ZDOTDIR"] = directory
    Path(directory, ".zshenv").write_text('[[ -f "$OMARCHY_SCREENSAVER_ORIGINAL_ZDOTDIR/.zshenv" ]] && source "$OMARCHY_SCREENSAVER_ORIGINAL_ZDOTDIR/.zshenv"\nZDOTDIR="$OMARCHY_SCREENSAVER_ZDOTDIR"\n')
    Path(directory, ".zshrc").write_text('ZDOTDIR="$OMARCHY_SCREENSAVER_ORIGINAL_ZDOTDIR"\n[[ -f "$OMARCHY_SCREENSAVER_ORIGINAL_ZDOTDIR/.zshrc" ]] && source "$OMARCHY_SCREENSAVER_ORIGINAL_ZDOTDIR/.zshrc"\nautoload -Uz add-zsh-hook\n__omarchy_task_idle() { printf "\\033]777;OMARCHY_SCREENSAVER_IDLE\\007"; }\n__omarchy_task_busy() { printf "\\033]777;OMARCHY_SCREENSAVER_BUSY\\007"; }\nadd-zsh-hook precmd __omarchy_task_idle\nadd-zsh-hook preexec __omarchy_task_busy\n')
    return env, [shutil.which("zsh"), "-i"]
  rc = Path(directory, "bashrc")
  rc.write_text('[[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc"\n__omarchy_task_idle() { printf "\\033]777;OMARCHY_SCREENSAVER_IDLE\\007"; }\nif [[ $(declare -p PROMPT_COMMAND 2>/dev/null) == "declare -a"* ]]; then\n  PROMPT_COMMAND+=(__omarchy_task_idle)\nelse\n  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}__omarchy_task_idle"\nfi\n')
  return env, [shutil.which("bash"), "--rcfile", str(rc), "-i"]


def install_opencode():
  config = Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
  path = config / "opencode/plugins/omarchy-task-screensaver.js"
  source = (Path(os.environ["OMARCHY_PATH"]) / "default/omarchy/opencode-screensaver.js").read_text()
  path.parent.mkdir(parents=True, exist_ok=True)
  if path.exists() and path.read_text() != source:
    raise ValueError(f"{path} has different contents; refusing to overwrite it")
  path.write_text(source)
  return path


def session(shell, delay):
  if delay <= 0 or not shutil.which(shell):
    raise ValueError("Choose an installed shell and an inactivity delay greater than zero")
  art = Path.home() / ".config/omarchy/branding/screensaver.txt"
  flag = Path.home() / ".local/state/omarchy/toggles/screensaver-task-on"
  original = termios.tcgetattr(0)
  size = os.get_terminal_size(1)
  screen = Display(size.columns, size.lines)
  stream = pyte.Stream(screen)
  decoder = codecs.getincrementaldecoder("utf-8")("replace")
  markers = Markers()
  busy = waiting = overlay = mouse_on = overlay_alternate = False
  last_activity = time.monotonic()
  agent = animation = None
  pending_output = bytearray()
  prompt_tail = ""
  running = True
  resize_pending = False

  with tempfile.TemporaryDirectory(prefix="omarchy-auto-", dir="/tmp") as directory:
    control = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    control.bind(str(Path(directory, "control.sock")))
    control.listen()
    control.setblocking(False)
    peers = {}
    env, command = shell_environment(shell, directory)
    env["SCREENSAVER_CONTROL_SOCKET"] = str(Path(directory, "control.sock"))
    pid, master = pty.fork()
    if pid == 0:
      os.execvpe(command[0], command, env)
    fcntl.ioctl(master, termios.TIOCSWINSZ, struct.pack("HHHH", size.lines, size.columns, 0, 0))

    def write(data):
      remaining = memoryview(data)
      while remaining:
        remaining = remaining[os.write(1, remaining):]

    def mouse(enabled, force=False):
      nonlocal mouse_on
      if enabled != mouse_on or (enabled and force):
        write(b"\x1b[?1003h\x1b[?1006h" if enabled else b"\x1b[?1003l\x1b[?1006l")
        if not enabled:
          for mode in screen.mouse:
            write(f"\x1b[?{mode}h".encode())
        mouse_on = enabled

    def dismiss():
      nonlocal overlay, animation
      if not overlay:
        return
      if animation is not None:
        if animation.poll() is None:
          animation.terminate()
          animation.wait()
        animation.stdout.close()
      if screen.alternate:
        write(screen.redraw())
      elif overlay_alternate:
        write(b"\x1b[?1049l")
        write(screen.redraw())
      else:
        write(b"\x1b[?1049l")
        if pending_output:
          write(pending_output)
        write(b"\x1b[?25l" if screen.cursor.hidden else b"\x1b[?25h")
      pending_output.clear()
      overlay = False
      animation = None

    def resize(signum, frame):
      nonlocal resize_pending
      resize_pending = True

    def stop(signum, frame):
      nonlocal running
      running = False
      try:
        os.killpg(os.tcgetpgrp(master), signal.SIGHUP)
        os.kill(pid, signal.SIGHUP)
      except ProcessLookupError:
        pass

    old_handlers = {sig: signal.getsignal(sig) for sig in (signal.SIGWINCH, signal.SIGTERM, signal.SIGHUP)}
    signal.signal(signal.SIGWINCH, resize)
    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGHUP, stop)
    try:
      tty.setraw(0)
      while running:
        if resize_pending:
          resize_pending = False
          size = os.get_terminal_size(1)
          screen.resize(size.lines, size.columns)
          dismiss()
          fcntl.ioctl(master, termios.TIOCSWINSZ, struct.pack("HHHH", size.lines, size.columns, 0, 0))
          last_activity = time.monotonic()
        descriptors = [0, master, control, *peers]
        if animation is not None and not animation.stdout.closed:
          descriptors.append(animation.stdout)
        ready, _, _ = select.select(descriptors, [], [], .05)
        if control in ready:
          peer, _ = control.accept()
          peer.setblocking(False)
          peers[peer] = b""
        for peer in list(peers):
          if peer not in ready:
            continue
          chunk = peer.recv(4096)
          if not chunk:
            peer.close()
            peers.pop(peer)
            continue
          peers[peer] += chunk
          if len(peers[peer]) > 65536:
            peer.close()
            peers.pop(peer)
            continue
          while b"\n" in peers[peer]:
            line, peers[peer] = peers[peer].split(b"\n", 1)
            try:
              message = json.loads(line)
              if message["state"] not in ("busy", "idle", "waiting") or os.getpgid(int(message["pid"])) != os.tcgetpgrp(master):
                continue
              previous = agent["state"] if agent else None
              agent = dict(message, seen=time.monotonic())
              if message["state"] != "busy":
                dismiss()
              if previous != message["state"]:
                last_activity = time.monotonic()
            except (ValueError, KeyError, TypeError, ProcessLookupError):
              continue
        if master in ready:
          try:
            chunk = os.read(master, 65536)
          except OSError as error:
            if error.errno != errno.EIO:
              raise
            break
          if not chunk:
            break
          for kind, data in markers.feed(chunk):
            if kind == "idle":
              dismiss()
              busy = waiting = False
              agent = None
              mouse(False)
            elif kind == "busy":
              busy, waiting = True, False
              last_activity = time.monotonic()
            else:
              text = decoder.decode(data)
              stream.feed(text)
              if not screen.alternate:
                prompt_tail = (prompt_tail + text)[-1024:].rsplit("\n", 1)[-1]
                plain = re.sub(r"\x1b\[[0-?]*[ -/]*[@-~]", "", prompt_tail)
                if PROMPT.search(plain):
                  waiting = True
                  dismiss()
                elif text:
                  waiting = False
              if overlay and not screen.alternate and not overlay_alternate:
                pending_output.extend(data)
                if len(pending_output) >= 16 * 1024 * 1024:
                  dismiss()
                  last_activity = time.monotonic()
              elif not overlay:
                write(data)
        if 0 in ready:
          data = os.read(0, 4096)
          if not data:
            break
          last_activity = time.monotonic()
          was_overlay = overlay
          dismiss()
          keyboard = MOUSE.sub(b"", data)
          if keyboard:
            waiting = False
            prompt_tail = ""
          if keyboard and (not was_overlay or b"\x03" in keyboard):
            os.write(master, keyboard)
            if shell == "bash" and (b"\r" in keyboard or b"\n" in keyboard):
              busy = True
          if not was_overlay and screen.mouse:
            for event in MOUSE.findall(data):
              os.write(master, event)
        now = time.monotonic()
        live_agent = agent is not None and now - agent["seen"] < 5
        modes = termios.tcgetattr(master)[3]
        eligible = agent["state"] == "busy" if live_agent else busy and not waiting and not screen.alternate and bool(modes & termios.ICANON) and bool(modes & termios.ECHO)
        eligible = eligible and flag.is_file()
        mouse(eligible or overlay, master in ready)
        if not eligible:
          dismiss()
        elif not overlay and now - last_activity >= delay:
          try:
            usable_art = art.read_text().strip()
          except (OSError, UnicodeError):
            usable_art = ""
          if not usable_art:
            last_activity = now
            continue
          overlay = True
          overlay_alternate = screen.alternate
          if not screen.alternate:
            write(b"\x1b[?1049h")
          write(b"\x1b[?25l\x1b[0m\x1b[2J")
        if overlay and (animation is None or animation.poll() is not None):
          if animation is not None and animation.returncode not in (None, 0):
            dismiss()
            last_activity = now
            continue
          if animation is not None:
            animation.stdout.close()
          size = os.get_terminal_size(1)
          width, height = max(1, size.columns - 1), max(1, size.lines - 1)
          write(f"\x1b[2J\x1b[{height + 1};1H\x1b7".encode())
          animation = subprocess.Popen([
            "ttfx", "-i", str(art), "--frame-rate", "120", "--canvas-width", str(width), "--canvas-height", str(height),
            "--anchor-text", "c", "--anchor-canvas", "sw", "--reuse-canvas", "--no-eol", "--no-restore-cursor", "--random-effect",
          ], stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
             env=dict(os.environ, COLUMNS=str(width), LINES=str(height)))
          os.set_blocking(animation.stdout.fileno(), False)
        if overlay and animation is not None:
          try:
            write(os.read(animation.stdout.fileno(), 65536).replace(b"\n", b"\r\n"))
          except OSError as error:
            if error.errno not in (errno.EAGAIN, errno.EIO):
              raise
    finally:
      with ExitStack() as cleanup:
        cleanup.callback(termios.tcsetattr, 0, termios.TCSADRAIN, original)
        cleanup.callback(control.close)
        cleanup.callback(os.close, master)
        for sig, handler in old_handlers.items():
          cleanup.callback(signal.signal, sig, handler)
        for peer in peers:
          cleanup.callback(peer.close)
        dismiss()
        mouse(False)
    _, status = os.waitpid(pid, 0)
    code = os.waitstatus_to_exitcode(status)
    return code if code >= 0 else 128 - code


def main():
  parser = argparse.ArgumentParser(description="Automatic unattended-task terminal screensaver")
  parser.add_argument("--shell", choices=("bash", "zsh"), default="bash")
  parser.add_argument("--idle-after", type=float, default=10)
  parser.add_argument("--install-opencode", action="store_true")
  args = parser.parse_args()
  if args.install_opencode:
    print(f"Installed {install_opencode()}. Quit and restart OpenCode in an automatic terminal session.")
    return 0
  if not os.isatty(0) or not os.isatty(1):
    parser.error("Run this command in an interactive terminal")
  return session(args.shell, args.idle_after)


if __name__ == "__main__":
  raise SystemExit(main())
