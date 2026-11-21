#!/usr/bin/python3
"""Generate the target-native runtime integrity manifest after packaging."""
import hashlib
import json
from pathlib import Path
import platform
import sys

REQUIRED = ('fs-uae/FRAME_PROTOCOL', 'fs-uae/bin/fs-uae', 'audio/libopenal.so.1', 'audio/libamiga-pulse.so',
            'bin/gl-probe', 'guard/AmigaInput/libamigainput.so',
            'guard/AmigaInput/qmldir', 'guard/Guard.qml')


def main():
  if len(sys.argv) != 2:
    print('Usage: write-runtime-manifest.py <runtime-root>', file=sys.stderr)
    return 2
  root = Path(sys.argv[1]).resolve()
  files = {}
  actual = [path for path in root.rglob('*') if path.is_file() and path.name != 'runtime-manifest.json'
            and '__pycache__' not in path.parts and path.suffix != '.pyc']
  if any(path.is_symlink() for path in root.rglob('*')):
    raise ValueError('Runtime symlinks are forbidden')
  for path in sorted(actual):
    name = path.relative_to(root).as_posix()
    with path.open('rb') as stream:
      files[name] = hashlib.file_digest(stream, 'sha256').hexdigest()
  if set(REQUIRED) - set(files):
    raise ValueError('Missing runtime artifact: ' + sorted(set(REQUIRED) - set(files))[0])
  data = {'schema_version': 1, 'architecture': platform.machine(), 'files': files}
  target = root / 'runtime-manifest.json'
  temporary = target.with_suffix('.json.tmp')
  temporary.write_text(json.dumps(data, indent=2) + '\n')
  temporary.replace(target)
  return 0


if __name__ == '__main__':
  sys.exit(main())
