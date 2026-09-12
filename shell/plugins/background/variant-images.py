#!/usr/bin/python
"""List still-image variants without decoding wallpapers into the shell."""

import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time


EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}
CACHE_LIFETIME = 30 * 24 * 60 * 60


def cache_directory():
  return Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache") / "omarchy/background-dimensions"


def dimensions(path, cache):
  try:
    # Theme staging changes both timestamps even when the pixels are unchanged.
    # Hash compressed bytes instead; one record per path also bounds replacements.
    with path.open("rb") as image:
      signature = hashlib.file_digest(image, "sha256").hexdigest()
    cached = cache / hashlib.sha256(str(path).encode()).hexdigest()
  except OSError:
    return None

  try:
    record = json.loads(cached.read_text())
    if record["signature"] == signature and record["width"] > 0 and record["height"] > 0:
      try:
        cached.touch()
      except OSError:
        pass
      return {"path": str(path), "width": record["width"], "height": record["height"]}
  except (OSError, ValueError, KeyError, TypeError):
    pass

  try:
    # Read both fields in one process, rather than starting libvips twice.
    header = subprocess.check_output(
      ["vipsheader", "-a", str(path)],
      stderr=subprocess.DEVNULL, timeout=2, text=True,
    )
    fields = dict(line.split(": ", 1) for line in header.splitlines() if ": " in line)
    width, height = int(fields["width"]), int(fields["height"])
    if width <= 0 or height <= 0:
      return None
  except (OSError, ValueError, KeyError, subprocess.SubprocessError):
    return None

  # Caching is best-effort: a full or read-only cache must not hide a valid image.
  temporary = cached.with_suffix(f".{os.getpid()}.tmp")
  try:
    cache.mkdir(parents=True, exist_ok=True)
    temporary.write_text(json.dumps({"signature": signature, "width": width, "height": height}))
    temporary.replace(cached)
  except OSError:
    try:
      temporary.unlink(missing_ok=True)
    except OSError:
      pass
  return {"path": str(path), "width": width, "height": height}


def prune_cache(cache):
  try:
    cutoff = time.time() - CACHE_LIFETIME
    for entry in cache.iterdir():
      if entry.is_file() and entry.stat().st_mtime < cutoff:
        entry.unlink()
  except OSError:
    pass


def candidates(default, cache):
  # The sibling directory opts an image into the convention. A directly
  # selected variant without its own sibling directory stays an ordinary file.
  if default.suffix.lower() not in EXTENSIONS:
    return []
  directory = default.with_suffix("")
  if not directory.is_dir():
    return []
  prune_cache(cache)
  files = [default]
  files.extend(sorted(p for p in directory.iterdir()
            if p.is_file() and p.suffix.lower() in EXTENSIONS))
  return [result for p in files if (result := dimensions(p, cache))]


if __name__ == "__main__":
  default = Path(sys.argv[1])
  try:
    print(json.dumps(candidates(default, cache_directory())))
  except OSError:
    print("[]")
