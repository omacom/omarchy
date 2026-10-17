# SPDX-License-Identifier: GPL-2.0-only
"""CLI dispatch uses stubs; no sudo, package installation or hardware access."""
from pathlib import Path
import os
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[4]


class CommandTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="omarchy-mbp-command-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.log = self.root / "calls"
        for name in ("bash", "python3", "gum", "sudo"):
            script = self.root / name
            script.write_text('''#!/bin/bash
printf '%s\\n' "${0##*/} $*" >> "$TEST_LOG"
if [[ ${0##*/} == gum ]]; then exit "${TEST_CONFIRM:-0}"; fi
''')
            script.chmod(0o755)
        self.env = dict(os.environ, OMARCHY_PATH=str(ROOT), TEST_LOG=str(self.log),
                        PATH=str(self.root) + ":/usr/bin")

    def run_command(self, *args, success=True):
        run = subprocess.run(["/bin/bash", str(ROOT / "bin/omarchy-setup-macbookpro13-3"), *args],
                             env=self.env, capture_output=True, text=True, timeout=5)
        self.assertEqual(run.returncode == 0, success, run.stdout + run.stderr)
        return self.log.read_text() if self.log.exists() else ""

    def test_default_check_does_not_elevate_or_request_apply(self):
        calls = self.run_command()
        self.assertIn("persistent-sleep/macbook-suspend check", calls)
        self.assertIn("python3 -I ", calls)
        self.assertNotIn("--apply", calls)
        self.assertNotIn("sudo", calls)

    def test_install_and_remove_hold_sleep_inhibitor(self):
        for action in ("install", "remove"):
            with self.subTest(action=action):
                calls = self.run_command(action)
                self.assertIn("gum confirm", calls)
                self.assertIn("sudo /usr/bin/systemd-inhibit --what=sleep --mode=block", calls)
                self.assertIn(f"/install.sh {action}", calls)
                self.log.unlink()

    def test_declining_installation_never_elevates(self):
        self.env["TEST_CONFIRM"] = "1"
        self.assertNotIn("sudo", self.run_command("install"))

    def test_invalid_actions_and_extra_arguments_never_dispatch(self):
        for args in (("reboot",), ("install", "unexpected")):
            with self.subTest(args=args):
                self.assertEqual(self.run_command(*args, success=False), "")


class NvmeTests(unittest.TestCase):
    def test_only_nvme_class_devices_are_targeted(self):
        with tempfile.TemporaryDirectory(prefix="omarchy-mbp-nvme-") as directory:
            root = Path(directory)
            nvme = root / "class/nvme/nvme0/device/d3cold_allowed"
            gpu = root / "bus/pci/devices/0000:01:00.0/d3cold_allowed"
            for file in (nvme, gpu):
                file.parent.mkdir(parents=True)
                file.write_text("1\n")
            helper = root / "helper"
            helper.write_text((ROOT / "default/hardware/macbookpro13-3/platform/macbook-nvme-suspend-fix")
                              .read_text().replace("/sys/", str(root) + "/"))
            subprocess.run(["/bin/bash", str(helper)], check=True, timeout=5)
            self.assertEqual(nvme.read_text(), "0\n")
            self.assertEqual(gpu.read_text(), "1\n")


if __name__ == "__main__":
    unittest.main()
