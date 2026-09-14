echo "Repair an existing SDDM Qt5 theme selection with missing greeter libraries"

# This is a one-time repair, not a recurring theme-selection guard.
# An existing theme with SddmGreeterTheme/QtVersion=5 (the default) selects
# /usr/bin/sddm-greeter. If that executable lacks libraries, login stays black.
# Missing themes or executables already fall back safely in SDDM itself.
# Preserve working selections and replace only a confirmed broken Qt5 choice.

sddm_conf="${OMARCHY_SDDM_CONF:-/etc/sddm.conf}"
sddm_conf_dir="${OMARCHY_SDDM_CONF_DIR:-/etc/sddm.conf.d}"
sys_conf_dir="${OMARCHY_SDDM_SYS_CONF_DIR:-/usr/lib/sddm/sddm.conf.d}"
theme_dir="${OMARCHY_SDDM_THEME_DIR:-/usr/share/sddm/themes}"
qt5_greeter="${OMARCHY_SDDM_QT5_GREETER:-/usr/bin/sddm-greeter}"
qt6_greeter="${OMARCHY_SDDM_QT6_GREETER:-/usr/bin/sddm-greeter-qt6}"
backup_dir="${OMARCHY_SDDM_BACKUP_DIR:-/var/lib/omarchy/sddm-backups}"
proc_root="${OMARCHY_SDDM_PROC_ROOT:-/proc}"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

as_root python3 -I - "$sddm_conf" "$sddm_conf_dir" "$sys_conf_dir" "$theme_dir" "$qt5_greeter" "$qt6_greeter" "$backup_dir" "$proc_root" <<'PY'
import ctypes
import ctypes.util
import io
import os
from pathlib import Path
import re
import stat
import subprocess
import sys
import tempfile

conf, conf_dir, sys_dir, themes, qt5, qt6, backups, proc_root = map(Path, sys.argv[1:])
os.umask(0o077)
os.chdir('/')


def service_locale():
  def main_pid():
    result = subprocess.run(['systemctl', 'show', 'sddm.service', '--property=MainPID', '--value'],
      stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, timeout=5)
    return result.stdout.strip() if result.returncode == 0 else ''
  try:
    pid = main_pid()
    if not re.fullmatch(r'[1-9][0-9]*', pid):
      return None
    fd = os.open(proc_root / pid, os.O_RDONLY | os.O_DIRECTORY)
    try:
      if os.readlink('exe', dir_fd=fd).removesuffix(' (deleted)') != '/usr/bin/sddm':
        return None
      environment = {}
      with os.fdopen(os.open('environ', os.O_RDONLY, dir_fd=fd), 'rb') as source:
        for entry in source.read().split(b'\0'):
          key, _, value = entry.partition(b'=')
          if key in (b'LC_ALL', b'LC_COLLATE', b'LANG'):
            environment[key] = value
    finally:
      os.close(fd)
    if main_pid() == pid:
      return (environment.get(b'LC_ALL') or environment.get(b'LC_COLLATE') or environment.get(b'LANG') or b'C').decode('ascii').split('.')[0]
  except (OSError, ValueError, subprocess.TimeoutExpired):
    return None


