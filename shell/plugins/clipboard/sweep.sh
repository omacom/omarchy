#!/bin/bash

# Sweeps orphaned files in clipboard-images/ that are no longer referenced by
# clipboard-history.json (pre-existing leaks, legacy entries without inodes, or
# captures orphaned by a crash). Runs under the same .lock as capture.sh and
# fails safe on missing or malformed history.

set -o pipefail
umask 077

history_path=${1:-}
image_dir=${2:-}

[[ -f $history_path && ! -L $history_path && -d $image_dir ]] || exit 0

shopt -s nullglob
entries=("$image_dir"/*)
(( ${#entries[@]} > 0 )) || exit 0

python3 - "$history_path" "$image_dir" <<'PY'
import fcntl
import json
import os
import sys
import time

history_path, image_dir = sys.argv[1], sys.argv[2]
lock_path = os.path.join(image_dir, ".lock")

try:
  lock_fd = os.open(lock_path, os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
except OSError:
  sys.exit(0)

try:
  fcntl.flock(lock_fd, fcntl.LOCK_EX)

  try:
    hist_fd = os.open(history_path, os.O_RDONLY | os.O_NOFOLLOW)
    with os.fdopen(hist_fd, "r", encoding="utf-8") as f:
      data = json.load(f)
  except Exception:
    sys.exit(0)

  if not isinstance(data, list):
    sys.exit(0)

  keep = set()
  for item in data:
    if isinstance(item, dict) and (item.get("type") or item.get("kind")) == "image":
      path = item.get("path")
      if isinstance(path, str) and path:
        keep.add(path)
        try:
          keep.add(os.path.realpath(path))
        except OSError:
          pass

  cutoff = time.time() - 60
  try:
    with os.scandir(image_dir) as it:
      for entry in it:
        name = entry.name
        if name.startswith(".") or name.startswith("clipboard."):
          continue
        try:
          if not entry.is_file(follow_symlinks=False):
            continue
          full = entry.path
          if full in keep or os.path.realpath(full) in keep:
            continue
          if entry.stat(follow_symlinks=False).st_mtime < cutoff:
            os.unlink(full)
        except OSError:
          pass
  except OSError:
    pass
finally:
  os.close(lock_fd)
PY
