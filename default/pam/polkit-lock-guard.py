"""Monitor the real compositor's lock protocol for a Polkit PAM transaction.

pam_omarchy_lock supplies a kernel-derived agent UID and a private control
socket. Root's namespace view crosses the PAM helper's ProtectHome sandbox.
No user environment, marker, logind hint or arbitrary command is trusted.
"""

import os
from pathlib import Path
import socket
import stat
import struct
import sys
import time

HOST_ROOT = Path("/proc/1/root")
HYPRLAND = HOST_ROOT / "usr/bin/Hyprland"
MAX_REPLY = 1024 * 1024


class Unavailable(Exception):
  pass


def owner_uid(pid):
  try:
    with open(f"/proc/{pid}/status", encoding="ascii") as source:
      for line in source:
        if line.startswith("Uid:"):
          fields = line.split()
          # The real and effective compositor owners must agree.
          if fields[1] != fields[2]:
            return None
          return int(fields[1])
  except (FileNotFoundError, ProcessLookupError):
    return None
  raise Unavailable("cannot identify compositor owner")


def trusted_executable(pid):
  try:
    candidate = Path(f"/proc/{pid}/exe")
    metadata = candidate.stat()
    if metadata.st_uid != 0 or metadata.st_mode & 0o022:
      return False
    # A package update may replace the executable while the session lives.
    if os.readlink(candidate) == "/usr/bin/Hyprland (deleted)":
      return True
    trusted = HYPRLAND.stat()
    return (metadata.st_dev, metadata.st_ino) == (trusted.st_dev, trusted.st_ino)
  except (FileNotFoundError, ProcessLookupError):
    return False


def compositor_pids(uid):
  for entry in Path("/proc").iterdir():
    if entry.name.isdecimal():
      pid = int(entry.name)
      if owner_uid(pid) == uid and trusted_executable(pid):
        yield pid


class Locked(Exception):
  pass


def wire_string(value):
  encoded = value.encode("ascii") + b"\0"
  return struct.pack("=I", len(encoded)) + encoded + b"\0" * (-len(encoded) % 4)


class LockNotification:
  """Minimal client for wl_registry and hyprland-lock-notify-v1 only.

  No surface, input, image or shared-memory protocols are bound. The socket
  has already been authenticated with SO_PEERCRED against the compositor.
  """

  def __init__(self, connection):
    self.connection = connection
    self.buffer = bytearray()
    self.next_id = 3
    self.manager_name = None
    self.notification = None
    self.callbacks = set()
    self.send(1, 1, struct.pack("=I", 2))  # wl_display.get_registry
    self.roundtrip()
    if self.manager_name is None:
      raise Unavailable("compositor has no lock-notify protocol")
    manager = self.allocate()
    self.notification = self.allocate()
    self.send(2, 0, struct.pack("=I", self.manager_name)
         + wire_string("hyprland_lock_notifier_v1") + struct.pack("=II", 1, manager))
    self.send(manager, 1, struct.pack("=I", self.notification))
    # An already-locked compositor sends locked before this sync completes.
    self.roundtrip()

  def allocate(self):
    result = self.next_id
    self.next_id += 1
    return result

  def send(self, target, opcode, payload=b""):
    message = struct.pack("=II", target, ((len(payload) + 8) << 16) | opcode) + payload
    self.connection.sendall(message)

  def receive(self):
    data = self.connection.recv(65536)
    if not data:
      raise Unavailable("compositor connection closed")
    self.buffer.extend(data)
    if len(self.buffer) > MAX_REPLY:
      raise Unavailable("oversized compositor event")
    while len(self.buffer) >= 8:
      target, header = struct.unpack_from("=II", self.buffer)
      size, opcode = header >> 16, header & 0xffff
      if size < 8 or size % 4:
        raise Unavailable("invalid compositor event")
      if len(self.buffer) < size:
        return
      payload = bytes(self.buffer[8:size])
      del self.buffer[:size]
      if target == 1 and opcode == 0:
        raise Unavailable("Wayland protocol error")
      if target == 2 and opcode == 0:
        if len(payload) < 12:
          raise Unavailable("invalid registry event")
        name, length = struct.unpack_from("=II", payload)
        if not 1 <= length <= 256 or 8 + length + 4 > len(payload):
          raise Unavailable("invalid registry interface")
        interface = payload[8:8 + length]
        if interface == b"hyprland_lock_notifier_v1\0":
          self.manager_name = name
      if target == self.notification and opcode == 0:
        raise Locked("compositor secured the session")
      if target in self.callbacks and opcode == 0:
        self.callbacks.remove(target)

  def roundtrip(self):
    callback = self.allocate()
    self.callbacks.add(callback)
    self.send(1, 0, struct.pack("=I", callback))
    deadline = time.monotonic() + 2.0
    while callback in self.callbacks:
      remaining = deadline - time.monotonic()
      if remaining <= 0:
        raise Unavailable("compositor check timed out")
      self.connection.settimeout(remaining)
      self.receive()


