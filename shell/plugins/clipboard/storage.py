"""Bounded clipboard history transactions, shared by capture and the picker.

The lock covers publishing image files, saving their references, and collection.
Directory-relative operations never follow history-provided paths for deletion.
"""

import contextlib
import fcntl
import hashlib
import hmac
import json
import os
import re
import stat
import subprocess
import sys
import time
import uuid

TEXT_BYTES = 1024 * 1024
HISTORY_BYTES = 8 * 1024 * 1024
IMAGE_BYTES = 16 * 1024 * 1024
IMAGES_BYTES = 128 * 1024 * 1024
ENTRY_LIMIT = 500
EXTENSIONS = {"image/png": "png", "image/jpeg": "jpg", "image/webp": "webp",
              "image/gif": "gif", "image/bmp": "bmp", "image/tiff": "tiff"}
IMAGE_NAME = re.compile(r"[0-9a-f]{64}\.(?:png|jpg|webp|gif|bmp|tiff)\Z")
TEMP_NAME = re.compile(r"\.clipboard-history-[0-9a-f]{32}\Z")
HISTORY_NAME = "clipboard-history.json"
GENERATION_NAME = "clipboard-generation"
IDENTITY_KEY_NAME = "clipboard-identity-key"


class HistoryBlocked(Exception):
  pass


def encode(value):
  return json.dumps(value, ensure_ascii=False, separators=(",", ":")).encode("utf-8")


def notify(message):
  # Never include clipboard content in diagnostics or notifications.
  print("Clipboard history: " + message, file=sys.stderr)
  try:
    subprocess.run(["omarchy-notification-send", "Clipboard history", message],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=1)
  except (OSError, subprocess.TimeoutExpired):
    pass


def normalize(value):
  if isinstance(value, str):
    value = {"type": "text", "text": value}
  if not isinstance(value, dict):
    return None
  kind = value.get("type", value.get("kind"))
  if kind == "text":
    text = value.get("text")
    if not isinstance(text, str) or not text.strip():
      return None
    if len(text.encode("utf-8")) > TEXT_BYTES:
      raise HistoryBlocked("Text over 1 MiB is not recorded. The current clipboard is unchanged.")
    return {"type": "text", "text": text}
  if kind == "image":
    path = value.get("path")
    mime = value.get("mime", "image/png")
    if (not isinstance(path, str) or not os.path.isabs(path) or len(path) > 4096
        or path != os.path.normpath(path)
        or not isinstance(mime, str) or mime not in EXTENSIONS):
      return None
    entry = {"type": "image", "mime": mime, "path": path}
    timestamp = value.get("capturedAt")
    if isinstance(timestamp, str) and len(timestamp) <= 128:
      entry["capturedAt"] = timestamp
    return entry
  return None


def identity(entry):
  return (entry["type"], entry.get("path", entry.get("text")))


