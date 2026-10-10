"""One stable gate for usage publishers, cache collectors and acceptance cleanup.

The gate is a sibling of usage/, never part of a captured/replaced tree.
All participants use the same state context. Writers hold shared before
any protected mutation; cleanup holds exclusive while it captures/restores.
The outer gate precedes account-registry and per-provider cache locks.
"""
import argparse
import errno
from contextlib import contextmanager
import fcntl
import hashlib
import json
import os
from pathlib import Path
import sys
import stat
import tempfile
import time


def gate_path():
  state = Path(os.environ.get("XDG_STATE_HOME") or (Path.home() / ".local/state"))
  return state / "omarchy/agents/.usage-restore.lock"


@contextmanager
def shared_gate():
  path = gate_path()
  path.parent.mkdir(parents=True, exist_ok=True)
  # Do not truncate or replace the shared inode. Inherit no descriptor into
  # unrelated RPC children; this collector keeps its own descriptor alive.
  with path.open("a+") as handle:
    fcntl.flock(handle, fcntl.LOCK_SH)
    try:
      yield
    finally:
      fcntl.flock(handle, fcntl.LOCK_UN)


def process_identity(pid):
  if pid <= 0:
    raise ValueError("lock owner is not a live process")
  fields = (Path("/proc") / str(pid) / "stat").read_text().rsplit(") ", 1)[1].split()
  if fields[0] == "Z":
    raise ValueError("lock owner has exited")
  return fields[19]


def descriptor_exclusive_lock(descriptor):
  # Btrfs may expose a subvolume st_dev different from the kernel lock device.
  # Bind the FD to its path using stat, then obtain the kernel identity from
  # that very descriptor's held FLOCK evidence. Do not compare those devices.
  held = os.fstat(descriptor)
  expected = os.stat(gate_path())
  identity = (held.st_dev, held.st_ino)
  if identity != (expected.st_dev, expected.st_ino):
    raise ValueError("gate inode changed")
  locks = []
  for line in Path("/proc/self/fdinfo/" + str(descriptor)).read_text().splitlines():
    fields = line.split()
    if not fields or fields[0] != "lock:":
      continue
    if len(fields) != 9:
      raise ValueError("malformed descriptor lock evidence")
    if fields[2:5] != ["FLOCK", "ADVISORY", "WRITE"]:
      continue
    if not fields[1].endswith(":") or not fields[1][:-1].isdecimal() or fields[7:] != ["0", "EOF"]:
      raise ValueError("unsupported descriptor lock evidence")
    owner = int(fields[5])
    major, minor, inode = fields[6].split(":")
    kernel_identity = (int(major, 16), int(minor, 16), int(inode))
    if kernel_identity[2] != held.st_ino:
      raise ValueError("descriptor lock inode differs")
    start = process_identity(owner)
    locks.append((identity, kernel_identity, owner, start))
  if not locks:
    return None
  if len(locks) != 1:
    raise ValueError("ambiguous descriptor exclusive lock")
  current = os.fstat(descriptor)
  path = os.stat(gate_path())
  if identity != (current.st_dev, current.st_ino) or identity != (path.st_dev, path.st_ino):
    raise ValueError("gate binding changed during observation")
  if process_identity(locks[0][2]) != locks[0][3]:
    raise ValueError("lock owner identity changed")
  return locks[0]


def kernel_root_waiters(lock, table):
  """Bind READ waiters to this actual owner/root in one lock-table read.

  A kernel device/inode can collide across Btrfs subvolumes. Neither that
  pair alone nor fdinfo's FD-local row number names the global root lock.
  Require exactly one root with the held FD's owner and kernel identity,
  then accept only its own READ waiting relationship in this observation.
  """
  roots = []
  waiters = []
  for line in table.splitlines():
    fields = line.split()
    if not fields or not fields[0].endswith(":") or not fields[0][:-1].isdecimal():
      raise ValueError("malformed kernel lock row")
    root_id = int(fields[0][:-1])
    waiting = len(fields) > 1 and fields[1] == "->"
    record = fields[2:] if waiting else fields[1:]
    if not record or record[0] != "FLOCK":
      continue
    if len(record) != 7 or record[1] != "ADVISORY" or record[2] not in ("READ", "WRITE") or record[5:] != ["0", "EOF"]:
      raise ValueError("malformed kernel flock evidence")
    owner = int(record[3])
    major, minor, inode = record[4].split(":")
    identity = (int(major, 16), int(minor, 16), int(inode))
    if not waiting and record[2] == "WRITE" and owner == lock[2] and identity == lock[1]:
      roots.append(root_id)
    elif waiting and record[2] == "READ":
      waiters.append((root_id, identity, owner))
  if len(roots) != 1:
    raise ValueError("held kernel root is missing or ambiguous")
  return {owner for root_id, identity, owner in waiters if root_id == roots[0] and identity == lock[1]}


