#!/usr/bin/env python3
"""Decision tests for the SMC optimized-charging policy. No hardware writes."""

import tempfile
import unittest
from datetime import datetime, timedelta
from pathlib import Path

import charge_policy as policy


def local_unix(year, month, day, hour, minute) -> int:
    local = datetime(year, month, day, hour, minute).astimezone()
    return int(local.timestamp())


# Wednesday 2026-10-21. weekday() == 2.
WED_22 = local_unix(2026, 10, 21, 22, 0)
WED_0720 = local_unix(2026, 10, 21, 7, 20)
WED_0810 = local_unix(2026, 10, 21, 8, 10)
WED_0910 = local_unix(2026, 10, 21, 9, 10)
MON_0800 = local_unix(2026, 10, 19, 8, 0)


def departure_at(when: int, plugged_for: int = policy.MIN_DEPARTURE_SESSION_S) -> dict:
    local = datetime.fromtimestamp(when).astimezone()
    return {
        "t": when,
        "minute": local.hour * 60 + local.minute,
        "weekday": local.weekday(),
        "duration_s": plugged_for,
    }


def mornings(start_day: datetime, days: int, hour: int = 8, minute: int = 0) -> list[dict]:
    found = []
    for offset in range(days):
        day = start_day + timedelta(days=offset)
        when = local_unix(day.year, day.month, day.day, hour, minute)
        found.append(departure_at(when))
    return found


class CircularTimeTests(unittest.TestCase):
    def test_median_clusters_in_the_morning(self):
        self.assertEqual(policy.circular_median([470, 480, 490]), 480)

    def test_median_wraps_midnight(self):
        center = policy.circular_median([23 * 60 + 50, 10, 5])
        self.assertIsNotNone(center)
        self.assertLess(policy.spread_minutes([23 * 60 + 50, 10, 5], center), 20)

    def test_scattered_day_is_not_a_routine(self):
        minutes = [8 * 60, 8 * 60 + 10, 18 * 60, 19 * 60]
        center = policy.circular_median(minutes)
        self.assertGreater(policy.spread_minutes(minutes, center), policy.MAX_SPREAD_MIN)


