#!/bin/bash

# The OpenCode collector's local stats: pi, omp and opencode usage on the Zen
# and Go providers only, with the thinking suffix stripped from model names.
# How pi and opencode stores are read (roots, forks, both opencode stores,
# OPENCODE_DB, untrusted values) is held centrally by the shared and
# partition tests, the unused-machine record by the partition test, and the
# scan cache by the contract check. The limits are agent-usage-opencode-limits-test.sh's.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *


def opencode(*args):
  with FakeHttp():
    return collect("opencode", *(args or ("--force",)))


def sessions():
  return home() / ".pi" / "agent" / "sessions"


# ------------------------------------------------------------- pi and omp

# pi and omp can spend an OpenCode subscription without opencode's CLI ever
# running, so its own database cannot be the only source. A custom
# "opencode-local" gateway is somewhere else, and a user line is no reply.
sandbox()
write_pi_session(sessions() / "project" / "pi.jsonl", [
  pi_reply("opencode", id="pi-1", model="deepseek-v4.1-flash:high", usage={"input": 100, "output": 15, "reasoning": 5, "cacheRead": 20, "cacheWrite": 3}),
  pi_reply("opencode-local", id="pi-2", model="gpt-nope", usage={"input": 999, "output": 999}),
  {"type": "message", "id": "pi-3", "timestamp": iso_in(0), "message": {"role": "user", "provider": "opencode", "model": "deepseek-v4.1-flash", "usage": {"input": 999, "output": 999}}},
])
write_pi_session(home() / ".omp" / "agent" / "sessions" / "project" / "omp.jsonl", [
  pi_reply("opencode-go", id="omp-1", model="minimax-m3", usage={"input": 50, "output": 5, "reasoningTokens": 1, "cacheRead": 5, "cacheWrite": 0}),
  pi_reply("openai-codex", id="other-1", model="gpt-nope", usage={"input": 999, "output": 999}),
])
record = opencode()
expect("OpenCode counts its Zen and Go usage from pi and omp, reasoning already in output, stripping the thinking suffix", {
  "name": record["name"], "today": record["todayTotalTokens"], "models": record["modelUsage"],
}, {
  "name": "OpenCode", "today": 198, "models": {
    "deepseek-v4.1-flash": {"inputTokens": 100, "outputTokens": 15, "cacheReadInputTokens": 20, "cacheCreationInputTokens": 3},
    "minimax-m3": {"inputTokens": 50, "outputTokens": 5, "cacheReadInputTokens": 5, "cacheCreationInputTokens": 0},
  },
}, record)

# ---------------------------------------------------------------- opencode

# A subscription burned entirely through opencode has no pi session files;
# usage comes from opencode's own database, filtered to its providers.
sandbox()
db = opencode_db(tables=("message",), message=[
  ("msg_1", "ses_1", oc_v1("opencode", {"input": 80, "output": 40, "reasoning": 5, "cache": {"read": 30, "write": 0}}, model="deepseek-v4-flash")),
  ("msg_2", "ses_1", oc_v1("opencode-go", {"input": 10, "output": 2}, model="minimax-m3")),
  ("msg_3", "ses_1", oc_v1("anthropic", {"input": 999, "output": 999}, model="claude-opus-5")),
  ("msg_7", "ses_1", oc_v1("openai", {"input": 999, "output": 999}, model="gpt-5.5")),
  ("msg_4", "ses_1", oc_v1("opencode-local", {"input": 999, "output": 999}, model="gpt-nope")),
  ("msg_5", "ses_1", oc_v1("opencode", {"input": 999, "output": 999}, model="deepseek-v4-flash", role="user")),
  ("msg_6", "ses_1", '["not","an","object"]'),
])
record = opencode()
expect("OpenCode counts opencode's own rows on its providers, leaving Anthropic, OpenAI, look-alike gateways, prompts and malformed rows out", {
  "today": record["todayTotalTokens"], "sessions": record["totalSessions"], "models": record["modelUsage"],
}, {
  "today": 167, "sessions": 1, "models": {
    "deepseek-v4-flash": {"inputTokens": 80, "outputTokens": 45, "cacheReadInputTokens": 30, "cacheCreationInputTokens": 0},
    "minimax-m3": {"inputTokens": 10, "outputTokens": 2, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0},
  },
}, record)

# Valid JSON with a nested field of the wrong shape (a numeric time, a list of
# tokens or of cache counts, a list for a pi message or its usage) costs that
# field or that row, never the record.
sandbox()
write_pi_session(sessions() / "project" / "pi.jsonl", [
  {"type": "message", "id": "pi-odd", "timestamp": iso_in(0), "message": ["provider", "opencode"]},
  {"type": "message", "id": "pi-usage", "timestamp": iso_in(0), "message": {"role": "assistant", "provider": "opencode", "model": "kimi-k3", "usage": [1, 2]}},
])
odd_db = data_home() / "opencode" / "opencode.db"
odd_db.parent.mkdir(parents=True)
conn = sqlite3.connect(odd_db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, data text NOT NULL)")
conn.executemany("INSERT INTO message VALUES (?, 'ses_odd', ?)", [(row_id, json.dumps(data)) for row_id, data in (
  ("odd_time", {"role": "assistant", "providerID": "opencode", "modelID": "kimi-k3", "tokens": {"input": 40, "output": 0}, "time": 12345}),
  ("odd_tokens", {"role": "assistant", "providerID": "opencode", "modelID": "kimi-k3", "tokens": [1, 2], "time": {"created": ms_in(0)}}),
  ("odd_cache", {"role": "assistant", "providerID": "opencode", "modelID": "kimi-k3", "tokens": {"input": 2, "cache": [9]}, "time": {"created": ms_in(0)}}),
)])
conn.commit()
conn.close()
record = opencode()
expect("OpenCode survives malformed nested fields", [record["totalPrompts"], record["modelUsage"]["kimi-k3"]["inputTokens"]], [2, 42], record)

# ---------------------------------------------------------------- contract

sandbox()


def add_reply():
  add_reply.count = getattr(add_reply, "count", 0) + 1
  write_pi_session(sessions() / "grown" / f"{add_reply.count}.jsonl", [pi_reply("opencode-go", 5, id=f"grown-{add_reply.count}")])


check_scan_cache(Adapter("opencode", grow=add_reply, pi_root=sessions))
PY
