"""Exact-owned subprocess and compositor helpers for the Amiga controller."""
import contextlib
import ctypes
import json
import os
from pathlib import Path
import re
import signal
import subprocess

_OWNED = {}
APP_CLASS = 'org.omarchy.amiga-screensaver'


def ipc(method, *args):
  return subprocess.check_output(['omarchy-shell', 'idle', method, *args], text=True, timeout=4).strip()


def hypr(*args):
  return json.loads(subprocess.check_output(['hyprctl', '-j', *args], text=True, timeout=3))


def launch_command(command, log):
  parent = os.getpid()

  def die_with_owner():
    if ctypes.CDLL(None, use_errno=True).prctl(1, signal.SIGKILL, 0, 0, 0) != 0:
      os._exit(1)
    if os.getppid() != parent:
      os._exit(1)

  process = subprocess.Popen(command, env={}, stdout=log, stderr=subprocess.STDOUT,
                             start_new_session=True, preexec_fn=die_with_owner)
  try:
    _OWNED[process] = (process.pid, os.pidfd_open(process.pid))
  except OSError:
    process.kill()
    process.wait()
    raise
  return process


def stop(process):
  # Only real child handles registered by launch_command() can be cleaned up.
  # Never coerce a mock PID, use a name match, or signal a process group.
  if type(process) is not subprocess.Popen or type(process.pid) is not int or process.pid <= 1:
    raise ValueError('Refusing cleanup without a real owned subprocess')
  identity = _OWNED.get(process)
  if identity is None or identity[0] != process.pid:
    raise ValueError('Refusing cleanup of a process not created by this controller')
  fd = identity[1]
  try:
    # The kernel handle cannot retarget a reused numeric PID after child exit.
    with contextlib.suppress(ProcessLookupError):
      signal.pidfd_send_signal(fd, signal.SIGTERM)
    try:
      process.wait(timeout=2)
    except subprocess.TimeoutExpired:
      with contextlib.suppress(ProcessLookupError):
        signal.pidfd_send_signal(fd, signal.SIGKILL)
      process.wait()
  finally:
    _OWNED.pop(process, None)
    os.close(fd)


def owned_window(appid, process):
  matches = [c for c in hypr('clients') if c.get('class') == appid and c.get('initialClass') == appid]
  if len(matches) > 1:
    raise ValueError('Ambiguous owned window')
  if not matches:
    return None
  window = matches[0]
  pid = window.get('pid')
  if type(pid) is not int or pid <= 1:
    raise ValueError('Invalid emulator PID')
  current = pid
  while current > 1 and current != process.pid:
    current = int(Path(f'/proc/{current}/stat').read_text().rsplit(')', 1)[1].split()[1])
  if current != process.pid or Path(f'/proc/{pid}/comm').read_text().strip() != 'fs-uae':
    raise ValueError('Window is not a descendant of the registered sandbox')
  for namespace in ('pid', 'user', 'mnt', 'net'):
    if os.readlink(f'/proc/{pid}/ns/{namespace}') == os.readlink(f'/proc/self/ns/{namespace}'):
      raise ValueError('Emulator is not isolated')
  if not re.fullmatch(r'0x[0-9a-fA-F]+', window.get('address', '')):
    raise ValueError('Invalid owned window address')
  return window


def source_geometry_ready(window):
  return window.get('floating') is True and window.get('size') == [640, 480]


def _fullscreen_confirmed(address):
  try:
    for client in hypr('clients'):
      if client.get('address') == address:
        # Hyprland generations encode the mode differently (1 vs 2); any
        # nonzero fullscreen state presents the emulator across the output.
        return client.get('fullscreen', 0) != 0
  except (OSError, subprocess.SubprocessError, ValueError):
    pass
  return False


def fullscreen_window(address):
  """Fullscreen the owned emulator window, tolerant of Hyprland generations.

  Omarchy always ships Hyprland, but the dispatcher syntax changed when the
  Lua config API landed. Use the Lua form with an explicit idempotent
  action="set" and verify the resulting client state; verification matters
  because a param-level failure can still exit zero. Fall back to the classic
  focus+fullscreen pair for older builds.
  """
  if not re.fullmatch(r'0x[0-9a-fA-F]+', address):
    raise ValueError('Invalid owned window address')
  target = 'address:' + address
  # The capture guard is an exclusive overlay. Focus the exact owned client
  # before fullscreening it so the compositor schedules its initial buffers;
  # otherwise a covered Wayland client can remain on its black startup buffer.
  subprocess.run(['hyprctl', 'dispatch',
                  'hl.dsp.focus({ window = "' + target + '" })'],
                 capture_output=True, timeout=3)
  for _ in range(3):
    subprocess.run(['hyprctl', 'dispatch',
                    'hl.dsp.window.fullscreen({ window = "' + target + '", action = "set", mode = "fullscreen" })'],
                   capture_output=True, timeout=3)
    if _fullscreen_confirmed(address):
      return
  with contextlib.suppress(subprocess.SubprocessError):
    subprocess.run(['hyprctl', 'dispatch', 'focuswindow', target], capture_output=True, timeout=3)
    subprocess.run(['hyprctl', 'dispatch', 'fullscreen', '1'], capture_output=True, timeout=3)
  if not _fullscreen_confirmed(address):
    raise ValueError('Compositor refused fullscreen for the owned emulator window')