class DecisionTests(unittest.TestCase):
    def test_unknown_routine_on_battery_charges_to_full(self):
        state, decision = policy.reduce(None, policy.Sample(False, 73, "Discharging"), WED_22)
        self.assertEqual(decision, policy.Decision(100, 100, "charge-to-full-learning"))
        self.assertEqual(state["last_full_at"], WED_22)

    def test_short_unknown_plug_in_charges_to_full(self):
        state, _ = policy.reduce(None, policy.Sample(True, 40, "Charging"), WED_22)
        _, decision = policy.reduce(
            state,
            policy.Sample(True, 55, "Charging"),
            WED_22 + 10 * 60,
        )
        self.assertEqual(decision.reason, "charge-to-full-learning")
        self.assertEqual((decision.start, decision.end), (100, 100))

    def test_long_unknown_plug_in_holds(self):
        state, _ = policy.reduce(None, policy.Sample(True, 40, "Charging"), WED_22)
        state, decision = policy.reduce(
            state,
            policy.Sample(True, 100, "Full"),
            WED_22 + policy.EXTENDED_SESSION_S,
        )
        self.assertEqual(decision.reason, "charging-on-hold-rarely-on-battery")
        self.assertEqual(decision.behaviour, "inhibit-charge")
        self.assertEqual((decision.start, decision.end), (100, 100))
        self.assertTrue(state["inhibit_hold"])

    def test_far_departure_holds_immediately(self):
        state = policy.fresh_state(WED_22)
        state["departures"] = mornings(datetime(2026, 10, 14), 7)
        _, decision = policy.reduce(state, policy.Sample(True, 60, "Charging"), WED_22)
        self.assertEqual(decision.reason, "charging-on-hold")
        self.assertEqual(decision.behaviour, "auto")
        self.assertEqual(decision.end, 100)
        self.assertIsNotNone(decision.departure)

    def test_far_departure_on_battery_does_not_arm_force_discharge(self):
        state = policy.fresh_state(WED_22)
        state["departures"] = mornings(datetime(2026, 10, 14), 7)
        _, decision = policy.reduce(state, policy.Sample(False, 73, "Discharging"), WED_22)
        self.assertEqual(decision.behaviour, "auto")
        self.assertEqual((decision.start, decision.end), (100, 100))

    def test_inside_topup_window_charges_to_full(self):
        state = policy.fresh_state(WED_0720)
        state["departures"] = mornings(datetime(2026, 10, 14), 7)
        _, decision = policy.reduce(state, policy.Sample(True, 80, "Not charging"), WED_0720)
        self.assertEqual(decision.reason, "charge-to-full")
        self.assertEqual(decision.end, 100)

    def test_just_after_departure_still_tops_up(self):
        state = policy.fresh_state(WED_0810)
        state["departures"] = mornings(datetime(2026, 10, 14), 7)
        _, decision = policy.reduce(state, policy.Sample(True, 82, "Charging"), WED_0810)
        self.assertEqual(decision.reason, "charge-to-full")

    def test_well_after_departure_waits_for_the_next_day(self):
        state = policy.fresh_state(WED_0910)
        state["departures"] = mornings(datetime(2026, 10, 14), 7)
        _, decision = policy.reduce(state, policy.Sample(True, 90, "Not charging"), WED_0910)
        self.assertEqual(decision.reason, "charging-on-hold")
        departure = datetime.fromtimestamp(decision.departure).astimezone()
        self.assertEqual(departure.hour, 8)
        self.assertGreater(departure.date().day, 21)

    def test_loose_history_is_not_a_departure_prediction(self):
        state = policy.fresh_state(WED_22)
        when = [
            local_unix(2026, 10, 12, 8, 0),
            local_unix(2026, 10, 13, 8, 10),
            local_unix(2026, 10, 14, 18, 0),
            local_unix(2026, 10, 15, 19, 0),
        ]
        state["departures"] = [departure_at(item) for item in when]
        _, decision = policy.reduce(state, policy.Sample(True, 50, "Charging"), WED_22)
        self.assertEqual(decision.reason, "charge-to-full-learning")
        self.assertIsNone(decision.departure)

    def test_same_weekday_routine_beats_other_days(self):
        state = policy.fresh_state(WED_0720)
        # Two Wednesdays at 08:00, and several afternoon unplugs on other days.
        state["departures"] = [
            departure_at(local_unix(2026, 10, 7, 8, 0)),
            departure_at(local_unix(2026, 10, 14, 8, 5)),
            departure_at(local_unix(2026, 10, 15, 18, 0)),
            departure_at(local_unix(2026, 10, 16, 18, 30)),
            departure_at(local_unix(2026, 10, 19, 17, 45)),
            departure_at(local_unix(2026, 10, 20, 18, 15)),
        ]
        _, decision = policy.reduce(state, policy.Sample(True, 70, "Charging"), WED_0720)
        self.assertEqual(decision.reason, "charge-to-full")

    def test_charge_to_full_now_overrides_a_hold(self):
        state = policy.fresh_state(WED_22)
        state["departures"] = mornings(datetime(2026, 10, 14), 7)
        state["charge_to_full_now"] = True
        state["ac_online"] = True
        state["plugged_since"] = WED_22 - 3600
        _, decision = policy.reduce(state, policy.Sample(True, 60, "Charging"), WED_22)
        self.assertEqual(decision.reason, "charge-to-full-now")
        self.assertEqual(decision.end, 100)

    def test_unplug_clears_the_override_and_records_a_long_session(self):
        start = WED_22 - policy.MIN_DEPARTURE_SESSION_S - 180
        state, _ = policy.reduce(None, policy.Sample(True, 50, "Charging"), start)
        state["charge_to_full_now"] = True
        last_online = WED_22 - 120
        state, _ = policy.reduce(state, policy.Sample(True, 80, "Not charging"), last_online)
        # Gap from the last on-power sample is past the debounce, so this is a real unplug.
        state, decision = policy.reduce(state, policy.Sample(False, 80, "Discharging"), WED_22)
        self.assertFalse(state["charge_to_full_now"])
        self.assertEqual(len(state["departures"]), 1)
        self.assertEqual(state["departures"][0]["t"], last_online)
        self.assertEqual(decision.reason, "charge-to-full-learning")

    def test_short_unplug_is_not_a_departure(self):
        start = WED_22 - 20 * 60
        state, _ = policy.reduce(None, policy.Sample(True, 50, "Charging"), start)
        state, _ = policy.reduce(state, policy.Sample(False, 55, "Discharging"), start + 30)
        state, _ = policy.reduce(state, policy.Sample(False, 54, "Discharging"), WED_22)
        self.assertEqual(state["departures"], [])

    def test_ac_blip_does_not_end_the_session(self):
        state, _ = policy.reduce(None, policy.Sample(True, 50, "Charging"), WED_22)
        state, _ = policy.reduce(state, policy.Sample(False, 50, "Discharging"), WED_22 + 30)
        self.assertIsNotNone(state["plugged_since"])
        self.assertTrue(state["ac_online"])
        state, _ = policy.reduce(state, policy.Sample(True, 51, "Charging"), WED_22 + 60)
        self.assertEqual(state["departures"], [])
        self.assertEqual(state["plugged_since"], WED_22)

    def test_confirmed_unplug_records_the_departure_time(self):
        start = WED_22 - 3 * 60 * 60
        state, _ = policy.reduce(None, policy.Sample(True, 40, "Charging"), start)
        state, _ = policy.reduce(state, policy.Sample(True, 80, "Not charging"), WED_22)
        state, _ = policy.reduce(state, policy.Sample(False, 80, "Discharging"), WED_22 + 30)
        self.assertTrue(state["ac_online"])
        self.assertEqual(state["departures"], [])
        state, _ = policy.reduce(state, policy.Sample(False, 79, "Discharging"), WED_22 + 60)
        self.assertEqual(len(state["departures"]), 1)
        self.assertEqual(state["departures"][0]["t"], WED_22 + 60)

    def test_suspend_gap_dates_the_departure_at_the_last_online_sample(self):
        start = local_unix(2026, 10, 21, 1, 0)
        last_online = local_unix(2026, 10, 21, 8, 0)
        resume = local_unix(2026, 10, 21, 18, 0)
        state, _ = policy.reduce(None, policy.Sample(True, 40, "Charging"), start)
        state, _ = policy.reduce(state, policy.Sample(True, 80, "Not charging"), last_online)
        state, _ = policy.reduce(state, policy.Sample(False, 70, "Discharging"), resume)
        self.assertEqual(len(state["departures"]), 1)
        self.assertEqual(state["departures"][0]["t"], last_online)
        self.assertFalse(state["ac_online"])

    def test_calibration_after_a_fortnight_on_power(self):
        state = policy.fresh_state(WED_22)
        state["last_full_at"] = WED_22 - policy.CALIBRATION_S - 10
        state["departures"] = mornings(datetime(2026, 10, 14), 7)
        _, decision = policy.reduce(state, policy.Sample(True, 80, "Not charging"), WED_22)
        self.assertEqual(decision.reason, "charge-to-full-calibration")

    def test_calibration_does_not_run_on_battery_or_when_already_full(self):
        state = policy.fresh_state(WED_22)
        state["last_full_at"] = WED_22 - policy.CALIBRATION_S - 10
        _, on_battery = policy.reduce(state, policy.Sample(False, 80, "Discharging"), WED_22)
        self.assertNotEqual(on_battery.reason, "charge-to-full-calibration")
        _, already = policy.reduce(
            state,
            policy.Sample(True, 100, "Full"),
            WED_22,
        )
        self.assertNotEqual(already.reason, "charge-to-full-calibration")

    def test_seeing_full_resets_the_calibration_clock(self):
        state = policy.fresh_state(WED_22 - policy.CALIBRATION_S)
        state["last_full_at"] = WED_22 - policy.CALIBRATION_S
        state, _ = policy.reduce(state, policy.Sample(True, 100, "Full"), WED_22)
        self.assertEqual(state["last_full_at"], WED_22)

    def test_rarely_on_battery_holds_after_a_day_of_power(self):
        state = policy.fresh_state(WED_22)
        state["ac_seconds"] = policy.RARELY_MIN_OBSERVED_S
        state["battery_seconds"] = 60 * 60
        state["ac_online"] = True
        state["plugged_since"] = WED_22 - policy.RARELY_SESSION_S
        state["last_sample_at"] = WED_22 - 30
        _, decision = policy.reduce(state, policy.Sample(True, 70, "Charging"), WED_22)
        self.assertEqual(decision.reason, "charging-on-hold-rarely-on-battery")

    def test_rarely_ratio_waits_for_enough_observation(self):
        state = policy.fresh_state(WED_22)
        state["ac_seconds"] = 2 * 60 * 60
        state["battery_seconds"] = 0
        state["ac_online"] = True
        state["plugged_since"] = WED_22 - policy.RARELY_SESSION_S
        state["last_sample_at"] = WED_22 - 30
        _, decision = policy.reduce(state, policy.Sample(True, 70, "Charging"), WED_22)
        self.assertEqual(decision.reason, "charge-to-full-learning")

    def test_topup_hysteresis_does_not_fall_back_immediately(self):
        state = policy.fresh_state(WED_0720)
        state["departures"] = mornings(datetime(2026, 10, 14), 7)
        state["last_reason"] = "charge-to-full"
        # 50 min default window + 15 min hysteresis; 60 min out still stays on full.
        now = local_unix(2026, 10, 21, 7, 0)
        _, decision = policy.reduce(state, policy.Sample(True, 80, "Charging"), now)
        self.assertEqual(decision.reason, "charge-to-full")

    def test_topup_uses_time_to_full_only_from_the_hold_point(self):
        below = policy.Sample(True, 40, "Charging", time_to_full_s=3 * 60 * 60)
        above = policy.Sample(True, 90, "Charging", time_to_full_s=20 * 60)
        self.assertEqual(policy.topup_seconds(below), policy.TOPUP_DEFAULT_S)
        self.assertEqual(policy.topup_seconds(above), 20 * 60 + policy.TOPUP_SLACK_S)

    def test_reported_current_estimates_the_remaining_topup(self):
        sample = policy.Sample(
            True,
            90,
            "Charging",
            charge_full_uah=4_000_000,
            current_ua=2_000_000,
        )
        # 10% of 4 Ah at 2 A is 0.2 h = 720 s, plus slack.
        self.assertEqual(policy.topup_seconds(sample), 720 + policy.TOPUP_SLACK_S)


