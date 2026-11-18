#!/bin/bash

# The Antigravity collector reads agy's times with a parser of its own (agy
# writes Go's zero time for an uninitialized summary), so its boundaries are
# held here in fixed-offset zones: what is undated (a day outside 2000-2100
# included, as the shared reader has it), which local day a time lands on,
# and that undated activity still counts toward the lifetime totals without
# inventing a date.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

import subprocess
import types
from unittest.mock import patch

collector = load_collector("agy")
NOW = datetime(2026, 10, 2, 12, tzinfo=timezone.utc)
ZONES = ("UTC0", "EST5", "JST-9")  # Fixed offsets; no host zoneinfo or DST rules.
INVALID = (None, "", "not a date", 0, -1, "0", -1.5, "2026-02-30T12:00:00Z", [], {}, True,
           "0001-01-01 00:00:00+00:00", "0001-01-01T00:00:00Z",
           "0001-01-01T00:00:00", "0001-01-01T01:00:00+01:00",
           10**30, -(10**30), 10**400, "9" * 400, float("inf"), float("nan"))


@contextlib.contextmanager
def local_zone(zone):
  old = os.environ.get("TZ")
  try:
    os.environ["TZ"] = zone
    time.tzset()
    yield
  finally:
    if old is None:
      os.environ.pop("TZ", None)
    else:
      os.environ["TZ"] = old
    time.tzset()


class FrozenDatetime(datetime):
  @classmethod
  def now(cls, tz=None):
    return NOW.astimezone(tz) if tz else NOW.astimezone().replace(tzinfo=None)


def write_fixture(root, invalid):
  history = [dict(timestamp="2026-10-02T02:00:00Z", conversation_id="valid")]
  history += [dict(timestamp=value, conversation_id="bad-history") for value in invalid]
  history += [{}, dict(timestamp="1969-07-20T12:00:00Z", conversation_id="old"),
              dict(timestamp="2026-10-02T12:00:00Z", conversation_id="valid")]
  root.mkdir(parents=True, exist_ok=True)
  (root / "history.jsonl").write_text("\n".join(map(json.dumps, history)))
  with contextlib.closing(sqlite3.connect(root / "conversation_summaries.db")) as db, db:
    db.execute("CREATE TABLE conversation_summaries (conversation_id TEXT, last_modified_time TEXT)")
    db.executemany("INSERT INTO conversation_summaries VALUES (?, ?)", [
      ("valid", "2026-10-02T12:00:00Z"), ("undated", "0001-01-01 00:00:00+00:00"),
      ("undated", None), ("undated", "not a date"),
      ("summary-only", "2026-10-02T12:00:00Z")])
  transcript = root / "brain/valid/.system_generated/logs/transcript.jsonl"
  transcript.parent.mkdir(parents=True)
  steps = [dict(created_at="2026-10-02T12:00:00Z", model="dated", usage=dict(input_tokens=10, output_tokens=5))]
  steps += [dict(created_at=value, model="undated", usage=dict(input_tokens=2, output_tokens=1)) for value in invalid]
  steps += [dict(model="undated", usage=dict(input_tokens=2, output_tokens=1)),
            dict(created_at="2026-10-02T02:00:00Z", model="dated", usage=dict(input_tokens=7, output_tokens=3))]
  transcript.write_text("\n".join(map(json.dumps, steps)))


def days(values):
  return [collector.local_day(value) for value in values]


sandbox()

# -------------------------------------------------------------- the parser

for zone in ZONES:
  with local_zone(zone):
    expect(f"zero and invalid times are undated ({zone})", days(INVALID), [""] * len(INVALID))
    check(f"Go's zero time parses as no time ({zone})", collector.parse_time("0001-01-01 00:00:00+00:00") is None)

for zone, early_day in zip(ZONES, ("2026-10-02", "2026-10-01", "2026-10-02")):
  with local_zone(zone):
    expect(f"valid times keep every format agy writes and land on the local day ({zone})",
           days(("2026-10-02T02:00:00Z", "2026-10-02 02:00:00", "2026-10-02T04:00:00+02:00", 1790906400, 1790906400000, "1790906400000",
                 "2026-10-02T20:00:00Z")),
           [early_day] * 6 + ["2026-10-03" if zone == "JST-9" else "2026-10-02"])

# A day before 2000 or after 2100 is a damaged stamp (a stray 1 reads as
# 1970), and so is every time at the edges of what a date can hold.
OUT_OF_RANGE = ("1969-07-20T12:00:00Z", 1, "1999-12-31T12:00:00Z", "2101-01-01T12:00:00Z",
                "0001-01-01T00:00:01Z", "0001-01-01T12:00:00Z", "9999-12-31T23:59:59Z", "9999-12-31T12:00:00Z",
                "0001-01-01T00:00:01+14:00", "9999-12-31T23:59:59-12:00")
for zone in ZONES:
  with local_zone(zone):
    expect(f"a day outside 2000-2100 is undated ({zone})", days(OUT_OF_RANGE), [""] * len(OUT_OF_RANGE))
    expect(f"the years 2000 and 2100 still date ({zone})", days(("2000-06-01T12:00:00Z", "2100-06-01T12:00:00Z")), ["2000-06-01", "2100-06-01"])

# Errors that aren't a bad time propagate rather than reading as undated.
for name, patched in (
  ("parser", {"datetime": types.SimpleNamespace(fromisoformat=lambda value: (_ for _ in ()).throw(RuntimeError("unexpected")))}),
  ("conversion", {"parse_time": lambda value: types.SimpleNamespace(astimezone=lambda: (_ for _ in ()).throw(RuntimeError("unexpected")))}),
):
  with patch.dict(collector.__dict__, patched):
    try:
      collector.local_day("2026-10-02T12:00:00Z")
      raised = False
    except RuntimeError:
      raised = True
  check(f"an unrelated {name} failure propagates", raised)

