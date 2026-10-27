#!/bin/bash

# The Mistral Vibe collector's own sources: Vibe's Unified Harness store, the
# session logs older releases wrote and their per-session index, the model
# and provider each session resolves to, the plan Vibe caches, VIBE_HOME and
# its session_logging settings, and the model names pi, omp and opencode give
# Mistral's models. How pi and opencode
# stores are read (roots, forks, both opencode stores, PI_CODING_AGENT_DIR,
# untrusted values) is held by the shared and partition tests, as is the
# unused-machine record; the scan cache goes through the contract check.
# Mistral publishes no limits, so there is no limits contract to hold.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/agent-usage-helpers.sh"

agent_sandbox

python3 - <<'PY'
from agent_usage_fixtures import *

MISTRAL_CONFIG = {
  "active_model": "mistral-medium-3.5",
  "models": {
    "mistral-medium-3.5": {"name": "mistral-vibe-cli-latest", "provider": "mistral", "alias": "mistral-medium-3.5"},
    "local": {"name": "qwen", "provider": "llamacpp", "alias": "local"},
  },
  "providers": [
    {"name": "mistral", "api_base": "https://api.mistral.ai/v1", "backend": "mistral"},
    {"name": "llamacpp", "api_base": "http://127.0.0.1:8080/v1", "backend": "generic"},
  ],
}
LOCAL_CONFIG = {**MISTRAL_CONFIG, "active_model": "local"}
NOW = iso_in(0)


def vibe(*args):
  return collect("vibe", *(args or ("--force",)))


def session_root():
  return home() / ".vibe" / "logs" / "session"


# A Vibe session's meta.json: its running totals and the config it ran with.
def write_meta(directory, start, prompt, cached, completion, config=MISTRAL_CONFIG):
  stats = {"session_prompt_tokens": prompt, "session_cached_tokens": cached, "session_completion_tokens": completion}
  return write_json(Path(directory) / "meta.json", {"session_id": Path(directory).name, "start_time": start, "stats": stats, "config": config})


def write_messages(directory, lines):
  (Path(directory) / "messages.jsonl").write_text("".join(json.dumps(line) + "\n" for line in lines))


# ------------------------------------------------------------ Vibe sessions

sandbox()
main_session = session_root() / "session_20260101_120000_aaaa"
write_meta(main_session, NOW, 1000, 400, 200)
write_messages(main_session, [
  {"role": "user", "content": "Fix the bug"},
  {"role": "assistant", "content": "Done"},
  {"role": "user", "content": "<reminder>", "injected": True},
  {"role": "user", "content": "summary", "context_boundary": "compaction"},
  {"role": "tool", "content": "ok"},
  {"role": "user", "content": "Thanks"},
])
# A subagent's totals belong to the session that spawned it; its task is not
# a prompt anyone typed.
subagent = main_session / "agents" / "explore_20260101_120100_bbbb"
write_meta(subagent, NOW, 300, 0, 50)
write_messages(subagent, [{"role": "user", "content": "Look around"}])
# A session on the local llama.cpp provider is not Mistral usage, but the
# local collector's.
write_meta(session_root() / "session_20260101_130000_cccc", NOW, 9000, 0, 9000, LOCAL_CONFIG)
write_messages(session_root() / "session_20260101_130000_cccc", [{"role": "user", "content": "local"}])
# Running totals are booked on the day the session started.
write_meta(session_root() / "session_20260101_140000_dddd", iso_in(-2 * 86400), 100, 0, 10)

record = vibe()
two_days_ago = (datetime.now() - timedelta(days=2)).strftime("%Y-%m-%d")
expect("Vibe counts Mistral sessions, their subagents, and typed prompts only, booked on the day each started", {
  "name": record["name"],
  "counts": {key: record[key] for key in ("ready", "todayPrompts", "todaySessions", "todayTotalTokens", "totalPrompts", "totalSessions", "activeDays")},
  "models": record["modelUsage"],
  "two days ago": next(day["messageCount"] for day in record["recentDays"] if day["date"] == two_days_ago),
}, {
  "name": "Mistral Vibe",
  "counts": {"ready": True, "todayPrompts": 2, "todaySessions": 1, "todayTotalTokens": 1550, "totalPrompts": 2, "totalSessions": 2, "activeDays": 2},
  "models": {"mistral-medium-3.5": {"inputTokens": 1000, "outputTokens": 260, "cacheReadInputTokens": 400, "cacheCreationInputTokens": 0}},
  "two days ago": 110,
}, record)
local = collect("local", "--force")
expect("Local counts the Vibe session on the llama.cpp server, with its prompt",
       [local["todayTokensByModel"], local["todayPrompts"], local["todaySessions"]], [{"local": 18000}, 1, 1], local)

