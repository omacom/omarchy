"""Mock mount/loop state; signal only fixture PIDs in a fresh PID namespace."""

import os
from pathlib import Path
import signal
import shutil
import subprocess
import sys
import time

assert os.getpid() == 1, 'this fixture must run as PID 1 in a fresh PID namespace'
root = Path(os.environ['ROOT'])
scratch = Path(sys.argv[1]) / 'signals'
scratch.mkdir()
command = scratch / 'wifi'
source = (root / 'bin/omarchy-hw-t2-wifi').read_text()
# A regular fixture file stands for the block node. No mknod, loop setup or
# real mount is needed; every command crossing that boundary is a stub.
source = source.replace('! -b $t2_loop', '! -f $t2_loop').replace('! -b $loop', '! -f $loop')
command.write_text(source)
bin_dir = scratch / 'bin'
bin_dir.mkdir()
for name in ('cat', 'dirname', 'mktemp', 'mkdir', 'rm', 'touch', 'awk', 'sleep'):
  (bin_dir / name).symlink_to(shutil.which(name) or '/usr/bin/' + name)
stubs = {
  'setsid': '''case ${T2_LAUNCH:-normal} in
  fail) exit 127 ;;
  before-session)
    echo $$ >"$T2_CASE/ready"
    exec /usr/bin/sleep 30
    ;;
esac
exec /usr/bin/setsid "$@"''',
  'lspci': "echo '[106b:1801]'",
  'omarchy-cmd-present': 'exit 1',
  'ip': "echo 'default via fixture'",
  'df': "printf 'Filesystem Available\nfixture 0 0 8000000\n'",
  'sudo': 'exit 99',
  'omarchy-pkg-add': 'exit 0',
  'dmg2img': ': >"${@: -1}"',
  'lsblk': 'printf "%s part\\n" "$T2_CASE/loop"',
  'mountpoint': '[[ -f $T2_CASE/mounted ]]',
  'umount': 'echo umount >>"$T2_CASE/events"\n[[ $T2_PHASE != "umount-fails" ]] || exit 1\nrm -f "$T2_CASE/mounted"',
  'losetup': '''if [[ $1 == "-d" ]]; then
  echo detach >>"$T2_CASE/events"
  [[ $T2_PHASE != "detach-fails" ]] || exit 1
else
  touch "$T2_CASE/loop"
  echo "$T2_CASE/loop"
fi''',
  'recovery': ''': >"${@: -1}/BaseSystem.dmg"
if [[ $T2_PHASE == "download" ]]; then
  echo $$ >"$T2_CASE/ready"
  exec /usr/bin/sleep 30
fi''',
  'mount': '''touch "$T2_CASE/mounted"
if [[ $T2_PHASE == "mounted" ]]; then
  echo $$ >"$T2_CASE/ready"
  exec /usr/bin/sleep 30
fi
exit 1''',
}
for name, body in stubs.items():
  path = bin_dir / name
  path.write_text('#!/bin/bash\nset -eu\n' + body + '\n')
  path.chmod(0o755)


def reap():
  while True:
    try:
      pid, _ = os.waitpid(-1, os.WNOHANG)
    except ChildProcessError:
      return
    if pid == 0:
      return


