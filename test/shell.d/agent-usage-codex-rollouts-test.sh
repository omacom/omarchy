#!/bin/bash

# The Codex rollout records every collector billing a custom provider reads
# (codex_rollouts): one cache per Codex home that they all share, and a
# rollout that only grew read on from where the last read stopped, with the
# same totals a whole read gives. The lines are shaped as Codex 0.163 wrote
# them in a real run on a Z.ai model_providers entry.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
import json
import os
import threading
import time
from pathlib import Path

from agent_usage_fixtures import *
import collectors

THREAD = "01a1644c-0d61-7072-be1b-fe5b114d8a73"
TURN = "01a1644c-0d83-7963-a2ff-038fc748bbae"
codex = home() / ".codex"
sessions = codex / "sessions" / "2026" / "10" / "22"
sessions.mkdir(parents=True)
(codex / "config.toml").write_text(
  'model = "glm-4.6"\n'
  '[model_providers.zai]\nname = "zai"\nbase_url = "https://api.z.ai/api/coding/paas/v4"\n'
  '[model_providers.mm]\nname = "mm"\nbase_url = "https://api.minimax.io/v1"\n'
)


def stamp(n):
  return f"2026-10-22T15:47:{n:02d}.229Z"


def meta(provider):
  return {"timestamp": stamp(0), "type": "session_meta", "payload": {
    "session_id": THREAD, "id": THREAD, "timestamp": stamp(0), "cwd": "/home/u/proj", "originator": "codex_exec",
    "cli_version": "0.163.0", "source": "exec", "thread_source": "user", "model_provider": provider,
    "base_instructions": "You are Codex.", "history_mode": "paginated"}}


def turn_context(n, model):
  return {"timestamp": stamp(n), "type": "turn_context", "payload": {"turn_id": TURN, "root_turn_id": TURN, "cwd": "/home/u/proj",
    "approval_policy": "never", "sandbox_policy": {"type": "danger-full-access"}, "model": model,
    "collaboration_mode": {"mode": "default", "settings": {"model": model}}, "summary": "none"}}


def prompt(n, text):
  return {"timestamp": stamp(n), "type": "event_msg", "payload": {"type": "item_completed", "thread_id": THREAD, "turn_id": TURN,
    "item": {"type": "UserMessage", "id": f"msg{n}", "content": [{"type": "text", "text": text, "text_elements": []}]}}}


def usage(input_tokens, cached, written, output):
  return {"input_tokens": input_tokens, "cached_input_tokens": cached, "cache_write_input_tokens": written,
    "output_tokens": output, "reasoning_output_tokens": 0, "total_tokens": input_tokens + output}


def response(n, rid, spent, thread):
  return {"timestamp": stamp(n), "type": "token_usage_record", "payload": {"thread_id": THREAD, "turn_id": TURN, "session_id": THREAD,
    "root_turn_id": TURN, "response_id": rid, "usage": usage(*spent), "turn_token_usage": usage(*thread), "thread_token_usage": usage(*thread)}}


def token_count(n, last, total):
  return {"timestamp": stamp(n), "type": "event_msg", "payload": {"type": "token_count",
    "info": {"total_token_usage": usage(*total), "last_token_usage": usage(*last), "model_context_window": 258400}}}


def noise(n):
  return {"timestamp": stamp(n), "type": "response_item", "payload": {"type": "message", "role": "assistant",
    "content": [{"type": "output_text", "text": "x" * 4000}]}}


def lines(*entries):
  return "".join(json.dumps(entry) + "\n" for entry in entries)


FIRST = (10234, 71, 31, 51)
SECOND = (11234, 72, 32, 52)
THIRD = (12234, 73, 33, 53)


def total(*spent):
  return tuple(map(sum, zip(*spent)))


# A session's first turn, then a prompt typed while nothing has answered it.
HEAD = lines(
  meta("zai"), turn_context(1, "glm-4.6"), noise(2), prompt(3, "zcompone"),
  response(4, "resp_0001", FIRST, FIRST), token_count(5, FIRST, FIRST), noise(6),
  prompt(7, "and again"),
)
# Codex answers it on another model, writes the earlier response's record a
# second time, a token_count repeating it, and one more response.
TAIL = lines(
  turn_context(8, "glm-4.6-air"), response(9, "resp_0002", SECOND, total(FIRST, SECOND)),
  response(10, "resp_0002", SECOND, total(FIRST, SECOND)), token_count(11, SECOND, total(FIRST, SECOND)),
  noise(12), response(13, "resp_0003", THIRD, total(FIRST, SECOND, THIRD)),
)

zai = sessions / f"rollout-2026-10-22T11-47-48-{THREAD}.jsonl"
mm = sessions / "rollout-2026-10-22T11-50-48-01a1644e-cbd2-72d3-8d17-8c9af79b8b7d.jsonl"
zai.write_text(HEAD)
mm.write_text(lines(meta("mm"), turn_context(1, "MiniMax-M2"), prompt(2, "hi"), response(3, "resp_m1", FIRST, FIRST)))


def tokens(spent):
  input_tokens, cached, written, output = spent
  return [input_tokens - cached - written, output, cached, written]


