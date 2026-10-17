"""User-owned Top asset pack. No downloads, executable assets or boot fallback."""
import configparser
import fcntl
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import tempfile
import zipfile


def digest(path):
  with Path(path).open('rb') as stream:
    return hashlib.file_digest(stream, 'sha256').hexdigest()


def contained(root, name):
  path = PurePosixPath(name)
  if not name or path.is_absolute() or '..' in path.parts or str(path) != name:
    raise ValueError('Invalid pack path: ' + name)
  result = root / name
  if result.is_symlink() or not result.resolve().is_relative_to(root.resolve()):
    raise ValueError('Pack path escapes collection: ' + name)
  return result


def inventory(root):
  sums = {}
  for line in (root / 'SHA256SUMS').read_text().splitlines():
    match = re.fullmatch(r'([a-f0-9]{64})  (.+)', line)
    if not match or match[2] in sums:
      raise ValueError('Invalid or duplicate pack checksum')
    sums[match[2]] = match[1]
    path = contained(root, match[2])
    if not path.is_file() or digest(path) != match[1]:
      raise ValueError('Pack checksum mismatch: ' + match[2])
  return sums


def demo_path(production_id, value):
  """Resolve a checksum-bound path relative to one production folder."""
  if not isinstance(value, str) or not value:
    raise ValueError('Invalid per-demo path')
  path = PurePosixPath(value)
  if path.is_absolute() or '..' in path.parts or str(path) != value:
    raise ValueError('Invalid per-demo path')
  return production_id + '/' + value


def production_title(demo):
  title = demo.get('title')
  if not isinstance(title, str) or not title.strip() or any(ord(c) < 32 for c in title):
    raise ValueError('Missing or invalid catalog production title')
  return title


def playback_duration(demo):
  """Return the curator-measured presentation duration, when explicitly set."""
  playback = demo.get('playback')
  if playback is None:
    return None
  if not isinstance(playback, dict) or set(playback) != {'schema', 'duration_seconds'}:
    raise ValueError('Invalid playback metadata')
  if playback.get('schema') != 'amiga-playback-v1':
    raise ValueError('Unsupported playback metadata')
  seconds = playback.get('duration_seconds')
  if type(seconds) is not int or not 1 <= seconds <= 3600:
    raise ValueError('Invalid playback duration')
  return seconds


def validate_settings(settings):
  # Deliberately narrow pack contract, not FS-UAE's permissive option parser.
  # Validate both parsed input and the final relocated values before emission.
  enums = {
    'kickstart_file': {'internal'},
    'amiga_model': {'A500', 'A500/512K', 'A500+', 'A600', 'A1000', 'A1200'},
    'chipset': {'OCS', 'ECS', 'AGA'},
    'accuracy': {'-1', '0', '1', '100'},
    'floppy_drive_speed': {'0', '100', '200', '400', '800'},
    **{key: {'0', '1'} for key in ('ntsc', 'keep_aspect_ratio', 'grab_input', 'deterministic')},
    'chip_memory': {'128', '256', '512', '1024', '2048', '4096', '8192'},
    'slow_memory': {'0', '256', '512', '1024', '1536', '1792'},
    'fast_memory': {'0', '1', '2', '4', '8'},
  }
  disks = {f'floppy_drive_{n}' for n in range(4)}
  for key, value in settings.items():
    if not isinstance(value, str) or not value or any(not c.isprintable() for c in value):
      raise ValueError('Unsafe configuration value: ' + key)
    if key in disks:
      if not (value.startswith('$CONFIG/') or re.fullmatch(r'/media/[A-Za-z0-9_. -]+', value)):
        raise ValueError('Unsupported configuration disk path')
    elif key not in enums or value not in enums[key]:
      raise ValueError('Unsupported configuration value: ' + key)
  if settings.get('kickstart_file') != 'internal':
    raise ValueError('Unsupported configuration Kickstart')


