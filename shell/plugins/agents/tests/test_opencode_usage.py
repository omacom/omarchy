import importlib.machinery
import importlib.util
import json
import sqlite3
import tempfile
import unittest
from datetime import datetime
from pathlib import Path

_path = Path(__file__).resolve().parents[4] / "bin/omarchy-agent-usage-opencode"
_loader = importlib.machinery.SourceFileLoader("opencode_usage", str(_path))
_spec = importlib.util.spec_from_loader(_loader.name, _loader)
opencode = importlib.util.module_from_spec(_spec)
_loader.exec_module(opencode)


def assistant(created_ms, tokens, completed=True):
    data = {
        "role": "assistant",
        "modelID": "muse-spark-1.3-contributor-free",
        "tokens": tokens,
        "time": {"created": created_ms},
    }
    if completed:
        data["time"]["completed"] = created_ms + 1000
    return data


class OpenCodeUsageTests(unittest.TestCase):
    def test_ms_timestamps_are_local_days_not_today(self):
        local = datetime.now().astimezone().replace(year=2026, month=9, day=6, hour=8, minute=0, second=0, microsecond=0)
        self.assertEqual(opencode.day_from_stamp(int(local.timestamp() * 1000)), "2026-09-06")
        self.assertEqual(opencode.day_from_stamp(0), "")
        self.assertEqual(opencode.day_from_stamp(None), "")

    def test_missing_stamp_is_not_today(self):
        self.assertEqual(opencode.day_from_stamp(""), "")

    def _db(self, messages):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        path = Path(tmp.name) / "opencode.db"
        conn = sqlite3.connect(path)
        conn.execute("CREATE TABLE session(id TEXT PRIMARY KEY, directory TEXT)")
        conn.execute("CREATE TABLE message(id TEXT, session_id TEXT, time_created INTEGER, data TEXT)")
        conn.execute("INSERT INTO session VALUES ('s1', '/tmp')")
        for i, (created, data) in enumerate(messages):
            conn.execute(
                "INSERT INTO message VALUES (?, 's1', ?, ?)",
                (f"m{i}", created, json.dumps(data)),
            )
        conn.commit()
        conn.close()
        return path

    def test_old_session_does_not_count_as_today(self):
        old = datetime.now().astimezone().replace(year=2026, month=9, day=6, hour=8)
        created = int(old.timestamp() * 1000)
        path = self._db([(created, assistant(created, {
            "input": 1000, "output": 20, "reasoning": 5,
            "cache": {"read": 585147 - 1025, "write": 0},
        }))])
        stats = opencode.collect(path)
        today = datetime.now().astimezone().date().isoformat()
        self.assertEqual(stats["todayTotalTokens"], 0 if today != "2026-09-06" else 585147)
        self.assertIn("2026-09-06", stats["activeDates"])
        by_date = {row["date"]: row["messageCount"] for row in stats["recentDays"]}
        if today != "2026-09-06":
            self.assertEqual(by_date.get(today, 0), 0)
            self.assertEqual(stats["todayPrompts"], 0)
            self.assertEqual(stats["todaySessions"], 0)

    def test_incomplete_assistant_is_skipped(self):
        now = datetime.now().astimezone()
        created = int(now.timestamp() * 1000)
        path = self._db([(created, assistant(created, {
            "input": 50, "output": 10, "cache": {"read": 0, "write": 0},
        }, completed=False))])
        stats = opencode.collect(path)
        self.assertEqual(stats["todayTotalTokens"], 0)
        self.assertEqual(stats["totalPrompts"], 0)

    def test_user_messages_are_skipped(self):
        now = datetime.now().astimezone()
        created = int(now.timestamp() * 1000)
        path = self._db([(created, {"role": "user", "time": {"created": created}, "tokens": {"input": 9}})])
        self.assertEqual(opencode.collect(path)["totalPrompts"], 0)

    def test_empty_db_writes_current_week_zeros(self):
        stats = opencode.collect(Path("/tmp/missing-opencode.db"))
        today = datetime.now().astimezone().date().isoformat()
        self.assertEqual(stats["todayTotalTokens"], 0)
        self.assertEqual(stats["recentDays"][-1]["date"], today)


if __name__ == "__main__":
    unittest.main()