def days(record):
  return {model: totals for models in record["days"].values() for model, totals in models.items()}


def read_counting(scan):
  """What `scan` returns, and how many rollout lines it parsed."""
  real = json.loads
  parsed = []

  def counting(text, *args, **kwargs):
    if isinstance(text, str) and '"payload"' in text:
      parsed.append(text)
    return real(text, *args, **kwargs)

  json.loads = counting
  try:
    return scan(), len(parsed)
  finally:
    json.loads = real


def grow(path, text):
  with path.open("a") as handle:
    handle.write(text)


records, complete = collectors.codex_rollouts(collectors.codex_rollout_cache("zai"))
expect("the waiting prompt counts on the model last in effect until something answers it",
  days(records[str(zai)]), {"glm-4.6": [*tokens(FIRST), 2]})

# --------------------------------------------------------------- resuming

grow(zai, TAIL)
(records, complete), parsed = read_counting(lambda: collectors.codex_rollouts(collectors.codex_rollout_cache("zai")))
whole = collectors.read_codex_rollout(zai, zai.stat())
expect("a rollout that grew counts what a whole read counts, the prompt moving to the model that answered it",
  days(records[str(zai)]), days(whole))
expect("the response written twice and the token_count repeating it count once",
  days(records[str(zai)]), {"glm-4.6": [*tokens(FIRST), 1], "glm-4.6-air": [*map(sum, zip(tokens(SECOND), tokens(THIRD))), 1]})
grown = sum(any(marker in line for marker in collectors._CODEX_MARKERS) for line in TAIL.splitlines())
check("a rollout that grew is read on from where the last read stopped, not again from its start",
  parsed == grown, f"parsed {parsed} lines, the grown part has {grown} worth reading")

# ---------------------------------------------------- one shared cache

before = records[str(mm)]
grow(mm, lines(response(4, "resp_m2", SECOND, total(FIRST, SECOND))))
collectors.scan_codex_routed("zai")
reads = []
real_reader = collectors.read_codex_rollout


def reader(*args, **kwargs):
  reads.append(args[0])
  return real_reader(*args, **kwargs)


collectors.read_codex_rollout = reader
try:
  minimax_rows, _ = collectors.scan_codex_routed("minimax")
  collectors.scan_codex_routed("ollama")
  collectors.codex_rollouts(collectors.codex_rollout_cache("local"))
finally:
  collectors.read_codex_rollout = real_reader
check("once one collector has read a rollout that grew, the others billing Codex providers reuse its read",
  not reads, f"read again: {[str(path) for path in reads]}")
expect("the collector a provider's base_url names counts that rollout from the shared read",
  sorted((row.model, row.input_tokens, row.output_tokens) for row in minimax_rows),
  [("MiniMax-M2", *tokens(total(FIRST, SECOND))[:2])])
expect("every collector keeps its Codex records in one cache file per Codex home",
  sorted(path.name for path in cache_root().glob("*codex*.json")), [collectors.codex_rollout_cache().name])

# ------------------------------------------ what a resume can't trust

# A rollout replaced by a longer copy that differs in what was read, as a
# restore from a backup leaves it, is read whole again.
copy = zai.with_suffix(".new")
copy.write_text(zai.read_text().replace('"output_tokens": 51', '"output_tokens": 91', 1) + lines(noise(14)))
copy.replace(zai)
records, _ = collectors.codex_rollouts(collectors.codex_rollout_cache())
expect("a rollout replaced by a longer one is read whole again",
  days(records[str(zai)]), days(collectors.read_codex_rollout(zai, zai.stat())))
check("the rewritten count is the one counted", days(records[str(zai)])["glm-4.6"][1] == FIRST[3] + 40, days(records[str(zai)]))

# A last line still being written counts as a whole read counts it, and
# the read once it is whole counts it once.
partial = sessions / "rollout-2026-10-22T12-00-00-01a16450-0000-7000-8000-000000000000.jsonl"
partial.write_text(lines(meta("zai"), turn_context(1, "glm-4.6"), prompt(2, "p")) + json.dumps(response(3, "resp_p1", FIRST, FIRST)))
records, _ = collectors.codex_rollouts(collectors.codex_rollout_cache())
expect("a rollout ending in a line with no newline yet counts that line", days(records[str(partial)]), {"glm-4.6": [*tokens(FIRST), 1]})
grow(partial, "\n" + lines(response(4, "resp_p2", SECOND, total(FIRST, SECOND))))
records, _ = collectors.codex_rollouts(collectors.codex_rollout_cache())
expect("once that line is whole and more follow, it still counts once",
  days(records[str(partial)]), {"glm-4.6": [*map(sum, zip(tokens(FIRST), tokens(SECOND))), 1]})

# The same totals whichever way the collectors got there.
resumed = sorted(collectors.scan_codex_routed("zai")[0])
expect("Z.ai's Codex rows are the same read on as read whole", resumed, sorted(collectors.scan_codex_routed("zai", reuse=False)[0]))

