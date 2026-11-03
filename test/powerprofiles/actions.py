import runpy
import tempfile
import subprocess
import stat
import sys
import types
import unittest
from pathlib import Path
from unittest.mock import Mock, patch


class Actions(unittest.TestCase):
    def test_validated_actions_continue_after_failure(self):
        gio, glib = Mock(), Mock()
        glib.Error = RuntimeError
        bus = gio.bus_get_sync.return_value
        bus.call_sync.return_value.unpack.return_value = ['power-saver']
        repo = types.ModuleType('gi.repository')
        repo.Gio, repo.GLib = gio, glib
        script = Path(__file__).resolve().parents[2] / 'default/powerprofiles/profile-actions.py'
        with patch.dict(sys.modules, {'gi': types.ModuleType('gi'), 'gi.repository': repo}):
            module = runpy.run_path(str(script))
        scripts = [Mock() for _ in range(6)]
        for index, entry in enumerate(scripts):
            entry.__str__ = Mock(return_value=f'/action{index}')
            entry.lstat.return_value = types.SimpleNamespace(st_uid=0, st_mode=stat.S_IFREG | 0o755)
        scripts[0].lstat.return_value.st_mode |= 0o002
        scripts[1].lstat.return_value.st_mode = stat.S_IFLNK | 0o777
        scripts[2].lstat.return_value.st_uid = 1000
        scripts[2].lstat.side_effect = FileNotFoundError('removed action')
        with patch.object(Path, 'glob', return_value=scripts), patch('os.access', return_value=True), patch('subprocess.run') as run, patch('builtins.sorted', side_effect=lambda x: list(x)):
            run.side_effect = [subprocess.CalledProcessError(1, '/action3'), subprocess.TimeoutExpired('/action4', 10), None]
            module['apply']()
            self.assertEqual([call.args[0] for call in run.call_args_list],
                             [[f'/action{i}', 'power-saver'] for i in (3, 4, 5)])
            run.reset_mock()
            bus.call_sync.return_value.unpack.return_value = ['invalid']
            with self.assertRaises(ValueError): module['apply']()
            run.assert_not_called()

    def test_wifi_continues_after_disappearance_and_iw_failure(self):
        root = Path(__file__).resolve().parents[2]
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)
            net = tmp / 'net'
            for name in ('wlan0', 'wlan1', 'wlan2'):
                (net / name / 'wireless').mkdir(parents=True)
            tools = tmp / 'bin'
            tools.mkdir()
            (tools / 'readlink').write_text('#!/bin/bash\ncase "$*" in *wlan0*) exit 1;; *) echo /drivers/brcmfmac;; esac\n')
            log = tmp / 'calls'
            (tools / 'iw').write_text(f'#!/bin/bash\necho "$*" >> "{log}"\n[[ $2 != wlan1 ]]\n')
            for tool in tools.iterdir(): tool.chmod(0o755)
            script = (root / 'default/powerprofiles/actions.d/10-wifi').read_text()
            script = script.replace('/sys/class/net', str(net))
            import os
            result = subprocess.run(['bash', '-c', script, 'wifi', 'power-saver'],
                                    env={**os.environ, 'PATH': str(tools) + ':' + os.environ['PATH']},
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(log.read_text().splitlines(),
                             ['dev wlan1 set power_save on', 'dev wlan2 set power_save on'])


if __name__ == '__main__': unittest.main()
