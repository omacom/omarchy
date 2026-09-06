#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

python3 - <<'PY'
import json
import os
import subprocess
import unittest
from datetime import datetime, timedelta
from pathlib import Path


class SolarScheduleTest(unittest.TestCase):
  def evaluate(self, zone, at):
    result = subprocess.run(
      [str(Path(os.environ["ROOT"]) / "bin/omarchy-nightlight-schedule"),
       "evaluate", "--at", at.isoformat() if isinstance(at, datetime) else at],
      env={
        **os.environ,
        "OMARCHY_NIGHTLIGHT_STATE": "/dev/null",
        "OMARCHY_NIGHTLIGHT_TIMEZONE": zone,
        "OMARCHY_ZONEINFO_DIR": "/usr/share/zoneinfo",
      },
      check=True,
      capture_output=True,
      text=True,
    )
    schedule = json.loads(result.stdout)
    self.assertNotIn("error", schedule)
    return schedule

  def test_advertised_sunset_changes_night_state(self):
    zone = "America/Los_Angeles"
    schedule = self.evaluate(zone, "2026-03-20T12:00:00-07:00")
    self.assertEqual(schedule["nextEvent"], "sunset")
    sunset = datetime.fromisoformat(schedule["nextEventAt"])
    self.assertTrue(self.evaluate(zone, sunset + timedelta(seconds=1))["night"])

  def test_apia_includes_todays_sunset(self):
    schedule = self.evaluate("Pacific/Apia", "2026-08-30T17:00:00+13:00")
    self.assertEqual(schedule["nextEvent"], "sunset")
    self.assertTrue(schedule["nextEventAt"].startswith("2026-08-30T18:"))

  def assert_transition(self, zone, schedule):
    event = datetime.fromisoformat(schedule["nextEventAt"])
    was_night = schedule["nextEvent"] == "sunrise"
    for offset in (-1, -0.000001, 0, 0.999999, 1):
      with self.subTest(zone=zone, event=event, offset=offset):
        at = event + timedelta(seconds=offset)
        result = self.evaluate(zone, at)
        self.assertEqual(result["night"], was_night if offset < 0 else not was_night)
        self.assertGreater(datetime.fromisoformat(result["nextEventAt"]), at)
        if offset < 0:
          self.assertEqual(result["nextEventAt"], schedule["nextEventAt"])
          self.assertEqual(result["nextEvent"], schedule["nextEvent"])

  def test_boundaries_across_seasons_timezones_and_dst(self):
    cases = (
      ("America/Los_Angeles", "2026-03-20"),
      ("America/Los_Angeles", "2026-06-21"),
      ("America/Los_Angeles", "2026-09-22"),
      ("America/Los_Angeles", "2026-12-21"),
      ("America/Los_Angeles", "2026-03-08"),
      ("America/Los_Angeles", "2026-11-01"),
      ("Europe/London", "2026-03-29"),
      ("Europe/London", "2026-10-25"),
      ("Pacific/Apia", "2026-08-30"),
      ("Pacific/Kiritimati", "2026-08-30"),
      ("Pacific/Honolulu", "2026-08-30"),
      ("Pacific/Auckland", "2026-08-30"),
      ("Pacific/Chatham", "2026-08-30"),
      ("Asia/Tokyo", "2026-08-30"),
      ("Australia/Sydney", "2026-04-05"),
      ("Australia/Sydney", "2026-10-04"),
    )
    for zone, day in cases:
      with self.subTest(zone=zone, day=day):
        schedule = self.evaluate(zone, day + "T00:00:00")
        self.assertEqual(schedule["nextEvent"], "sunrise")
        self.assertTrue(schedule["nextEventAt"].startswith(day))
        self.assert_transition(zone, schedule)
        sunset = self.evaluate(zone, schedule["nextEventAt"])
        self.assertEqual(sunset["nextEvent"], "sunset")
        self.assertTrue(sunset["nextEventAt"].startswith(day))
        self.assert_transition(zone, sunset)

  def test_polar_day_and_night_find_the_next_real_crossing(self):
    zone = "Arctic/Longyearbyen"
    for at, night, next_event in (
      ("2026-06-21T12:00:00", False, "sunset"),
      ("2026-12-21T12:00:00", True, "sunrise"),
    ):
      with self.subTest(at=at):
        schedule = self.evaluate(zone, at)
        self.assertEqual(schedule["night"], night)
        self.assertEqual(schedule["nextEvent"], next_event)
        event = datetime.fromisoformat(schedule["nextEventAt"])
        self.assertGreater((event.replace(tzinfo=None) - datetime.fromisoformat(at)).days, 20)
        self.assert_transition(zone, schedule)


unittest.main()
PY
