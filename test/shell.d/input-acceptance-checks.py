"""Regression fixture for the acceptance test's notification attribution.

test/acceptance.d/input-methods-test.sh asserts that no input-method
notification appeared, so a parser that stops recognising one passes there
silently. This holds the parser to a real dbus-monitor capture.
"""

from pathlib import Path
import runpy
import unittest


ROOT = Path(__file__).resolve().parents[2]
notifications = runpy.run_path(str(ROOT / "test/acceptance.d/input-method-notifications.py"))


class NotificationAttribution(unittest.TestCase):
  def test_notifications_follow_process_ownership_across_restarts(self):
    def call(sender, app, body):
      return f'''method call time=1 sender={sender} -> destination=org.freedesktop.Notifications serial=1 path=/org/freedesktop/Notifications; interface=org.freedesktop.Notifications; member=Notify
   string "{app}"
   uint32 0
   string "icon"
   string "summary"
   string "{body}"
'''
    reminder = call(":1.99", "Fcitx", "unrelated reminder")
    first = call(":1.42", "Input Method", "input setup prompt")
    second = call(":1.43", "拼音", "cloud input prompt")
    changed = '''signal time=2 sender=org.freedesktop.DBus -> destination=(null destination) serial=2 path=/org/freedesktop/DBus; interface=org.freedesktop.DBus; member=NameOwnerChanged
   string "org.fcitx.Fcitx5"
   string ":1.42"
   string ":1.43"
'''
    selected = list(notifications["input_notifications"](reminder + first + changed + second, ":1.42"))
    self.assertEqual(selected, [first, second])
    self.assertEqual(list(notifications["input_notifications"](reminder, ":1.42")), [])
    self.assertEqual(list(notifications["input_notifications"]("", ":1.42")), [])


if __name__ == "__main__":
  unittest.main()
