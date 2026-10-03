from pathlib import Path
import runpy
import unittest
from unittest.mock import Mock, patch

module = runpy.run_path(str(Path(__file__).parents[1] / 'watch.py'))
Watcher = module['Watcher']


def fleet(count=0, online=True, ready=True):
    return {'hosts': [{'id': 'remote', 'online': online}, {'id': 'local', 'online': True}],
            'desktops': [{'host': 'remote', 'ready': ready} for _ in range(count)]}


class WatchTest(unittest.TestCase):
    def test_first_desktop_opens_once_until_the_batch_ends(self):
        launches = []
        watcher = Watcher(lambda: launches.append(True))
        watcher.update(fleet())
        self.assertEqual(launches, [])
        watcher.update(fleet(1, ready=False))
        self.assertEqual(launches, [])
        watcher.update(fleet(1))
        watcher.update(fleet(8))
        # Closing the app does not alter the active fleet episode.
        watcher.update(fleet(2))
        self.assertEqual(len(launches), 1)
        watcher.update(fleet())
        watcher.update(fleet(1))
        self.assertEqual(len(launches), 2)

    def test_offline_hosts_retain_previously_active_desktops(self):
        launches = []
        watcher = Watcher(lambda: launches.append(True))
        watcher.update(fleet(1))
        watcher.update(fleet(0, online=False))
        watcher.update(fleet(1))
        self.assertEqual(len(launches), 1)
        watcher.update(fleet())
        watcher.update(fleet(1))
        self.assertEqual(len(launches), 2)

    def test_an_unused_sleeping_host_does_not_block_rearming(self):
        launches = []
        watcher = Watcher(lambda: launches.append(True))
        data = fleet(0, online=False)
        watcher.update(data)
        data['desktops'] = [{'host': 'local', 'ready': True}]
        watcher.update(data)
        data['desktops'] = []
        watcher.update(data)
        data['desktops'] = [{'host': 'local', 'ready': True}]
        watcher.update(data)
        self.assertEqual(len(launches), 2)

    def test_a_failed_launch_can_retry(self):
        def fail(): raise OSError('launch unavailable')
        watcher = Watcher(fail)
        with self.assertRaises(OSError): watcher.update(fleet(1))
        launches = []
        watcher.launch = lambda: launches.append(True)
        watcher.update(fleet(1))
        self.assertEqual(launches, [True])

    def test_child_startup_failure_does_not_consume_the_batch(self):
        watcher = Watcher(lambda: module['await_ready'](check=lambda: False, sleep=lambda _: None, attempts=2))
        with self.assertRaises(OSError): watcher.update(fleet(1))
        self.assertFalse(watcher.active)
        watcher.launch = lambda: module['await_ready'](check=lambda: True)
        watcher.update(fleet(1))
        self.assertTrue(watcher.active)

    def test_a_registered_but_unready_launch_is_not_treated_as_an_existing_viewer(self):
        launcher = module['Launcher']()
        watcher = Watcher(launcher)
        start = Mock()
        readiness = Mock(side_effect=[OSError('not ready'), OSError('still not ready'), None])
        with patch.dict(launcher.__call__.__func__.__globals__, {
                'running': Mock(side_effect=[False, True, True]),
                'subprocess': Mock(run=start), 'await_ready': readiness}):
            for _ in range(2):
                with self.assertRaises(OSError): watcher.update(fleet(1))
                self.assertFalse(watcher.active)
            watcher.update(fleet(1))
        self.assertEqual(start.call_count, 1)
        self.assertTrue(watcher.active)
        self.assertFalse(launcher.starting)

    def test_invalid_snapshot_cannot_rearm(self):
        watcher = Watcher(lambda: None)
        watcher.update(fleet(1))
        with self.assertRaises(ValueError): watcher.update({'desktops': [], 'hosts': []})
        self.assertTrue(watcher.active)


class LocalConfigurationTest(unittest.TestCase):
    def test_default_endpoint_and_custom_port_need_no_fleet_or_t3_configuration(self):
        import io
        import json
        import tempfile
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            state = home / '.local/share/hypr-desktop'
            state.mkdir(parents=True)
            (state / 'local-url').write_text('http://127.0.0.1:17873/mcp\n')
            (state / 'token').write_text('fixture-token\n')
            opener = Mock()
            opener.open.return_value = io.StringIO(json.dumps(fleet()))
            with patch.object(Path, 'home', return_value=home), patch.dict(module['snapshot'].__globals__, {'build_opener': Mock(return_value=opener)}):
                self.assertEqual(module['snapshot'](), fleet())
            request = opener.open.call_args.args[0]
            self.assertEqual(request.full_url, 'http://127.0.0.1:17873/hypr-desktop/viewer/agents/fleet')
            self.assertEqual(request.get_header('Authorization'), 'Bearer fixture-token')


if __name__ == '__main__':
    unittest.main()