class RunningDriverHoldTests(unittest.TestCase):
    def _departures(self):
        return mornings(datetime(2026, 10, 14), 7)

    def test_above_80_inhibits_and_leaves_the_ceiling_at_100(self):
        state = policy.fresh_state(WED_22)
        state["departures"] = self._departures()
        state, decision = policy.reduce(state, policy.Sample(True, 95, "Charging"), WED_22)
        self.assertEqual(decision.reason, "charging-on-hold")
        self.assertEqual(decision.behaviour, "inhibit-charge")
        self.assertEqual((decision.start, decision.end), (100, 100))
        self.assertTrue(state["inhibit_hold"])

    def test_hysteresis_stays_paused_until_75(self):
        state = policy.fresh_state(WED_22)
        state["departures"] = self._departures()
        state["inhibit_hold"] = True
        _, paused = policy.reduce(state, policy.Sample(True, 78, "Not charging"), WED_22)
        self.assertEqual(paused.behaviour, "inhibit-charge")
        _, released = policy.reduce(state, policy.Sample(True, 75, "Discharging"), WED_22)
        self.assertEqual(released.behaviour, "auto")
        self.assertEqual(released.end, 100)

    def test_hold_now_pauses_a_full_pack_without_a_partial_ceiling(self):
        state = policy.fresh_state(WED_22)
        state["hold_now"] = True
        _, decision = policy.reduce(
            state,
            policy.Sample(True, 95, "Charging", behaviour="[auto] inhibit-charge"),
            WED_22,
        )
        self.assertEqual(decision.behaviour, "inhibit-charge")
        self.assertEqual(decision.end, 100)

    def test_charge_to_full_now_beats_hold_now(self):
        state = policy.fresh_state(WED_22)
        state["hold_now"] = True
        state["charge_to_full_now"] = True
        state["ac_online"] = True
        state["plugged_since"] = WED_22 - 3600
        _, decision = policy.reduce(state, policy.Sample(True, 95, "Not charging"), WED_22)
        self.assertEqual(decision.reason, "charge-to-full-now")
        self.assertEqual(decision.behaviour, "auto")


