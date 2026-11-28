"""Exercise the privileged sudo configuration helper against temporary PAM files."""
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[4] / "default/fingerprint"))
import sudo_pam


class SetupTest(unittest.TestCase):
  def test_sudo_opt_in_round_trip_keeps_other_methods_and_password_fallback(self):
    original = (b"#%PAM-1.0\nauth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2\n"
                b"auth\tinclude\tsystem-auth\naccount include system-auth\nsession include system-auth\n")
    with tempfile.TemporaryDirectory() as tmp:
      path = Path(tmp) / "sudo"
      path.write_bytes(original)
      self.assertFalse(sudo_pam.enabled(path))
      sudo_pam.configure(path, True)
      active = path.read_bytes()
      self.assertTrue(sudo_pam.enabled(path))
      self.assertIn(sudo_pam.GATE + b"\n" + sudo_pam.FINGERPRINT + b"\nauth\tinclude", active)
      sudo_pam.configure(path, True)
      self.assertEqual(path.read_bytes(), active)
      sudo_pam.configure(path, False)
      self.assertEqual(path.read_bytes(), original)

      # Older Omarchy puts the same two rules ahead of the PAM header.
      path.write_bytes(sudo_pam.GATE + b"\n" + sudo_pam.FINGERPRINT + b"\n" + original)
      self.assertTrue(sudo_pam.enabled(path))
      sudo_pam.configure(path, False)
      self.assertEqual(path.read_bytes(), original)
      custom = original + b"Auth required pam_access.so\n"
      path.write_bytes(custom)
      self.assertIsNone(sudo_pam.enabled(path))
      with self.assertRaises(ValueError):
        sudo_pam.configure(path, True)
      self.assertEqual(path.read_bytes(), custom)

if __name__ == "__main__":
  unittest.main()
