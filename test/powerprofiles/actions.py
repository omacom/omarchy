import runpy
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
        scripts = [Mock() for _ in range(4)]
        for index, entry in enumerate(scripts):
            entry.__str__ = Mock(return_value=f'/action{index}')
            entry.lstat.return_value = types.SimpleNamespace(st_uid=0, st_mode=stat.S_IFREG | 0o755)
        scripts[0].lstat.return_value.st_mode |= 0o002
        scripts[1].lstat.return_value.st_mode = stat.S_IFLNK | 0o777
        scripts[2].lstat.return_value.st_uid = 1000
        with patch.object(Path, 'glob', return_value=scripts), patch('os.access', return_value=True), patch('subprocess.run') as run, patch('builtins.sorted', side_effect=lambda x: list(x)):
            module['apply']()
            run.assert_called_once_with(['/action3', 'power-saver'], check=True, timeout=10)
            run.reset_mock()
            bus.call_sync.return_value.unpack.return_value = ['invalid']
            with self.assertRaises(ValueError): module['apply']()
            run.assert_not_called()


if __name__ == '__main__': unittest.main()
