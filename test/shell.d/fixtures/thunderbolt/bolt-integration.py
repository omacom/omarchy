"""Only the hardware fixture is Python: upstream Bolt uses UMockdev/GObject.

All Omarchy behavior and assertions run in bolt-exercise.sh against real boltd,
real busctl, a private system bus, and disposable sysfs/firmware/store state.
"""
import importlib.machinery
import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import time
import unittest

root = Path(sys.argv.pop(1))
loader = importlib.machinery.SourceFileLoader('bolt_upstream', str(Path(os.environ['BOLT_TEST_SOURCE']) / 'tests/test-integration'))
spec = importlib.util.spec_from_loader(loader.name, loader)
u = importlib.util.module_from_spec(spec)
loader.exec_module(u)


class ApprovalIntegration(u.BoltTest):
  def exercise(self, security, numeric=False):
    self.user_config(AuthMode='disabled', DefaultPolicy='manual')
    _, host = self.add_domain_host(security=security, iommu='1')
    path, uid = self.add_device(host, 1, 'Dock', 'Example', authorized=0, key='' if security == 'secure' else None, boot='0')
    _, other = self.add_device(host, 2, 'Unknown', 'Example', authorized=0, key=None, boot='0')
    if numeric:
      # Linux omits these files when the peripheral has no descriptive names.
      for attribute in ('device_name', 'vendor_name'):
        Path(self.testbed.get_root_dir(), path.lstrip('/'), attribute).unlink()
    self.daemon_start()
    self.polkitd_start()
    self.polkitd.SetAllowed(['org.freedesktop.bolt.authorize', 'org.freedesktop.bolt.enroll', 'org.freedesktop.bolt.manage'])
    env = os.environ | {'ROOT': str(root), 'UMOCKDEV_DIR': self.testbed.get_root_dir(),
                        'TB_TEST_DIR': self.rundir, 'TB_TEST_UID': uid, 'TB_TEST_OTHER': other,
                        'TB_TEST_KEYS': str(Path(self.dbpath, 'keys')), 'TB_TEST_SECURITY': security}
    command = ['bash', str(root / 'test/shell.d/fixtures/thunderbolt/bolt-exercise.sh')]
    subprocess.run(command + ['approve'], env=env, check=True)
    self.daemon_stop()
    self.testbed.set_attribute(path, 'authorized', '0')
    if security == 'secure':
      self.testbed.set_attribute(path, 'key', '\n')
    self.daemon_start()
    subprocess.run(command + ['restart'], env=env, check=True)
    # The real Bash daemon publishes a fresh readable snapshot and reconnects
    # to Bolt after a restart. No custom Omarchy D-Bus server is involved.
    child = subprocess.Popen(command + ['daemon'], env=env)
    try:
      for _ in range(100):
        result = subprocess.run(command + ['status'], env=env, capture_output=True)
        if result.returncode == 0:
          break
        time.sleep(0.1)
      else:
        raise RuntimeError('Bash daemon did not publish a valid snapshot')
      subprocess.run(command + ['once'], env=env, check=True)
      self.daemon_stop()
      self.daemon_start()
      for _ in range(100):
        if subprocess.run(command + ['status'], env=env, capture_output=True).returncode == 0:
          break
        time.sleep(0.1)
      else:
        raise RuntimeError('Bash daemon did not publish the new Bolt generation')
    finally:
      child.terminate()
      child.wait(timeout=15)
    self.daemon_stop()

  def test_user_approval(self):
    self.exercise('user')

  def test_secure_approval(self):
    self.exercise('secure')

  def test_numeric_identity(self):
    self.exercise('user', numeric=True)


suite = unittest.TestSuite(ApprovalIntegration(name) for name in ('test_user_approval', 'test_secure_approval', 'test_numeric_identity'))
result = unittest.TextTestRunner(verbosity=2).run(suite)
sys.exit(not result.wasSuccessful())
