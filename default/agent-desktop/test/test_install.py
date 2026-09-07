import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SOURCE = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('desktop_install', SOURCE / 'install.py')
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)


class InstallTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='agent-desktop-install-')
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name) / 'home with spaces'
        self.config = self.home / '.config/hypr/hyprland.lua'
        self.config.parent.mkdir(parents=True)
        self.original = '-- user settings\nhl.config({})\n'
        self.config.write_text(self.original)

    def fake_run(self, *args, **kwargs):
        if '-p' in args:
            return subprocess.CompletedProcess(args, 0, '22\n', '')
        return subprocess.CompletedProcess(args, 0, '', '')

    def install(self):
        with patch.object(installer, 'run', side_effect=self.fake_run), patch.object(installer.shutil, 'which', return_value='/usr/bin/node'):
            installer.install(self.home, SOURCE, 17873, 'DP-1', False)

    def test_staging_installs_a_self_contained_runtime_and_private_token(self):
        self.install()
        launcher = self.home / '.local/bin/agent-desktop'
        self.assertTrue(launcher.resolve().is_file())
        help_result = subprocess.run([str(launcher), '--help'], capture_output=True, text=True)
        self.assertEqual(help_result.returncode, 0, help_result.stderr)
        self.assertIn('agent-desktop tool', help_result.stdout)
        skill = self.home / '.codex/skills/agent-desktop/SKILL.md'
        self.assertTrue(skill.resolve().is_file())
        token = self.home / '.local/share/hypr-desktop/token'
        self.assertEqual(token.stat().st_mode & 0o777, 0o600)
        self.assertEqual(len(token.read_text().strip()), 64)
        self.assertTrue(self.config.read_text().startswith(self.original))
        unit = (self.home / '.config/systemd/user/hypr-desktop.service').read_text()
        self.assertIn('"' + str(launcher.resolve().parents[1] / 'mcp/index.js') + '"', unit)
        self.assertIn('HYPR_DESKTOP_PORT=17873', unit)

    def test_foreign_cli_is_preserved_and_nothing_is_installed(self):
        launcher = self.home / '.local/bin/agent-desktop'
        launcher.parent.mkdir(parents=True)
        launcher.write_text('user-owned script')
        with self.assertRaisesRegex(RuntimeError, 'Existing installation'):
            self.install()
        self.assertEqual(launcher.read_text(), 'user-owned script')
        self.assertEqual(self.config.read_text(), self.original)
        self.assertFalse((self.home / '.local/share/hypr-desktop').exists())

    def test_foreign_service_is_not_overwritten(self):
        unit = self.home / '.config/systemd/user/hypr-desktop.service'
        unit.parent.mkdir(parents=True)
        unit.write_text('[Service]\nExecStart=/user/server\n')
        with self.assertRaisesRegex(RuntimeError, 'Existing or modified file'):
            self.install()
        self.assertIn('/user/server', unit.read_text())
        self.assertFalse((self.home / '.local/share/agent-desktop').exists())

    def test_failed_dependency_install_preserves_user_configuration(self):
        def fail_npm(*args, **kwargs):
            if args[0] == 'npm':
                raise subprocess.CalledProcessError(1, args)
            return self.fake_run(*args, **kwargs)
        with patch.object(installer, 'run', side_effect=fail_npm), patch.object(installer.shutil, 'which', return_value='/usr/bin/node'):
            with self.assertRaises(subprocess.CalledProcessError):
                installer.install(self.home, SOURCE, 17873, None, False)
        self.assertEqual(self.config.read_text(), self.original)
        self.assertFalse((self.home / '.local/share/hypr-desktop/token').exists())
        self.assertFalse((self.home / '.local/bin/agent-desktop').exists())

    def test_failure_after_runtime_swap_rolls_back_and_allows_retry(self):
        original_write = Path.write_text
        def fail_rule(path, *args, **kwargs):
            if path.name == 'agent-desktop.lua':
                raise OSError('simulated disk failure')
            return original_write(path, *args, **kwargs)
        with patch.object(Path, 'write_text', fail_rule):
            with self.assertRaisesRegex(OSError, 'simulated disk failure'):
                self.install()
        self.assertEqual(self.config.read_text(), self.original)
        self.assertFalse((self.home / '.local/bin/agent-desktop').exists())
        self.install()
        self.assertTrue((self.home / '.local/share/hypr-desktop/installation.json').exists())

    def test_modified_generated_config_is_preserved(self):
        self.install()
        rule = self.home / '.config/hypr/agent-desktop.lua'
        rule.write_text('-- personal change\n')
        with self.assertRaisesRegex(RuntimeError, 'Existing or modified file'):
            self.install()
        self.assertEqual(rule.read_text(), '-- personal change\n')


if __name__ == '__main__':
    unittest.main()
