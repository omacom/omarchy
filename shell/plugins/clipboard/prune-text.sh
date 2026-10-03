#!/bin/bash

# Keep both the overlay's pending entries and the last successful on-disk save.
# Recovery backups protect only the names they mention, even when malformed.
# Never follow links or delete paths supplied by a history file.

set -o pipefail

dir=${1:?usage: prune-text.sh <text-dir> <history-path> [name ...]}
history=${2:?usage: prune-text.sh <text-dir> <history-path> [name ...]}
shift 2

[[ -d $dir && ! -L $dir ]] || exit 0

timeout -k 1 30 python3 - "$dir" "$history" "$@" <<'PY'
import json
import fcntl
import os
import re
import stat
import sys
import time
from pathlib import Path

folder = Path(sys.argv[1])
history = Path(sys.argv[2])
pattern = re.compile(rb'[0-9a-f]{64}\.txt')
keep = set(sys.argv[3:])
now = time.time()


def regular(path):
  file = os.fdopen(os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK), 'rb')
  if not stat.S_ISREG(os.fstat(file.fileno()).st_mode):
    file.close()
    raise OSError('not a regular history')
  return file


try:
  lock = os.open(str(history) + '.lock', os.O_RDWR | os.O_CREAT | os.O_NOFOLLOW | os.O_NONBLOCK, 0o600)
  if not stat.S_ISREG(os.fstat(lock).st_mode):
    sys.exit(0)
  fcntl.flock(lock, fcntl.LOCK_EX)
  # A save can fail, or an older asynchronous write can still be pending.
  # Deleting files mentioned by the actual saved history would break restart.
  if history.exists() or history.is_symlink():
    with regular(history) as source:
      raw = source.read(32 * 1024 * 1024 + 1)
    if len(raw) > 32 * 1024 * 1024:
      sys.exit(0)
    entries = json.loads(raw or b'[]', parse_constant=lambda _: (_ for _ in ()).throw(ValueError('invalid constant')))
    if not isinstance(entries, list):
      sys.exit(0)
    for entry in entries:
      if isinstance(entry, dict) and entry.get('type') == 'largetext':
        keep.add(Path(str(entry.get('path', ''))).name)
  # Scan recovery files in chunks. A name split at a chunk boundary still counts.
  for backup in list(history.parent.glob(history.name + '.rejected-*')) + list(history.parent.glob(history.name + '.migrated-*')):
    if backup.is_symlink() or not backup.is_file():
      continue
    with regular(backup) as source:
      tail = b''
      while chunk := source.read(65536):
        data = tail + chunk
        keep.update(match.group().decode('ascii') for match in pattern.finditer(data))
        tail = data[-67:]
except (OSError, ValueError):
  sys.exit(0)

for file in folder.iterdir():
  info = file.lstat()
  if not stat.S_ISREG(info.st_mode):
    continue
  age = now - info.st_mtime
  if (pattern.fullmatch(file.name.encode()) and age > 60 and file.name not in keep
      or file.name.startswith('clipboard.') and age > 3600):
    file.unlink(missing_ok=True)
PY
