import os
from pathlib import Path
import subprocess
import tempfile
import unittest

# Never execute lifecycle fixtures in the desktop's namespaces.
for namespace in ('pid', 'user', 'mnt', 'net'):
  host = os.environ.get('OMARCHY_TEST_HOST_' + namespace)
  assert host and os.readlink('/proc/self/ns/' + namespace) != host, 'Use the verified outer namespace test runner'

ROOT = Path(os.environ['ROOT'])


class SelectionTest(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.home = Path(self.tmp.name)
    self.bin = self.home / 'bin'
    self.bin.mkdir()
    self.env = dict(os.environ, HOME=str(self.home), OMARCHY_PATH=str(ROOT),
                    PATH=f'{self.bin}:{ROOT / "bin"}:/usr/bin:/bin')
    self.state = self.home / '.config/omarchy/screensaver'
    self.stub('omarchy-pkg-add', 'exit 1')
    self.stub('omarchy-launch-floating-terminal-with-presentation', 'touch "$HOME/terminal-ran"; exit 1')

  def stub(self, name, body):
    path = self.bin / name
    path.write_text('#!/bin/bash\n' + body + '\n')
    path.chmod(0o755)

  def run_command(self, *args):
    return subprocess.run(['bash', str(ROOT / 'bin/omarchy-setup-screensaver'), *args],
                          env=self.env, capture_output=True, text=True)

  def test_default_and_failed_first_selection_preserve_state(self):
    self.assertEqual(self.run_command().stdout.strip(), 'text')
    self.assertNotEqual(self.run_command('amiga').returncode, 0)
    self.assertFalse(self.state.exists())

  def test_repeat_failure_and_text_preserve_branding(self):
    self.state.parent.mkdir(parents=True)
    self.state.write_text('amiga\n')
    branding = self.state.parent / 'branding/screensaver.txt'
    branding.parent.mkdir()
    branding.write_text('My brand')
    self.assertNotEqual(self.run_command('amiga').returncode, 0)
    self.assertEqual(self.state.read_text(), 'amiga\n')
    self.assertEqual(self.run_command('text').returncode, 0)
    self.assertEqual(self.run_command().stdout.strip(), 'text')
    self.assertEqual(branding.read_text(), 'My brand')

  def test_absent_bundle_opens_installer_once_and_validates_before_selection(self):
    self.stub('uname', 'printf "x86_64\\n"')
    self.stub('pacman', '[[ $1 == "-Si" && $2 == "omarchy-amiga" ]]')
    self.stub('omarchy-pkg-add', 'printf "%s\\n" "$*" > "$HOME/packages"; touch "$HOME/ready"')
    self.stub('omarchy-screensaver-amiga', '[[ -f $HOME/ready ]]')
    self.stub('omarchy-launch-floating-terminal-with-presentation', 'printf "%s\\n" "$*" >> "$HOME/terminals"; bash "$OMARCHY_PATH/bin/omarchy-setup-screensaver" amiga --install')
    self.assertEqual(self.run_command('amiga').returncode, 0)
    self.assertEqual((self.home / 'terminals').read_text(), 'omarchy-setup-screensaver amiga --install\n')
    self.assertEqual((self.home / 'packages').read_text(), 'omarchy-amiga\n')
    self.assertEqual(self.state.read_text(), 'amiga\n')
    (self.home / 'packages').unlink()
    (self.home / 'terminals').unlink()
    self.assertEqual(self.run_command('amiga').returncode, 0)
    self.assertFalse((self.home / 'packages').exists())
    self.assertFalse((self.home / 'terminals').exists())

  def test_failed_or_partial_bundle_preserves_default_and_user_media(self):
    self.assertEqual(self.run_command('default').returncode, 0)
    media = self.home / 'Wallpapers/AMIGA/user.adf'
    media.parent.mkdir(parents=True)
    media.write_text('user media')
    self.stub('uname', 'printf "x86_64\\n"')
    self.stub('pacman', 'exit 0')
    self.stub('omarchy-pkg-add', 'mkdir -p "$HOME/.local/lib/omarchy-amiga-runtime"; exit 1')
    self.stub('omarchy-screensaver-amiga', 'exit 1')
    result = self.run_command('amiga', '--install')
    self.assertNotEqual(result.returncode, 0)
    self.assertEqual(self.state.read_text(), 'default\n')
    self.assertEqual(media.read_text(), 'user media')

  def test_checksum_rejection_after_install_preserves_previous_mode_and_allows_retry(self):
    self.assertEqual(self.run_command('default').returncode, 0)
    self.stub('uname', 'printf "x86_64\\n"')
    self.stub('pacman', 'exit 0')
    self.stub('omarchy-pkg-add', 'touch "$HOME/installed"')
    self.stub('omarchy-screensaver-amiga', '[[ -f $HOME/checksums-ok ]]')
    failed = self.run_command('amiga', '--install')
    self.assertNotEqual(failed.returncode, 0)
    self.assertIn('verification', failed.stderr.lower())
    self.assertEqual(self.state.read_text(), 'default\n')
    (self.home / 'checksums-ok').touch()
    self.assertEqual(self.run_command('amiga').returncode, 0)
    self.assertEqual(self.state.read_text(), 'amiga\n')

  def test_unsupported_architecture_never_installs_or_selects(self):
    self.assertEqual(self.run_command('default').returncode, 0)
    self.stub('uname', 'printf "riscv64\\n"')
    self.stub('pacman', 'touch "$HOME/package-probe"; exit 0')
    self.stub('omarchy-pkg-add', 'touch "$HOME/install-request"; exit 0')
    self.stub('omarchy-screensaver-amiga', 'exit 1')
    result = self.run_command('amiga', '--install')
    self.assertNotEqual(result.returncode, 0)
    self.assertIn('unsupported', result.stderr.lower())
    self.assertFalse((self.home / 'package-probe').exists())
    self.assertFalse((self.home / 'install-request').exists())
    self.assertEqual(self.state.read_text(), 'default\n')

  def test_default_never_checks_or_installs_amiga_dependencies(self):
    self.stub('uname', 'touch "$HOME/uname-ran"; exit 1')
    self.stub('pacman', 'touch "$HOME/package-probe"; exit 1')
    self.stub('omarchy-pkg-add', 'touch "$HOME/install-request"; exit 1')
    self.stub('omarchy-screensaver-amiga', 'touch "$HOME/readiness-check"; exit 1')
    self.assertEqual(self.run_command('default').returncode, 0)
    for marker in ('uname-ran', 'package-probe', 'install-request', 'readiness-check'):
      self.assertFalse((self.home / marker).exists())
    self.assertEqual(self.state.read_text(), 'default\n')

  def test_prepared_selection_bypasses_installer(self):
    self.stub('omarchy-pkg-add', 'touch "$HOME/installer-ran"; exit 1')
    self.stub('omarchy-screensaver-amiga', 'exit 0')
    self.assertEqual(self.run_command('amiga').returncode, 0)
    self.assertFalse((self.home / 'installer-ran').exists())
    self.assertFalse((self.home / 'terminal-ran').exists())
    self.assertEqual(self.state.read_text(), 'amiga\n')

  def test_dispatch_never_installs_and_branding_can_preview_text(self):
    self.state.parent.mkdir(parents=True)
    self.state.write_text('amiga\n')
    self.stub('omarchy-toggle-enabled', 'exit 1')
    self.stub('pgrep', 'exit 1')
    self.stub('omarchy-screensaver-amiga', 'touch "$HOME/amiga-ran"')
    self.stub('omarchy-hyprland-monitor-focused', 'echo TEST')
    self.stub('xdg-terminal-exec', 'echo unsupported')
    self.stub('omarchy-notification-send', 'exit 0')
    def launch(*args):
      return subprocess.run(['bash', str(ROOT / 'bin/omarchy-launch-screensaver'), *args], env=self.env, capture_output=True)
    self.assertEqual(launch().returncode, 0)
    self.assertTrue((self.home / 'amiga-ran').exists())
    (self.home / 'amiga-ran').unlink()
    self.assertNotEqual(launch('force', 'text').returncode, 0)
    self.assertFalse((self.home / 'amiga-ran').exists())
    self.stub('omarchy-toggle-enabled', 'exit 0')
    self.assertNotEqual(launch().returncode, 0)
    self.assertFalse((self.home / 'amiga-ran').exists())
    self.assertEqual(launch('force').returncode, 0)

  def test_default_force_dispatches_only_the_original_screensaver(self):
    self.state.parent.mkdir(parents=True)
    self.state.write_text('default\n')
    self.stub('omarchy-toggle-enabled', 'exit 0')
    self.stub('pgrep', 'exit 1')
    self.stub('omarchy-screensaver-amiga', 'touch "$HOME/amiga-ran"; exit 9')
    self.stub('omarchy-hyprland-monitor-focused', 'echo TEST')
    self.stub('xdg-terminal-exec', 'echo foot')
    self.stub('socat', 'exit 0')
    self.stub('hyprctl', 'printf "%s\\n" "$*" >> "$HOME/hyprctl-calls"; if [[ $1 == monitors ]]; then printf "[{\\"name\\":\\"TEST\\"}]\\n"; fi; exit 0')
    result = subprocess.run(['bash', str(ROOT / 'bin/omarchy-launch-screensaver'), 'force'], env=self.env, capture_output=True)
    self.assertEqual(result.returncode, 0, result.stderr.decode())
    self.assertFalse((self.home / 'amiga-ran').exists())
    self.assertIn('omarchy-screensaver', (self.home / 'hyprctl-calls').read_text())

  def test_amiga_failure_never_falls_back_to_text_or_ttfx(self):
    self.state.parent.mkdir(parents=True)
    self.state.write_text('amiga\n')
    self.stub('omarchy-toggle-enabled', 'exit 1')
    self.stub('pgrep', 'exit 1')
    self.stub('omarchy-screensaver-amiga', 'exit 1')
    for name in ('ttfx', 'xdg-terminal-exec', 'omarchy-screensaver'):
      self.stub(name, 'touch "$HOME/alternate-backend"')
    result = subprocess.run(['bash', str(ROOT / 'bin/omarchy-launch-screensaver'), 'force'], env=self.env, capture_output=True)
    self.assertNotEqual(result.returncode, 0)
    self.assertFalse((self.home / 'alternate-backend').exists())

  def test_missing_readiness_probes_only_bundle_contract(self):
    self.stub('uname', 'printf "x86_64\\n"')
    self.stub('omarchy-screensaver-amiga', 'exit 1')
    self.stub('pacman', '[[ $1 == "-Si" && $2 == "omarchy-amiga" ]] || exit 9')
    self.stub('omarchy-pkg-add', 'printf "%s\\n" "$*" > "$HOME/install-request"; exit 1')
    self.assertNotEqual(self.run_command('amiga', '--install').returncode, 0)
    self.assertEqual((self.home / 'install-request').read_text(), 'omarchy-amiga\n')
    self.assertFalse(self.state.exists())

  def test_unpublished_bundle_never_escalates_or_changes_selection(self):
    self.assertEqual(self.run_command('text').returncode, 0)
    self.stub('omarchy-screensaver-amiga', 'exit 1')
    self.stub('pacman', 'exit 1')
    self.stub('omarchy-pkg-add', 'touch "$HOME/install-request"; exit 0')
    self.assertNotEqual(self.run_command('amiga', '--install').returncode, 0)
    self.assertFalse((self.home / 'install-request').exists())
    self.assertEqual(self.state.read_text(), 'text\n')

  def test_unknown_state_is_not_executed(self):
    self.state.parent.mkdir(parents=True)
    self.state.write_text('$(touch "$HOME/unsafe")')
    self.assertEqual(self.run_command().stdout.strip(), 'text')
    self.assertFalse((self.home / 'unsafe').exists())
    self.assertNotEqual(self.run_command('unknown').returncode, 0)


class RuntimeTest(unittest.TestCase):
  @classmethod
  def setUpClass(cls):
    import importlib.util
    spec = importlib.util.spec_from_file_location('amiga', ROOT / 'shell/plugins/services/idle/amiga.py')
    assert spec and spec.loader
    cls.amiga = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(cls.amiga)

  def test_cleanup_rejects_mock_without_any_signals(self):
    from unittest.mock import MagicMock, patch
    with patch.object(os, 'kill') as kill, patch.object(os, 'killpg') as killpg, patch.object(self.amiga.signal, 'pidfd_send_signal') as pidfd:
      with self.assertRaises(ValueError):
        self.amiga.stop(MagicMock())
      kill.assert_not_called()
      killpg.assert_not_called()
      pidfd.assert_not_called()

  def test_owned_pidfd_cleanup_and_unowned_rejection(self):
    from unittest.mock import patch
    # These real children live only inside the outer test-isolated namespace.
    process = subprocess.Popen(['/usr/bin/sleep', '30'])
    try:
      with patch.object(os, 'kill') as kill, patch.object(os, 'killpg') as killpg, patch.object(self.amiga.signal, 'pidfd_send_signal') as pidfd:
        with self.assertRaises(ValueError):
          self.amiga.stop(process)
        kill.assert_not_called()
        killpg.assert_not_called()
        pidfd.assert_not_called()
      self.amiga._OWNED[process] = (process.pid, os.pidfd_open(process.pid))
      with patch.object(os, 'kill', side_effect=AssertionError('numeric signal')), patch.object(os, 'killpg', side_effect=AssertionError('group signal')):
        self.amiga.stop(process)
      self.assertIsNotNone(process.poll())
      self.assertNotIn(process, self.amiga._OWNED)
    finally:
      if process.poll() is None:
        process.kill()
      process.wait()

  def test_launch_registers_wrapper_and_never_falls_back(self):
    from unittest.mock import patch
    import sys
    process = self.amiga.launch_command(['/usr/bin/sleep', '30'], sys.stdout)
    self.amiga.stop(process)
    with patch.object(self.amiga.subprocess, 'Popen', side_effect=FileNotFoundError) as popen:
      with self.assertRaises(FileNotFoundError):
        self.amiga.launch_command(['/nonexistent/bwrap'], sys.stdout)
      self.assertEqual(popen.call_count, 1)


  def test_child_dies_with_controller(self):
    import select
    import signal
    import sys
    code = """import importlib.util, sys, time
spec = importlib.util.spec_from_file_location('amiga', sys.argv[1])
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
p = m.launch_command(['/usr/bin/sleep', '30'], sys.stderr)
print(p.pid, flush=True)
time.sleep(30)
"""
    owner = subprocess.Popen([sys.executable, '-c', code, str(ROOT / 'shell/plugins/services/idle/amiga.py')], stdout=subprocess.PIPE, text=True)
    child_fd = None
    try:
      assert owner.stdout
      child_fd = os.pidfd_open(int(owner.stdout.readline()))
      owner.kill()
      owner.wait()
      self.assertTrue(select.select([child_fd], [], [], 2)[0], 'controller death must kill its wrapper')
    finally:
      if owner.poll() is None:
        owner.kill()
      owner.wait()
      if owner.stdout:
        owner.stdout.close()
      if child_fd is not None:
        try:
          signal.pidfd_send_signal(child_fd, signal.SIGKILL)
        except ProcessLookupError:
          pass
        os.close(child_fd)


if __name__ == '__main__':
  unittest.main()