# A zoneless start at the edge of the calendar, in a zone off UTC, is no
# start to book; the scan still completes, and is cached.
sandbox()
saved_tz = os.environ.get("TZ")
os.environ["TZ"] = "Asia/Tokyo"
time.tzset()
write_meta(session_root() / "session_20260101_150000_eeee", "0001-01-01T00:00:00", 100, 0, 10)
write_meta(session_root() / "session_20260101_160000_ffff", NOW, 100, 0, 10)
try:
  record = vibe()
finally:
  if saved_tz is None:
    os.environ.pop("TZ")
  else:
    os.environ["TZ"] = saved_tz
  time.tzset()
expect("a zoneless start at year 1 off UTC skips that session, and the scan is cached",
       [record["totalSessions"], bool(scan_cache_files("vibe"))], [1, True], record)

# --------------------------------------------------- Unified Harness store

import hashlib


# One session in the Unified Harness store, as Vibe 3 writes it: CURRENT names
# a generation whose projection-state.json holds the camelCase public state,
# its history kept in the chunk pool when chunked, and the journal it names
# holds the records since. meta.json names only the model.
def write_unified(session_id, usage, entries=(), journal=(), alias="mistral-medium-3.5", chunked=False, metadata=None, torn=b""):
  root = session_root() / "unified" / session_id
  generation = "0000000000000003-abcd"
  gen = root / "generations" / generation
  gen.mkdir(parents=True)
  def doc(path, value):
    path.write_text(json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n")
  session = {"id": session_id, "rootSessionId": (metadata or {}).get("root_session_id", session_id), "status": {"type": "idle"},
             "createdAt": ms_in(0), "updatedAt": ms_in(0), "tokenUsage": usage}
  history = {"range": "latest", "entries": [] if chunked else list(entries), "cursor": {}}
  projection = {"projection_state_version": 1, "session_id": session_id, "snapshot_sequence": 3, "watermark": 9,
                "snapshot": {"format": "harness.public-session-state/v1", "session": session, "history": history, "turnQueue": {}}}
  described = {"path": "projection-state.json", "sha256": "0" * 64}
  if chunked:
    body = json.dumps(list(entries), sort_keys=True, separators=(",", ":")).encode()
    digest = hashlib.sha256(body).hexdigest()
    (root / "chunks").mkdir()
    (root / "chunks" / f"{digest}.json").write_bytes(body)
    described["chunks"] = [digest]
  doc(gen / "projection-state.json", projection)
  doc(gen / "runtime-state.json", {"session_id": session_id, "snapshot_sequence": 3,
                                   "session_metadata": {"cwd": "/tmp", "root_session_id": session_id, **(metadata or {})}})
  doc(gen / "manifest.json", {"manifest_version": 1, "session_id": session_id, "generation": generation, "snapshot_sequence": 3,
                              "execution_state": "quiescent", "projection_state": described,
                              "runtime_state": {"path": "runtime-state.json", "sha256": "0" * 64},
                              "checkpoint": {"path": "checkpoint.json", "sha256": "0" * 64},
                              "recovery_journal_segment": {"path": "journal/0000000000000004.jsonl", "first_sequence": 4}})
  (root / "journal").mkdir()
  lines = [json.dumps({"recovery_journal_record_version": 1, "sequence": 4 + index, "type": kind, "payload": payload}) + "\n"
           for index, (kind, payload) in enumerate(journal)]
  (root / "journal" / "0000000000000004.jsonl").write_bytes("".join(lines).encode() + torn)
  doc(root / "CURRENT", {"store_format": "mistral.vibe.unified-session-store/v1", "store_format_minor": 3, "session_id": session_id,
                         "generation": generation, "snapshot_sequence": 3, "manifest_sha256": "0" * 64})
  config = {"active_model": alias, "model_name": "mistral-vibe-cli-latest"} if alias else None
  write_json(root / "meta.json", {"session_id": session_id, "start_time": NOW, "config": config})
  return root


def usage(input_tokens, output_tokens, cached=0):
  return {"inputTokens": input_tokens, "outputTokens": output_tokens, "totalTokens": input_tokens + output_tokens, "cachedInputTokens": cached}


def message(entry_id, role, source):
  return {"type": "message", "id": entry_id, "role": role, "source": source, "content": [{"type": "text", "text": entry_id}]}


sandbox()
# The journal's newest envelope carries the totals since the generation was
# published, and a record still being written counts for nothing.
newer = {"format": "harness.public-session-state/v1", "history": {"entries": []},
         "session": {"id": "ses_main", "createdAt": ms_in(0), "tokenUsage": usage(5000, 700, 2000)}}
write_unified("ses_main", usage(1000, 100, 400), chunked=True, entries=[
  message("u1", "user", "turn_start"),
  message("a1", "assistant", "turn_start"),
  message("r1", "user", "harness"),
], journal=[
  ("projection_delta", {"watermark": 10, "delta": [{"op": "append_entry", "entry": message("u2", "user", "turn_steer")}, {"op": "set_envelope", "state": newer}]}),
], torn=b'{"type":"projection_delta","payload":{"delta":[{"op":"set_envelope","state":{"session":{"tokenUsage":{"inputTokens":999999')
# A subagent's totals belong to the session that spawned it; its task is not a
# prompt anyone typed.
write_unified("ses_child", usage(300, 50), entries=[message("t1", "user", "turn_start")],
              metadata={"root_session_id": "ses_main", "parent_session_id": "ses_main", "subagent_spawn_key": "spawn-1"})
# A fork starts from no usage of its own, and what it copied is not its prompts.
write_unified("ses_fork", usage(40, 10), entries=[message("c1", "user", "harness"), message("f1", "user", "turn_start")],
              metadata={"root_session_id": "ses_main", "parent_session_id": "ses_main"})
# A session on the local llama.cpp model config.toml adds is not Mistral
# usage, but the local collector's.
(home() / ".vibe").mkdir(parents=True, exist_ok=True)
(home() / ".vibe" / "config.toml").write_text('[[models]]\nname = "qwen"\nprovider = "llamacpp"\nalias = "local"\n\n[[providers]]\nname = "llamacpp"\napi_base = "http://127.0.0.1:8080/v1"\n')
write_unified("ses_local", usage(9000, 9000), entries=[message("l1", "user", "turn_start")], alias="local")
with contextlib.redirect_stderr(io.StringIO()):
  record = vibe()
expect("Vibe counts Unified Harness sessions from the store's newest state, folding subagents into their session", {
  key: record[key] for key in ("ready", "todayPrompts", "todaySessions", "todayTotalTokens", "totalSessions", "modelUsage")
}, {
  "ready": True, "todayPrompts": 3, "todaySessions": 2, "todayTotalTokens": 6100, "totalSessions": 2,
  "modelUsage": {"mistral-medium-3.5": {"inputTokens": 3340, "outputTokens": 760, "cacheReadInputTokens": 2000, "cacheCreationInputTokens": 0}},
}, record)
check("Vibe caches a Unified Harness scan whose torn last journal record is still being written", bool(scan_cache_files("vibe")))
with contextlib.redirect_stderr(io.StringIO()):
  local = collect("local", "--force")
expect("Local counts the Unified Harness session on the llama.cpp server, with its prompt",
       [local["todayTokensByModel"], local["todayPrompts"]], [{"local": 18000}, 1], local)

# A store whose CURRENT names a generation that isn't there leaves the scan
# incomplete, so it isn't cached.
sandbox()
write_unified("ses_ok", usage(10, 5))
write_unified("ses_broken", usage(10, 5))
write_json(session_root() / "unified" / "ses_broken" / "CURRENT", {"generation": "missing"})
with contextlib.redirect_stderr(io.StringIO()):
  record = vibe()
expect("Vibe skips a Unified Harness session it cannot read without caching the scan",
       [record["todayTotalTokens"], bool(scan_cache_files("vibe"))], [15, False], record)

# A Unified Harness session goes where config.toml routes its alias now, so a
# route change reaches the cached scan at once, even on the panel's
# --limits-only refresh that otherwise reuses a scan for minutes.
sandbox()
MISTRAL_TOML = '[[providers]]\nname = "mistral"\napi_base = "{}"\napi_key_env_var = "MISTRAL_API_KEY"\nbackend = "mistral"\n\n[[models]]\nname = "devstral-2"\nprovider = "mistral"\nalias = "devstral-mock"\n'
(home() / ".vibe").mkdir(parents=True, exist_ok=True)
(home() / ".vibe" / "config.toml").write_text(MISTRAL_TOML.format("https://api.mistral.ai/v1"))
write_unified("ses_routed", usage(67000, 896), entries=[message("u1", "user", "turn_start")], alias="devstral-mock")
before = vibe("--limits-only")
(home() / ".vibe" / "config.toml").write_text(MISTRAL_TOML.format("http://127.0.0.1:18083/v1"))
after = vibe("--limits-only")
expect("a Vibe route change reaches Vibe's cached scan at once",
       [before["todayTokensByModel"], after["todayTokensByModel"], after["todayPrompts"]], [{"devstral-mock": 67896}, {}, 0], after)

# A session whose alias config.toml no longer names isn't Mistral's because
# Vibe would now fall back to its default: no one can say who served it.
sandbox()
(home() / ".vibe").mkdir(parents=True, exist_ok=True)
(home() / ".vibe" / "config.toml").write_text('[[models]]\nname = "qwen"\nprovider = "llamacpp"\nalias = "local"\n')
write_unified("ses_dropped", usage(5000, 5000), entries=[message("d1", "user", "turn_start")], alias="removed-local")
with contextlib.redirect_stderr(io.StringIO()):
  record = vibe("--force")
  local = collect("local", "--force")
expect("a Unified Harness session on an alias config.toml dropped is billed to no one",
       [record["todayTokensByModel"], local["todayTokensByModel"]], [{}, {}], [record, local])

# ------------------------------------------------------- model resolution

sandbox()
# Unpinned: Vibe falls back to its default alias.
write_meta(session_root() / "session_1", NOW, 10, 0, 0, {
  "active_model": "",
  "models": {"local": {"name": "q", "provider": "llamacpp", "alias": "local"}, "mistral-medium-3.5": {"name": "m", "provider": "mistral", "alias": "mistral-medium-3.5"}},
  "providers": [{"name": "mistral", "backend": "mistral"}, {"name": "llamacpp", "backend": "generic"}],
})
# Older releases dump the models as a list.
write_meta(session_root() / "session_2", NOW, 20, 0, 0, {
  "active_model": "devstral", "models": [{"name": "devstral-2", "provider": "mistral", "alias": "devstral"}], "providers": [{"name": "mistral", "backend": "mistral"}],
})
# A generic provider aimed at Mistral's API is still Mistral.
write_meta(session_root() / "session_3", NOW, 40, 0, 0, {
  "active_model": "codestral", "models": {"codestral": {"name": "codestral-latest", "provider": "la-plateforme", "alias": "codestral"}},
  "providers": [{"name": "la-plateforme", "api_base": "https://codestral.mistral.ai/v1", "backend": "generic"}],
})
# A lookalike host is not.
write_meta(session_root() / "session_4", NOW, 80, 0, 0, {
  "active_model": "x", "models": {"x": {"name": "x", "provider": "proxy", "alias": "x"}},
  "providers": [{"name": "proxy", "api_base": "https://mistral.ai.example.com/v1", "backend": "generic"}],
})
# The mistral backend sends to its api_base too: one aimed at a server you
# run is the local collector's, and one at another provider's host is not
# Mistral's, as Vibe 3.0.1 wrote them against a local mock.
for n, api_base in ((5, "http://127.0.0.1:18083/v1"), (6, "https://api.deepseek.com/v1")):
  write_meta(session_root() / f"session_{n}", NOW, 1000 * n, 0, 0, {
    "active_model": "devstral-mock", "models": [{"name": "devstral-2", "provider": "mistral", "alias": "devstral-mock"}],
    "providers": [{"name": "mistral", "api_base": api_base, "api_key_env_var": "MISTRAL_API_KEY", "backend": "mistral"}],
  })
record = vibe()
expect("Vibe resolves the session model and its provider as Vibe does",
       {model: usage["inputTokens"] for model, usage in record["modelUsage"].items()}, {"mistral-medium-3.5": 10, "devstral": 20, "codestral": 40}, record)
local = collect("local", "--force")
expect("Local counts a mistral-backend session on a server you run",
       local["todayTokensByModel"], {"devstral-mock": 5000}, local)

# --------------------------------------------------------- untrusted fields

sandbox()
write_meta(session_root() / "session_bad_time", "not a time", 500, 0, 500)
write_meta(session_root() / "session_future", "2999-01-01T00:00:00+00:00", 500, 0, 500)
write_meta(session_root() / "session_odd_tokens", NOW, "700", True, float("nan"))
write_meta(session_root() / "session_negative", NOW, -5, 0, 7)
(session_root() / "session_not_json").mkdir()
(session_root() / "session_not_json" / "meta.json").write_text("[1, 2")
with contextlib.redirect_stderr(io.StringIO()):
  record = vibe()
expect("Vibe skips bad times and bad token fields without losing the record",
       [record["ready"], record["todayTotalTokens"], record["totalSessions"]], [True, 7, 1], record)

# A meta.json that fails to parse leaves the scan incomplete, so it isn't cached.
check("Vibe does not cache a scan that could not read every session", not scan_cache_files("vibe"),
      ", ".join(path.name for path in scan_cache_files("vibe")))

# --------------------------------------------------------------------- plan

sandbox()
write_json(home() / ".vibe" / "whoami_cache.json", {
  "old": {"stored_at_timestamp": 100, "payload": {"plan_type": "api", "plan_name": "FREE_TRIAL"}},
  "new": {"stored_at_timestamp": 200, "payload": {"plan_type": "chat", "plan_name": "individual"}},
})
record = vibe()
expect("Vibe names the newest cached plan as Vibe does, with no local stats while no session has run",
       [record["ready"], record["tierLabel"], record["hasLocalStats"]], [True, "Pro", False], record)

write_json(home() / ".vibe" / "whoami_cache.json", {"a": {"stored_at_timestamp": 1, "payload": {"plan_type": "chat", "plan_name": "MYSTERY"}}})
record = vibe()
expect("Vibe leaves a plan Vibe cannot name unnamed", [record["ready"], record["tierLabel"]], [False, ""], record)

# ---------------------------------------------------- VIBE_HOME and save_dir

sandbox()
(home() / "vibe-home").mkdir()
(home() / "vibe-home" / "config.toml").write_text(f'[session_logging]\nsave_dir = "{home() / "elsewhere"}"\nsession_prefix = "run"\n')
write_meta(home() / "elsewhere" / "run_1", NOW, 30, 0, 3)
write_meta(home() / "elsewhere" / "session_1", NOW, 999, 0, 999)
os.environ["VIBE_HOME"] = str(home() / "vibe-home")
record = vibe()
del os.environ["VIBE_HOME"]
expect("Vibe honors VIBE_HOME and session_logging in config.toml", record["todayTotalTokens"], 33, record)

# ------------------------------------------------------ pi, omp, opencode

# Only the mistral provider counts, and Mistral's models keep their own names:
# a thinking suffix and a provider prefix come off.
sandbox()
write_pi_session(home() / ".pi" / "agent" / "sessions" / "p" / "a.jsonl", [
  pi_reply("mistral", id="m1", model="mistral-large:high", usage={"input": 6, "output": 1}),
  pi_reply("openrouter", id="m2", model="mistralai/devstral", usage={"input": 999, "output": 999}),
])
opencode_db(tables=("message",), message=[
  ("o1", "ses_1", oc_v1("mistral", {"input": 100, "output": 20, "reasoning": 5, "cache": {"read": 30, "write": 0}}, model="mistral/codestral-latest")),
  ("o2", "ses_1", oc_v1("mistral-proxy", {"input": 999, "output": 999}, model="mistral/codestral-latest")),
])
record = vibe()
expect("Vibe counts pi and opencode messages on the mistral provider under Mistral's model names", record["modelUsage"], {
  "mistral-large": {"inputTokens": 6, "outputTokens": 1, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0},
  "codestral-latest": {"inputTokens": 100, "outputTokens": 25, "cacheReadInputTokens": 30, "cacheCreationInputTokens": 0},
}, record)

# ---------------------------------------------------------------- contract

sandbox()


def add_session():
  add_session.count = getattr(add_session, "count", 0) + 1
  write_meta(session_root() / f"session_grown_{add_session.count}", iso_in(0), 5, 0, 0)


check_scan_cache(Adapter("vibe", grow=add_session, pi_root=lambda: home() / ".pi" / "agent" / "sessions"))

# The per-session index is only an optimization: a session whose meta.json
# changed is read again.
before = vibe()["todayTotalTokens"]
write_meta(session_root() / "session_grown_1", iso_in(0), 50, 0, 0)
record = vibe()
expect("Vibe rereads a session whose meta.json changed", record["todayTotalTokens"] - before, 45, record)
PY
