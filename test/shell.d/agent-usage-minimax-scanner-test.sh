#!/bin/bash

# The MiniMax collector's local stats: MiniMax Code's own sessions (and where
# MINIMAX_DATA_DIR moves them), and pi, omp and opencode usage on MiniMax's
# provider ids. How pi and opencode stores are read (roots, forks, both
# opencode stores, OPENCODE_DB, opencode-v2.db, untrusted values) is held
# centrally by the shared and partition tests, the unused-machine record by
# the partition test, and the scan cache by the contract check. The limits
# are agent-usage-minimax-test.sh's.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *



def minimax(*args):
  with FakeHttp():
    return collect("minimax", *(args or ("--force",)))


def mcode_session(root, name, lines):
  path = Path(root) / "v2" / "sessions" / name / "messages.jsonl"
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join((line if isinstance(line, str) else json.dumps(line)) + "\n" for line in lines))
  return path


def mcode_reply(usage, timestamp=None, model="MiniMax-M2", provider=None):
  message = {"role": "assistant", "timestamp": ms_in(0) if timestamp is None else timestamp, "model": model, "usage": usage}
  if provider is not None:
    message["provider"] = provider
  return {"message": message}


def sessions():
  return home() / ".pi" / "agent" / "sessions"


# ---------------------------------------------------------- every source

# MiniMax Code's own sessions: user messages are prompts, assistant usage is
# tokens, and a row with a garbage timestamp, token count or line drops on
# its own. Beside them, pi and omp sessions and opencode rows on any MiniMax provider
# id; other providers, and a gateway named like one, drop.
sandbox()
mcode_session(home() / ".minimax", "s1", [
  {"message": {"role": "user", "timestamp": ms_in(0), "content": "hi"}},
  mcode_reply({"input": 10, "output": 5, "cacheRead": 3, "cacheWrite": 2, "totalTokens": 20}),
  mcode_reply({"input": 9999}, timestamp=True),
  mcode_reply({"input": -4, "output": 1e300}),
  "not json",
  "[" * 100000,  # nested too deep to parse: a RecursionError, not a ValueError
])
mcode_session(home() / ".minimax", "s2", [
  {"message": {"role": "user", "timestamp": "2020-01-01T00:00:00Z"}},
  mcode_reply({"totalTokens": 7}, timestamp="2020-01-01T00:00:01Z"),
])
stamp = iso_in(0)
parent = write_pi_session(sessions() / "p" / "a.jsonl", [
  pi_reply("minimax", id="m1", model="MiniMax-M2", usage={"input": 100, "output": 50}, timestamp=stamp),
  pi_reply("openai", id="m2", model="gpt", usage={"input": 999}),
])
write_pi_session(home() / ".omp" / "profiles" / "work" / "agent" / "sessions" / "p" / "b.jsonl", [
  pi_reply("minimax", id="m1", model="MiniMax-M2", usage={"input": 100, "output": 50}, timestamp=stamp),
  pi_reply("minimax-cn", id="m3", model="MiniMax-M2", usage={"input": 1000}),
], parent=parent)
opencode_db(tables=("message",), message=[
  ("o1", "ses1", oc_v1("minimax-coding-plan", {"input": 7, "output": 2, "reasoning": 1, "cache": {"read": 0, "write": 0}}, model="MiniMax-M2")),
  ("o2", "ses1", oc_v1("anthropic", {"input": 999}, model="claude")),
  ("o3", "ses1", oc_v1("minimax-proxy", {"input": 999}, model="MiniMax-M2")),
])

# Today: MiniMax Code 20, pi 150 (the forked copy counts once) + 1000,
# opencode 10. Prompts: one MiniMax Code message today and one before, two
# pi turns, one opencode turn.
record = minimax()
expect("MiniMax counts MiniMax Code, pi/omp and opencode usage, prompts and sessions per source, skipping garbage rows", {
  key: record[key] for key in ("todayTotalTokens", "todayPrompts", "totalPrompts", "totalSessions", "activeDays")
} | {"model": record["modelUsage"].get("MiniMax-M2")}, {
  "todayTotalTokens": 1180, "todayPrompts": 4, "totalPrompts": 5, "totalSessions": 5, "activeDays": 2,
  "model": {"inputTokens": 1124, "outputTokens": 58, "cacheReadInputTokens": 3, "cacheCreationInputTokens": 2},
}, record)

# In use here without a key: local stats show and the limits wait for one.
expect("MiniMax in use without a key waits for auth",
       {key: record[key] for key in ("ready", "hasLocalStats", "hasPromptStats", "usageStatusText", "limits", "tierLabel")},
       {"ready": True, "hasLocalStats": True, "hasPromptStats": True, "usageStatusText": "Waiting for auth", "limits": [], "tierLabel": ""}, record)

# MINIMAX_DATA_DIR moves MiniMax Code's data, ahead of MAVIS_DATA_DIR.
mcode_session(home() / "moved", "s", [mcode_reply({"input": 5})])
os.environ.update(MINIMAX_DATA_DIR=str(home() / "moved"), MAVIS_DATA_DIR=str(home() / ".minimax"))
record = minimax()
os.environ.pop("MINIMAX_DATA_DIR")
os.environ.pop("MAVIS_DATA_DIR")
expect("MiniMax reads MiniMax Code's sessions from MINIMAX_DATA_DIR, ahead of MAVIS_DATA_DIR", record["todayTotalTokens"], 1165, record)

