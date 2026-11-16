#!/bin/bash

# Every collector reads the whole pi/omp history through scan_pi_sessions,
# each for its own providers, so what one scan parses is paid once per
# collector on every refresh. A file holding none of a collector's lines
# must cost it nothing beyond rg's search: its prompts, tool results and
# compactions are never parsed, and no file is read again for the model a
# summary ran on. A count, the same on every machine, rather than a time.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command rg

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

WORK="$WORK" python3 - <<'PY'
import json
import os
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.environ["OMARCHY_PATH"], "shell", "plugins", "agents"))
import collectors  # noqa: E402

work = Path(os.environ["WORK"])
home = work / "home"
home.mkdir()
os.environ["HOME"] = str(home)
for name in ("PI_CODING_AGENT_DIR", "PI_CODING_AGENT_SESSION_DIR"):
  os.environ.pop(name, None)


def check(description, condition, detail=""):
  if condition:
    print("ok - " + description)
    return
  print("not ok - " + description, file=sys.stderr)
  if detail:
    print(detail, file=sys.stderr)
  sys.exit(1)


stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
runtime = {"version": "18.12.6"}


def usage(tokens):
  return {"input": tokens, "output": 10, "cacheRead": 0, "cacheWrite": 0, "totalTokens": tokens + 10, "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0, "total": 0}}


def pi_session(provider, model, n, tokens):
  """A tool-loop session as pi 1.4.0 writes one, with a pasted image and a
  compaction, on one provider."""
  lines = [
    {"type": "session", "version": 3, "id": f"s{n}", "timestamp": stamp, "cwd": "/proj"},
    {"type": "model_change", "id": f"mc{n}", "parentId": None, "timestamp": stamp, "provider": provider, "modelId": model},
    {"type": "message", "id": f"u{n}", "timestamp": stamp, "message": {"role": "user", "content": [{"type": "text", "text": "read it"}, {"type": "image", "mimeType": "image/png", "data": "iVBORw0KGgo" * 2000}], "timestamp": 1}},
    {"type": "message", "id": f"a{n}", "timestamp": stamp, "message": {"role": "assistant", "content": [{"type": "toolCall", "id": f"c{n}", "name": "read", "arguments": {"path": "/x"}}],
                                                                     "api": "openai-completions", "provider": provider, "model": model, "usage": usage(tokens), "stopReason": "toolUse", "timestamp": 2}},
    {"type": "message", "id": f"r{n}", "timestamp": stamp, "message": {"role": "toolResult", "toolCallId": f"c{n}", "toolName": "read", "content": [{"type": "text", "text": "x" * 4000}], "isError": False, "timestamp": 3}},
    {"type": "message", "id": f"b{n}", "timestamp": stamp, "message": {"role": "assistant", "content": [{"type": "text", "text": "done"}],
                                                                     "api": "openai-completions", "provider": provider, "model": model, "usage": usage(tokens + 1), "stopReason": "stop", "timestamp": 4}},
    {"type": "compaction", "id": f"cp{n}", "parentId": f"b{n}", "timestamp": stamp, "summary": "s", "firstKeptEntryId": f"u{n}", "tokensBefore": 40000, "usage": usage(tokens + 2)},
  ]
  return lines


def write(path, lines):
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join(json.dumps(line) + "\n" for line in lines))


sessions = home / ".pi" / "agent" / "sessions" / "--proj--"
write(sessions / "mine.jsonl", pi_session("demo", "demo-model", 0, 1000))
for n in range(1, 41):
  write(sessions / f"other-{n}.jsonl", pi_session(f"other{n % 4}", "other-model", n, 50000))
# As omp 18.12.6 writes one: the switch names provider/model, no field
# `pattern` sees, and the only usage is a compaction on that model.
write(home / ".omp" / "agent" / "sessions" / "-" / "omp-compacted.jsonl", [
  {"type": "session", "version": 3, "id": "o1", "timestamp": stamp, "cwd": "/proj"},
  {"type": "model_change", "id": "omc", "parentId": None, "timestamp": stamp, "runtime": runtime, "model": "demo/omp-model", "resolvedModelIsFallback": False},
  {"type": "message", "id": "ou", "timestamp": stamp, "runtime": runtime, "message": {"role": "user", "content": [{"type": "text", "text": "compact"}], "attribution": "user", "timestamp": 1}},
  {"type": "compaction", "id": "ocp", "timestamp": stamp, "runtime": runtime, "summary": "s", "firstKeptEntryId": "ou", "tokensBefore": 900, "usage": usage(700)},
])

