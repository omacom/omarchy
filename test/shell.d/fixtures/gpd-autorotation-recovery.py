"""Exercise the production daemon with deterministic sensor/compositor replies."""
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch

loader = importlib.machinery.SourceFileLoader("gpd_rotation", sys.argv.pop(1))
spec = importlib.util.spec_from_loader(loader.name, loader)
daemon = importlib.util.module_from_spec(spec)
loader.exec_module(daemon)


class Sensor:
    def __init__(self, available=True):
        self.available = available
        self.owner = ":1.10"
        self.handlers = {}
        self.claims = 0

    def get_cached_property(self, key):
        return self.available if key == "HasAccelerometer" else "right-up"

    def get_name_owner(self):
        return self.owner

    def connect(self, signal, callback):
        self.handlers[signal] = callback

    def call_sync(self, method, *_):
        assert method == "ClaimAccelerometer"
        self.claims += 1


class RecoveryTests(unittest.TestCase):
    def test_delayed_sensor(self):
        sensor = Sensor()
        factory = Mock(side_effect=[RuntimeError(), Sensor(False), sensor])
        gio = SimpleNamespace(DBusProxy=SimpleNamespace(new_for_bus_sync=factory),
                              BusType=SimpleNamespace(SYSTEM=0),
                              DBusProxyFlags=SimpleNamespace(NONE=0))
        with patch.object(daemon, "Gio", gio), patch.object(daemon, "GLib", SimpleNamespace(Error=RuntimeError)), \
                patch.object(daemon.time, "monotonic", side_effect=[0, 1, 2]), \
                patch.object(daemon.time, "sleep") as sleep:
            self.assertIs(daemon.wait_for_sensor(), sensor)
            self.assertEqual(factory.call_count, 3)
            self.assertEqual(sleep.call_args_list[0].args, (2,))
            self.assertEqual(sleep.call_count, 2)

    def test_sensor_timeout(self):
        gio = SimpleNamespace(DBusProxy=SimpleNamespace(new_for_bus_sync=lambda *_: Sensor(False)),
                              BusType=SimpleNamespace(SYSTEM=0), DBusProxyFlags=SimpleNamespace(NONE=0))
        with patch.object(daemon, "Gio", gio), patch.object(daemon.time, "monotonic", side_effect=[0, 61]):
            self.assertIsNone(daemon.wait_for_sensor())

    def run_main(self, action):
        sensor = Sensor()
        loop = SimpleNamespace(quit=Mock())
        timer = {}

        def add_timer(seconds, callback):
            self.assertEqual(seconds, 10)
            timer["callback"] = callback

        loop.run = lambda: action(sensor, timer, loop)
        glib = SimpleNamespace(MainLoop=lambda: loop, timeout_add_seconds=add_timer, Error=RuntimeError)
        gio = SimpleNamespace(DBusCallFlags=SimpleNamespace(NONE=0))
        with patch.object(daemon, "GLib", glib), patch.object(daemon, "Gio", gio), \
                patch.object(daemon, "ensure_hyprland_env", return_value=True), \
                patch.object(daemon, "detect_monitor", return_value="eDP-1"), \
                patch.object(daemon, "detect_touch_device", return_value="touch"), \
                patch.object(daemon, "load_offset", return_value=0), \
                patch.object(daemon, "wait_for_sensor", return_value=sensor), \
                patch.object(daemon, "current_monitor_transform", return_value=0), \
                patch.object(daemon, "apply_transform") as apply:
            result = daemon.main()
            return result, sensor, loop, apply.call_args_list

    def test_reload_reconciliation(self):
        def reload(sensor, timer, loop):
            self.assertTrue(timer["callback"]())

        result, sensor, _, calls = self.run_main(reload)
        self.assertEqual(result, 0)
        self.assertEqual(sensor.claims, 1)
        self.assertEqual([c.args for c in calls], [("eDP-1", "touch", 3)] * 2)

    def test_sensor_owner_loss_and_replacement_fail_for_systemd_retry(self):
        for replacement in (None, ":1.11"):
            with self.subTest(owner=replacement):
                def restart(sensor, timer, loop):
                    sensor.owner = replacement
                    self.assertIn("notify::g-name-owner", sensor.handlers)
                    sensor.handlers["notify::g-name-owner"](sensor, None)

                result, _, loop, _ = self.run_main(restart)
                self.assertEqual(result, 1)
                loop.quit.assert_called_once()
        # A restarted process claims its new proxy again before handling pose.
        _, replacement, _, _ = self.run_main(lambda *_: None)
        self.assertEqual(replacement.claims, 1)

    def test_fallback_uses_newest_reachable_instance(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {"XDG_RUNTIME_DIR": directory}):
            os.environ.pop("HYPRLAND_INSTANCE_SIGNATURE", None)
            root = Path(directory) / "hypr"
            root.mkdir()
            for name, mtime in (("z-old", 10), ("a-live", 20), ("dead-newest", 30)):
                path = root / name
                path.mkdir()
                os.utime(path, (mtime, mtime))
            attempted = []

            def probe(command, **kwargs):
                self.assertEqual(command, ["hyprctl", "monitors", "-j"])
                self.assertEqual(kwargs["timeout"], 3)
                signature = kwargs["env"]["HYPRLAND_INSTANCE_SIGNATURE"]
                attempted.append(signature)
                if signature == "dead-newest":
                    raise subprocess.CalledProcessError(1, command)
                return SimpleNamespace(stdout=json.dumps([{"name": "eDP-1"}]))

            with patch.object(daemon.subprocess, "run", side_effect=probe):
                self.assertTrue(daemon.ensure_hyprland_env())
            self.assertEqual(attempted, ["dead-newest", "a-live"])
            self.assertEqual(os.environ["HYPRLAND_INSTANCE_SIGNATURE"], "a-live")

    def test_fallback_does_not_publish_unreachable_instance(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {"XDG_RUNTIME_DIR": directory}):
            os.environ.pop("HYPRLAND_INSTANCE_SIGNATURE", None)
            (Path(directory) / "hypr" / "dead").mkdir(parents=True)
            with patch.object(daemon.subprocess, "run", side_effect=subprocess.TimeoutExpired("hyprctl", 3)):
                self.assertFalse(daemon.ensure_hyprland_env())
            self.assertNotIn("HYPRLAND_INSTANCE_SIGNATURE", os.environ)


unittest.main()