# A scan that couldn't read one of MiniMax Code's files isn't kept for the
# next run.
if os.geteuid() != 0:
  for path in scan_cache_files("minimax"):
    path.unlink()
  locked = home() / ".minimax" / "v2" / "sessions" / "s2" / "messages.jsonl"
  locked.chmod(0)
  try:
    minimax()
  finally:
    locked.chmod(0o644)
  record = minimax("--limits-only")
  expect("MiniMax does not cache a scan that missed a MiniMax Code file", record["totalPrompts"], 5, record)

  # Nor one that couldn't list a session directory, whose files it never saw.
  for path in scan_cache_files("minimax"):
    path.unlink()
  locked.parent.chmod(0)
  try:
    minimax()
  finally:
    locked.parent.chmod(0o755)
  record = minimax("--limits-only")
  expect("MiniMax does not cache a scan that couldn't list a MiniMax Code session directory", record["totalPrompts"], 5, record)
else:
  print("ok - MiniMax does not cache a scan that missed a MiniMax Code file # SKIP root reads anything")

# MiniMax Code 0.6 names each reply's route, as `minimax` (its Token Plan),
# `minimax_api`, or `custom_provider:<name>` for a custom endpoint or a Z.AI or
# OpenRouter preset. Only MiniMax's own routes count, and a prompt goes with
# the route of the reply that answered it.
sandbox()
mcode_session(home() / ".minimax", "routed", [
  {"message": {"role": "user", "timestamp": ms_in(0), "content": [{"type": "text", "text": "one"}]}},
  mcode_reply({"input": 1234, "output": 51, "cacheRead": 71, "cacheWrite": 31, "totalTokens": 1387}, provider="custom_provider:mockanth"),
  {"message": {"role": "user", "timestamp": ms_in(0), "content": [{"type": "text", "text": "two"}]}},
  mcode_reply({"input": 2234, "output": 52, "cacheRead": 72, "cacheWrite": 0, "totalTokens": 2358}, model="glm-5", provider="custom_provider:zai-coding-plan"),
  {"message": {"role": "user", "timestamp": ms_in(0), "content": [{"type": "text", "text": "three"}]}},
  mcode_reply({"input": 10, "output": 5, "totalTokens": 15}, provider="minimax"),
  {"message": {"role": "user", "timestamp": ms_in(0), "content": [{"type": "text", "text": "four"}]}},
  mcode_reply({"input": 20, "output": 5, "totalTokens": 25}, provider="minimax_api"),
])
mcode_session(home() / ".minimax", "elsewhere", [
  {"message": {"role": "user", "timestamp": ms_in(0), "content": "unanswered, after a custom route"}},
  mcode_reply({"input": 999, "output": 1}, model="glm-mock", provider="custom_provider:mockoai"),
  {"message": {"role": "user", "timestamp": ms_in(0), "content": "still waiting"}},
])
record = minimax()
expect("MiniMax counts only MiniMax Code replies on MiniMax's own routes, and the prompts they answered",
       {key: record[key] for key in ("todayTotalTokens", "todayPrompts", "todaySessions", "todayTokensByModel")},
       {"todayTotalTokens": 40, "todayPrompts": 2, "todaySessions": 1, "todayTokensByModel": {"MiniMax-M2": 40}}, record)

# Claude Code pointed at MiniMax's Anthropic API is MiniMax's; with no
# endpoint, only a MiniMax model's reply is.
sandbox()
claude_code_session("mm", [("MiniMax-M2", 300), ("claude-sonnet-4-5", 40)])
record = minimax()
expect("MiniMax counts Claude Code's MiniMax replies, and no Claude one",
       [record["todayTokensByModel"], record["todayPrompts"], record["todaySessions"]], [{"MiniMax-M2": 300}, 1, 1], record)
claude_code_session("mm", [("MiniMax-M2", 300), ("claude-sonnet-4-5", 40)], base_url="https://api.minimax.io/anthropic")
record = minimax()
expect("MiniMax counts every Claude Code reply while Claude Code is pointed at MiniMax",
       [record["todayTokensByModel"], record["todayPrompts"]], [{"MiniMax-M2": 300, "claude-sonnet-4-5": 40}, 2], record)

# Nor is a scan that couldn't read one of Claude Code's transcripts kept for
# the next run.
if os.geteuid() != 0:
  sandbox()
  claude_code_session("mm", [("MiniMax-M2", 300)])
  locked = claude_code_session("late", [("MiniMax-M2", 40)])
  locked.chmod(0)
  try:
    minimax()
  finally:
    locked.chmod(0o644)
  record = minimax("--limits-only")
  expect("MiniMax does not cache a scan that missed a Claude Code transcript", record["todayTokensByModel"], {"MiniMax-M2": 340}, record)
else:
  print("ok - MiniMax does not cache a scan that missed a Claude Code transcript # SKIP root reads anything")

# A MiniMax Code custom provider is billed by whoever runs its baseURL in
# config.yaml: one at MiniMax's own host is MiniMax's, one at OpenRouter's
# isn't, and neither is one gone from the config.
sandbox()
mcode_routed_session("own", "custom_provider:mm", "MiniMax-M2", 300, base_url="https://api.minimax.io/anthropic")
mcode_routed_session("router", "custom_provider:router", "MiniMax-M2-or", 40, base_url="https://openrouter.ai/api/v1")
mcode_routed_session("gone", "custom_provider:gone", "MiniMax-M2-gone", 5)
record = minimax()
expect("MiniMax counts a MiniMax Code custom provider at MiniMax's host, and no other",
       [record["todayTokensByModel"], record["todayPrompts"], record["todaySessions"]], [{"MiniMax-M2": 300}, 1, 1], record)

# ---------------------------------------------------------------- contract

sandbox()


def add_reply():
  add_reply.count = getattr(add_reply, "count", 0) + 1
  mcode_session(home() / ".minimax", f"grown-{add_reply.count}", [mcode_reply({"input": 5})])


check_scan_cache(Adapter("minimax", grow=add_reply, pi_root=sessions))
PY