class Store:
  def __init__(self, repair_key=False):
    self.repair_key = repair_key

  def __enter__(self):
    self.handles = contextlib.ExitStack()
    state_home = os.environ.get("XDG_STATE_HOME") or os.path.join(os.environ["HOME"], ".local/state")
    self.path = os.path.abspath(os.path.join(state_home, "omarchy"))
    self.image_path = os.path.join(self.path, "clipboard-images")
    try:
      os.makedirs(self.path, mode=0o700, exist_ok=True)
      self.directory = self.open_directory(self.path)
      lock = self.open_file("clipboard-history.lock", os.O_RDWR | os.O_CREAT)
      until = time.monotonic() + 3
      while True:
        try:
          fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
          break
        except BlockingIOError:
          if time.monotonic() >= until:
            raise HistoryBlocked("History is busy; recording will retry on the next copy.")
          time.sleep(0.02)
      try:
        os.mkdir("clipboard-images", mode=0o700, dir_fd=self.directory)
      except FileExistsError:
        pass
      self.images = self.open_directory("clipboard-images", self.directory)
      # A killed atomic writer may leave a private staging file. Other writers
      # cannot be using one now that this process owns the shared lock.
      with os.scandir(self.directory) as files:
        for file in files:
          if TEMP_NAME.fullmatch(file.name):
            info = file.stat(follow_symlinks=False)
            if stat.S_ISREG(info.st_mode) and info.st_uid == os.getuid():
              os.unlink(file.name, dir_fd=self.directory)
      self.identity_key = self.read_identity_key()
      return self
    except Exception:
      self.handles.close()
      raise

  def __exit__(self, *args):
    return self.handles.__exit__(*args)

  def open_directory(self, path, parent=None):
    fd = os.open(path, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=parent)
    self.handles.callback(os.close, fd)
    info = os.fstat(fd)
    if info.st_uid != os.getuid() or info.st_mode & 0o022:
      raise HistoryBlocked("History directory must be owned by you and not writable by other users.")
    return fd

  def open_file(self, name, flags):
    fd = os.open(name, flags | os.O_NOFOLLOW | os.O_NONBLOCK, 0o600, dir_fd=self.directory)
    self.handles.callback(os.close, fd)
    info = os.fstat(fd)
    if not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid():
      raise HistoryBlocked("History storage is not a regular file owned by you.")
    return fd

  def read(self):
    try:
      fd = self.open_file(HISTORY_NAME, os.O_RDONLY)
    except FileNotFoundError:
      return []
    if os.fstat(fd).st_size > HISTORY_BYTES:
      raise HistoryBlocked("Saved history exceeds 8 MiB. Clear history to resume recording; the original file is unchanged.")
    with os.fdopen(os.dup(fd), "rb") as stream:
      raw = stream.read(HISTORY_BYTES + 1)
    if len(raw) > HISTORY_BYTES:
      raise HistoryBlocked("Saved history exceeds 8 MiB. Clear history to resume recording; the original file is unchanged.")
    try:
      parsed = json.loads(raw)
      if not isinstance(parsed, list):
        raise ValueError("not a list")
      return parsed
    except (ValueError, UnicodeError, RecursionError):
      raise HistoryBlocked("Saved history cannot be read. Clear history to resume recording; the original file is unchanged.")

  def owned_name(self, path):
    name = os.path.basename(path)
    if IMAGE_NAME.fullmatch(name) and path == os.path.join(self.image_path, name):
      return name
    return None

  def image_size(self, entry):
    name = self.owned_name(entry["path"])
    try:
      info = os.stat(name if name else entry["path"],
                     dir_fd=self.images if name else None, follow_symlinks=False)
      if not stat.S_ISREG(info.st_mode) or info.st_size > IMAGE_BYTES:
        return None
      return info.st_size
    except OSError:
      return None

  def read_identity_key(self):
    # IDs travel in process arguments. A keyed digest avoids exposing a hash
    # that another local user could test against guessed clipboard secrets.
    key = None
    try:
      fd = self.open_file(IDENTITY_KEY_NAME, os.O_RDONLY)
      key = os.read(fd, 33)
      if len(key) != 32 or stat.S_IMODE(os.fstat(fd).st_mode) != 0o600:
        raise HistoryBlocked("Clipboard identity storage is invalid. Clear history to reset it.")
    except FileNotFoundError:
      pass
    except (OSError, HistoryBlocked):
      if not self.repair_key:
        raise
      key = None
    if key is None:
      key = os.urandom(32)
      self.write_value(IDENTITY_KEY_NAME, key)
    return key

  def bounded(self, entries):
    result, keys = [], set()
    history_bytes, image_bytes = 2, 0
    for value in entries:
      try:
        entry = normalize(value)
      except HistoryBlocked:
        raise HistoryBlocked("Saved history contains text over 1 MiB. Clear history to resume recording; the original file is unchanged.")
      if entry is None or identity(entry) in keys:
        continue
      content = entry.get("path", entry.get("text"))
      entry["id"] = hmac.new(self.identity_key, (entry["type"] + "\0" + content).encode("utf-8"),
                             hashlib.sha256).hexdigest()
      size = self.image_size(entry) if entry["type"] == "image" else 0
      if size is None:
        continue
      serialized_bytes = len(encode(entry)) + (1 if result else 0)
      if (len(result) >= ENTRY_LIMIT or history_bytes + serialized_bytes > HISTORY_BYTES
          or image_bytes + size > IMAGES_BYTES):
        break
      result.append(entry)
      keys.add(identity(entry))
      history_bytes += serialized_bytes
      image_bytes += size
    return result

  def write_value(self, destination, data):
    name = ".clipboard-history-" + uuid.uuid4().hex
    try:
      fd = os.open(name, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW,
                   0o600, dir_fd=self.directory)
      with os.fdopen(fd, "wb") as stream:
        stream.write(data)
      os.replace(name, destination, src_dir_fd=self.directory, dst_dir_fd=self.directory)
    finally:
      try:
        os.unlink(name, dir_fd=self.directory)
      except FileNotFoundError:
        pass

  def generation(self):
    try:
      fd = self.open_file(GENERATION_NAME, os.O_RDONLY)
    except FileNotFoundError:
      return "0" * 32
    value = os.read(fd, 33).decode("ascii")
    if not re.fullmatch(r"[0-9a-f]{32}", value):
      raise HistoryBlocked("The clipboard capture state cannot be read. Clear history to resume recording.")
    return value

  def collect(self, history):
    referenced = {self.owned_name(entry["path"]) for entry in history if entry["type"] == "image"}
    with os.scandir(self.images) as files:
      for file in files:
        if not IMAGE_NAME.fullmatch(file.name) or file.name in referenced:
          continue
        try:
          info = file.stat(follow_symlinks=False)
          if stat.S_ISREG(info.st_mode) and info.st_uid == os.getuid():
            os.unlink(file.name, dir_fd=self.images)
        except FileNotFoundError:
          pass

  def transact(self, action, entry=None):
    # Clear is deliberately available when an oversized or malformed old file
    # cannot be loaded. Only this explicit action discards that blocked file.
    previous = [] if action == "clear" else self.read()
    if action == "clear":
      # Invalidate captures that started before clear, including producers still
      # streaming their bytes. Write this first so a crash cannot revive them.
      self.write_value(GENERATION_NAME, uuid.uuid4().hex.encode("ascii"))
    if action == "add":
      previous = [entry] + [value for value in previous if normalize(value) is not None
                            and identity(normalize(value)) != identity(entry)]
    elif action == "remove":
      previous = [value for value in previous if normalize(value) is not None
                  and identity(normalize(value)) != identity(entry)]
    history = self.bounded(previous)
    if action != "load" or history != previous:
      self.write_value(HISTORY_NAME, encode(history))
    self.collect(history)
    return history

  def add_image(self, data, mime, timestamp):
    # Refuse blocked legacy history before creating any image. No observer can
    # collect the new file before its reference is persisted under this lock.
    self.bounded(self.read())
    name = hashlib.sha256(data).hexdigest() + "." + EXTENSIONS[mime]
    try:
      fd = os.open(name, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW,
                   0o600, dir_fd=self.images)
    except FileExistsError:
      info = os.stat(name, dir_fd=self.images, follow_symlinks=False)
      if not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid() or info.st_size != len(data):
        raise HistoryBlocked("The captured image could not be stored safely.")
    else:
      with os.fdopen(fd, "wb") as stream:
        stream.write(data)
    entry = {"type": "image", "mime": mime, "path": os.path.join(self.image_path, name), "capturedAt": timestamp}
    self.transact("add", entry)
    return entry


