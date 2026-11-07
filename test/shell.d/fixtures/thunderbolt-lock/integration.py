"""Upstream Bolt UMockdev hardware only; assertions run in exercise.sh."""
import importlib.machinery
import importlib.util
import ctypes
import os
import select
import signal
import struct
from pathlib import Path
import subprocess
import sys
import time
import threading
import unittest

root = Path(sys.argv.pop(1))
loader = importlib.machinery.SourceFileLoader('bolt_upstream', str(Path(os.environ['BOLT_TEST_SOURCE']) / 'tests/test-integration'))
spec = importlib.util.spec_from_loader(loader.name, loader)
u = importlib.util.module_from_spec(spec)
loader.exec_module(u)

class LockIntegration(u.BoltTest):
    def exercise(self, security):
        self.user_config(AuthMode='disabled', DefaultPolicy='manual')
        _, host = self.add_domain_host(security=security, iommu='1')
        self.add_device(host, 1, 'Input', 'Example', authorized=0, key=None, boot='0')
        self.daemon_start()
        self.polkitd_start()
        self.polkitd.SetAllowed(['org.freedesktop.bolt.authorize', 'org.freedesktop.bolt.enroll', 'org.freedesktop.bolt.manage'])
        env = os.environ | {'ROOT':str(root), 'UMOCKDEV_DIR':self.testbed.get_root_dir(), 'TB_TEST_DIR':self.rundir, 'TB_TEST_SECURITY':security, 'TB_TEST_KEYS':str(Path(self.dbpath, 'keys'))}
        command = ['bash', str(root / 'test/shell.d/fixtures/thunderbolt-lock/exercise.sh')]
        def run(action, uid='', wait=False):
            deadline = time.monotonic() + (20 if wait else 0)
            while True:
                result = subprocess.run(command + [action], env=env | {'TB_TEST_UID':uid}, capture_output=True, text=True)
                if result.returncode == 0:
                    print('PASS', security, action, uid, flush=True)
                    return
                if time.monotonic() >= deadline:
                    raise RuntimeError(action + ': ' + result.stdout + result.stderr)
                time.sleep(.15)
        def remove(path):
            self.testbed.uevent(path, 'remove')
            self.testbed.remove_device(path)
            time.sleep(.2)
        def reconnect(uid, number, name, secure=False):
            attributes = ['device_name', name, 'device', '0x23', 'vendor_name', 'Example', 'vendor', '0x23', 'authorized', '0', 'unique_id', uid, 'boot', '0']
            if secure:
                attributes += ['key', '\n']
            return self.testbed.add_device('thunderbolt', '0-'+str(number), host, attributes, ['DEVTYPE','thunderbolt_device'])
        run('initial')
        daemon = subprocess.Popen(command + ['daemon'], env=env, start_new_session=True)
        try:
            run('snapshot', wait=True)
            run('lock')
            queued, queued_uid = self.add_device(host, 2, 'Queued', 'Example', authorized=0, key=None, boot='0')
            run('blocked', queued_uid, True)
            os.killpg(daemon.pid, signal.SIGTERM)
            daemon.wait(timeout=15)
            daemon = subprocess.Popen(command + ['daemon'], env=env, start_new_session=True)
            run('snapshot', wait=True)
            run('blocked', queued_uid)
            run('unlock')
            run('allowed', queued_uid, True)
            run('runtime-trusted', queued_uid)
            run('temporary', queued_uid)
            remove(queued)
            run('lock')
            run('unlock')
            run('lock')
            queued = reconnect(queued_uid, 2, 'Queued')
            run('allowed', queued_uid, True)
            run('optional')
            run('allowed', queued_uid, True)
            run('temporary', queued_uid)
            remove(queued)
            run('lock')
            run('unlock')
            queued = reconnect(queued_uid, 2, 'Queued')
            run('allowed', queued_uid, True)
            run('temporary', queued_uid)
            device, uid = self.add_device(host, 3, 'Trusted', 'Example', authorized=0, key='' if security=='secure' else None, boot='0')
            run('blocked', uid, True)
            run('lock')
            later, later_uid = self.add_device(host, 4, 'Later', 'Example', authorized=0, key=None, boot='0')
            run('blocked', later_uid, True)
            run('unlock')
            run('blocked', uid)
            run('allowed', later_uid, True)
            run('approve', uid)
            remove(device)
            device = reconnect(uid, 3, 'Trusted', security=='secure')
            run('allowed', uid, True)
            if security=='secure': run('secure', uid)
            self.daemon_stop()
            self.daemon_start()
            run('snapshot', wait=True)
            run('allowed', uid, True)
            run('forget', uid)
            run('allowed', uid)
            remove(device)
            device = reconnect(uid, 3, 'Trusted', security=='secure')
            run('blocked', uid, True)
            run('temporary', uid)
            run('approve', uid)
            remove(device)
            remove(later)
            remove(queued)
            run('restart-policy')
            device = reconnect(uid, 3, 'Trusted', security=='secure')
            later = reconnect(later_uid, 4, 'Later')
            queued = reconnect(queued_uid, 2, 'Queued')
            run('allowed', uid, True)
            run('blocked', later_uid, True)
            run('blocked', queued_uid, True)
        finally:
            os.killpg(daemon.pid, signal.SIGTERM)
            daemon.wait(timeout=15)
            self.daemon_stop()
    def test_user(self): self.exercise('user')
    def test_secure(self): self.exercise('secure')

    def test_temporary_secure(self):
        self.user_config(AuthMode='disabled', DefaultPolicy='manual')
        _, host = self.add_domain_host(security='secure', iommu='1')
        env = os.environ | {'ROOT':str(root), 'UMOCKDEV_DIR':self.testbed.get_root_dir(), 'TB_TEST_DIR':self.rundir, 'TB_TEST_SECURITY':'secure', 'TB_TEST_KEYS':str(Path(self.dbpath, 'keys'))}
        command = ['bash', str(root / 'test/shell.d/fixtures/thunderbolt-lock/exercise.sh')]
        # A real kernel emits a change uevent after a sysfs authorization write.
        # Mirror that hardware event for the regular files supplied by UMockdev.
        libc = ctypes.CDLL(None, use_errno=True)
        notify = libc.inotify_init1(os.O_CLOEXEC)
        self.assertGreaterEqual(notify, 0)
        stop_read, stop_write = os.pipe()
        watches = {}
        def changes():
            while True:
                ready, _, _ = select.select([notify, stop_read], [], [])
                if stop_read in ready: return
                data = os.read(notify, 65536)
                offset = 0
                while offset < len(data):
                    wd, mask, _, length = struct.unpack_from('iIII', data, offset)
                    offset += 16 + length
                    path = watches.get(wd)
                    if mask & 8 and path is not None and Path(self.testbed.get_root_dir(), path.lstrip('/')).exists():
                        self.testbed.uevent(path, 'change')
        events = threading.Thread(target=changes)
        events.start()
        def add(uid=None, name='Input Dock', key=''):
            if uid is None:
                path, uid = self.add_device(host, 1, name, 'Example', authorized=0, key=key, boot='0')
            else:
                attrs = ['device_name',name,'device','0x23','vendor_name','Example','vendor','0x23','authorized','0','unique_id',uid,'boot','0']
                if key is not None: attrs += ['key', '\n']
                path = self.testbed.add_device('thunderbolt', '0-1', host, attrs, ['DEVTYPE','thunderbolt_device'])
            actual = str(Path(self.testbed.get_root_dir(), path.lstrip('/'), 'authorized'))
            wd = libc.inotify_add_watch(notify, actual.encode(), 8)
            self.assertGreaterEqual(wd, 0)
            watches[wd] = path
            return path, uid
        def remove(path):
            self.testbed.uevent(path, 'remove')
            self.testbed.remove_device(path)
            time.sleep(.2)
        def run(action, wait=False):
            deadline = time.monotonic() + (20 if wait else 0)
            while True:
                result = subprocess.run(command + [action], env=env | {'TB_TEST_UID':uid}, capture_output=True, text=True)
                if result.returncode == 0:
                    print('PASS temporary-secure', action, flush=True)
                    return
                if time.monotonic() >= deadline:
                    raise RuntimeError(action + ': ' + result.stdout + result.stderr)
                time.sleep(.15)
        daemon = None
        try:
            device, uid = add()
            self.daemon_start()
            self.polkitd_start()
            self.polkitd.SetAllowed(['org.freedesktop.bolt.authorize', 'org.freedesktop.bolt.enroll', 'org.freedesktop.bolt.manage'])
            run('initial', True)
            run('temporary-key')
            run('lock')
            remove(device)
            device, _ = add(uid)
            run('lock')
            run('allowed', True)
            run('temporary-key')
            run('temporary-secure')
            daemon = subprocess.Popen(command + ['daemon'], env=env, start_new_session=True)
            run('snapshot', True)
            remove(device)
            device, _ = add(uid)
            run('allowed', True)
            run('temporary-key')
            run('temporary-secure')
            remove(device)
            device, _ = add(uid, name='Different dock')
            run('lock')
            run('blocked')
            remove(device)
            device, _ = add(uid, key=None)
            run('lock')
            run('blocked')
            remove(device)
            os.killpg(daemon.pid, signal.SIGTERM)
            daemon.wait(timeout=15)
            daemon = None
            run('restart-policy')
            run('lock')
            device, _ = add(uid)
            run('lock')
            run('blocked')
            run('unlock')
            run('allowed', True)
            run('temporary-key')
            run('optional')
            run('approve')
            remove(device)
            run('lock')
            device, _ = add(uid)
            run('lock')
            run('allowed', True)
            run('secure')
        finally:
            if daemon is not None:
                os.killpg(daemon.pid, signal.SIGTERM)
                daemon.wait(timeout=15)
            os.write(stop_write, b'x')
            events.join(timeout=5)
            for fd in (notify, stop_read, stop_write): os.close(fd)
            self.daemon_stop()

result = unittest.TextTestRunner(verbosity=2).run(unittest.TestSuite(LockIntegration(name) for name in ('test_user','test_secure','test_temporary_secure')))
sys.exit(not result.wasSuccessful())
