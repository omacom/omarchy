#!/bin/bash

# The Z.ai collector's local stats: pi and omp turns on the zai and zhipu
# providers, dated as Z.ai's harnesses date them, and the keyless wait for
# auth. How pi and opencode stores are read (roots, forks, repeated ids, both
# opencode stores, OPENCODE_DB, opencode-v2.db, untrusted values) is held
# centrally by the shared and partition tests, the unused-machine record by
# the partition test, and the scan cache by the contract check. The limits
# are agent-usage-zai-limits-test.sh's.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *


def zai(*args):
  with FakeHttp():
    return collect("zai", *(args or ("--force",)))


def sessions():
  return home() / ".pi" / "agent" / "sessions"


# One session file exercises the scan:
#   a  zai, today, with reasoning + cache tokens        -> counted, today
#   b  zhipu, today                                     -> counted, today
#   c  openai provider                                  -> ignored
#   d  zai but a user turn                              -> ignored
#   a' a repeated message id                            -> deduped
#   f  zai, no top-level timestamp, message.timestamp   -> counted, NOT today
#   e  malformed JSON                                   -> skipped, rest survive
sandbox()
stamp = today_stamp()
write_pi_session(sessions() / "project" / "pi.jsonl", [
  {"type": "message", "id": "u1", "timestamp": stamp, "message": {"role": "user", "content": "hi"}},
  pi_reply("zai", id="a", model="glm-5.3", timestamp=stamp, usage={"input": 10, "output": 10, "reasoning": 6, "cacheRead": 3, "cacheWrite": 2}),
  pi_reply("zhipu", id="b", model="glm-4.7", timestamp=stamp, usage={"input": 20, "output": 5}),
  pi_reply("openai", id="c", model="gpt", timestamp=stamp, usage={"input": 999, "output": 999}),
  {"type": "message", "id": "d", "timestamp": stamp, "message": {"role": "user", "provider": "zai", "model": "glm-5.3", "usage": {"input": 500, "output": 500}}},
  pi_reply("zai", id="a", model="glm-5.3", timestamp=stamp, usage={"input": 77, "output": 77}),
  {"type": "message", "id": "u2", "timestamp": stamp, "message": {"role": "user", "content": "again"}},
  {"type": "message", "id": "f", "message": {"role": "assistant", "provider": "zai", "model": "glm-4.6", "timestamp": "2020-01-01T00:00:00Z", "usage": {"input": 7}}},
  '{"type":"message","id":"e","message":{"role":"assistant","provider":"zai","usage":{ broken',
])
record = zai()

# In use here, but no key to ask for its limits.
expect("Z.ai is ready on local stats alone and waits for a key, naming ZAI_API_KEY",
       [record["name"], record["ready"], record["limits"], record["usageStatusText"], "ZAI_API_KEY" in record["authHelpText"]],
       ["Z.ai", True, [], "Waiting for auth", True], record)

# Reasoning tokens fold into output and cache tokens split out; openai, the
# user turn and the malformed line drop out.
expect("Z.ai counts zai and zhipu assistant turns, reasoning already in output", {
  "models": sorted(record["modelUsage"]), "glm-5.3": record["modelUsage"]["glm-5.3"],
}, {
  "models": ["glm-4.6", "glm-4.7", "glm-5.3"],
  "glm-5.3": {"inputTokens": 10, "outputTokens": 10, "cacheReadInputTokens": 3, "cacheCreationInputTokens": 2},
}, record)

# a + b land today (25 + 25); f is dated by its message's own time, an old
# day, so it counts in the totals and never in today's. A prompt books on the
# first reply after it, a's and f's, b being a further step, and counts on
# the day it was typed: both today.
expect("Z.ai dates a turn by message.timestamp, keeping an old one out of today",
       [record["todayTotalTokens"], record["todayPrompts"], record["totalPrompts"], record["activeDays"]], [50, 2, 2, 2], record)

