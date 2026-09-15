#!/usr/bin/env python3
"""Bounded deferred-data codec and login-time promotion helper.

This file is deliberately self-contained. Activation installs an exact copy in
the private keyboard-settings state directory so the fixed Lua loader remains
usable when the UI checkout is removed with --keep-settings.
"""
from __future__ import annotations

import errno
import fcntl
import os
from pathlib import Path
import re
import secrets
import stat
import sys


DATA_HEADER_V1 = b"omarchy.keyboard-layout-v1\n"
DATA_HEADER = b"omarchy.keyboard-layout-v2\n"
SUCCESS_PREFIX = b"omarchy.keyboard-layout-promote-v1\n"
FIELDS = ("name", "layout", "variant", "options")
SESSION_PATTERN = re.compile(r"[A-Za-z0-9_.:-]{1,256}")
MAX_DATA_BYTES = 64 * 1024
MAX_ROWS = 64
MAX_FIELD_BYTES = 4096
MAX_PATH_BYTES = 4096


class UnsafeState(Exception):
  """A state path is not a private, single-link regular file."""


class InvalidData(ValueError):
  """Deferred data is bounded but does not follow the inert data format."""


def _decode_hex(value, maximum, error):
  if (len(value) > maximum * 2 or len(value) % 2
      or re.fullmatch(rb"[0-9a-f]*", value) is None):
    raise InvalidData(error)
  try:
    return bytes.fromhex(value.decode("ascii"))
  except (UnicodeError, ValueError) as exc:
    raise InvalidData(error) from exc


def _session(value):
  if not isinstance(value, str) or (value and not SESSION_PATTERN.fullmatch(value)):
    raise InvalidData("invalid Hyprland session identifier")
  if len(value.encode("utf-8")) > 256:
    raise InvalidData("invalid Hyprland session identifier")
  return value


def decode(data):
  """Validate bounded inert data and return its session and rows."""
  if not isinstance(data, bytes) or not data or len(data) > MAX_DATA_BYTES or not data.endswith(b"\n"):
    raise InvalidData("invalid deferred keyboard data")
  if data.startswith(DATA_HEADER):
    lines = data[len(DATA_HEADER):].splitlines()
    if not lines or not lines[0].startswith(b"session\t"):
      raise InvalidData("invalid deferred keyboard session")
    fields = lines.pop(0).split(b"\t")
    if len(fields) != 2:
      raise InvalidData("invalid deferred keyboard session")
    try:
      saved = _decode_hex(fields[1], 256, "invalid deferred keyboard session").decode("utf-8")
    except (UnicodeError, ValueError) as exc:
      raise InvalidData("invalid deferred keyboard session") from exc
    _session(saved)
  elif data.startswith(DATA_HEADER_V1):
    lines = data[len(DATA_HEADER_V1):].splitlines()
    saved = ""
  else:
    raise InvalidData("invalid deferred keyboard data")

  if len(lines) > MAX_ROWS:
    raise InvalidData("too many deferred keyboard rows")
  rows = []
  names = set()
  for line in lines:
    if not line:
      continue
    values = line.split(b"\t")
    if len(values) != len(FIELDS):
      raise InvalidData("invalid deferred keyboard row")
    try:
      decoded = [_decode_hex(value, MAX_FIELD_BYTES, "invalid deferred keyboard field")
           for value in values]
      row = {key: value.decode("utf-8") for key, value in zip(FIELDS, decoded)}
    except (UnicodeError, ValueError) as exc:
      raise InvalidData("invalid deferred keyboard field") from exc
    if not row["name"] or row["name"] in names:
      raise InvalidData("invalid deferred keyboard name")
    names.add(row["name"])
    rows.append(row)
  return saved, rows


