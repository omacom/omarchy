#!/usr/bin/env python3
"""Bounded process-group supervisor for the native QML singleton."""
from __future__ import annotations

from pathlib import Path
import json
import os
import signal
import sys
import time


sys.dont_write_bytecode = True
if __package__ in (None, ""):
  sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from backend.keyboard_settings import parse_request, response


MAX_RESPONSE_BYTES = 192 * 1024
ALLOWED_ACTIONS = {"animations", "catalog", "status", "choose", "switch", "save"}
TRANSPORT_ERROR = {
  "ok": False,
  "transportFailure": True,
  "error": "The keyboard helper did not respond safely. The result is unconfirmed.",
}


def _write_all(fd, data):
  view = memoryview(data)
  while view:
    written = os.write(fd, view)
    if written <= 0:
      raise OSError("short response write")
    view = view[written:]


def _close_unrelated(keep):
  try:
    descriptors = [int(name) for name in os.listdir("/proc/self/fd")]
  except OSError:
    descriptors = range(0, 1024)
  for descriptor in descriptors:
    if descriptor not in keep:
      try:
        os.close(descriptor)
      except OSError:
        pass


def _watch(read_fd, process_group, supervisor_pid):
  """Outlive a killed supervisor long enough to clean its descendants."""
  completed = False
  try:
    os.setsid()
    _close_unrelated({read_fd})
    while True:
      marker = os.read(read_fd, 1)
      if not marker:
        break
      completed = completed or marker == b"C"
  except OSError:
    pass
  finally:
    try:
      os.close(read_fd)
    except OSError:
      pass
  if completed:
    # The response was fully written. Let the group leader leave normally,
    # then clean only descendants that unexpectedly kept its group alive.
    deadline = time.monotonic() + 1
    while time.monotonic() < deadline:
      try:
        os.kill(supervisor_pid, 0)
      except ProcessLookupError:
        break
      except OSError:
        break
      time.sleep(0.01)
  try:
    os.killpg(process_group, signal.SIGTERM)
  except ProcessLookupError:
    os._exit(0)
  except OSError:
    os._exit(1)
  deadline = time.monotonic() + 1
  while time.monotonic() < deadline:
    try:
      os.killpg(process_group, 0)
    except ProcessLookupError:
      os._exit(0)
    except OSError:
      break
    time.sleep(0.02)
  try:
    os.killpg(process_group, signal.SIGKILL)
  except ProcessLookupError:
    pass
  except OSError:
    os._exit(1)
  os._exit(0)


def _install_watchdog():
  os.setsid()
  process_group = os.getpgrp()
  supervisor_pid = os.getpid()
  read_fd, write_fd = os.pipe2(os.O_CLOEXEC)
  child = os.fork()
  if child == 0:
    os.close(write_fd)
    _watch(read_fd, process_group, supervisor_pid)
    os._exit(1)
  os.close(read_fd)
  return write_fd


def _encode(value):
  data = (json.dumps(value, ensure_ascii=False, separators=(",", ":")) + "\n").encode("utf-8")
  if len(data) > MAX_RESPONSE_BYTES:
    return (json.dumps(TRANSPORT_ERROR, separators=(",", ":")) + "\n").encode("utf-8")
  return data


def main(arguments=None):
  arguments = sys.argv[1:] if arguments is None else arguments
  response_fd = os.dup(1)
  watchdog_fd = None
  try:
    watchdog_fd = _install_watchdog()
    null_fd = os.open("/dev/null", os.O_RDWR | os.O_CLOEXEC)
    os.dup2(null_fd, 1)
    os.dup2(null_fd, 2)
    if null_fd not in (1, 2):
      os.close(null_fd)
    try:
      action, request = parse_request(arguments)
      if action not in ALLOWED_ACTIONS:
        value = {"ok": False, "error": "Unknown request."}
      else:
        value = response(action, request)
    except (ValueError, UnicodeError):
      value = {"ok": False, "error": "Invalid request."}
    except BaseException:
      value = TRANSPORT_ERROR
    _write_all(response_fd, _encode(value))
    os.write(watchdog_fd, b"C")
    return 0 if value.get("ok") else 1
  except BaseException:
    try:
      _write_all(response_fd, _encode(TRANSPORT_ERROR))
    except OSError:
      pass
    return 2
  finally:
    if watchdog_fd is not None:
      try:
        os.close(watchdog_fd)
      except OSError:
        pass
    os.close(response_fd)


if __name__ == "__main__":
  raise SystemExit(main())
