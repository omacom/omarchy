from pathlib import Path
from types import SimpleNamespace
import tempfile
import unittest
from unittest.mock import MagicMock, patch

import mbp2019_amdgpu_demand as controller


class FakeHardware:
    cap = 50000000

    def __init__(self):
        self.current = 'low'
        self.writes = []
        self.samples = iter([controller.Sample(90, 55000, 57000, 4000000)] * 2)

    def mode(self):
        return self.current

    def set_mode(self, mode):
        self.writes.append(mode)
        self.current = mode

    def sample(self):
        try:
            return next(self.samples)
        except StopIteration:
            raise controller.SafetyError('Simulated missing temperature sensor')


class ControllerTests(unittest.TestCase):
    def exercise_fault(self, boottimes):
        hardware = FakeHardware()
        stop = MagicMock()
        stop.is_set.return_value = False
        with tempfile.TemporaryDirectory() as directory:
            runtime = MagicMock()
            runtime.lstat.return_value = SimpleNamespace(st_uid=0, st_mode=0o755)
            runtime.is_symlink.return_value = False
            runtime.__truediv__.side_effect = lambda name: Path(directory) / name
            with (
                patch.object(controller, 'Hardware', return_value=hardware),
                patch.object(controller, 'RUNTIME', runtime),
                patch.object(controller.os, 'geteuid', return_value=0),
                patch.object(controller.signal, 'signal'),
                patch.object(controller.threading, 'Event', return_value=stop),
                patch.object(controller.time, 'monotonic', side_effect=[0, 0, 1, 2]),
                patch.object(controller.time, 'clock_gettime', side_effect=boottimes),
                patch.object(controller, 'emit'),
                patch.object(controller, 'save_status') as status,
            ):
                with self.assertRaises(controller.SafetyError):
                    controller.run(True, 60)
                self.assertEqual(hardware.writes, ['high', 'low'])
                self.assertEqual(hardware.current, 'low')
                self.assertFalse(status.call_args.kwargs['running'])

    def test_sensor_failure_restores_low_before_exit(self):
        self.exercise_fault([0, 0, 1, 2])

    def test_uncoordinated_sleep_restores_low_before_exit(self):
        self.exercise_fault([0, 0, 1, 30])

    def test_nonroot_live_mode_fails_before_hardware_access(self):
        with patch.object(controller.os, 'geteuid', return_value=1000):
            with patch.object(controller, 'Hardware') as hardware:
                with self.assertRaises(controller.SafetyError):
                    controller.run(True, 10)
                hardware.assert_not_called()

    def test_disallowed_modes_never_open_sysfs(self):
        hardware = object.__new__(controller.Hardware)
        for mode in ('auto', 'manual', 'profile_peak', '', None):
            with self.assertRaises(controller.SafetyError):
                hardware.set_mode(mode)

    def test_bad_sensor_values_are_rejected(self):
        for value in ('garbage', '-1', '101', 'NaN', ''):
            path = MagicMock()
            path.read_text.return_value = value
            with self.assertRaises(controller.SafetyError):
                controller.read_number(path, 0, 100)


if __name__ == '__main__':
    unittest.main()
