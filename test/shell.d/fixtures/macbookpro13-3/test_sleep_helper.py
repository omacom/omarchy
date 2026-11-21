# SPDX-License-Identifier: GPL-2.0-only
"""Exercise the published Bash helper against temporary files, never live sysfs."""
from pathlib import Path
import os
import subprocess
import tempfile
import unittest


REPO = (Path(__file__).resolve().parents[4] / "default/hardware/macbookpro13-3")


class SleepHelperTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="mbp13-3-test-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.sys = self.root / "sys"
        self.state = self.root / "run/macbook-suspend/state"
        self.state.parent.mkdir(parents=True)
        self.env = dict(os.environ, MBP_TEST_ROOT=str(self.root), MBP_TEST_PRIVILEGES="1")
        self.write("class/dmi/id/product_name", "MacBookPro13,3\n")
        self.write("module/thunderbolt/parameters/host_reset", "Y\n")
        self.write("module/acpi/parameters/ec_no_wakeup", "N\n")
        self.write("bus/platform/devices/PNP0C0D:00/power/wakeup", "enabled\n")
        self.write("power/pm_async", "1\n")
        self.write("power/mem_sleep", "s2idle [deep]\n")
        self.write("bus/usb/devices/1-1/idVendor", "05ac\n")
        self.write("bus/usb/devices/1-1/idProduct", "8600\n")
        self.write("class/drm/card0-eDP-1/status", "connected\n")
        self.write("class/drm/card1-USB-1/status", "connected\n")
        for index, (device, driver) in enumerate(
            [("0x15d2", "thunderbolt"), ("0x15d4", "xhci_hcd")] * 2
        ):
            path = f"bus/pci/devices/0000:{index:02x}:00.0"
            self.write(f"{path}/vendor", "0x8086\n")
            self.write(f"{path}/device", device + "\n")
            destination = self.sys / "drivers" / driver
            destination.mkdir(parents=True, exist_ok=True)
            (self.sys / path / "driver").symlink_to(destination)

        mock = self.root / "modprobe"
        mock.write_text("""#!/usr/bin/python3
import os, pathlib, shutil, sys
root = pathlib.Path(os.environ['MBP_TEST_ROOT'])
module = root / 'sys/module'
args = sys.argv[1:]
with (root / 'modprobe-calls').open('a') as log:
    log.write(' '.join(args) + '\\n')
if args == ['macbook_ec_wake_trial', 'apply=1']:
    if os.environ.get('MBP_TEST_FAIL_EC') == '1':
        sys.exit(1)
    path = module / 'macbook_ec_wake_trial/parameters'
    path.mkdir(parents=True, exist_ok=True)
    (path / 'apply').write_text('Y\\n')
elif args == ['-r', 'thunderbolt']:
    if os.environ.get('MBP_TEST_FAIL_UNLOAD') == '1':
        sys.exit(1)
    shutil.rmtree(module / 'thunderbolt')
elif args == ['thunderbolt', 'host_reset=0']:
    if os.environ.get('MBP_TEST_FAIL_RELOAD') == '1':
        sys.exit(1)
    path = module / 'thunderbolt/parameters'
    path.mkdir(parents=True, exist_ok=True)
    (path / 'host_reset').write_text('N\\n')
else:
    sys.exit('unexpected fake modprobe arguments')
""")
        mock.chmod(0o755)
        original = (REPO / "persistent-sleep/macbook-suspend").read_text()
        self.assertEqual(original.count("/usr/bin/modprobe"), 3)
        self.assertEqual(original.count("[[ $EUID == 0 ]]"), 1)
        script = original.replace("/sys/", str(self.sys) + "/")
        script = script.replace("/run/macbook-suspend/state", str(self.state))
        script = script.replace("/usr/bin/modprobe", str(mock))
        script = script.replace("[[ $EUID == 0 ]]", '[[ ${MBP_TEST_PRIVILEGES:-0} == 1 ]]')
        self.assertNotIn("/sys/", script.replace(str(self.sys) + "/", ""))
        self.assertNotIn("/usr/bin/modprobe", script)
        self.helper = self.root / "helper"
        self.helper.write_text(script)

    def write(self, relative, value):
        path = self.sys / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(value)

    def run_helper(self, operation, success=True):
        result = subprocess.run(
            ["bash", str(self.helper), operation], env=self.env,
            text=True, capture_output=True, timeout=10,
        )
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def assert_no_modprobe(self):
        self.assertFalse((self.root / "modprobe-calls").exists())

    def test_read_only_preflight(self):
        self.run_helper("check")
        self.assert_no_modprobe()
        self.assertEqual((self.sys / "power/pm_async").read_text(), "1\n")

    def test_wrong_model_refused(self):
        self.write("class/dmi/id/product_name", "MacBookPro14,2\n")
        self.run_helper("pre", success=False)
        self.assert_no_modprobe()

    def test_external_usb_refused(self):
        self.write("bus/usb/devices/2-1/idVendor", "1234\n")
        self.write("bus/usb/devices/2-1/idProduct", "5678\n")
        self.run_helper("pre", success=False)
        self.assert_no_modprobe()

    def test_external_thunderbolt_refused(self):
        (self.sys / "bus/thunderbolt/devices/0-1").mkdir(parents=True)
        self.run_helper("pre", success=False)
        self.assert_no_modprobe()

    def test_external_display_refused(self):
        self.write("class/drm/card0-DP-1/status", "connected\n")
        self.run_helper("pre", success=False)
        self.assert_no_modprobe()

    def test_missing_controller_binding_refused(self):
        (self.sys / "bus/pci/devices/0000:03:00.0/driver").unlink()
        self.run_helper("pre", success=False)
        self.assert_no_modprobe()

    def test_disabled_lid_wake_refused(self):
        self.write("bus/platform/devices/PNP0C0D:00/power/wakeup", "disabled\n")
        self.run_helper("pre", success=False)
        self.assert_no_modprobe()

    def test_disabled_ec_wake_refused(self):
        self.write("module/acpi/parameters/ec_no_wakeup", "Y\n")
        self.run_helper("pre", success=False)
        self.assert_no_modprobe()

    def test_first_suspend_selects_s2idle_and_restores_state(self):
        self.run_helper("pre")
        self.assertEqual((self.sys / "power/mem_sleep").read_text(), "s2idle\n")
        self.assertEqual((self.sys / "power/pm_async").read_text(), "0\n")
        self.assertFalse((self.sys / "module/thunderbolt").exists())
        self.run_helper("post")
        self.assertEqual((self.sys / "power/pm_async").read_text(), "1\n")
        self.assertEqual((self.sys / "module/thunderbolt/parameters/host_reset").read_text(), "N\n")
        self.assertFalse(self.state.exists())
        self.run_helper("post")

    def test_original_synchronous_setting_preserved(self):
        self.write("power/pm_async", "0\n")
        self.run_helper("pre")
        self.run_helper("post")
        self.assertEqual((self.sys / "power/pm_async").read_text(), "0\n")

    def test_ec_load_failure_aborts_before_controller_changes(self):
        self.env["MBP_TEST_FAIL_EC"] = "1"
        self.run_helper("pre", success=False)
        self.run_helper("post")
        self.assertEqual((self.sys / "power/pm_async").read_text(), "1\n")
        self.assertEqual((self.sys / "power/mem_sleep").read_text(), "s2idle [deep]\n")
        self.assertTrue((self.sys / "module/thunderbolt").is_dir())
        self.assertFalse(self.state.exists())

    def test_unload_failure_is_cleaned_up(self):
        self.env["MBP_TEST_FAIL_UNLOAD"] = "1"
        self.run_helper("pre", success=False)
        self.assertTrue(self.state.is_dir())
        self.run_helper("post")
        self.assertEqual((self.sys / "power/pm_async").read_text(), "1\n")
        self.assertTrue((self.sys / "module/thunderbolt").is_dir())
        self.assertFalse(self.state.exists())

    def test_reload_failure_keeps_state_for_recovery(self):
        self.run_helper("pre")
        self.env["MBP_TEST_FAIL_RELOAD"] = "1"
        self.run_helper("post", success=False)
        self.assertEqual((self.sys / "power/pm_async").read_text(), "1\n")
        self.assertTrue((self.state / "reload_thunderbolt").exists())
        del self.env["MBP_TEST_FAIL_RELOAD"]
        self.run_helper("post")
        self.assertFalse(self.state.exists())


if __name__ == "__main__":
    unittest.main()