# ---------------------------------------------------------------- the scan

for zone in ZONES:
  # These offset timestamps overflow while normalizing to UTC in all zones.
  invalid = INVALID + ("0001-01-01T00:00:01+14:00", "9999-12-31T23:59:59-12:00")
  if zone == "EST5":
    invalid += ("0001-01-01T00:00:01Z",)
  elif zone == "JST-9":
    invalid += ("9999-12-31T23:59:59Z",)
  root = home() / f"mixed-{zone}"
  write_fixture(root, invalid)
  with local_zone(zone):
    # Today is the shared module's to say, as well as the collector's.
    with patch.dict(collector.__dict__, datetime=FrozenDatetime), patch.object(sys.modules["collectors"], "datetime", FrozenDatetime):
      stats = collector.local_stats(root)
  today = 15 if zone == "EST5" else 25
  dates = ["2026-10-01", "2026-10-02"] if zone == "EST5" else ["2026-10-02"]
  recent = {row["date"]: row["messageCount"] for row in stats["recentDays"]}
  # Summary identities remain countable without a date; bad history isn't,
  # nor history from 1969. Undated usage keeps its lifetime totals, as a
  # missing time does.
  expect(f"mixed activity survives without inventing dates ({zone})", {
    "hasLocalStats": stats["hasLocalStats"], "totalPrompts": stats["totalPrompts"], "todayPrompts": stats["todayPrompts"],
    "totalSessions": stats["totalSessions"], "todaySessions": stats["todaySessions"], "activeDates": stats["activeDates"],
    "activeDays": stats["activeDays"], "todayTotalTokens": stats["todayTotalTokens"], "todayTokensByModel": stats["todayTokensByModel"],
    "today": recent["2026-10-02"], "recent": sum(recent.values()),
    "dated": [stats["modelUsage"]["dated"]["inputTokens"], stats["modelUsage"]["dated"]["outputTokens"]],
    "undated": [stats["modelUsage"]["undated"]["inputTokens"], stats["modelUsage"]["undated"]["outputTokens"]],
  }, {
    "hasLocalStats": True, "totalPrompts": 2, "todayPrompts": 1 if zone == "EST5" else 2,
    "totalSessions": 3, "todaySessions": 2, "activeDates": dates,
    "activeDays": len(dates), "todayTotalTokens": today, "todayTokensByModel": {"dated": today},
    "today": today, "recent": 25,
    "dated": [17, 8],
    "undated": [2 * (len(invalid) + 1), len(invalid) + 1],
  })

# --------------------------------------------------------------- the quota

# A usable quota remains useful without a trustworthy reset countdown.
RESETS = [({}, "")] + [({"resetTime": value}, "") for value in INVALID] + [
  ({"resetTime": "2026-10-02T11:00:00Z"}, "2026-10-02T11:00:00+00:00"),
  ({"resetTime": "2026-10-02T15:00:00+02:00"}, "2026-10-02T15:00:00+02:00"),
  ({"resetTime": "2026-10-02 13:00:00"}, "2026-10-02T13:00:00+00:00"),
  ({"resetTime": (NOW.timestamp() + 3600) * 1000}, "2026-10-02T13:00:00+00:00"),
]
for zone in ZONES:
  with local_zone(zone):
    seen = []
    for reset, _ in RESETS:
      bucket = dict(reset, window="5h", remainingFraction=0.75)
      limits = collector.extract_limits({"groups": [{"displayName": "Gemini", "buckets": [bucket]}]})
      seen.append((collector.reset_of(bucket), [(entry["resetsAt"], entry["percent"]) for entry in limits]))
    expect(f"a quota window keeps an unknown or valid reset, and its meter, whatever the reset says ({zone})",
           seen, [(expected, [(expected, 0.25)]) for _, expected in RESETS])

# ------------------------------------------------------------ the command

# The collector run as a command in each zone: local history alone puts
# Antigravity in use here, waiting for a sign-in, and a --limits-only run
# reuses that scan, a step written since included, with nothing on stderr
# either time.
stubs = home() / "bin"
stubs.mkdir()
(stubs / "secret-tool").write_text("#!/bin/bash\nexit 1\n")
(stubs / "secret-tool").chmod(0o755)
for zone in ZONES:
  root = home() / f"cli-{zone}"
  write_fixture(root, ("0001-01-01 00:00:00+00:00", None, "not a date"))
  env = dict(os.environ, AGY_DIR=str(root), XDG_CACHE_HOME=str(root / "cache"), PATH=f"{stubs}{os.pathsep}{os.defpath}", TZ=zone)
  for flag in ("--force", "--limits-only"):
    if flag == "--limits-only":
      with (root / "brain/valid/.system_generated/logs/transcript.jsonl").open("a") as transcript:
        transcript.write("\n" + json.dumps(dict(created_at="2026-10-02T12:00:00Z", model="dated", usage=dict(input_tokens=100, output_tokens=1))))
    result = subprocess.run([str(ROOT / "bin" / "omarchy-agent-usage-agy"), flag], env=env, capture_output=True, text=True, timeout=30)
    record = json.loads(result.stdout or "{}")
    expect(f"Antigravity collector runs cleanly as a command ({zone}, {flag})",
           [result.returncode, result.stderr, record.get("ready"), record.get("usageStatusText"), record.get("limits"),
            record.get("totalPrompts"), record.get("totalSessions"), (record.get("modelUsage") or {}).get("dated", {}).get("inputTokens")],
           [0, "", True, "Waiting for auth", [], 2, 3, 17], record)
PY
