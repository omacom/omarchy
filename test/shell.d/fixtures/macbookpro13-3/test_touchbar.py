# SPDX-License-Identifier: GPL-2.0-only
"""No device access: exercise the recovery's actual HID protocol code."""
import contextlib
import importlib.util
import io
import os
from pathlib import Path
import stat
import struct
import subprocess
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    "unpark", (Path(__file__).resolve().parents[4] / "default/hardware/macbookpro13-3") / "touchbar/unpark.py")
unpark = importlib.util.module_from_spec(spec)
spec.loader.exec_module(unpark)


class TouchBarTests(unittest.TestCase):
    def test_resume_wrapper_requires_success_and_completed_cleanup(self):
        source = ((Path(__file__).resolve().parents[4] / "default/hardware/macbookpro13-3") / 'touchbar/resume').read_text()
        boundary = source.index('exec /usr/bin/timeout')
        # Stub only the final hardware-command boundary; execute the real guards.
        source = source[:boundary] + "printf 'recovery-requested\\n'\n"
        with tempfile.TemporaryDirectory() as directory:
            state = Path(directory) / 'state'
            script = Path(directory) / 'resume'
            script.write_text(source.replace('/run/macbook-suspend/state', str(state)))
            for result, pending, expected in (('', False, False), ('exit-code', False, False),
                                               ('success', True, False), ('success', False, True)):
                with self.subTest(result=result, pending=pending):
                    if pending:
                        state.mkdir()
                    elif state.exists():
                        state.rmdir()
                    run = subprocess.run(['bash', str(script)],
                                         env={'SERVICE_RESULT': result}, text=True,
                                         capture_output=True, timeout=5)
                    self.assertEqual(run.returncode, 0, run.stderr)
                    self.assertEqual('recovery-requested' in run.stdout, expected)

    def run_protocol(self, before=1, after=2, length=15, report_id=3,
                     written=15, read_error=False, write_error=False):
        self.writes = []
        reads = iter([before, after])

        def ioctl(fd, request, report, mutate):
            if request == unpark.GET_FEATURE:
                if read_error:
                    raise OSError("read failed")
                report[0], report[1] = report_id, next(reads)
                return length
            self.assertEqual(request, unpark.SET_FEATURE)
            self.writes.append(bytes(report))
            if write_error:
                raise OSError("write failed")
            return written

        with patch.object(unpark.fcntl, "ioctl", side_effect=ioctl), \
             patch.object(unpark.time, "sleep"), contextlib.redirect_stdout(io.StringIO()):
            unpark.trial(123, if_parked=True)

    def test_exact_single_report(self):
        self.run_protocol()
        self.assertEqual(self.writes, [bytes([3, 2, 244, 1] + [0] * 11)])

    def test_already_awake_does_not_write(self):
        self.run_protocol(before=2)
        self.assertEqual(self.writes, [])

    def test_invalid_initial_report_never_writes(self):
        for invalid in ({"before": 0}, {"before": 9}, {"length": 14},
                        {"report_id": 4}, {"read_error": True}):
            with self.subTest(invalid=invalid):
                with self.assertRaises((RuntimeError, OSError)):
                    self.run_protocol(**invalid)
                self.assertEqual(self.writes, [])

    def test_failed_or_short_write_is_not_retried(self):
        for failure in ({"written": 14}, {"write_error": True}):
            with self.subTest(failure=failure):
                with self.assertRaises((RuntimeError, OSError)):
                    self.run_protocol(**failure)
                self.assertEqual(len(self.writes), 1)

    def test_still_parked_or_unknown_readback_fails_without_retry(self):
        for mode in (1, 9):
            with self.subTest(mode=mode):
                with self.assertRaises(RuntimeError):
                    self.run_protocol(after=mode)
                self.assertEqual(len(self.writes), 1)

    def test_opened_device_identity_and_descriptor_are_checked(self):
        descriptor = b"fixture descriptor"
        for bad in (None, "regular", "device_number", "vendor", "size", "descriptor"):
            with self.subTest(bad=bad):
                info = SimpleNamespace(st_mode=stat.S_IFREG if bad == "regular" else stat.S_IFCHR,
                                       st_rdev=os.makedev(1, 4 if bad == "device_number" else 3))

                def ioctl(fd, request, data, mutate):
                    if request == unpark.GET_INFO:
                        data[:] = struct.pack('=IHH', 3, 0 if bad == "vendor" else 0x05ac, 0x8600)
                    elif request == unpark.GET_DESC_SIZE:
                        data[:] = struct.pack('=I', 999 if bad == "size" else len(descriptor))
                    elif request == unpark.GET_DESC:
                        data[4:4 + len(descriptor)] = b'x' * len(descriptor) if bad == "descriptor" else descriptor
                    else:
                        self.fail("Device verification must not send a feature report")
                    return 0

                with patch.object(unpark.os, "fstat", return_value=info), \
                     patch.object(unpark, "attr", return_value="1:3"), \
                     patch.object(unpark.fcntl, "ioctl", side_effect=ioctl):
                    if bad:
                        with self.assertRaises(RuntimeError):
                            unpark.verify_fd(123, Path('/fixture'), descriptor)
                    else:
                        unpark.verify_fd(123, Path('/fixture'), descriptor)


if __name__ == "__main__":
    unittest.main()