# Claude Code pointed at Z.ai (its settings' env, as Z.ai's guide sets it) is
# Z.ai's whatever model answered; with no endpoint, only a GLM reply is. A
# Claude reply sent to Anthropic stays Claude's.
sandbox()
claude_code_session("glm", [("glm-4.6", 500), ("claude-sonnet-4-5", 40)])
record = zai()
expect("Z.ai counts Claude Code's GLM replies and their prompts, and no Claude one",
       [record["todayTokensByModel"], record["todayPrompts"], record["todaySessions"], record["ready"]], [{"glm-4.6": 500}, 1, 1, True], record)
claude_code_session("glm", [("glm-4.6", 500), ("claude-sonnet-4-5", 40)], base_url="https://api.z.ai/api/anthropic")
record = zai()
expect("Z.ai counts every Claude Code reply while Claude Code is pointed at Z.ai",
       [record["todayTokensByModel"], record["todayPrompts"]], [{"glm-4.6": 500, "claude-sonnet-4-5": 40}, 2], record)

# MiniMax Code's Z.AI preset is a custom provider at api.z.ai: Z.ai's, with
# the prompt it answered. One at another host isn't.
sandbox()
mcode_routed_session("zed", "custom_provider:zai-coding-plan", "glm-4.7", 2358, base_url="https://api.z.ai/api/coding/paas/v4")
mcode_routed_session("other", "custom_provider:acme", "glm-elsewhere", 40, base_url="https://llm.acme.example/v1")
record = zai()
expect("Z.ai counts MiniMax Code replies on a custom provider at api.z.ai",
       [record["todayTokensByModel"], record["todayPrompts"], record["todaySessions"]], [{"glm-4.7": 2358}, 1, 1], record)

# DeepSeek Harness logs a turn's route and its usage under $DSH_HOME/sessions;
# a Z.ai turn is the route `zai`, whatever model answered, and another
# provider's route on the same session is not Z.ai's.
sandbox()
os.environ["DSH_HOME"] = str(home() / "dsh")
now = ms_in(0)

try:
  from compression import zstd
except ImportError:
  zstd = None


def dsh_header(session):
  return {"type": "session", "version": 4, "id": session, "createdAt": now, "isSeeded": False, "delegationDepth": 0}


def typed(seq=1):
  return {"type": "user/message", "seq": seq, "time": now, "data": {"content": [{"type": "text", "text": "go"}], "source": {"kind": "user"}, "role": "user", "id": f"m{seq}"}}


def route(provider, model, seq=1):
  return {"type": "request/header", "seq": seq, "time": now, "data": {"header": {"config": {"provider": provider, "model": model}}, "reason": "initial"}}


def message(turn, step, usage, seq=2):
  return {"type": "assistant/message", "seq": seq, "time": now, "data": {"turn": turn, "step": step, "stream": [], "usage": usage}}


def usage(input, output=0):
  return {"inputTokens": input, "outputTokens": output, "cacheReadTokens": 0, "cacheWriteTokens": 0}


def write_log(path, records):
  path.parent.mkdir(parents=True, exist_ok=True)
  lines = [(json.dumps(record) + "\n").encode() for record in records]
  if zstd is not None:
    path.write_bytes(b"".join(zstd.compress(line) for line in lines))
  else:
    path.write_bytes(b"".join(lines))


suffix = ".jsonl.zstd" if zstd is not None else ".jsonl"
project = home() / "dsh" / "sessions" / "--home-me-code--"
write_log(project / "s1" / ("session.v4" + suffix), [
  dsh_header("s1"),
  typed(),
  route("zai", "glm-5.3"),
  message(1, 1, usage(400, 100)),
  route("deepseek-official", "deepseek-v4-pro", seq=3),
  message(2, 1, usage(999, 999), seq=4),
])
record = zai()
expect("Z.ai counts DeepSeek Harness's zai route, not its other routes",
       [record["todayTokensByModel"], record["todayPrompts"], record["todaySessions"], record["ready"]],
       [{"glm-5.3": 500}, 1, 1, True], record)

# ---------------------------------------------------------------- contract

sandbox()


def add_reply():
  add_reply.count = getattr(add_reply, "count", 0) + 1
  write_pi_session(sessions() / "grown" / f"{add_reply.count}.jsonl", [pi_reply("zai", 5, id=f"grown-{add_reply.count}")])


check_scan_cache(Adapter("zai", grow=add_reply, pi_root=sessions))
PY