def render_rows(targets, session=""):
  """Encode validated rows without changing the v2 wire format."""
  session = _session(session)
  if not isinstance(targets, list) or len(targets) > MAX_ROWS:
    raise InvalidData("too many deferred keyboard rows")
  names = set()
  checked = []
  for target in targets:
    if not isinstance(target, dict) or any(not isinstance(target.get(key), str) for key in FIELDS):
      raise InvalidData("saved keyboard target is invalid")
    values = {key: target[key].encode("utf-8") for key in FIELDS}
    if any(len(value) > MAX_FIELD_BYTES for value in values.values()):
      raise InvalidData("saved keyboard field is too large")
    if not target["name"] or target["name"] in names:
      raise InvalidData("saved keyboard names overlap")
    names.add(target["name"])
    checked.append(values)
  lines = [DATA_HEADER.rstrip(b"\n"), b"session\t" + session.encode("utf-8").hex().encode("ascii")]
  lines.extend(b"\t".join(target[key].hex().encode("ascii") for key in FIELDS) for target in checked)
  result = b"\n".join(lines) + b"\n"
  if len(result) > MAX_DATA_BYTES:
    raise InvalidData("saved keyboard data is too large")
  return result


def _identity(info):
  return (info.st_dev, info.st_ino, info.st_mode, info.st_nlink,
      info.st_uid, info.st_size, info.st_mtime_ns, info.st_ctime_ns)


def _check_regular(info):
  if (not stat.S_ISREG(info.st_mode) or info.st_uid != os.geteuid()
      or info.st_nlink != 1 or stat.S_IMODE(info.st_mode) & 0o077):
    raise UnsafeState("state file is not a private owned regular file")


def _read_fd(fd, limit):
  before = os.fstat(fd)
  _check_regular(before)
  if before.st_size > limit:
    raise InvalidData("state file is too large")
  chunks = []
  size = 0
  while True:
    chunk = os.read(fd, min(65536, limit + 1 - size))
    if not chunk:
      break
    chunks.append(chunk)
    size += len(chunk)
    if size > limit:
      raise InvalidData("state file is too large")
  after = os.fstat(fd)
  if _identity(before) != _identity(after):
    raise UnsafeState("state file changed while it was read")
  return b"".join(chunks), _identity(after)


def read_at(directory_fd, name, limit, missing_ok=False):
  """Read a private regular file relative to a pinned directory."""
  flags = os.O_RDONLY | os.O_CLOEXEC | os.O_NOFOLLOW | os.O_NONBLOCK
  try:
    fd = os.open(name, flags, dir_fd=directory_fd)
  except FileNotFoundError:
    if missing_ok:
      return None, None
    raise
  except OSError as exc:
    if exc.errno in (errno.ELOOP, errno.ENXIO, errno.ENODEV):
      raise UnsafeState("unsafe state path") from exc
    raise
  try:
    return _read_fd(fd, limit)
  finally:
    os.close(fd)


def read_path(path, limit, missing_ok=False):
  """Read a private regular path without following its final component."""
  value = os.fspath(path)
  parent, name = os.path.split(value)
  try:
    directory_fd = os.open(parent or ".", os.O_RDONLY | os.O_DIRECTORY | os.O_CLOEXEC)
  except FileNotFoundError:
    if missing_ok:
      return None
    raise
  try:
    return read_at(directory_fd, name, limit, missing_ok)[0]
  finally:
    os.close(directory_fd)


def _current_identity(directory_fd, name):
  try:
    info = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
  except FileNotFoundError:
    return None
  return _identity(info)


def _write_all(fd, data):
  view = memoryview(data)
  while view:
    written = os.write(fd, view)
    if written <= 0:
      raise OSError("short state write")
    view = view[written:]


def _read_deferred(directory_fd, name, missing_ok=False):
  try:
    data, identity = read_at(directory_fd, name, MAX_DATA_BYTES, missing_ok)
  except InvalidData:
    try:
      info = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
      _check_regular(info)
      identity = _identity(info)
    except (OSError, UnsafeState) as exc:
      raise UnsafeState("unsafe deferred state path") from exc
    return None, None, identity
  if data is None:
    return None, None, None
  try:
    saved, rows = decode(data)
  except InvalidData:
    return None, None, identity
  return (saved, rows), data, identity


