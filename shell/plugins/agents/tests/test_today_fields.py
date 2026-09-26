"""Contract for Main.qml todayFieldsAreCurrent / currentTodayStats.

A usage file that stopped being rewritten keeps yesterday's totals in
todayTotalTokens. The Day filter must not treat that as calendar today.
"""
import unittest
from datetime import date, datetime, timezone


def date_string(value):
    if isinstance(value, datetime):
        value = value.astimezone()
        return value.date().isoformat()
    if isinstance(value, date):
        return value.isoformat()
    parsed = datetime.fromisoformat(str(value).replace("Z", "+00:00"))
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone().date().isoformat()


def today_fields_are_current(record, today):
    if not record:
        return False
    updated = record.get("updatedAt")
    if updated:
        try:
            if date_string(updated) == today:
                return True
        except (TypeError, ValueError):
            pass
    for key in ("recentDays", "history"):
        for row in record.get(key) or []:
            if str((row or {}).get("date") or "") == today:
                return True
    return False


def current_today_stats(record, today):
    if today_fields_are_current(record, today):
        return {
            "todayPrompts": int(record.get("todayPrompts") or 0),
            "todaySessions": int(record.get("todaySessions") or 0),
            "todayTotalTokens": int(record.get("todayTotalTokens") or 0),
            "todayTokensByModel": record.get("todayTokensByModel") or {},
        }
    return {
        "todayPrompts": 0,
        "todaySessions": 0,
        "todayTotalTokens": 0,
        "todayTokensByModel": {},
    }


class TodayFieldsTests(unittest.TestCase):
    today = "2026-09-12"

    def test_stale_opencode_file_is_not_today(self):
        record = {
            "updatedAt": None,
            "todayTotalTokens": 585147,
            "todayPrompts": 20,
            "todaySessions": 2,
            "todayTokensByModel": {"muse-spark-1.3-contributor-free": 585147},
            "recentDays": [
                {"date": "2026-08-31", "messageCount": 0},
                {"date": "2026-09-06", "messageCount": 585147},
            ],
            "activeDates": ["2026-09-05", "2026-09-06"],
        }
        self.assertFalse(today_fields_are_current(record, self.today))
        self.assertEqual(current_today_stats(record, self.today)["todayTotalTokens"], 0)

    def test_fresh_updated_at_keeps_today(self):
        noon = datetime(2026, 9, 12, 12, 0, tzinfo=datetime.now().astimezone().tzinfo)
        record = {
            "updatedAt": noon.isoformat(),
            "todayTotalTokens": 64196065,
            "recentDays": [{"date": "2026-09-11", "messageCount": 1}],
        }
        self.assertTrue(today_fields_are_current(record, self.today))
        self.assertEqual(current_today_stats(record, self.today)["todayTotalTokens"], 64196065)

    def test_yesterday_updated_at_drops_today(self):
        yesterday = datetime(2026, 9, 11, 12, 0, tzinfo=datetime.now().astimezone().tzinfo)
        record = {
            "updatedAt": yesterday.isoformat(),
            "todayTotalTokens": 500000,
            "recentDays": [{"date": "2026-09-11", "messageCount": 500000}],
        }
        self.assertFalse(today_fields_are_current(record, self.today))
        self.assertEqual(current_today_stats(record, self.today)["todayTotalTokens"], 0)

    def test_recent_days_covering_today_without_updated_at(self):
        record = {
            "updatedAt": None,
            "todayTotalTokens": 12,
            "recentDays": [{"date": self.today, "messageCount": 12}],
        }
        self.assertTrue(today_fields_are_current(record, self.today))
        self.assertEqual(current_today_stats(record, self.today)["todayTotalTokens"], 12)


if __name__ == "__main__":
    unittest.main()