def read_command():
  raw = sys.stdin.buffer.readline(HISTORY_BYTES + 1)
  if len(raw) > HISTORY_BYTES:
    raise HistoryBlocked("The clipboard item exceeds the history size limit and was not recorded.")
  return json.loads(raw)


def main():
  mode = sys.argv[1]
  try:
    if mode == "begin":
      with Store() as store:
        sys.stdout.write(store.generation() + "\n")
      return 0
    if mode == "image":
      mime, timestamp = sys.argv[2:4]
      if mime not in EXTENSIONS:
        raise HistoryBlocked("This image format is not supported by clipboard history.")
      data = sys.stdin.buffer.read(IMAGE_BYTES + 1)
      if len(data) > IMAGE_BYTES:
        raise HistoryBlocked("Images over 16 MiB are not recorded. The current clipboard is unchanged.")
      if not data:
        return
      with Store() as store:
        if len(sys.argv) > 4 and sys.argv[4] != store.generation():
          return 0
        result = store.add_image(data, mime, timestamp)
    elif mode == "add":
      entry = normalize(read_command())
      if entry is None:
        return
      with Store() as store:
        if len(sys.argv) > 2 and sys.argv[2] != store.generation():
          return 0
        store.transact("add", entry)
      # Preserve capture.sh's entry event protocol; stable IDs belong to the
      # persisted history and picker, not to the clipboard payload itself.
      result = {key: value for key, value in entry.items() if key != "id"}
    elif mode == "apply":
      request = read_command()
      if not isinstance(request, dict):
        raise ValueError("invalid request")
      action = request.get("action")
      if action not in ("load", "clear", "remove", "add"):
        raise ValueError("unknown action")
      entry = normalize(request.get("entry")) if action in ("remove", "add") else None
      if action in ("remove", "add") and entry is None:
        raise ValueError("missing entry")
      with Store(repair_key=action == "clear") as store:
        result = {"history": store.transact(action, entry), "blocked": False}
    elif mode in ("get", "copy", "get-index", "copy-index"):
      identifier = sys.argv[2]
      by_index = mode.endswith("-index")
      if not re.fullmatch(r"[0-9]+" if by_index else r"[0-9a-f]{64}", identifier):
        raise ValueError("invalid entry identifier")
      with Store() as store:
        history = store.bounded(store.read())
        if by_index:
          index = int(identifier)
          result = history[index] if index < len(history) else None
        else:
          result = next((entry for entry in history if entry["id"] == identifier), None)
        if result is None:
          raise HistoryBlocked("This entry has left clipboard history. Copy it again to use it.")
        if mode.startswith("copy"):
          if len(sys.argv) > 3 and result["type"] != sys.argv[3]:
            raise ValueError("unexpected entry type")
          if result["type"] == "image":
            # Open while holding the collector's lock. Once opened, unlinking
            # cannot invalidate this descriptor or cause an old clipboard paste.
            name = store.owned_name(result["path"])
            fd = os.open(name if name else result["path"], os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK,
                         dir_fd=store.images if name else None)
            with os.fdopen(fd, "rb") as stream:
              info = os.fstat(stream.fileno())
              if not stat.S_ISREG(info.st_mode) or info.st_size > IMAGE_BYTES:
                raise ValueError("invalid stored image")
              data = stream.read(IMAGE_BYTES + 1)
              if len(data) > IMAGE_BYTES:
                raise ValueError("image grew beyond its limit")
            copy_command = ["wl-copy", "--type", result["mime"]]
          else:
            data = result["text"].encode("utf-8")
            copy_command = ["wl-copy"]
      if mode.startswith("copy"):
        subprocess.run(copy_command, input=data, check=True, timeout=2)
        return 0
    else:
      raise ValueError("unknown command")
    sys.stdout.buffer.write(encode(result) + b"\n")
  except (HistoryBlocked, OSError, ValueError, UnicodeError, RecursionError,
          subprocess.SubprocessError) as error:
    message = str(error) if isinstance(error, HistoryBlocked) else "History storage is unavailable; no clipboard data was changed."
    notify(message)
    if mode == "apply":
      sys.stdout.buffer.write(encode({"history": [], "blocked": True, "error": message}) + b"\n")
    elif mode in ("copy", "get", "copy-index", "get-index"):
      return 1


if __name__ == "__main__":
  sys.exit(main())
