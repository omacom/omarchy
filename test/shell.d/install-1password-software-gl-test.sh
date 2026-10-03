#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

# The 1Password installer routes the app through the software GL wrapper only
# where there is no DRM render node, and keeps an administrator's launcher and
# the user's desktop customizations.
export ROOT
python3 - <<'PY'
import ctypes
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(os.environ['ROOT'])
installer = str(root / 'bin/omarchy-install-service-1password')

with tempfile.TemporaryDirectory() as tmp:
  tmp = Path(tmp)
  home = tmp / 'home'
  bind = tmp / 'bind'
  stubs = tmp / 'stubs'
  dri = tmp / 'dri'
  for directory in (home, bind, stubs, dri):
    directory.mkdir()
  real = tmp / '1Password app' / '1password'
  real.parent.mkdir()
  real.write_text('#!/bin/bash\nexit 0\n')
  real.chmod(0o755)
  vendor = tmp / '1password.desktop'
  original = f'''[Desktop Entry]
Name=1Password
Exec="{real}" %U
TryExec="{real}"
[Desktop Action custom]
Exec=env SPECIAL=yes chromium %U
'''
  vendor.write_text(original)
  calls = tmp / 'calls'

  def stub(name, body):
    path = stubs / name
    path.write_text('#!/bin/bash\n' + body + '\n')
    path.chmod(0o755)

  stub('omarchy-pkg-add', 'echo "pkg-add $*" >>"$CALLS"')
  stub('omarchy-cmd-missing', '[[ $1 == chromium ]]')
  stub('setsid', 'echo "launch $*" >>"$CALLS"')
  # Nothing here may escalate: the launcher directory is writable.
  stub('sudo', 'echo "sudo $*" >>"$CALLS"; exit 91')

  env = dict(os.environ, HOME=str(home), OMARCHY_PATH=str(root), CALLS=str(calls),
             PATH=f'{stubs}:{root}/bin:' + os.environ['PATH'],
             OMARCHY_ELECTRON_GL_BIND_DIR=str(bind), OMARCHY_1PASSWORD_BIN=str(real),
             OMARCHY_1PASSWORD_DESKTOP=str(vendor), OMARCHY_DRI_PATH=str(dri))

  def install(status=0):
    result = subprocess.run(['bash', installer], env=env, capture_output=True, text=True)
    assert result.returncode == status, (result.returncode, result.stdout, result.stderr)
    return result

  desktop = home / '.local/share/applications/1password.desktop'
  wrapper = bind / '1password'

  # A machine with a render node keeps the packaged launcher untouched.
  (dri / 'renderD128').touch()
  install()
  assert not wrapper.exists() and not desktop.exists()
  assert 'pkg-add 1password 1password-cli' in calls.read_text()
  assert 'sudo' not in calls.read_text()
  print('ok - a machine with a render GPU keeps the packaged 1Password launcher')

  # Without one, 1Password launches through the wrapper, and the user's entry
  # points at it with its arguments kept.
  (dri / 'renderD128').unlink()
  install()
  assert wrapper.is_file() and '# omarchy-electron-gl-wrapper' in wrapper.read_text()
  expected = original.replace(f'"{real}"', f'"{wrapper}"').replace(f'TryExec="{wrapper}"', f'TryExec={wrapper}')
  assert desktop.read_text() == expected, desktop.read_text()
  out = subprocess.run([str(wrapper), '--version'], env=env, capture_output=True, text=True)
  assert out.returncode == 0
  print('ok - without a render GPU 1Password launches through the software GL wrapper')

  # Reinstalling changes nothing and leaves no new backup of the entry.
  wrapper_before = wrapper.read_bytes()
  install()
  assert wrapper.read_bytes() == wrapper_before and desktop.read_text() == expected
  assert not list(desktop.parent.glob('1password.desktop.bak.*'))
  print('ok - reinstalling 1Password without a render GPU is idempotent')

  # A launcher an administrator owns is kept, and the install still finishes.
  wrapper.write_text('#!/bin/bash\n# administrator launcher\n')
  admin = wrapper.read_bytes()
  result = install()
  assert wrapper.read_bytes() == admin
  assert 'administrator-owned 1Password launcher' in result.stderr
  print('ok - an administrator-owned 1Password launcher is preserved')

  # A failed write is not an ownership conflict and stops the install.
  wrapper.unlink()
  stub('mktemp', 'exit 93')
  install(93)
  assert not wrapper.exists()
  (stubs / 'mktemp').unlink()
  print('ok - a wrapper that cannot be written stops the install')

  # GLib must accept the entry before and after a spaced executable path is
  # rewritten. Parsing the entry never runs its command.
  gio = ctypes.CDLL('libgio-2.0.so.0')
  gio.g_desktop_app_info_new_from_filename.argtypes = [ctypes.c_char_p]
  gio.g_desktop_app_info_new_from_filename.restype = ctypes.c_void_p
  gio.g_object_unref.argtypes = [ctypes.c_void_p]
  def resolves(path):
    app = gio.g_desktop_app_info_new_from_filename(os.fsencode(path))
    if app:
      gio.g_object_unref(app)
    return bool(app)
  spaced = tmp / 'wrapper directory' / '1password'
  spaced.parent.mkdir()
  spaced.write_bytes(real.read_bytes())
  spaced.chmod(0o755)
  valid = tmp / 'valid.desktop'
  valid.write_text(f'[Desktop Entry]\nType=Application\nName=Spaced path\nExec="{real}" %U\nTryExec={real}\n')
  assert resolves(valid), 'native resolver accepts the original unquoted TryExec path'
  repair = str(root / 'bin/omarchy-cmd-desktop-exec-repair')
  subprocess.run([repair, str(valid), str(vendor), str(spaced), str(real)], env=env, check=True)
  assert f'TryExec={spaced}\n' in valid.read_text()
  assert resolves(valid), 'native resolver accepts the repaired spaced wrapper path'
  bad = tmp / 'quoted.desktop'
  bad.write_text(valid.read_text().replace(f'TryExec={spaced}', f'TryExec="{spaced}"'))
  assert not resolves(bad), 'quoted TryExec is a rejected negative control'
  subprocess.run([repair, str(bad), str(vendor), str(spaced), str(real)], env=env, check=True)
  assert resolves(bad), 'a previously generated quoted wrapper route is repaired too'
  print('ok - repaired desktop entries still resolve in GLib')

  # A symlinked entry is the user's own route and is left alone.
  desktop.unlink()
  desktop.symlink_to(vendor)
  subprocess.run([repair, str(desktop), str(vendor), str(wrapper), str(real)], env=env, check=True)
  assert desktop.is_symlink() and vendor.read_text() == original
  print('ok - a symlinked desktop entry is preserved')
PY