# A guardian thread counts under the session that started it, as Codex 0.160
# writes one: its session_id and parent_thread_id name the thread it checks.
GUARDIAN = "01a1284c-6fa4-7c13-8d29-e2d8b566ae36"
guardian = sessions / f"rollout-2026-10-22T12-05-00-{GUARDIAN}.jsonl"
guardian_meta = meta("zai")
guardian_meta["payload"].update({"id": GUARDIAN, "parent_thread_id": THREAD, "originator": "codex-tui",
  "source": {"subagent": {"other": "guardian"}}, "thread_source": "guardian_review"})
guardian.write_text(lines(guardian_meta, turn_context(1, "codex-auto-review"), response(2, "resp_g1", FIRST, FIRST)))
rows = collectors.scan_codex_routed("zai")[0]
expect("a guardian thread's rows count under the session it checks",
  sorted({row.session for row in rows if row.model == "codex-auto-review"}), [THREAD])
# Every Z.ai rollout here belongs to that one thread, so it is one session.
stats = collectors.Stats()
for row in rows:
  stats.add_row(row, row.model)
expect("so Z.ai counts one session, not one per rollout file", stats.snapshot()["totalSessions"], 1)

# A built-in rollout is left unread, and marked so, until openai_base_url
# sends the built-in provider elsewhere; then the cached stub is read whole,
# session and all, and the full record stays once nothing needs it.
native = sessions / "rollout-2026-10-22T12-10-00-01a16451-0000-7000-8000-000000000000.jsonl"
native.write_text(lines(meta("openai"), turn_context(1, "hf:zai-org/GLM-4.6"), prompt(2, "p"), response(3, "resp_n1", FIRST, FIRST)))
records, _ = collectors.codex_rollouts(collectors.codex_rollout_cache())
check("a built-in rollout is skipped while nothing sends it elsewhere", records[str(native)].get("skipped") and not records[str(native)]["days"], records[str(native)])
records, _ = collectors.codex_rollouts(collectors.codex_rollout_cache(), native=True)
expect("once something does, the skipped built-in rollout is read whole", days(records[str(native)]), {"hf:zai-org/GLM-4.6": [*tokens(FIRST), 1]})
expect("under the thread that started it", records[str(native)]["session"], THREAD)
records, _ = collectors.codex_rollouts(collectors.codex_rollout_cache())
expect("a built-in rollout read whole stays read", days(records[str(native)]), {"hf:zai-org/GLM-4.6": [*tokens(FIRST), 1]})

# ------------------------------------------------- one forced refresh

# A refresh forces every collector at once. The ones that wait for the lock
# take what the first forced read wrote meanwhile, built-in rollouts read
# whole included, so each rollout is parsed once per refresh, not once per
# collector, while a forced read after that one parses them all again.
files = sorted(str(path) for path in sessions.glob("*.jsonl"))
lock = collectors.codex_rollout_cache().with_name(collectors.codex_rollout_cache().name + ".lock")
reads = []
forced = []
collectors.read_codex_rollout = reader
try:
  # Every one of them is waiting for the lock before any gets it.
  with collectors.exclusive_lock(lock):
    threads = [threading.Thread(target=lambda: forced.append(collectors.codex_rollouts(collectors.codex_rollout_cache(), reuse=False, native=True))) for _ in range(3)]
    for thread in threads:
      thread.start()
    time.sleep(0.5)
  for thread in threads:
    thread.join()
  once = sorted(str(path) for path in reads)
  reads.clear()
  collectors.codex_rollouts(collectors.codex_rollout_cache(), reuse=False, native=True)
  again = sorted(str(path) for path in reads)
finally:
  collectors.read_codex_rollout = real_reader
expect("collectors forced together parse each rollout once between them", once, files)
check("and each gets every rollout, read whole", len(forced) == 3 and all(sorted(records) == files and not any(r.get("skipped") for r in records.values()) for records, _ in forced), forced)
expect("a forced read after theirs parses every rollout again", again, files)

# The collectors of one refresh start together but get to the rollouts when
# each does, so one forced read can be done before the next begins. Told when
# the refresh began, as omarchy-agent-usage-update tells them, the later ones
# take what the earlier one read: only the built-in rollout it skipped is
# read again, for the one that needs it. A refresh stamp from long ago forces
# as --force alone does.
cache = collectors.codex_rollout_cache()


def forced_reads(native=False):
  reads.clear()
  collectors.codex_rollouts(cache, reuse=False, native=native)
  return sorted(str(path) for path in reads)


collectors.read_codex_rollout = reader
try:
  os.environ["OMARCHY_AGENT_USAGE_REFRESH_AT"] = str(time.time())
  first, second, built_in = forced_reads(), forced_reads(), forced_reads(native=True)
  os.environ["OMARCHY_AGENT_USAGE_REFRESH_AT"] = str(time.time() - collectors.CODEX_REFRESH_SECONDS - 1)
  stale = forced_reads()
finally:
  collectors.read_codex_rollout = real_reader
  del os.environ["OMARCHY_AGENT_USAGE_REFRESH_AT"]
expect("one refresh's forced reads, one after another, parse each rollout once between them", [first, second, built_in], [files, [], [str(native)]])
expect("a refresh stamp from long ago parses every rollout again", stale, files)
PY
