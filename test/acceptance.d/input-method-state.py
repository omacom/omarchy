"""Snapshot test-owned config paths, including targets of nested symlinks."""

import filecmp
import json
from pathlib import Path
import shutil
import sys


def copy(source, destination):
  if source.is_symlink():
    destination.symlink_to(source.readlink())
  elif source.is_dir():
    shutil.copytree(source, destination, symlinks=True)
  elif source.exists():
    shutil.copy2(source, destination)


def backup(directory, paths):
  directory.mkdir()
  recorded = {}

  def capture(path):
    path = path.absolute()
    if str(path) in recorded:
      return
    name = str(len(recorded))
    recorded[str(path)] = name
    copy(path, directory / name)
    if not path.parent.exists():
      capture(path.parent)
    # Setup writes to the resolved target; intermediate links are unchanged.
    resolved = path.resolve()
    if resolved != path:
      capture(resolved)
    if path.is_dir() and not path.is_symlink():
      for child in path.rglob("*"):
        if child.is_symlink():
          capture(child)

  for path in paths:
    capture(path)
  (directory / "paths.json").write_text(json.dumps(recorded))


def unchanged(saved, original):
  if saved.is_symlink() or original.is_symlink():
    return saved.is_symlink() and original.is_symlink() and saved.readlink() == original.readlink()
  if not saved.exists() or not original.exists():
    return not saved.exists() and not original.exists()
  if saved.stat().st_mode != original.stat().st_mode:
    return False
  if saved.is_file() and original.is_file():
    return filecmp.cmp(saved, original, shallow=False)
  if saved.is_dir() and original.is_dir():
    names = {child.name for child in saved.iterdir()}
    return names == {child.name for child in original.iterdir()} and all(
      unchanged(saved / name, original / name) for name in names
    )
  return False


def restore(directory):
  for original, name in json.loads((directory / "paths.json").read_text()).items():
    path = Path(original)
    saved = directory / name
    if unchanged(saved, path):
      continue
    if path.is_symlink() or path.is_file():
      path.unlink()
    elif path.is_dir():
      shutil.rmtree(path)
    if saved.exists() or saved.is_symlink():
      path.parent.mkdir(parents=True, exist_ok=True)
      copy(saved, path)


if __name__ == "__main__":
  action, directory, *paths = sys.argv[1:]
  if action == "backup":
    backup(Path(directory), [Path(path) for path in paths])
  elif action == "restore":
    restore(Path(directory))
  else:
    raise SystemExit("Expected backup or restore")