def revalidate_exclusive_lock(descriptor, lock):
  if descriptor_exclusive_lock(descriptor) != lock:
    raise ValueError("exclusive lease changed during observation")


def exclusive_held(descriptor):
  lock = descriptor_exclusive_lock(descriptor)
  if lock is None:
    return False
  kernel_root_waiters(lock, Path("/proc/locks").read_text())
  revalidate_exclusive_lock(descriptor, lock)
  return True


def blocked_on_gate(pid, descriptor):
  """True only for a kernel READ waiter on cleanup's actual held inode.

  Python collectors wait themselves. Bash's updater waits for its immediate
  flock child before its first protected mkdir. A later command mentioning a
  gate, a live pid, or an environment marker is not evidence of blocking.
  Read/parse failures are unknown and the caller keeps them active.
  """
  lock = descriptor_exclusive_lock(descriptor)
  if lock is None:
    raise ValueError("exclusive gate is not held")
  process = Path("/proc") / str(pid)
  before = (process / "stat").read_text().rsplit(") ", 1)[1].split()[19]
  children = (process / "task" / str(pid) / "children").read_text().split()
  candidates = {pid}
  for child in children:
    if not child.isdecimal():
      raise ValueError("invalid child pid")
    status = (Path("/proc") / child / "status").read_text()
    parent = next(line.split()[1] for line in status.splitlines() if line.startswith("PPid:"))
    if int(parent) != pid:
      raise ValueError("child relationship changed")
    candidates.add(int(child))
  waiting = kernel_root_waiters(lock, Path("/proc/locks").read_text())
  revalidate_exclusive_lock(descriptor, lock)
  after = (process / "stat").read_text().rsplit(") ", 1)[1].split()[19]
  if before != after:
    raise ValueError("process identity changed")
  status = (process / "status").read_text()
  threads = next(line.split()[1] for line in status.splitlines() if line.startswith("Threads:"))
  if threads != "1":
    return False
  if pid in waiting:
    return True
  # A shell that merely starts a blocked child may still be writing. Its
  # only child must be that waiter, and the shell itself must be in wait.
  # Without this kernel state, the relationship alone proves no exclusion.
  if len(children) != 1 or int(children[0]) not in waiting:
    return False
  # Only our unmodified normal updater is known to do no protected work
  # between this blocking flock and its successful return. Unknown parent
  # scripts remain active even if one of their children waits on the gate.
  argv = (process / "cmdline").read_bytes().split(b"\0")
  updater = Path(__file__).resolve().parent.parent / "bin/omarchy-agent-usage-update"
  if len(argv) < 3 or not argv[1] or not os.path.samefile(os.fsdecode(argv[1]), updater):
    return False
  if not os.path.samefile(process / "exe", "/bin/bash"):
    return False
  if (process / "wchan").read_text().strip() != "do_wait":
    return False
  if (process / "task" / str(pid) / "children").read_text().split() != children:
    raise ValueError("child set changed")
  return (process / "wchan").read_text().strip() == "do_wait"


def hold_exclusive(descriptor, seconds):
  deadline = time.monotonic() + seconds
  while True:
    try:
      fcntl.flock(descriptor, fcntl.LOCK_EX | fcntl.LOCK_NB)
      break
    except OSError as error:
      if error.errno not in (errno.EAGAIN, errno.EACCES) or time.monotonic() >= deadline:
        raise
      time.sleep(0.02)
  # Keep the actual acquisition owner alive. Linux /proc/locks filters locks
  # whose acquiring process has exited out of a child PID namespace, including
  # their waiters. The control pipe's EOF releases this actual lease.
  try:
    print("locked", flush=True)
    sys.stdin.buffer.read()
  finally:
    fcntl.flock(descriptor, fcntl.LOCK_UN)