parsed = {"files": set(), "lines": 0}
pi_rows = collectors._pi_rows


def counting_rows(path, lines, accept):
  parsed["files"].add(Path(path).name)
  parsed["lines"] += len(lines)
  return pi_rows(path, lines, accept)


collectors._pi_rows = counting_rows


def scan(provider):
  for key in parsed:
    parsed[key] = set() if key != "lines" else 0
  pattern = r'"provider"\s*:\s*"' + provider + '"'
  return collectors.scan_pi_sessions(pattern, lambda name, model, entry: name == provider)


rows, complete = scan("nobody")
check("a scan for a provider with no sessions parses no line",
      complete and not rows and not parsed["files"] and parsed["lines"] == 0, json.dumps({**parsed, "files": sorted(parsed["files"])}))

rows, complete = scan("demo")
check("a scan parses only the files holding its own lines, the omp switch's included",
      complete and parsed["files"] == {"mine.jsonl", "omp-compacted.jsonl"}, json.dumps(sorted(parsed["files"])))
# The omp prompt no reply answered counts on the switch's model.
check("its own replies, prompts and compactions still count",
      sorted((row.model, row.input_tokens, row.prompts) for row in rows)
      == [("demo-model", 1000, 1), ("demo-model", 1001, 0), ("demo-model", 1002, 0), ("omp-model", 0, 1), ("omp-model", 700, 0)],
      json.dumps([row._asdict() for row in rows]))

rows, complete = scan("other1")
check("another provider's scan parses only its own ten files",
      complete and len(parsed["files"]) == 10 and all(name.startswith("other-") for name in parsed["files"]) and len(rows) == 30,
      json.dumps({"files": sorted(parsed["files"]), "rows": len(rows)}))
# A prompt goes with the reply that answered it, even one rg's pattern keeps
# out of the parse: another provider's reply after a handoff answered it, and
# the next reply here answers none.
turns = work / "turns"
write(turns / "handoff.jsonl", [
  {"type": "model_change", "id": "hm", "timestamp": stamp, "provider": "demo", "modelId": "demo-model"},
  {"type": "message", "id": "hu", "timestamp": stamp, "message": {"role": "user", "content": "ask the other one"}},
  {"type": "message", "id": "ho", "timestamp": stamp, "message": {"role": "assistant", "provider": "elsewhere", "model": "e", "usage": usage(300)}},
  {"type": "message", "id": "hd", "timestamp": stamp, "message": {"role": "assistant", "provider": "demo", "model": "demo-model", "usage": usage(30)}},
])
rows, _ = collectors.scan_pi_sessions(r'"provider"\s*:\s*"demo"', lambda name, model, entry: name == "demo", roots=[turns])
check("a prompt another provider answered is not booked on the next reply here",
      [(row.input_tokens, row.prompts) for row in rows] == [(30, 0)], json.dumps([row._asdict() for row in rows]))

# A prompt counts on the day it was typed, not the day its reply came, and
# one whose time can't be trusted counts nowhere.
yesterday = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat(timespec="milliseconds").replace("+00:00", "Z")
dated = work / "dated"
write(dated / "midnight.jsonl", [
  {"type": "model_change", "id": "dm", "timestamp": stamp, "provider": "demo", "modelId": "demo-model"},
  {"type": "message", "id": "du", "timestamp": yesterday, "message": {"role": "user", "content": "late"}},
  {"type": "message", "id": "da", "timestamp": stamp, "message": {"role": "assistant", "provider": "demo", "model": "demo-model", "usage": usage(40)}},
  {"type": "message", "id": "dx", "timestamp": 0, "message": {"role": "user", "content": "untimed"}},
  {"type": "message", "id": "db", "timestamp": stamp, "message": {"role": "assistant", "provider": "demo", "model": "demo-model", "usage": usage(50)}},
])
rows, _ = collectors.scan_pi_sessions(r'"provider"\s*:\s*"demo"', lambda name, model, entry: name == "demo", roots=[dated])
today = collectors.local_day(stamp)
check("a prompt counts on its own day, and an untimed one not at all",
      sorted((row.day, row.input_tokens, row.prompts) for row in rows)
      == sorted([(collectors.local_day(yesterday), 0, 1), (today, 40, 0), (today, 50, 0)]),
      json.dumps([row._asdict() for row in rows]))


