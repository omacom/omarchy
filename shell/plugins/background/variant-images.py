#!/usr/bin/python
"""List still-image variants without decoding wallpapers into the shell."""

import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys


EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}


def dimensions(path, cache):
  try:
    stat = path.stat()
    signature = f"{path}\0{stat.st_size}\0{stat.st_mtime_ns}\0{stat.st_ctime_ns}"
    key = hashlib.sha256(signature.encode()).hexdigest()
    cached = cache / key
    if cached.is_file():
      width, height = json.loads(cached.read_text())
    else:
      width, height = (
        int(subprocess.check_output(
          ["vipsheader", "-f", field, str(path)],
          stderr=subprocess.DEVNULL, timeout=2,
        ))
        for field in ("width", "height")
      )
      if width <= 0 or height <= 0:
        return None
      cache.mkdir(parents=True, exist_ok=True)
      temporary = cached.with_suffix(f".{os.getpid()}.tmp")
      temporary.write_text(json.dumps([width, height]))
      temporary.replace(cached)
    return {"path": str(path), "width": width, "height": height}
  except (OSError, ValueError, subprocess.SubprocessError):
    return None


def candidates(default, cache):
  # The sibling directory opts an image into the convention. A directly
  # selected variant without its own sibling directory stays an ordinary file.
  if default.suffix.lower() not in EXTENSIONS:
    return []
  directory = default.with_suffix("")
  if not directory.is_dir():
    return []
  files = [default]
  files.extend(sorted(p for p in directory.iterdir()
            if p.is_file() and p.suffix.lower() in EXTENSIONS))
  return [result for p in files if (result := dimensions(p, cache))]


if __name__ == "__main__":
  default = Path(sys.argv[1])
  cache = Path(os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache"))) / "omarchy/background-dimensions"
  try:
    print(json.dumps(candidates(default, cache)))
  except OSError:
    print("[]")
