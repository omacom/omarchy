"""Contract for Panel.qml periodModelMap.

Keep this in sync with the QML: bounded periods (day/week/month) may only
use history.tokensByModel and todayTokensByModel. modelUsage is all-time or
the current billing cycle and belongs to Total alone.
"""
import unittest
from datetime import date, timedelta


def bucket_total(bucket):
    if isinstance(bucket, (int, float)):
        return int(bucket)
    if not isinstance(bucket, dict):
        return 0
    return int(sum(float(bucket.get(k, 0) or 0) for k in (
        "inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens")))


def add_token(usage, mid, value):
    usage.setdefault(mid, {
        "inputTokens": 0, "outputTokens": 0,
        "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0,
    })
    if isinstance(value, dict):
        for key in usage[mid]:
            usage[mid][key] += int(float(value.get(key, 0) or 0))
    else:
        usage[mid]["inputTokens"] += int(float(value or 0))


def usage_map_total(usage):
    return sum(bucket_total(v) for v in usage.values())


def period_start(kind, today):
    if kind == "day":
        return today
    if kind == "week":
        return (date.fromisoformat(today) - timedelta(days=6)).isoformat()
    if kind == "month":
        return (date.fromisoformat(today) - timedelta(days=29)).isoformat()
    return ""


def period_model_map(p, kind, today):
    if not p:
        return {}
    if p.get("providerId") == "all":
        combined = {}
        for child in p.get("providers") or []:
            if not child or child.get("providerId") == "all":
                continue
            for mid, val in period_model_map(child, kind, today).items():
                add_token(combined, mid, val)
        return combined
    if kind == "total":
        usage = {}
        for mid, val in (p.get("modelUsage") or {}).items():
            add_token(usage, mid, val)
        return usage
    start = period_start(kind, today)
    usage = {}
    today_covered = False
    for row in p.get("history") or []:
        day = str(row.get("date") or "")
        if start and day < start:
            continue
        models = row.get("tokensByModel") or {}
        before = usage_map_total(usage)
        for mid, val in models.items():
            add_token(usage, mid, val)
        if day == today and usage_map_total(usage) > before:
            today_covered = True
    if not today_covered and period_today_is_current(p, today):
        for mid, val in (p.get("todayTokensByModel") or {}).items():
            add_token(usage, mid, val)
    return usage


def period_today_is_current(p, today):
    updated = p.get("updatedAt")
    if updated:
        try:
            stamp = str(updated).replace("Z", "+00:00")
            parsed = date.fromisoformat(stamp[:10])
            if parsed.isoformat() == today:
                return True
        except ValueError:
            pass
    for row in (p.get("recentDays") or []) + (p.get("history") or []):
        if str((row or {}).get("date") or "") == today:
            return True
    return False


class PeriodModelMapTests(unittest.TestCase):
    today = "2026-09-09"

    def test_day_does_not_use_cursor_billing_cycle(self):
        cursor = {
            "providerId": "cursor",
            "todayTotalTokens": 0,
            "todayTokensByModel": {},
            "history": [],
            "recentDays": [{"date": self.today, "messageCount": 1}],
            "modelUsage": {
                "grok-bot-default": {"inputTokens": 1_100_000_000},
                "cursor-grok-4.6-xhigh-fast": {"inputTokens": 994_200_000},
            },
        }
        grok = {
            "providerId": "grok",
            "updatedAt": "2026-09-09T12:00:00+00:00",
            "todayTotalTokens": 196_600_000,
            "todayTokensByModel": {"grok-4.6-build": 196_600_000},
            "history": [],
            "modelUsage": {"grok-4.6-build": {"inputTokens": 851_000_000}},
        }
        combined = period_model_map(
            {"providerId": "all", "providers": [cursor, grok]}, "day", self.today)
        self.assertNotIn("grok-bot-default", combined)
        self.assertNotIn("cursor-grok-4.6-xhigh-fast", combined)
        self.assertEqual(bucket_total(combined["grok-4.6-build"]), 196_600_000)

    def test_total_still_shows_cycle_usage(self):
        cursor = {
            "providerId": "cursor",
            "todayTokensByModel": {},
            "modelUsage": {"grok-bot-default": {"inputTokens": 1_100_000_000}},
        }
        usage = period_model_map(cursor, "total", self.today)
        self.assertEqual(bucket_total(usage["grok-bot-default"]), 1_100_000_000)

    def test_history_today_is_not_double_counted(self):
        hermes = {
            "providerId": "hermes",
            "todayTokensByModel": {"grok-4.6": 1_500_000},
            "history": [{
                "date": self.today,
                "messageCount": 1_500_000,
                "tokensByModel": {"grok-4.6": 1_500_000},
            }],
            "modelUsage": {"grok-4.6": {"inputTokens": 272_000_000}},
        }
        usage = period_model_map(hermes, "day", self.today)
        self.assertEqual(bucket_total(usage["grok-4.6"]), 1_500_000)

    def test_week_keeps_per_day_history_and_skips_all_time(self):
        hermes = {
            "providerId": "hermes",
            "todayTokensByModel": {"grok-4.6": 10},
            "history": [
                {"date": "2026-09-08", "tokensByModel": {"gpt-6-astra": 100}},
                {"date": "2026-09-09", "tokensByModel": {"grok-4.6": 10}},
            ],
            "modelUsage": {"gpt-6-astra": {"inputTokens": 74_000_000}},
        }
        usage = period_model_map(hermes, "week", self.today)
        self.assertEqual(bucket_total(usage["gpt-6-astra"]), 100)
        self.assertEqual(bucket_total(usage["grok-4.6"]), 10)

    def test_stale_today_tokens_are_not_a_day_fallback(self):
        stale = {
            "providerId": "opencode",
            "updatedAt": None,
            "todayTotalTokens": 585147,
            "todayTokensByModel": {"muse-spark-1.3-contributor-free": 585147},
            "history": [],
            "recentDays": [{"date": "2026-09-06", "messageCount": 585147}],
        }
        usage = period_model_map(stale, "day", self.today)
        self.assertEqual(usage, {})


if __name__ == "__main__":
    unittest.main()
