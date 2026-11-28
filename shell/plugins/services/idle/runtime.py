"""Integrity verification for an architecture-specific Amiga runtime."""
import hashlib
import json
from pathlib import Path
import platform
import re


def digest(path):
  with Path(path).open('rb') as stream:
    return hashlib.file_digest(stream, 'sha256').hexdigest()


def verify(root, required):
  root = Path(root)
  try:
    data = json.loads((root / 'runtime-manifest.json').read_text())
  except (OSError, ValueError) as error:
    raise ValueError('Missing or invalid runtime manifest') from error
  architecture = platform.machine()
  if data.get('schema_version') != 1 or data.get('architecture') != architecture:
    raise ValueError('Runtime architecture does not match this machine')
  files = data.get('files')
  if not isinstance(files, dict) or set(required) - set(files):
    raise ValueError('Runtime manifest does not bind every required file')
  actual = set()
  for path in root.rglob('*'):
    relative = path.relative_to(root).as_posix()
    if relative == 'runtime-manifest.json' or '__pycache__' in path.parts or path.suffix == '.pyc':
      continue
    if path.is_symlink():
      raise ValueError('Runtime contains a symlink outside its manifest: ' + relative)
    if path.is_file():
      actual.add(relative)
  if set(files) != actual:
    raise ValueError('Runtime manifest does not match the installed file set')
  for name in sorted(files):
    expected = files[name]
    path = root / name
    if not isinstance(expected, str) or not re.fullmatch(r'[a-f0-9]{64}', expected):
      raise ValueError('Invalid runtime manifest hash: ' + name)
    if not path.is_file() or path.is_symlink() or digest(path) != expected:
      raise ValueError('Runtime hash mismatch: ' + name)
