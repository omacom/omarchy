"""Read-only, bounded native messaging and Linux inotify in one process."""

import ctypes
import json
import os
from pathlib import Path
import re
import selectors
import signal
import stat
import struct
import sys
import time
import tomllib


MAX_MESSAGE_BYTES = 1024 * 1024
MAX_PALETTE_BYTES = 64 * 1024
COLOR_KEYS = (
  "accent", "background", "dark_background", "darker_background", "lighter_background",
  "foreground", "dark_foreground", "light_foreground", "bright_foreground", "cursor",
  "selection", "selection_background", "selection_foreground", "muted", "red", "green",
  "yellow", "blue", "magenta", "cyan", "orange", "brown", "bright_red", "bright_green",
  "bright_yellow", "bright_blue", "bright_magenta", "bright_cyan",
)
HEX_COLOR = re.compile(r"#[0-9a-fA-F]{6}\Z")
IN_CLOSE_WRITE = 0x8
IN_MOVED_TO = 0x80
IN_CREATE = 0x100
IN_DELETE = 0x200
IN_DELETE_SELF = 0x400
IN_MOVE_SELF = 0x800
IN_IGNORED = 0x8000
IN_Q_OVERFLOW = 0x4000
WATCH_EVENTS = IN_CLOSE_WRITE | IN_MOVED_TO | IN_CREATE | IN_DELETE | IN_DELETE_SELF | IN_MOVE_SELF


def palette_message(state):
  theme = state / "theme"
  source = {}
  try:
    # Opening a FIFO must never block the browser. Only regular source files
    # qualify; the byte cap also applies when a regular file grows while read.
    fd = os.open(theme / "colors.toml", os.O_RDONLY | os.O_NONBLOCK)
    try:
      if stat.S_ISREG(os.fstat(fd).st_mode):
        with os.fdopen(fd, "rb", closefd=False) as file:
          data = file.read(MAX_PALETTE_BYTES + 1)
        if len(data) <= MAX_PALETTE_BYTES:
          source = tomllib.loads(data.decode("utf-8"))
    finally:
      os.close(fd)
  except (OSError, ValueError, RecursionError):
    pass

  # No nested tables, arbitrary identifiers, theme names, or CSS expressions
  # cross the native boundary. Legacy aliases resolve to the same fixed schema.
  aliases = {
    "background": ("bg", "color0"), "foreground": ("fg", "color7"),
    "dark_background": ("dark_bg",), "darker_background": ("darker_bg",),
    "lighter_background": ("lighter_bg",), "dark_foreground": ("dark_fg", "color8"),
    "light_foreground": ("light_fg",), "bright_foreground": ("bright_fg", "color15"),
    "magenta": ("purple", "color5"), "bright_magenta": ("bright_purple", "color13"),
    "red": ("color1",), "green": ("color2",), "yellow": ("color3",),
    "blue": ("color4",), "cyan": ("color6",), "muted": ("color8",),
    "bright_red": ("color9",), "bright_green": ("color10",),
    "bright_yellow": ("color11",), "bright_blue": ("color12",), "bright_cyan": ("color14",),
  }
  colors = {}
  for key in COLOR_KEYS:
    for candidate in (key, *aliases.get(key, ())):
      value = source.get(candidate)
      if isinstance(value, str) and HEX_COLOR.fullmatch(value):
        colors[key] = value.lower()
        break

  # Match omarchy-theme-color's precedence and RGB-sum threshold, while
  # accepting only the two public modes rather than exporting arbitrary text.
  mode = next((source.get(key) for key in ("mode", "theme_type") if source.get(key) in ("dark", "light")), None)
  if mode is None:
    if (theme / "light.mode").is_file():
      mode = "light"
    elif "background" in colors:
      background = colors["background"]
      mode = "light" if sum(int(background[i:i + 2], 16) for i in (1, 3, 5)) > 382 else "dark"
    else:
      mode = "dark"
  return {"type": "palette", "mode": mode, "colors": colors}


def emit(message):
  payload = json.dumps(message, ensure_ascii=True, separators=(",", ":")).encode("ascii")
  if 0 < len(payload) <= MAX_MESSAGE_BYTES:
    sys.stdout.buffer.write(struct.pack("<I", len(payload)) + payload)
    sys.stdout.buffer.flush()