def manifest_snapshot(path):
  """Semantic evidence only: bytes, entry names and symlink targets are hashed."""
  try:
    before = os.lstat(path)
  except FileNotFoundError:
    return None
  version = lambda info: (info.st_dev, info.st_ino, info.st_mode, info.st_size,
                         info.st_mtime_ns, info.st_ctime_ns)
  result = {"type": stat.S_IFMT(before.st_mode), "mode": stat.S_IMODE(before.st_mode)}
  if stat.S_ISLNK(before.st_mode):
    result["target_sha256"] = hashlib.sha256(os.fsencode(os.readlink(path))).hexdigest()
  elif stat.S_ISDIR(before.st_mode):
    names = sorted(os.listdir(path))
    result["entries"] = {hashlib.sha256(os.fsencode(name)).hexdigest(): manifest_snapshot(path / name)
                         for name in names}
    if names != sorted(os.listdir(path)):
      raise OSError("directory changed during manifest observation")
  elif stat.S_ISREG(before.st_mode):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
      for block in iter(lambda: stream.read(65536), b""):
        digest.update(block)
    result["sha256"] = digest.hexdigest()
  else:
    raise OSError("unsupported manifest path type")
  if version(before) != version(os.lstat(path)):
    raise OSError("path changed during manifest observation")
  return result


def write_manifest(descriptor, directory, phase, capture_id, shell, usage, cache,
                   live_shell, live_usage, live_cache, backup):
  if phase not in ("captured", "restored") or Path(capture_id).name != capture_id:
    raise ValueError("invalid manifest identity")
  if not exclusive_held(descriptor):
    raise ValueError("exclusive gate is not held")
  directory = Path(directory).absolute()
  # Neither a lexical path nor a symlink may put evidence in a replaced tree
  # or in the backup which successful cleanup is about to delete.
  for protected in (live_shell, live_usage, live_cache, backup):
    protected = Path(protected).absolute()
    for candidate, root in ((directory, protected), (directory.resolve(), protected.resolve())):
      if candidate == root or root in candidate.parents:
        raise ValueError("manifest directory is inside a protected tree")
  paths = {"shell.json": manifest_snapshot(Path(shell)),
           "usage": manifest_snapshot(Path(usage)), "cache": manifest_snapshot(Path(cache))}
  held = os.fstat(descriptor)
  payload = {"capture_id": capture_id, "phase": phase, "paths": paths,
             "exclusive_gate": {"device": held.st_dev, "inode": held.st_ino}}
  data = (json.dumps(payload, sort_keys=True, separators=(",", ":")) + "\n").encode()
  directory.mkdir(parents=True, exist_ok=True)
  destination = directory / ("agents-provider-" + capture_id + "-" + phase + ".json")
  if phase == "captured" and destination.exists():
    # Retain the successful prepare checkpoint; retry may only confirm it.
    if destination.read_bytes() != data:
      raise ValueError("captured manifest differs from its original checkpoint")
    return
  temporary = None
  try:
    raw, temporary = tempfile.mkstemp(prefix=".agents-provider-manifest-", dir=directory)
    with os.fdopen(raw, "wb") as stream:
      stream.write(data)
      stream.flush()
      os.fsync(stream.fileno())
    if not exclusive_held(descriptor):
      raise ValueError("exclusive gate was lost during manifest observation")
    os.replace(temporary, destination)
    temporary = None
    parent = os.open(directory, os.O_RDONLY | os.O_DIRECTORY)
    try:
      os.fsync(parent)
    finally:
      os.close(parent)
  finally:
    if temporary is not None:
      os.unlink(temporary)


if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  modes = parser.add_mutually_exclusive_group(required=True)
  modes.add_argument("--blocked", nargs=2, type=int, metavar=("PID", "FD"))
  modes.add_argument("--held", type=int, metavar="FD")
  modes.add_argument("--hold", nargs=2, metavar=("FD", "SECONDS"))
  modes.add_argument("--manifest", nargs=11, metavar="ARG")
  args = parser.parse_args()
  try:
    if args.manifest:
      write_manifest(int(args.manifest[0]), *args.manifest[1:])
      sys.exit(0)
    if args.hold:
      hold_exclusive(int(args.hold[0]), float(args.hold[1]))
      sys.exit(0)
    result = blocked_on_gate(*args.blocked) if args.blocked else exclusive_held(args.held)
  except (OSError, ValueError, IndexError, StopIteration):
    sys.exit(2)
  sys.exit(0 if result else 1)