def turn(n, provider, model):
  return [{"type": "message", "id": f"fu{n}", "timestamp": stamp, "message": {"role": "user", "content": "go", "timestamp": 1}},
          {"type": "message", "id": f"fa{n}", "timestamp": stamp, "message": {"role": "assistant", "provider": provider, "model": model, "usage": usage(100), "timestamp": 2}}]


# A fork copies its parent's whole history, as pi --fork does. A collector
# that owns one fork's own reply reads the other files of the fork tree
# only when they hold a copy of a prompt it booked: here none does.
forks = work / "forks"
history = [{"type": "model_change", "id": "fm", "timestamp": stamp, "provider": "busy", "modelId": "busy-model"}]
for n in range(20):
  history += turn(n, "busy", "busy-model")
write(forks / "parent.jsonl", [{"type": "session", "version": 3, "id": "fp", "timestamp": stamp, "cwd": "/proj"}, *history])
for n in range(6):
  extra = []
  if n == 5:
    extra = [{"type": "model_change", "id": "fk", "timestamp": stamp, "provider": "late", "modelId": "late-model"}, *turn("k", "late", "late-model")]
  write(forks / f"fork-{n}.jsonl", [{"type": "session", "version": 3, "id": f"ff{n}", "timestamp": stamp, "cwd": "/proj", "parentSession": str(forks / "parent.jsonl")}, *history, *extra])
for key in parsed:
  parsed[key] = set() if key != "lines" else 0
rows, complete = collectors.scan_pi_sessions(r'"provider"\s*:\s*"late"', lambda name, model, entry: name == "late", roots=[forks])
check("a fork's own reply parses no other file of its fork tree that holds none of its prompts",
      complete and parsed["files"] == {"fork-5.jsonl"} and [(row.input_tokens, row.prompts) for row in rows] == [(100, 1)],
      json.dumps({"files": sorted(parsed["files"]), "rows": [row._asdict() for row in rows]}))

# pi deletes a session from /resume and leaves its forks naming it. The
# fork's copies then count under the fork, and the scan is complete.
orphan = work / "orphan"
write(orphan / "fork.jsonl", [{"type": "session", "version": 3, "id": "of", "timestamp": stamp, "cwd": "/proj", "parentSession": str(orphan / "deleted.jsonl")},
                              *history, {"type": "model_change", "id": "ok", "timestamp": stamp, "provider": "late", "modelId": "late-model"}, *turn("k", "late", "late-model")])
for provider, want in (("busy", (2000, 20)), ("late", (100, 1))):
  rows, complete = collectors.scan_pi_sessions(r'"provider"\s*:\s*"' + provider + '"', lambda name, model, entry: name == provider, roots=[orphan])
  check(f"a fork whose parent was deleted is read in full for {provider}",
        complete and (sum(row.input_tokens for row in rows), sum(row.prompts for row in rows)) == want,
        json.dumps({"complete": complete, "rows": [row._asdict() for row in rows]}))

# Two forks of that deleted session copied its last prompt, still
# unanswered, and answered it on different providers: the gone parent still
# ties them, so the prompt counts once, under one collector.
siblings = work / "siblings"
copied = [{"type": "model_change", "id": "sm", "timestamp": stamp, "provider": "busy", "modelId": "busy-model"},
          {"type": "message", "id": "sq", "timestamp": stamp, "message": {"role": "user", "content": "go", "timestamp": 1}}]
for name, provider in (("a", "alpha"), ("b", "beta")):
  write(siblings / f"fork-{name}.jsonl", [{"type": "session", "version": 3, "id": f"s{name}", "timestamp": stamp, "cwd": "/proj", "parentSession": str(siblings / "deleted.jsonl")},
                                         *copied, {"type": "model_change", "id": f"sc{name}", "timestamp": stamp, "provider": provider, "modelId": f"{provider}-model"},
                                         {"type": "message", "id": f"sr{name}", "timestamp": stamp, "message": {"role": "assistant", "provider": provider, "model": f"{provider}-model", "usage": usage(100), "timestamp": 2}}])
prompts, completes = 0, []
for provider in ("alpha", "beta"):
  rows, complete = collectors.scan_pi_sessions(r'"provider"\s*:\s*"' + provider + '"', lambda name, model, entry, provider=provider: name == provider, roots=[siblings])
  prompts += sum(row.prompts for row in rows)
  completes.append(complete)
check("a prompt two forks of a deleted session copied and answered on different providers counts once",
      all(completes) and prompts == 1, json.dumps({"prompts": prompts, "complete": completes}))
PY
