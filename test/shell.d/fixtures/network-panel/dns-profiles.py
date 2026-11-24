"""Exercise the actual libnm setting objects without touching host networking."""
import contextlib
import io
from pathlib import Path
import runpy
import unittest
from unittest.mock import patch

MODULE = runpy.run_path(str(Path(__file__).resolve().parents[4] / "shell/plugins/panels/network/profiles/network-dns"))
NM = MODULE["NM"]


class Connection:
    def __init__(self):
        self.settings = NM.SimpleConnection.new()
        for kind in (NM.SettingIP4Config, NM.SettingIP6Config):
            ip = kind.new()
            ip.props.method = "auto"
            self.settings.add_setting(ip)

    def __getattr__(self, name):
        return getattr(self.settings, name)

    def get_version_id(self):
        return 1


class ProfileTests(unittest.TestCase):
    def setUp(self):
        self.links = {"wired": Connection(), "wifi": Connection()}
        self.reapplies = []
        self.commits = []
        functions = MODULE["configure"].__globals__
        self.enterContext(patch.dict(
            functions,
            active=lambda: [("wired", "802-3-ethernet", "eth0"),
                            ("wifi", "802-11-wireless", "wlan0")],
            connection=self.links.__getitem__,
            discover_work_dns=lambda device: None,
            commit_profile=lambda remote, version: self.commits.append(remote),
            call=lambda *args: self.reapplies.append(args),
        ))
        self.enterContext(contextlib.redirect_stdout(io.StringIO()))

    def apply(self, mode, answers=None, target="wired"):
        with patch("builtins.input", side_effect=answers or []):
            return MODULE["configure"](mode, target, interactive=answers is not None)

    def test_switching_retains_legacy_work_and_independent_home_presets(self):
        remote = self.links["wired"]
        ip = remote.get_setting_ip4_config()
        ip.add_dns("192.0.2.53")
        ip.add_dns_search("~corp.example")
        ip.add_dns_search("~admin.example.org")
        metadata = NM.SettingUser.new()
        metadata.set_data(MODULE["KEY"], "Work/Google")
        remote.add_setting(metadata)
        self.assertEqual(self.apply("Automatic"), 0)
        self.assertEqual(ip.get_num_dns(), 0)
        self.assertEqual(self.apply("Home"), 3)
        self.assertEqual(self.apply("Home", ["2"]), 0)
        self.assertEqual(self.apply("Home office", ["3"]), 0)
        self.assertEqual(self.apply("Home"), 0)
        self.assertEqual(ip.get_dns(0), "8.8.8.8")
        self.assertEqual(self.apply("Home office"), 0)
        self.assertEqual(ip.get_dns(0), "1.1.1.1")
        self.assertEqual(self.apply("Work"), 0)
        self.assertEqual(ip.get_dns(0), "192.0.2.53")
        self.assertEqual(ip.get_dns_search(1), "~admin.example.org")
        self.assertEqual(self.apply("Work", target="wifi"), 3)

    def test_editing_inactive_mode_cancel_and_invalid_input(self):
        self.apply("Home", ["1"])
        count = len(self.reapplies)
        self.apply("--edit", ["1", "corp.example", "2001:db8::53", "3"])
        self.assertEqual(len(self.reapplies), count)
        self.assertEqual(MODULE["profile"]("wired"), ("Home", "Network DNS"))
        self.apply("Work")
        ip = self.links["wired"].get_setting_ip6_config()
        self.assertEqual(ip.get_dns(0), "2001:db8::53")
        self.assertEqual(ip.get_dns_search(0), "~corp.example")
        count = len(self.commits)
        with self.assertRaises(KeyboardInterrupt):
            self.apply("--edit", ["1", "changed.example", KeyboardInterrupt])
        with self.assertRaises(ValueError):
            self.apply("--edit", ["1", "invalid hostname", "", ""])
        self.assertEqual(len(self.commits), count)
        self.assertEqual(ip.get_dns_search(0), "~corp.example")

    def test_setup_accepts_dhcp_defaults_only_once(self):
        detected = (["~office.example"], MODULE["servers"]("192.0.2.53"))
        with patch.dict(MODULE["configure"].__globals__, discover_work_dns=lambda _: detected):
            self.apply("Work", ["office.example admin.example.org", "", ""])
        self.apply("Automatic")
        self.apply("Work")
        ip = self.links["wired"].get_setting_ip4_config()
        self.assertEqual(ip.get_dns_search(1), "~admin.example.org")
        self.assertEqual(ip.get_dns(0), "192.0.2.53")


if __name__ == "__main__":
    unittest.main()
