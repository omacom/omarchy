"""Restore only the stock SDDM entries removed by older Omarchy installers."""

import os
from pathlib import Path
import stat
import sys
import tempfile


STOCK = [
  "auth include system-login",
  "-auth optional pam_gnome_keyring.so",
  "-auth optional pam_kwallet5.so",
  "account include system-login",
  "password include system-login",
  "-password optional pam_gnome_keyring.so use_authtok",
  "session optional pam_keyinit.so force revoke",
  "session include system-login",
  "-session optional pam_gnome_keyring.so auto_start",
  "-session optional pam_kwallet5.so auto_start",
]
REMOVED = {STOCK[1], STOCK[5]}


def repaired_contents(original):
  lines = original.splitlines(keepends=True)
  active = [" ".join(line.split()) for line in lines if line.strip() and not line.lstrip().startswith("#")]
  # Already-configured custom stacks are administrator-owned too.
  if all(any(line.lstrip("-").startswith(kind + " ") and "pam_gnome_keyring.so" in line.split()
             for line in active) for kind in ("auth", "password", "session")):
    return original
  # Restore omissions only in the exact stock stack. Inserting into a custom
  # jump/ordering scheme could change authentication, even for optional modules.
  missing = REMOVED.difference(active)
  if active != [line for line in STOCK if line not in missing]:
    raise ValueError("Custom SDDM PAM stack: restore pam_gnome_keyring auth/password integration manually, then rerun omarchy-migrate. No PAM changes made.")
  additions = {
    STOCK[0]: "-auth       optional    pam_gnome_keyring.so\n",
    STOCK[4]: "-password   optional    pam_gnome_keyring.so    use_authtok\n",
  }
  result = []
  for line in lines:
    result.append(line)
    addition = additions.get(" ".join(line.split()))
    if addition and " ".join(addition.split()) in missing:
      if not line.endswith("\n"):
        result.append("\n")
      result.append(addition)
  return "".join(result)


def repair(path):
  if not path.exists():
    return
  if path.is_symlink() or not path.is_file():
    raise ValueError("Custom SDDM PAM path: review it manually. No PAM changes made.")
  original = path.read_text()
  replacement = repaired_contents(original)
  if replacement == original:
    return
  metadata = path.stat()
  fd, temporary = tempfile.mkstemp(prefix=".sddm-keyring-", dir=path.parent)
  try:
    with os.fdopen(fd, "w") as output:
      os.fchmod(output.fileno(), stat.S_IMODE(metadata.st_mode))
      os.fchown(output.fileno(), metadata.st_uid, metadata.st_gid)
      output.write(replacement)
      output.flush()
      os.fsync(output.fileno())
    os.replace(temporary, path)
  finally:
    if os.path.exists(temporary):
      os.unlink(temporary)


if __name__ == "__main__":
  try:
    if len(sys.argv) != 1:
      raise ValueError("This installed helper takes no arguments.")
    repair(Path("/etc/pam.d/sddm"))
  except (OSError, ValueError) as error:
    print(error, file=sys.stderr)
    sys.exit(1)
