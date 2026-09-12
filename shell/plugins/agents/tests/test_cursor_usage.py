import importlib.machinery
import importlib.util
import unittest
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

_path = Path(__file__).resolve().parents[4] / "bin/omarchy-agent-usage-cursor"
_loader = importlib.machinery.SourceFileLoader("cursor_usage", str(_path))
_spec = importlib.util.spec_from_loader(_loader.name, _loader)
cursor = importlib.util.module_from_spec(_spec)
_loader.exec_module(cursor)


class CursorUsageTests(unittest.TestCase):
    def test_day_bounds_are_local_midnight_to_last_ms(self):
        tz = timezone(timedelta(hours=-3))
        start, end = cursor.day_bounds_ms(date(2026, 9, 9), tz)
        self.assertEqual(datetime.fromtimestamp(start / 1000, tz=tz).isoformat(),
                         "2026-09-09T00:00:00-03:00")
        self.assertEqual(datetime.fromtimestamp(end / 1000, tz=tz).isoformat(),
                         "2026-09-09T23:59:59.999000-03:00")
        self.assertEqual(end - start, 86_400_000 - 1)

    def test_parse_aggregations_counts_string_token_fields(self):
        usage, totals, total = cursor.parse_aggregations({
            "aggregations": [{
                "modelIntent": "grok-bot-default",
                "inputTokens": "100",
                "outputTokens": "20",
                "cacheReadTokens": "5",
                "cacheWriteTokens": "1",
            }]
        })
        self.assertEqual(total, 126)
        self.assertEqual(totals["grok-bot-default"], 126)
        self.assertEqual(usage["grok-bot-default"]["inputTokens"], 100)
        self.assertEqual(usage["grok-bot-default"]["cacheReadInputTokens"], 5)

    def test_empty_aggregations_are_not_the_cycle_map(self):
        usage, totals, total = cursor.parse_aggregations({"aggregations": []})
        self.assertEqual((usage, totals, total), ({}, {}, 0))

    def _record(self, updated_at):
        return {
            "updatedAt": updated_at,
            "modelUsage": {"cursor-grok-4.6-high": {
                "inputTokens": 10, "outputTokens": 2,
                "cacheReadInputTokens": 3, "cacheCreationInputTokens": 1}},
            "history": [
                {"date": "2026-09-09", "messageCount": 400,
                 "tokensByModel": {"cursor-grok-4.6-high": 400}},
                {"date": "2026-09-10", "messageCount": 700,
                 "tokensByModel": {"cursor-grok-4.6-high": 700}},
            ],
            "recentDays": [{"date": "2026-09-09", "messageCount": 400},
                           {"date": "2026-09-10", "messageCount": 700}],
            "todayTotalTokens": 700,
            "todayTokensByModel": {"cursor-grok-4.6-high": 700},
        }

    def test_usage_map_total_sums_every_bucket(self):
        self.assertEqual(cursor.usage_map_total(self._record("")["modelUsage"]), 16)
        self.assertEqual(cursor.usage_map_total({"m": "not a bucket"}), 0)

    def test_carried_stats_keeps_tokens_from_the_last_full_run(self):
        local_now = datetime.now().astimezone().replace(
            year=2026, month=9, day=10, hour=12).isoformat()
        models, today_models, today_total, history, by_day = cursor.carried_stats(
            self._record(local_now), date(2026, 9, 10))
        self.assertEqual(today_total, 700)
        self.assertEqual(today_models, {"cursor-grok-4.6-high": 700})
        self.assertEqual([row["date"] for row in history], ["2026-09-09", "2026-09-10"])
        self.assertEqual(by_day["2026-09-09"], 400)
        self.assertIn("cursor-grok-4.6-high", models)

    def test_carried_stats_drops_a_stale_today(self):
        local_now = datetime.now().astimezone().replace(
            year=2026, month=9, day=10, hour=12).isoformat()
        models, today_models, today_total, history, by_day = cursor.carried_stats(
            self._record(local_now), date(2026, 9, 11))
        # The record is yesterday's: its day rows survive, its "today" does not.
        self.assertEqual((today_total, today_models), (0, {}))
        self.assertNotIn("2026-09-11", by_day)
        self.assertEqual([row["date"] for row in history], ["2026-09-09", "2026-09-10"])
        self.assertIn("cursor-grok-4.6-high", models)

    def test_carried_stats_survives_a_record_without_stats(self):
        self.assertEqual(cursor.carried_stats({}, date(2026, 9, 10)), ({}, {}, 0, [], {}))

    def test_record_local_date_reads_utc_as_local(self):
        tz = datetime.now().astimezone().utcoffset()
        stamp = (datetime(2026, 9, 10, 12, 0, tzinfo=timezone.utc) - tz).isoformat()
        self.assertEqual(cursor.record_local_date({"updatedAt": stamp}), "2026-09-10")
        self.assertEqual(cursor.record_local_date({}), "")
        self.assertEqual(cursor.record_age_seconds({}), float("inf"))

    def test_merge_day_replaces_todays_row_in_place(self):
        history = self._record("")["history"]
        merged = cursor.merge_day(history, "2026-09-10", 900, {"m": 900})
        self.assertEqual([row["date"] for row in merged], ["2026-09-09", "2026-09-10"])
        self.assertEqual(merged[-1]["messageCount"], 900)
        self.assertEqual(cursor.merge_day(history, "2026-09-10", 0, {})[-1]["date"], "2026-09-09")

    def test_fetch_day_tokens_rejects_a_window_that_returns_the_cycle(self):
        cycle = {"aggregations": [{"modelIntent": "m", "inputTokens": 1000}]}
        original = cursor.fetch_aggregated
        cursor.fetch_aggregated = lambda token, start=None, end=None: cycle
        try:
            self.assertEqual(cursor.fetch_day_tokens("t", date(2026, 9, 10), 1000), ({}, 0))
            self.assertEqual(cursor.fetch_day_tokens("t", date(2026, 9, 10), 0), ({"m": 1000}, 1000))
        finally:
            cursor.fetch_aggregated = original

    # Exact GetCurrentPeriodUsage shape from this Ultra account on 2026-09-12.
    # Cursor Settings shows Cursor Models 1% and Other Models 0%, not the
    # raw autoPercentUsed (60%) or includedSpend/limit (4.5%) fields, and it
    # does not call the $400 included allowance "prepaid credits".
    ULTRA_PERIOD = {
        "billingCycleEnd": "1791744316000",
        "planUsage": {
            "totalSpend": 1802,
            "includedSpend": 1802,
            "remaining": 38198,
            "limit": 40000,
            "autoPercentUsed": 0.6006666666666667,
            "apiPercentUsed": 0,
            "totalPercentUsed": 0.5812903225806452,
        },
        "displayMessage": "You've used 5% of your included usage",
        "autoModelSelectedDisplayMessage": "You've used 1% of your included total usage",
        "namedModelSelectedDisplayMessage": "You've used 0% of your included API usage",
    }

    def test_limits_match_cursor_settings_not_raw_percent_fields(self):
        limits = cursor.limits_from_period(self.ULTRA_PERIOD, "2026-10-11T18:45:16+00:00")
        self.assertEqual(
            [(row["label"], round(row["percent"], 4)) for row in limits],
            [("Cursor Models", 0.01), ("Other Models", 0.0)],
        )
        self.assertNotIn("Included spend", [row["label"] for row in limits])
        self.assertNotIn("Auto models", [row["label"] for row in limits])
        self.assertNotIn("Total usage", [row["label"] for row in limits])

    def test_subscription_allowance_is_not_prepaid_credit(self):
        self.assertIsNone(cursor.balance_from_period(self.ULTRA_PERIOD, {}))

    def test_percent_from_display_message(self):
        self.assertEqual(cursor.percent_from_message("You've used 1% of your included total usage"), 0.01)
        self.assertEqual(cursor.percent_from_message("You've used 0% of your included API usage"), 0.0)
        self.assertIsNone(cursor.percent_from_message(""))


if __name__ == "__main__":
    unittest.main()
