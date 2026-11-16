#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# These exercise the production wire parser and peer authentication. Live PAM
# and reader-release checks belong in a disposable desktop, not this suite.
python3 -B - <<'PY'
import importlib.util
import os
from pathlib import Path
import socket
import struct
import tempfile
import threading
import unittest

spec = importlib.util.spec_from_file_location('guard', Path(os.environ['ROOT']) / 'default/pam/polkit-lock-guard.py')
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)
# The unprivileged suite can read the installed executable directly; only the
# root guardian needs /proc/1/root to cross the Polkit helper's mount namespace.
guard.HYPRLAND = Path('/usr/bin/Hyprland')


class GuardTests(unittest.TestCase):
  def client(self):
    client, server = socket.socketpair()
    self.addCleanup(client.close)
    self.addCleanup(server.close)
    notification = guard.LockNotification.__new__(guard.LockNotification)
    notification.connection = client
    notification.buffer = bytearray()
    notification.next_id = 10
    notification.manager_name = None
    notification.notification = 8
    notification.callbacks = set()
    return notification, server

  def event(self, target, opcode, payload=b''):
    return struct.pack('=II', target, ((8 + len(payload)) << 16) | opcode) + payload

  def test_locked_then_unlocked_never_revives_authorization(self):
    client, server = self.client()
    server.sendall(self.event(8, 0) + self.event(8, 1))
    with self.assertRaises(guard.Locked):
      client.receive()

  def test_fragmented_lock_notification(self):
    client, server = self.client()
    wire = self.event(8, 0)
    server.sendall(wire[:5])
    client.receive()
    server.sendall(wire[5:])
    with self.assertRaises(guard.Locked):
      client.receive()

  def test_account_roundtrip_consumes_a_queued_lock(self):
    client, server = self.client()
    def reply():
      request = server.recv(12)
      callback, = struct.unpack('=I', request[8:])
      server.sendall(self.event(8, 0) + self.event(callback, 0, struct.pack('=I', 1)))
    thread = threading.Thread(target=reply)
    thread.start()
    with self.assertRaises(guard.Locked):
      client.roundtrip()
    thread.join(timeout=2)
    self.assertFalse(thread.is_alive())

  def test_disconnect_and_malformed_event_fail_closed(self):
    client, server = self.client()
    server.close()
    with self.assertRaises(guard.Unavailable):
      client.receive()
    client, server = self.client()
    server.sendall(struct.pack('=II', 8, 7 << 16))
    with self.assertRaises(guard.Unavailable):
      client.receive()

  def test_kernel_uid_and_gid_are_unsigned(self):
    class Credentials:
      def getsockopt(self, level, option, length):
        self.request = (level, option, length)
        return struct.pack("=iII", 123, 3_000_000_000, 4_000_000_000)
    connection = Credentials()
    self.assertEqual(guard.peer_credentials(connection), (123, 3_000_000_000, 4_000_000_000))
    self.assertEqual(connection.request, (socket.SOL_SOCKET, socket.SO_PEERCRED, 12))

  def test_user_marker_cannot_identify_a_fake_compositor(self):
    with tempfile.TemporaryDirectory() as directory:
      runtime = Path(directory)
      (runtime / 'hypr/decoy').mkdir(parents=True)
      (runtime / 'hypr/decoy/hyprland.lock').write_text(f'{os.getpid()}\nwayland-0\n')
      server = socket.socket(socket.AF_UNIX)
      self.addCleanup(server.close)
      server.bind(str(runtime / 'wayland-0'))
      server.listen()
      self.assertFalse(guard.trusted_executable(os.getpid()))
      with self.assertRaises(guard.Unavailable):
        guard.connect_compositor(os.getpid(), os.getuid(), runtime / 'hypr')


unittest.main()
PY

# Explicit disposable-VM opt-in. This never edits a system PAM configuration:
# pam_start_confdir loads a root-private temporary stack and the real module.
if (( EUID != 0 )) || [[ -z ${OMARCHY_POLKIT_GUARD_TEST_UID:-} ]]; then
  skip "native PAM lifecycle needs root and OMARCHY_POLKIT_GUARD_TEST_UID in a disposable VM"
  exit 0
fi
[[ $OMARCHY_POLKIT_GUARD_TEST_UID =~ ^[1-9][0-9]*$ ]] || fail "native test UID is unprivileged"
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
cp "$ROOT/default/pam/polkit-lock-guard.py" "$scratch/guard.py"
cc -fPIC -shared -Wall -Wextra -Werror -o "$scratch/guard.so" \
  -DOMARCHY_POLKIT_GUARD="\"$scratch/guard.py\"" "$ROOT/default/pam/polkit-lock-guard.c" -lpam
cc -Wall -Wextra -Werror -o "$scratch/transaction" \
  "$SHELL_TEST_DIR/fixtures/polkit-lock-guard/transaction.c" -lpam
printf 'auth requisite %s/guard.so\naccount requisite %s/guard.so\n' "$scratch" "$scratch" >"$scratch/polkit-1"

python3 - "$scratch" "$OMARCHY_POLKIT_GUARD_TEST_UID" "$ROOT/default/pam/polkit-policy.py" <<'PY'
import os
from pathlib import Path
import select
import signal
import subprocess
import sys
import time