class Watcher:
  def __init__(self, state):
    self.state = state
    self.libc = ctypes.CDLL(None, use_errno=True)
    self.libc.inotify_init1.argtypes = (ctypes.c_int,)
    self.libc.inotify_init1.restype = ctypes.c_int
    self.libc.inotify_add_watch.argtypes = (ctypes.c_int, ctypes.c_char_p, ctypes.c_uint32)
    self.libc.inotify_add_watch.restype = ctypes.c_int
    self.libc.inotify_rm_watch.argtypes = (ctypes.c_int, ctypes.c_int)
    self.libc.inotify_rm_watch.restype = ctypes.c_int
    self.fd = self.libc.inotify_init1(os.O_NONBLOCK | os.O_CLOEXEC)
    if self.fd < 0:
      raise OSError(ctypes.get_errno(), "Cannot initialize theme watch")
    try:
      self.parent = self.add(state)
      self.theme = None
      self.watch_theme()
    except BaseException:
      self.close()
      raise

  def add(self, path):
    descriptor = self.libc.inotify_add_watch(self.fd, os.fsencode(path), WATCH_EVENTS)
    if descriptor < 0:
      error = ctypes.get_errno()
      raise OSError(error, os.strerror(error), path)
    return descriptor

  def watch_theme(self):
    previous = self.theme
    try:
      self.theme = self.add(self.state / "theme")
    except FileNotFoundError:
      self.theme = None
    if previous is not None and previous != self.theme:
      self.libc.inotify_rm_watch(self.fd, previous)

  def changed(self):
    data = os.read(self.fd, 65536)
    offset = 0
    relevant = False
    while offset < len(data):
      descriptor, mask, _, length = struct.unpack_from("iIII", data, offset)
      offset += 16
      name = os.fsdecode(data[offset:offset + length].split(b"\0", 1)[0])
      offset += length
      if mask & IN_Q_OVERFLOW:
        raise OSError("Theme watch overflowed")
      if descriptor == self.parent:
        if mask & (IN_DELETE_SELF | IN_MOVE_SELF | IN_IGNORED):
          # A dead watch must disconnect, not keep an apparently healthy port.
          raise OSError("Theme state directory was replaced")
        if name == "theme":
          self.watch_theme()
          relevant = True
      elif descriptor == self.theme:
        if mask & (IN_DELETE_SELF | IN_MOVE_SELF | IN_IGNORED):
          if not mask & IN_IGNORED:
            self.libc.inotify_rm_watch(self.fd, descriptor)
          self.theme = None
        if name in ("colors.toml", "light.mode") or not name:
          relevant = True
    return relevant

  def close(self):
    os.close(self.fd)


def shutdown(*_):
  raise SystemExit(0)


def main():
  state = Path.home() / ".local/state/omarchy/current"
  state.mkdir(parents=True, exist_ok=True)
  signal.signal(signal.SIGTERM, shutdown)
  signal.signal(signal.SIGINT, shutdown)
  watcher = Watcher(state)
  pending = bytearray()
  deadline = None
  try:
    with selectors.DefaultSelector() as selector:
      os.set_blocking(sys.stdin.fileno(), False)
      selector.register(sys.stdin, selectors.EVENT_READ, "request")
      selector.register(watcher.fd, selectors.EVENT_READ, "theme")
      emit(palette_message(state))
      while True:
        timeout = None if deadline is None else max(0, deadline - time.monotonic())
        for key, _ in selector.select(timeout):
          if key.data == "theme":
            if watcher.changed():
              deadline = time.monotonic() + 0.2
          else:
            data = os.read(sys.stdin.fileno(), 65536)
            if not data:
              return
            pending.extend(data)
            while len(pending) >= 4:
              length, = struct.unpack_from("<I", pending)
              if not 0 < length <= MAX_MESSAGE_BYTES:
                return
              if len(pending) < length + 4:
                break
              payload = bytes(pending[4:length + 4])
              del pending[:length + 4]
              try:
                if b"\0" in payload:
                  return
                request = json.loads(payload.decode("utf-8"), parse_constant=lambda _: None)
                if not isinstance(request, dict):
                  return
              except (ValueError, RecursionError):
                return
              emit(palette_message(state))
        if deadline is not None and time.monotonic() >= deadline:
          emit(palette_message(state))
          deadline = None
  finally:
    watcher.close()


if __name__ == "__main__":
  try:
    main()
  except BrokenPipeError:
    # Avoid a second buffered flush while the interpreter exits.
    os.dup2(os.open(os.devnull, os.O_WRONLY), sys.stdout.fileno())
  except OSError as error:
    print(f"Theme Sync host: {error}", file=sys.stderr)
    sys.exit(1)