def _replace_active(directory_fd, data, active_identity, pending_identity):
  temporary = None
  fd = None
  renamed = False
  try:
    for _ in range(16):
      candidate = ".active-v1.conf." + secrets.token_hex(16)
      try:
        fd = os.open(candidate, os.O_RDWR | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW | os.O_CLOEXEC,
              0o600, dir_fd=directory_fd)
        temporary = candidate
        break
      except FileExistsError:
        continue
    if fd is None:
      raise OSError("could not allocate a deferred state temporary file")
    os.fchmod(fd, 0o600)
    _write_all(fd, data)
    os.fsync(fd)
    os.lseek(fd, 0, os.SEEK_SET)
    checked, temporary_identity = _read_fd(fd, MAX_DATA_BYTES)
    if checked != data or _current_identity(directory_fd, temporary) != temporary_identity:
      raise UnsafeState("deferred state temporary file changed")
    if (_current_identity(directory_fd, "active-v1.conf") != active_identity
        or _current_identity(directory_fd, "pending-v1.conf") != pending_identity):
      raise UnsafeState("deferred keyboard state changed during promotion")
    os.replace(temporary, "active-v1.conf", src_dir_fd=directory_fd, dst_dir_fd=directory_fd)
    renamed = True
    os.fsync(directory_fd)
    return data
  except Exception:
    if renamed:
      try:
        current, current_data, _ = _read_deferred(directory_fd, "active-v1.conf")
        if current is not None:
          return current_data
      except (OSError, UnsafeState, InvalidData):
        pass
    raise
  finally:
    if fd is not None:
      os.close(fd)
    if temporary is not None and not renamed:
      try:
        os.unlink(temporary, dir_fd=directory_fd)
      except FileNotFoundError:
        pass


def promote(root, current_session):
  """Return safe active bytes, promoting valid pending data when needed."""
  _session(current_session)
  if not os.path.isabs(root) or len(os.fsencode(root)) > MAX_PATH_BYTES:
    raise UnsafeState("invalid state root")
  directory_fd = os.open(root, os.O_RDONLY | os.O_DIRECTORY | os.O_CLOEXEC | os.O_NOFOLLOW)
  try:
    directory_info = os.fstat(directory_fd)
    if (directory_info.st_uid != os.geteuid()
        or stat.S_IMODE(directory_info.st_mode) & 0o077):
      raise UnsafeState("state root is not private")
    active, active_data, _ = _read_deferred(directory_fd, "active-v1.conf", missing_ok=True)
    pending, _, _ = _read_deferred(directory_fd, "pending-v1.conf", missing_ok=True)
    if (pending is None or not pending[0] or not current_session
        or pending[0] == current_session
        or (active is not None and active[1] == pending[1])):
      return active_data

    try:
      lock_fd = os.open("lock", os.O_RDWR | os.O_CLOEXEC | os.O_NOFOLLOW | os.O_NONBLOCK,
               dir_fd=directory_fd)
    except OSError as exc:
      raise UnsafeState("unsafe deferred state lock") from exc
    try:
      _check_regular(os.fstat(lock_fd))
      try:
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
      except BlockingIOError:
        return active_data
      active, active_data, active_identity = _read_deferred(
        directory_fd, "active-v1.conf", missing_ok=True)
      pending, pending_data, pending_identity = _read_deferred(
        directory_fd, "pending-v1.conf", missing_ok=True)
      if (pending is None or not pending[0] or not current_session
          or pending[0] == current_session
          or (active is not None and active[1] == pending[1])):
        return active_data
      return _replace_active(directory_fd, pending_data, active_identity, pending_identity)
    finally:
      os.close(lock_fd)
  finally:
    os.close(directory_fd)


def _main(argv):
  if len(argv) != 3:
    return 2
  try:
    legacy = Path(argv[1]).parent / "toggles/hypr/madmatt-keyboard-settings.lua"
    if legacy.exists() or legacy.is_symlink():
      return 0
    data = promote(argv[1], argv[2])
  except (OSError, ValueError, UnsafeState):
    return 1
  if data is None:
    return 0
  try:
    _write_all(1, SUCCESS_PREFIX + data)
  except OSError:
    return 1
  return 0


if __name__ == "__main__":
  raise SystemExit(_main(sys.argv))