try:
  cases = [('download', signal.SIGTERM, 'normal', False), ('mounted', signal.SIGTERM, 'normal', False), ('mounted', signal.SIGHUP, 'normal', False), ('mounted', signal.SIGINT, 'normal', False), ('failure', None, 'normal', False), ('umount-fails', None, 'normal', False), ('detach-fails', None, 'normal', False), ('download', signal.SIGTERM, 'before-session', False), ('download', None, 'fail', False), ('download', signal.SIGTERM, 'normal', True)]
  for phase, sig, launch, monitor in cases:
    case = scratch / f'{phase}-{sig}-{launch}-{monitor}'
    case.mkdir()
    for name in ('tmp', 'work', 'firmware', 'home', 'runtime'):
      (case / name).mkdir()
    (case / 'product').write_text('MacBookPro15,2\n')
    (case / 'vendor').write_text('Apple Inc.\n')
    env = dict(PATH=str(bin_dir), HOME=str(case / 'home'), TMPDIR=str(case / 'tmp'), XDG_RUNTIME_DIR=str(case / 'runtime'), ROOT=str(root), OMARCHY_PATH=str(root), T2_CASE=str(case), T2_PHASE=phase, OMARCHY_DMI_PRODUCT_NAME=str(case / 'product'), OMARCHY_DMI_SYS_VENDOR=str(case / 'vendor'), OMARCHY_T2_WIFI_FIRMWARE_DIR=str(case / 'firmware'), OMARCHY_T2_WIFI_WORKDIR_PARENT=str(case / 'work'), OMARCHY_T2_WIFI_RECOVERY_CMD=str(bin_dir / 'recovery'))
    env['T2_LAUNCH'] = launch
    for key, suffix in [('XDG_CONFIG_HOME', '.config'), ('XDG_CACHE_HOME', '.cache'), ('XDG_DATA_HOME', '.local/share'), ('XDG_STATE_HOME', '.local/state')]:
      env[key] = str(case / 'home' / suffix)
    with (case / 'stdout').open('w') as out, (case / 'stderr').open('w') as err:
      # The sibling shares the caller's group. It must never receive cleanup's
      # signals, including before setsid has created the helper's new group.
      sibling = subprocess.Popen(['/usr/bin/sleep', '30'])
      process = subprocess.Popen(['/bin/bash', *(['-m'] if monitor else []), str(command)], env=env, stdout=out, stderr=err)
      if sig is not None:
        deadline = time.monotonic() + 3
        while not (case / 'ready').exists() and process.poll() is None and time.monotonic() < deadline:
          time.sleep(0.01)
        assert (case / 'ready').exists(), (case / 'stderr').read_text()
        child = int((case / 'ready').read_text())
        if launch == 'normal':
          assert os.getpgid(child) == child, 'tracked helper is not its new group leader'
        # This is the command's top-level PID, not its helper or process group.
        os.kill(process.pid, sig)
      status = process.wait(timeout=4)
      assert sibling.poll() is None, 'cleanup signaled a sibling in the caller group'
      sibling.terminate()
      sibling.wait(timeout=2)
    if sig is not None:
      assert status == 128 + sig, (status, (case / 'stderr').read_text())
      child = int((case / 'ready').read_text())
      reap()
      assert not Path(f'/proc/{child}').exists(), f'fixture child {child} survived'
    else:
      assert status == 1, (status, (case / 'stderr').read_text())
    events = (case / 'events').read_text().splitlines() if (case / 'events').exists() else []
    if phase in ('umount-fails', 'detach-fails'):
      assert list((case / 'work').iterdir()), 'failed cleanup removed its backing image'
      assert 'keeping' in (case / 'stderr').read_text()
      if phase == 'umount-fails':
        assert events == ['umount'], events
    else:
      assert not list((case / 'work').iterdir()), 'recovery files leaked'
      assert not list((case / 'tmp').iterdir()), 'mount directory leaked'
      if phase != 'download':
        assert events == ['umount', 'detach'], events
    print(f'ok - {phase}/{launch}/monitor={monitor}: top-level {sig.name if sig else "failure exit"} preserves sibling and cleans or preserves resources', flush=True)
finally:
  # PID 1 can see only these fixture descendants. Clean and reap even if an
  # assertion or timeout failed before the command's own cleanup completed.
  for entry in Path('/proc').iterdir():
    if entry.name.isdigit() and int(entry.name) > 1:
      try:
        os.kill(int(entry.name), signal.SIGKILL)
      except ProcessLookupError:
        pass
  while True:
    try:
      os.waitpid(-1, 0)
    except ChildProcessError:
      break
