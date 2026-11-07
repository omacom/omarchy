# SPDX-License-Identifier: GPL-2.0-only
"""Execute the installer with temporary filesystem roots and command stubs."""
from pathlib import Path
import os
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[4]
PAYLOAD = ROOT / "default/hardware/macbookpro13-3"


class InstallTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="omarchy-mbp-install-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.env = dict(os.environ, TEST_ROOT=str(self.root))
        self.env["PATH"] = str(self.bin) + ":/usr/bin:/usr/sbin"
        self.target = self.root / "usr/local/libexec/omarchy-macbookpro13-3"
        self.src = self.root / "usr/src/macbook-ec-wake-0.1"
        self.dropin = self.root / "etc/systemd/system/systemd-suspend.service.d/60-omarchy-macbookpro13-3.conf"
        self.policy = self.root / "etc/systemd/sleep.conf.d/60-omarchy-macbookpro13-3.conf"
        model = self.root / "sys/class/dmi/id/product_name"
        model.parent.mkdir(parents=True)
        model.write_text("MacBookPro13,3\n")
        release = subprocess.check_output(["uname", "-r"], text=True).strip()
        (self.root / "usr/lib/modules" / release / "build").mkdir(parents=True)
        self.stub("systemctl", '''
printf '%s\\n' "$*" >> "$TEST_ROOT/systemctl-calls"
case $* in
  *ActiveState*) [[ ${TEST_BUS_FAIL:-0} == 0 ]] || exit 1; echo "${TEST_STATE-inactive}" ;;
  *ExecStartPre*)
    [[ ${TEST_PRE_QUERY_FAIL:-0} == 0 ]] || exit 1
    if [[ -e $TEST_ROOT/etc/systemd/system/systemd-suspend.service.d/60-omarchy-macbookpro13-3.conf ]]; then
      [[ ${TEST_MISSING_PRE:-0} == 1 ]] || echo "$TEST_ROOT/usr/local/libexec/omarchy-macbookpro13-3/suspend pre"
      exit 0
    else
      printf '%s' "${TEST_PRE_HOOK:-}"
    fi ;;
  *ExecStopPost*)
    [[ ${TEST_POST_QUERY_FAIL:-0} == 0 ]] || exit 1
    if [[ -e $TEST_ROOT/etc/systemd/system/systemd-suspend.service.d/60-omarchy-macbookpro13-3.conf ]]; then
      if [[ ${TEST_BAD_ORDER:-0} == 1 ]]; then
        echo "$TEST_ROOT/usr/local/libexec/omarchy-macbookpro13-3/resume"
      else
        printf '%s ' "$TEST_ROOT/usr/local/libexec/omarchy-macbookpro13-3/suspend post"
        echo "$TEST_ROOT/usr/local/libexec/omarchy-macbookpro13-3/resume"
      fi
    else
      printf '%s' "${TEST_POST_HOOK:-}"
    fi ;;
  daemon-reload) : ;;
  *) exit 99 ;;
esac
''')
        self.stub("systemd-analyze", '''
case $1 in
  verify) exit "${TEST_VERIFY_FAIL:-0}" ;;
  cat-config)
    cat "$TEST_ROOT/etc/systemd/sleep.conf.d/60-omarchy-macbookpro13-3.conf"
    [[ ${TEST_POLICY_CONFLICT:-0} == 0 ]] || printf '[Sleep]\\nMemorySleepMode=deep\\n'
    [[ ${TEST_STATE_CONFLICT:-0} == 0 ]] || printf '[Sleep]\\nSuspendState=freeze\\n'
    exit 0 ;;
  *) exit 99 ;;
esac
''')
        self.stub("modinfo", 'exit "${TEST_MODINFO_FAIL:-0}"\n')
        self.stub("dkms", '''
echo "$*" >> "$TEST_ROOT/dkms-calls"
case $1 in
  add) mkdir -p "$TEST_ROOT/var/lib/dkms/macbook-ec-wake/0.1" ;;
  build) exit "${TEST_BUILD_FAIL:-0}" ;;
  install) exit "${TEST_DKMS_INSTALL_FAIL:-0}" ;;
  remove) rmdir "$TEST_ROOT/var/lib/dkms/macbook-ec-wake/0.1" "$TEST_ROOT/var/lib/dkms/macbook-ec-wake" ;;
  *) exit 99 ;;
esac
''')
        self.stub("preflight", 'exit "${TEST_PREFLIGHT_FAIL:-0}"\n')

    def stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/bash\nset -euo pipefail\n" + body)
        path.chmod(0o755)

    def run_installer(self, action="install", success=True):
        source = (PAYLOAD / "install.sh").read_text()
        source = source.replace("export PATH=/usr/bin:/usr/sbin", "# fixture PATH")
        source = source.replace("[[ $EUID == 0 ]]", "[[ 1 == 1 ]]")
        for prefix in ("/sys/", "/usr/local/", "/etc/systemd/", "/run/macbook-",
                       "/var/lib/", "/usr/src/", "/usr/lib/modules/"):
            source = source.replace(prefix, str(self.root) + prefix)
        source = source.replace('base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)',
                                'base="' + str(PAYLOAD) + '"')
        source = source.replace('/usr/bin/python3 -I "$base/touchbar/unpark.py"', "preflight")
        source = source.replace('bash "$base/persistent-sleep/macbook-suspend" check', "preflight")
        script = self.root / "installer"
        script.write_text(source)
        result = subprocess.run(["bash", str(script), action], env=self.env,
                                capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result

    def assert_not_installed(self):
        for path in (self.target, self.src, self.dropin, self.policy):
            self.assertFalse(path.exists(), str(path))

    def test_install_remove_and_private_root_runtime_permissions(self):
        self.run_installer()
        self.assertEqual(self.target.stat().st_mode & 0o777, 0o700)
        for file, mode in (("unpark.py", 0o600), ("suspend", 0o700), ("resume", 0o700)):
            self.assertEqual((self.target / file).stat().st_mode & 0o777, mode)
        self.assertEqual(self.src.stat().st_mode & 0o777, 0o755)
        self.assertEqual(self.policy.stat().st_mode & 0o777, 0o644)
        self.assertEqual(self.dropin.read_bytes(), (PAYLOAD / "suspend.conf").read_bytes())
        self.run_installer("remove")
        self.assert_not_installed()
        self.assertNotIn("suspend\n", (self.root / "systemctl-calls").read_text())

    def test_noninactive_or_unreadable_systemd_state_never_installs(self):
        for key, value in (("TEST_BUS_FAIL", "1"), ("TEST_STATE", "activating"),
                           ("TEST_STATE", "active"), ("TEST_STATE", "deactivating"),
                           ("TEST_STATE", "failed"), ("TEST_STATE", "")):
            with self.subTest(key=key, value=value):
                self.env[key] = value
                self.run_installer(success=False)
                self.assert_not_installed()
                del self.env[key]

    def test_wrong_model_and_missing_model_refused(self):
        model = self.root / "sys/class/dmi/id/product_name"
        model.write_text("MacBookPro14,3\n")
        self.run_installer(success=False)
        self.assert_not_installed()
        model.unlink()
        self.run_installer(success=False)
        self.assert_not_installed()

    def test_pending_controller_recovery_refused(self):
        (self.root / "run/macbook-suspend/state").mkdir(parents=True)
        self.run_installer(success=False)
        self.assert_not_installed()

    def test_preflight_and_existing_hooks_refused(self):
        for key in ("TEST_PREFLIGHT_FAIL", "TEST_PRE_HOOK", "TEST_POST_HOOK",
                    "TEST_PRE_QUERY_FAIL", "TEST_POST_QUERY_FAIL"):
            with self.subTest(key=key):
                self.env[key] = "1"
                self.run_installer(success=False)
                self.assert_not_installed()
                del self.env[key]

    def test_existing_community_installation_and_dangling_symlink_preserved(self):
        path = self.root / "usr/local/sbin/macbook-suspend"
        path.parent.mkdir(parents=True)
        path.symlink_to("nonexistent")
        self.run_installer(success=False)
        self.assertTrue(path.is_symlink())
        self.assert_not_installed()

    def test_partial_failures_remove_policy_hooks_source_and_dkms(self):
        for key in ("TEST_BUILD_FAIL", "TEST_DKMS_INSTALL_FAIL", "TEST_MODINFO_FAIL",
                    "TEST_VERIFY_FAIL", "TEST_BAD_ORDER", "TEST_POLICY_CONFLICT",
                    "TEST_STATE_CONFLICT", "TEST_MISSING_PRE"):
            with self.subTest(key=key):
                self.env[key] = "1"
                self.run_installer(success=False)
                self.assert_not_installed()
                self.assertFalse((self.root / "var/lib/dkms/macbook-ec-wake").exists())
                del self.env[key]

    def test_existing_installation_and_admin_edits_preserved(self):
        self.run_installer()
        self.run_installer(success=False)
        (self.target / "resume").write_text("administrator edit\n")
        self.run_installer("remove", success=False)
        self.assertTrue(self.dropin.exists())
        self.assertEqual((self.target / "resume").read_text(), "administrator edit\n")

    def test_manifest_cannot_substitute_an_unrelated_file(self):
        self.run_installer()
        unrelated = self.root / "unrelated"
        unrelated.write_text("preserve me\n")
        (self.target / "files.sha256").write_bytes(subprocess.check_output(["sha256sum", str(unrelated)]))
        self.run_installer("remove", success=False)
        self.assertTrue(self.dropin.exists())
        self.assertTrue(unrelated.exists())


if __name__ == "__main__":
    unittest.main()