def load(root=None):
  root = Path(root) if root is not None else Path.home() / 'Wallpapers/AMIGA'
  sums = inventory(root)
  configs = sorted(path for path in sums if PurePosixPath(path).name == 'config.json')
  if not configs:
    raise ValueError('No checksum-bound per-demo config.json files')
  records, ids, tasks = [], set(), set()
  for config_name in configs:
    parts = PurePosixPath(config_name).parts
    if len(parts) != 2:
      raise ValueError('config.json must live directly inside its production folder')
    production_id = parts[0]
    demo = json.loads(contained(root, config_name).read_text())
    if demo.get('schema') != 'amiga-demo-v1' or demo.get('id') != production_id:
      raise ValueError('Invalid per-demo production ID')
    if production_id in ids or production_id in ('.', '..'):
      raise ValueError('Invalid or duplicate production ID')
    ids.add(production_id)
    preview = demo_path(production_id, demo.get('preview'))
    if preview not in sums:
      raise ValueError('Unbound preview')
    approved = []
    for source_variant in demo.get('variants', []):
      variant = dict(source_variant)
      variant['config'] = demo_path(production_id, variant.get('config'))
      variant['state'] = demo_path(production_id, variant.get('state'))
      variant['media'] = [dict(media, path=demo_path(production_id, media.get('path')))
                          for media in variant.get('media', [])]
      if variant.get('task_id') in tasks:
        raise ValueError('Duplicate configuration ID')
      tasks.add(variant.get('task_id'))
      if variant.get('review_status') != 'Ok':
        raise ValueError('Top pack contains a non-approved configuration')
      for key in ('config', 'state'):
        if variant[key] not in sums:
          raise ValueError('Unbound configuration or state')
      if sums[variant['state']] != variant.get('state_sha256'):
        raise ValueError('State binding mismatch')
      state = contained(root, variant['state'])
      with state.open('rb') as stream:
        if stream.read(3) != b'ASF':
          raise ValueError('Invalid USS header')
      parser = configparser.ConfigParser(interpolation=None, strict=True)
      parser.read(contained(root, variant['config']))
      settings = dict(parser['fs-uae'])
      validate_settings(settings)
      mounts, options = [], set()
      for media in variant['media']:
        option, embedded = media['option'], media['embedded_path']
        if option not in {f'floppy_drive_{n}' for n in range(4)} or option in options:
          raise ValueError('Invalid media option')
        if not re.fullmatch(r'/media/[A-Za-z0-9_. -]+', embedded) or embedded.endswith(('/.', '/..')):
          raise ValueError('Invalid embedded media mount')
        if media['path'] not in sums or sums[media['path']] != media['sha256']:
          raise ValueError('Media binding mismatch')
        path = contained(root, media['path'])
        config_value = settings.get(option, '')
        resolved = (contained(root, variant['config']).parent / config_value.removeprefix('$CONFIG/')).resolve()
        if not config_value.startswith('$CONFIG/') or resolved != path.resolve():
          raise ValueError('Configuration/media path mismatch')
        options.add(option)
        mounts.append((path, embedded, media['sha256']))
        settings[option] = embedded
      if {k for k in settings if k.startswith('floppy_drive_') and k != 'floppy_drive_speed'} != options:
        raise ValueError('Unbound disk in configuration')
      for key, value in variant['settings'].items():
        if key not in options and settings.get(key) != value:
          raise ValueError('Configuration settings binding mismatch')
      playback_duration(variant)
      approved.append(dict(variant, source_id=production_id, title=production_title(demo), preview_path=contained(root, preview),
                           state_path=state, mounts=mounts, settings=settings, root=root,
                           config_sha256=sums[config_name]))
    if not approved:
      raise ValueError('Production has no approved state')
    records.append(next((record for record in approved if record.get('attempt') == 'primary'), approved[0]))
  return records


def install(archive, destination=None):
  destination = Path(destination) if destination is not None else Path.home() / 'Wallpapers/AMIGA'
  destination.parent.mkdir(parents=True, exist_ok=True)
  with (destination.parent / '.amiga-pack-install.lock').open('a') as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    with tempfile.TemporaryDirectory(prefix='.amiga-pack-', dir=destination.parent) as temp:
      stage = Path(temp) / 'AMIGA'
      stage.mkdir()
      with zipfile.ZipFile(archive) as source:
        names = set()
        total = 0
        for entry in source.infolist():
          if entry.is_dir():
            continue
          if not entry.filename.startswith('AMIGA/') or entry.filename in names:
            raise ValueError('Pack must have one AMIGA root and unique entries')
          names.add(entry.filename)
          if stat.S_ISLNK(entry.external_attr >> 16):
            raise ValueError('Pack links are forbidden')
          total += entry.file_size
          if total > 4 * 1024 ** 3:
            raise ValueError('Pack exceeds 4 GiB asset limit')
          target = contained(stage, entry.filename[len('AMIGA/'):])
          target.parent.mkdir(parents=True, exist_ok=True)
          with source.open(entry) as src, target.open('xb') as dst:
            shutil.copyfileobj(src, dst)
      load(stage)
      sums = inventory(stage)
      files = {p.relative_to(stage).as_posix() for p in stage.rglob('*') if p.is_file()}
      if files != set(sums) | {'SHA256SUMS'}:
        raise ValueError('Pack contains unchecked assets')
      if destination.is_symlink():
        raise ValueError('Collection destination cannot be a symlink')
      # Preflight the entire merge BEFORE changing any existing collection.
      additions = []
      for child in stage.iterdir():
        target = destination / child.name
        if target.exists() or target.is_symlink():
          if target.is_symlink() or target.is_dir() != child.is_dir():
            raise ValueError('Incompatible existing collection: ' + str(target))
          staged_files = list(child.rglob('*')) if child.is_dir() else [child]
          actual_files = list(target.rglob('*')) if target.is_dir() else [target]
          expected_names = {p.relative_to(child) for p in staged_files if p.is_file()}
          actual_names = {p.relative_to(target) for p in actual_files if p.is_file()}
          if expected_names != actual_names or any(p.is_symlink() for p in actual_files):
            raise ValueError('Incompatible existing folder: ' + str(target))
          for p in staged_files:
            if p.is_file() and digest(p) != digest(target / p.relative_to(child) if child.is_dir() else target):
              raise ValueError('Existing asset differs; refusing overwrite: ' + str(target))
        else:
          additions.append((child, target))
      destination.mkdir(exist_ok=True)
      installed = []
      try:
        for child, target in additions:
          os.rename(child, target)
          installed.append((child, target))
        load(destination)
      except BaseException:
        for child, target in reversed(installed):
          os.rename(target, child)
        raise
  return load(destination)