class SeparateCeilingTests(unittest.TestCase):
    def test_auto_discharge_driver_publishes_80_and_stays_on_auto(self):
        behaviour = "[auto] inhibit-charge auto-discharge"
        state = policy.fresh_state(WED_22)
        state["departures"] = mornings(datetime(2026, 10, 14), 7)
        _, decision = policy.reduce(
            state,
            policy.Sample(True, 95, "Charging", behaviour=behaviour),
            WED_22,
        )
        self.assertTrue(policy.ceiling_without_discharge(policy.Sample(True, behaviour=behaviour)))
        self.assertEqual(decision.behaviour, "auto")
        self.assertEqual((decision.start, decision.end), (75, 80))
        self.assertEqual(decision.reason, "charging-on-hold")

    def test_running_behaviour_string_is_not_a_safe_ceiling(self):
        sample = policy.Sample(True, 95, "Charging", behaviour="[auto] inhibit-charge")
        self.assertFalse(policy.ceiling_without_discharge(sample))
        active, modes = policy.parse_modes(sample.behaviour)
        self.assertEqual(active, "auto")
        self.assertEqual(modes, {"auto", "inhibit-charge"})


class WritePlanTests(unittest.TestCase):
    def test_lowering_writes_start_before_end(self):
        self.assertEqual(policy.write_plan(100, 100, 75, 80), ["start", "end"])

    def test_raising_writes_end_before_start(self):
        self.assertEqual(policy.write_plan(75, 80, 100, 100), ["end", "start"])

    def test_unchanged_end_writes_nothing(self):
        self.assertEqual(policy.write_plan(75, 80, 75, 80), [])
        self.assertEqual(policy.write_plan(100, 100, 100, 100), [])

    def test_unknown_current_still_keeps_start_at_or_below_end(self):
        self.assertEqual(policy.write_plan(None, None, 75, 80), ["start", "end"])

    def test_apply_round_trip_on_a_fake_sysfs(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "charge_control_end_threshold").write_text("100\n")
            (root / "charge_control_start_threshold").write_text("100\n")
            written = policy.apply_thresholds(75, 80, root)
            self.assertEqual(written, ["start", "end"])
            self.assertEqual((root / "charge_control_start_threshold").read_text(), "75\n")
            self.assertEqual((root / "charge_control_end_threshold").read_text(), "80\n")
            self.assertEqual(policy.apply_thresholds(75, 80, root), [])

    def test_inhibit_does_not_lower_the_end_threshold(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "charge_control_end_threshold").write_text("100\n")
            (root / "charge_control_start_threshold").write_text("100\n")
            (root / "charge_behaviour").write_text("[auto] inhibit-charge\n")
            decision = policy.Decision(100, 100, "charging-on-hold", behaviour="inhibit-charge")
            policy.apply_decision(decision, root)
            self.assertEqual((root / "charge_control_end_threshold").read_text(), "100\n")
            self.assertEqual((root / "charge_behaviour").read_text(), "inhibit-charge\n")

    def test_restore_returns_to_auto_and_100(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "charge_control_end_threshold").write_text("80\n")
            (root / "charge_control_start_threshold").write_text("75\n")
            (root / "charge_behaviour").write_text("[inhibit-charge] auto\n")
            policy.restore_charging(root)
            self.assertEqual((root / "charge_control_end_threshold").read_text(), "100\n")
            self.assertEqual((root / "charge_control_start_threshold").read_text(), "100\n")
            self.assertEqual((root / "charge_behaviour").read_text(), "auto\n")

    def test_refuses_a_mode_the_driver_does_not_offer(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "charge_behaviour").write_text("[auto]\n")
            self.assertFalse(policy.apply_behaviour("inhibit-charge", root))
            self.assertEqual((root / "charge_behaviour").read_text(), "[auto]\n")

    def test_once_dry_run_persists_state_without_a_battery(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "capacity").write_text("73\n")
            (root / "status").write_text("Discharging\n")
            (root / "online").write_text("0\n")
            state_path = root / "state.json"
            decision = policy.step(
                state_path,
                root,
                root / "online",
                None,
                WED_22,
                dry_run=True,
            )
            self.assertEqual(decision.end, 100)
            self.assertTrue(state_path.exists())


class MondayAnchorTests(unittest.TestCase):
    def test_anchor_used_by_helpers_is_a_monday(self):
        self.assertEqual(datetime.fromtimestamp(MON_0800).astimezone().weekday(), 0)


if __name__ == "__main__":
    unittest.main()