directory, uid, policy_path = sys.argv[1:]

if os.environ.get('OMARCHY_POLKIT_GUARD_TEST_LOCKED') == '1':
  p = subprocess.Popen([directory + '/transaction', uid, directory, 'account'],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
  assert select.select([p.stdout], [], [], 5)[0], 'locked PAM check timed out'
  assert p.stdout.readline().strip() != 'AUTH 0', 'PAM_USER=root must not bypass the initiating user lock'
  assert p.wait(timeout=4) == 1
  print('ok - native PAM checks the initiating UID even when authenticating root')
  # An agent without a desktop must also respect the credential owner's lock.
  import pwd
  username = pwd.getpwuid(int(uid)).pw_name
  other_uid = str(pwd.getpwnam('nobody').pw_uid)
  p = subprocess.Popen([directory + '/transaction', other_uid, directory, 'account', username],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
  assert select.select([p.stdout], [], [], 5)[0], 'credential-owner check timed out'
  assert p.stdout.readline().strip() != 'AUTH 0', 'a different agent UID bypassed the locked credential owner'
  assert p.wait(timeout=4) == 1
  print('ok - native PAM checks the locked credential owner across initiating UIDs')
  # Use real PAM dispatch and permit/deny modules to model factor outcomes.
  # PAM ignores blank/comment/account rows when counting auth jumps.
  import runpy
  render = runpy.run_path(policy_path)['render']
  policy = render('AUTH [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed\n'
                  '# ignored by PAM auth\n\naccount required pam_permit.so\n'
                  'AUTH SUFFICIENT pam_fprintd.so\nauth required pam_deny.so\n')
  policy = policy.replace('pam_omarchy_lock.so', directory + '/guard.so')
  policy = policy.replace('pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed', 'pam_permit.so')
  policy = policy.replace('pam_fprintd.so', 'pam_permit.so')
  Path(directory + '/polkit-1').write_text(policy)
  p = subprocess.Popen([directory + '/transaction', uid, directory, 'account'],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
  assert select.select([p.stdout], [], [], 5)[0], 'PAM jump test timed out'
  assert p.stdout.readline().strip() != 'AUTH 0', 'clamshell jump bypassed the lock guard'
  assert p.wait(timeout=4) == 1
  print('ok - actual PAM jumps preserve the locked factor boundary across ignored rows')
  sys.exit(0)

def start(mode):
  child = subprocess.Popen([directory + '/transaction', uid, directory, mode],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
  assert select.select([child.stdout], [], [], 5)[0], 'PAM did not report readiness'
  assert child.stdout.readline().strip() == 'AUTH 0', 'native guard requires an unlocked, reachable compositor'
  return child

def guardian(child):
  path = Path(f'/proc/{child.pid}/task/{child.pid}/children')
  children = path.read_text().split()
  assert len(children) == 1, children
  return children[0]

def wait_gone(pid):
  for _ in range(100):
    try:
      state = Path(f'/proc/{pid}/stat').read_text().rsplit(')', 1)[1].split()[0]
    except FileNotFoundError:
      return
    if state == 'Z':
      return
    time.sleep(.02)
  raise AssertionError('orphan guardian ' + str(pid))

p = start('account')
assert p.stdout.readline().strip() == 'ACCOUNT 0', 'account-stage roundtrip failed'
assert p.wait(timeout=4) == 0
print('ok - native PAM auth and account checks complete and clean up')

p = start('wait')
watcher = guardian(p)
p.stdin.write('buffered credentials\n')
p.stdin.flush()
time.sleep(.1)
assert p.poll() is None, 'buffered input is not cancellation'
p.stdin.close()
assert p.wait(timeout=4) == -signal.SIGKILL, 'agent disconnect must terminate the PAM helper'
wait_gone(watcher)
print('ok - native agent disconnect terminates only its helper and guardian')

p = start('wait-ignored-signals')
watcher = guardian(p)
p.stdin.close()
assert p.wait(timeout=4) == -signal.SIGKILL, 'inherited ignored signals prevented cancellation'
wait_gone(watcher)
print('ok - legacy ignored SIGTERM/SIGCHLD cannot defeat cancellation or cleanup')

p = start('wait')
watcher = guardian(p)
p.kill()
p.wait(timeout=4)
p.stdin.close()
wait_gone(watcher)
print('ok - abrupt helper death leaves no guardian running')

p = start('wait-account')
watcher = guardian(p)
os.kill(int(watcher), signal.SIGKILL)
wait_gone(watcher)
p.stdin.write('Q')
p.stdin.flush()
assert p.stdout.readline().strip() != 'ACCOUNT 0', 'losing the guard must fail account management'
assert p.wait(timeout=4) == 1
p.stdin.close()
print('ok - a lost guardian fails closed at account management')

Path(directory + '/guard.py').unlink()
p = subprocess.Popen([directory + '/transaction', uid, directory, 'account'],
  stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
assert select.select([p.stdout], [], [], 5)[0], 'missing guardian check timed out'
assert p.stdout.readline().strip() != 'AUTH 0', 'a missing guardian must fail closed'
assert p.wait(timeout=4) == 1
p.stdin.close()
print('ok - a missing guardian fails closed before authentication')
PY