# SDDM v0.21.0 ConfigReader.cpp loads vendor files, local files, then sddm.conf.
# Match Qt's ICU collation, not libc sort order; the last [Theme] value wins.
def directory_files(files):
  language = service_locale()
  if language is None:
    raise RuntimeError('Cannot determine the running SDDM service locale for competing [Theme] settings; leaving SDDM unchanged')
  if language in ('C', 'POSIX') or len(files) < 2:
    return sorted(files, key=lambda p: p.name.encode('utf-16-be'))
  library = ctypes.util.find_library('icui18n')
  if not library:
    raise RuntimeError('Cannot load Qt\'s ICU collator to resolve SDDM configuration order')
  icu = ctypes.CDLL(library)
  version = re.search(r'\.so\.(\d+)', library)
  suffix = '_' + version[1] if version else ''
  open_collator = getattr(icu, 'ucol_open' + suffix)
  open_collator.argtypes, open_collator.restype = [ctypes.c_char_p, ctypes.POINTER(ctypes.c_int)], ctypes.c_void_p
  sort_key = getattr(icu, 'ucol_getSortKey' + suffix)
  sort_key.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_void_p, ctypes.c_int]
  close_collator = getattr(icu, 'ucol_close' + suffix)
  close_collator.argtypes, close_collator.restype = [ctypes.c_void_p], None
  set_attribute = getattr(icu, 'ucol_setAttribute' + suffix)
  set_attribute.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.POINTER(ctypes.c_int)]
  set_attribute.restype = None
  error = ctypes.c_int(0)
  collator = open_collator(language.encode(), ctypes.byref(error))
  if error.value > 0 or not collator:
    raise RuntimeError(f'Cannot initialize the ICU collator for {language}')
  def key(path):
    name = path.name.encode('utf-16-le' if sys.byteorder == 'little' else 'utf-16-be')
    length = sort_key(collator, name, len(name) // 2, None, 0)
    buffer = ctypes.create_string_buffer(length)
    sort_key(collator, name, len(name) // 2, buffer, length)
    return buffer.raw
  try:
    NORMALIZATION, STRENGTH, NUMERIC, ALTERNATE = 4, 5, 7, 1
    ON, TERTIARY, OFF, NON_IGNORABLE = 17, 2, 16, 21
    for attribute, value in ((NORMALIZATION, ON), (STRENGTH, TERTIARY), (NUMERIC, OFF), (ALTERNATE, NON_IGNORABLE)):
      set_attribute(collator, attribute, value, ctypes.byref(error))
    if error.value > 0:
      raise RuntimeError('Cannot configure the ICU collator to match Qt')
    keys = {path: key(path) for path in files}
    if len(set(keys.values())) != len(keys):
      raise RuntimeError('SDDM configuration filenames have ambiguous ICU ordering; leaving SDDM unchanged')
    return sorted(files, key=keys.__getitem__)
  finally:
    close_collator(collator)


def configuration():
  groups = [[p for p in directory.iterdir() if not p.name.startswith('.') and p.is_file()]
    if directory.exists() else [] for directory in (sys_dir, conf_dir)]
  groups.append([conf] if conf.exists() else [])
  values = {'Current': '', 'ThemeDir': str(themes)}
  contents, assignments, resolved = {}, {}, {}
  active = None
  for path in (p for group in groups for p in group):
    contents[path] = path.read_bytes()
    assignments[path] = {}
    section = 'General'
    for number, raw in enumerate(io.StringIO(contents[path].decode('utf-8'))):
      line = raw.split('#', 1)[0].strip()
      if '=' in line:
        key, value = (part.strip() for part in line.split('=', 1))
        if section == 'Theme' and key in values:
          assignments[path][key] = (value, number)
      elif line.startswith('[') and line.endswith(']'):
        section = line[1:-1]
  for group in reversed(groups):
    ordered = None
    for key in values.keys() - resolved.keys():
      choices = [p for p in group if key in assignments[p]]
      if not choices:
        continue
      if len({assignments[p][key][0] for p in choices}) > 1:
        if ordered is None:
          ordered = directory_files(group)
        choices = [next(p for p in reversed(ordered) if key in assignments[p])]
      path = choices[0]
      resolved[key], number = assignments[path][key]
      if key == 'Current' and len(choices) == 1:
        active = (path, number)
  values.update(resolved)
  return values, contents, active


def qt_version(theme):
  path = theme / 'metadata.desktop'
  if not path.exists():
    return 5
  section, version = '', '5'
  for raw in re.split(r'\r\n|\r|\n', path.read_text(encoding='utf-8-sig')):
    line = raw.strip()
    if not line or line.startswith(('#', ';')):
      continue
    if '\\' in line:
      raise RuntimeError(f'Cannot safely interpret escaped SDDM metadata: {path}')
    quoted = False
    for offset, character in enumerate(line):
      if character == '"':
        quoted = not quoted
      elif character == ';' and not quoted:
        line = line[:offset].strip()
        break
    if quoted:
      raise RuntimeError(f'Cannot safely interpret multiline SDDM metadata: {path}')
    if line.startswith('['):
      if not re.fullmatch(r'\[[^\[\]]+\]', line):
        raise RuntimeError(f'Cannot safely interpret malformed SDDM metadata section: {path}')
      section = line[1:-1].strip()
      if section == 'General':
        section = ''
    elif '=' in line:
      key, value = (part.strip() for part in line.split('=', 1))
      key = re.sub(r'%U([\da-fA-F]{4})|%([\da-fA-F]{2})',
        lambda match: chr(int(match[1] or match[2], 16)), '/'.join(filter(None, (section, key))))
      if key == 'SddmGreeterTheme/QtVersion':
        version = value.replace('"', '').strip()
  if version.startswith('@'):
    if not (version.startswith('@String(') and version.endswith(')')):
      raise RuntimeError(f'Cannot safely interpret typed SDDM QtVersion metadata: {path}')
    version = version[8:-1].strip()
  return int(version) if re.fullmatch(r'[+-]?[0-9]+', version) else 0


# Consume ldd completely: grep -q can cause SIGPIPE and invert a pipefail test.
# Probe failures are errors, not evidence that the greeter is healthy.
def missing_libraries(binary):
  result = subprocess.run(['ldd', str(binary)], capture_output=True, text=True,
    env=dict(os.environ, LC_ALL='C'))
  if result.returncode:
    raise RuntimeError(f'ldd failed for {binary} ({result.returncode}): {result.stderr.strip()}')
  return re.search(r'=>\s+not found(?:\s|$)', result.stdout) is not None


def trusted_path(path):
  for part in (path, *path.parents):
    if not part.exists() and not part.is_symlink():
      continue
    info = part.lstat()
    sticky_parent = part != path and stat.S_ISDIR(info.st_mode) and info.st_mode & stat.S_ISVTX
    if stat.S_ISLNK(info.st_mode) or info.st_uid not in (0, os.geteuid()) or (info.st_mode & 0o022 and not sticky_parent):
      raise RuntimeError(f'Refusing an untrusted SDDM repair path: {part}')


# Save recovery copies outside SDDM's loaded directories, without replacing any
# prior backup. Publish only the effective assignment through an atomic rename.
def repair():
  if not os.access(qt5, os.X_OK):
    return
  values, contents, active = configuration()
  name = values['Current']
  selected = Path(values['ThemeDir']) / name
  if not name or not selected.exists() or qt_version(selected) != 5:
    return
  if not missing_libraries(qt5):
    return
  replacement = themes / 'omarchy'
  if not replacement.is_dir() or qt_version(replacement) != 6 or not os.access(qt6, os.X_OK) or missing_libraries(qt6):
    raise RuntimeError('The packaged Omarchy Qt6 greeter is not a safe replacement; leaving SDDM unchanged')
  replacement_name = 'omarchy' if Path(values['ThemeDir']) == themes else str(replacement.absolute())
  source, number = active if active else (None, None)
  target = source if source and (source == conf or (source.parent == conf_dir and source.suffix == '.conf')) else conf
  trusted_path(target)
  trusted_path(backups)
  if any(backups.resolve().is_relative_to(directory.resolve()) for directory in (sys_dir, conf_dir)):
    raise RuntimeError('SDDM recovery backups must be outside its loaded configuration directories')
  original = contents.get(target, b'')
  info = target.lstat() if target.exists() else None
  if info and (not stat.S_ISREG(info.st_mode) or info.st_nlink != 1):
    raise RuntimeError(f'Refusing to replace a non-regular or hard-linked SDDM configuration: {target}')
  if target == source:
    lines = list(io.StringIO(original.decode('utf-8')))
    line = lines[number]
    prefix = re.match(r'\s*Current\s*=\s*', line).group()
    end = len(line.split('#', 1)[0].rstrip())
    lines[number] = prefix + replacement_name + line[end:]
    updated = ''.join(lines).encode('utf-8')
  else:
    updated = original + (b'\n' if original and not original.endswith(b'\n') else b'')
    updated += f'[Theme]\nCurrent={replacement_name}\n'.encode('utf-8')
  if configuration() != (values, contents, active):
    raise RuntimeError('SDDM configuration changed during the repair; retry the migration')
  if info:
    backups.mkdir(mode=0o700, parents=True, exist_ok=True)
    backup = Path(tempfile.mkdtemp(prefix='1788380505-', dir=backups)) / target.name
    with backup.open('xb') as output:
      output.write(original)
      output.flush()
      os.fsync(output.fileno())
    print(f'Saved SDDM recovery copy: {backup}', flush=True)
  fd, temporary = tempfile.mkstemp(prefix='.omarchy-sddm-', dir=target.parent)
  try:
    with os.fdopen(fd, 'wb') as output:
      output.write(updated)
      if info:
        os.fchown(output.fileno(), info.st_uid, info.st_gid)
      os.fchmod(output.fileno(), stat.S_IMODE(info.st_mode) if info else 0o644)
      output.flush()
      os.fsync(output.fileno())
    os.replace(temporary, target)
  finally:
    if os.path.exists(temporary):
      os.unlink(temporary)
  print(f"Reset SDDM theme from '{name}' to '{replacement_name}' because the Qt5 greeter has missing libraries.")


try:
  repair()
except (OSError, ValueError, RuntimeError, AttributeError) as error:
  print(f'SDDM theme repair failed: {error}', file=sys.stderr)
  sys.exit(1)
PY