def connect_compositor(pid, uid, runtime):
  # User-owned directories and lock files are routing hints, not authority.
  try:
    entries = list(runtime.iterdir())
  except FileNotFoundError as error:
    raise Unavailable("compositor IPC is missing") from error
  if len(entries) > 256:
    raise Unavailable("too many compositor endpoints")
  for entry in entries:
    try:
      directory = os.open(entry, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    except OSError:
      continue
    try:
      lock_fd = os.open("hyprland.lock", os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=directory)
      with os.fdopen(lock_fd, "rb") as lock:
        if not stat.S_ISREG(os.fstat(lock.fileno()).st_mode):
          continue
        lines = lock.read(256).splitlines()
        if len(lines) < 2 or lines[0] != str(pid).encode("ascii"):
          continue
        display = lines[1].decode("ascii")
        if not display.startswith("wayland-") or not display[8:].isdecimal():
          continue
      # A directory fd keeps the AF_UNIX path short and pins the routing
      # directory despite renames. The peer must still be the real PID.
      runtime_fd = os.open(runtime.parent, os.O_RDONLY | os.O_DIRECTORY)
      try:
        connection = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        connection.settimeout(2.0)
        connection.connect(f"/proc/self/fd/{runtime_fd}/{display}")
      finally:
        os.close(runtime_fd)
      peer_pid, peer_uid, _ = struct.unpack("3i", connection.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, 12))
      if peer_pid == pid and peer_uid == uid and trusted_executable(peer_pid):
        return LockNotification(connection)
      connection.close()
    except (OSError, ValueError, IndexError):
      continue
    finally:
      os.close(directory)
  raise Unavailable("no authenticated compositor endpoint")


def refresh(clients, uid):
  for pid in compositor_pids(uid):
    if pid not in clients:
      clients[pid] = connect_compositor(pid, uid, HOST_ROOT / f"run/user/{uid}/hypr")
  for client in clients.values():
    client.roundtrip()


def watch(uids):
  import select
  import signal

  parent = os.getppid()
  if parent <= 1:
    return 2
  parent_fd = os.pidfd_open(parent)
  control = socket.socket(fileno=0)
  clients = {}
  ready = False
  agent = select.poll()
  # The descriptor is never read: passwords belong exclusively to PAM. Watch
  # only hangup so buffered credentials cannot cause an idle busy loop.
  disconnected = select.POLLHUP | select.POLLERR | select.POLLNVAL | select.POLLRDHUP
  agent.register(3, disconnected)

  def agent_connected():
    if agent.poll(0):
      raise Unavailable("authentication agent disconnected")

  try:
    agent_connected()
    for uid in uids:
      refresh(clients, uid)
    agent_connected()
    control.sendall(b"U")
    ready = True
    while True:
      by_fd = {client.connection.fileno(): client for client in clients.values()}
      events = select.poll()
      events.register(3, disconnected)
      events.register(control, select.POLLIN)
      for descriptor in by_fd:
        events.register(descriptor, select.POLLIN)
      readable = dict(events.poll())
      if 3 in readable:
        raise Unavailable("authentication agent disconnected")
      # Consume lock transitions before acknowledging account-stage checks.
      for descriptor in readable:
        if descriptor in by_fd:
          by_fd[descriptor].receive()
      if control.fileno() in readable:
        request = control.recv(1)
        if not request:
          return 0
        if request != b"Q":
          raise Unavailable("invalid guard request")
        for uid in uids:
          refresh(clients, uid)
        agent_connected()
        control.sendall(b"U")
  except (OSError, ValueError, Unavailable, Locked) as error:
    if ready:
      # Terminate only the pinned PAM helper that created this watcher.
      # The old authentication cannot survive a lock/unlock cycle.
      signal.pidfd_send_signal(parent_fd, signal.SIGKILL)
    else:
      control.sendall(b"L" if isinstance(error, Locked) else b"E")
    return 1 if isinstance(error, Locked) else 2
  finally:
    os.close(parent_fd)
    for client in clients.values():
      client.connection.close()


def main():
  if os.geteuid() != 0 or len(sys.argv) not in (2, 3):
    return 2
  check_only = sys.argv[1] == "--check"
  raw_uids = sys.argv[2:] if check_only else sys.argv[1:]
  if not raw_uids or any(not uid.isdecimal() or not 0 <= int(uid) < 2**32 - 1 for uid in raw_uids):
    return 2
  if not check_only and int(raw_uids[0]) == 0:
    return 2
  uids = set(int(uid) for uid in raw_uids) - {0}
  if not check_only:
    return watch(uids)
  try:
    for uid in uids:
      refresh({}, uid)
    return 0
  except Locked:
    return 1
  except (OSError, ValueError, Unavailable):
    return 2


if __name__ == "__main__":
  sys.exit(main())
