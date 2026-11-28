#!/usr/bin/python3 -I
"""Switch the standard Omarchy sudo fingerprint rules as a single edit."""
import fcntl
import os
from pathlib import Path
import shutil
import stat
import sys
import tempfile

PAM = Path("/etc/pam.d/sudo")
GATE = b"auth      [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed"
FINGERPRINT = b"auth      sufficient pam_fprintd.so"
PASSWORD = b"auth include system-auth".split()
FIDO = b"auth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2".split()


def rules(contents):
  """Locate the password fallback and the optional Omarchy fingerprint pair."""
  auth = []
  for index, line in enumerate(contents.splitlines(keepends=True)):
    fields = line.split(b"#", 1)[0].split()
    if not fields:
      continue
    kind = fields[0].lower()
    if kind.lstrip(b"-") not in (b"auth", b"password", b"account", b"session") or kind == b"-auth" or fields[-1].endswith(b"\\"):
      raise ValueError("Custom sudo PAM configuration")
    if kind == b"auth":
      auth.append((index, fields))
  # Omarchy can also put its independent security-key method before sudo's
  # password stack. A method between the gate and fingerprint breaks its jump.
  if auth and auth[0][1] == FIDO:
    auth.pop(0)
  if len(auth) >= 2 and auth[-2][1] == FIDO:
    auth.pop(-2)
  kinds = [fields for _, fields in auth]
  if kinds == [PASSWORD]:
    return auth[0][0], ()
  if kinds == [GATE.split(), FINGERPRINT.split(), PASSWORD]:
    return auth[-1][0], (auth[0][0], auth[1][0])
  raise ValueError("Custom sudo PAM configuration")


def enabled(path=PAM):
  try:
    info = path.lstat()
    if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1:
      return None
    _, pair = rules(path.read_bytes())
    return bool(pair)
  except (OSError, ValueError):
    return None


def configure(path, enable):
  # Lock the directory, since this operation replaces the target inode.
  directory = os.open(path.parent, os.O_RDONLY | os.O_DIRECTORY)
  try:
    fcntl.flock(directory, fcntl.LOCK_EX)
    info = path.lstat()
    if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1:
      raise ValueError("Custom sudo PAM configuration")
    original = path.read_bytes()
    password, pair = rules(original)
    if bool(pair) == enable:
      return
    lines = original.splitlines(keepends=True)
    if enable:
      lines[password:password] = [GATE + b"\n", FINGERPRINT + b"\n"]
    else:
      for index in reversed(pair):
        del lines[index]
    fd, name = tempfile.mkstemp(dir=path.parent, prefix=".omarchy-sudo-")
    try:
      with os.fdopen(fd, "wb") as staged:
        staged.writelines(lines)
        staged.flush()
        os.fchown(fd, info.st_uid, info.st_gid)
        shutil.copystat(path, name)
        os.utime(name)
        os.fsync(fd)
      current = path.lstat()
      if (current.st_ino, current.st_ctime_ns) != (info.st_ino, info.st_ctime_ns):
        raise ValueError("The sudo PAM configuration changed. Try again.")
      os.replace(name, path)
    finally:
      Path(name).unlink(missing_ok=True)
  finally:
    os.close(directory)


if __name__ == "__main__":
  if sys.argv[1:] == ["status"]:
    print({True: "enabled", False: "disabled", None: "custom"}[enabled()])
    sys.exit(0)
  if len(sys.argv) != 2 or sys.argv[1] not in ("enable", "disable") or os.geteuid() != 0:
    sys.exit("Run as an administrator with enable or disable.")
  try:
    configure(PAM, sys.argv[1] == "enable")
  except (OSError, ValueError) as error:
    sys.exit(str(error))
