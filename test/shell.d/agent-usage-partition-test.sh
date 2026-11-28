#!/bin/bash

# Tokens are counted once, under the provider that bills them: pi, omp and
# opencode sessions are split by provider into the matching collector, and
# the `local` collector is the exact complement for self-hosted runtimes. Each
# collector's own test checks its own filter; this one runs every collector
# against one machine holding usage on every provider any of them claims, and
# checks the filters add up to a partition: each provider counted by exactly
# one collector, an unclaimed provider by none, and no copy counted twice.
# Every collector reads those shared sources the same way, so the fixture
# also holds each case where the copies once drifted: forks, compactions, a
# relocated opencode database, a moved pi tree, and a root nested in another.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command rg
require_command timeout

COLLECTOR_TIMEOUT=${AGENT_USAGE_PARTITION_TIMEOUT:-60}
TIMEOUT=$(command -v timeout)

# Every fixture row is today's, and the collectors run as their own processes,
# where no frozen clock reaches. A run that crossed local midnight would see
# its rows land on yesterday, so one that would start that close waits for the
# new day instead.
seconds_to_midnight=$(( $(date -d 'tomorrow 00:00' +%s) - $(date +%s) ))
if (( seconds_to_midnight < 120 )); then
  sleep $(( seconds_to_midnight + 1 ))
fi

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

collectors=()
for collector in "$ROOT"/bin/omarchy-agent-usage-*; do
  [[ ${collector##*/omarchy-agent-usage-} == "update" ]] && continue
  collectors+=("${collector##*/omarchy-agent-usage-}")
done
(( ${#collectors[@]} > 0 )) || fail "agent usage collectors are found under bin/"

# Only what the collectors need to read their sources: Python and rg. No
# agent CLI (codex, gh, omp, secret-tool, mise) can be found, so none is
# spawned, and nothing holds a credential.
mkdir -p "$WORK/bin"
ln -s "$(command -v python3)" "$WORK/bin/python3"
ln -s "$(command -v rg)" "$WORK/bin/rg"

# Each run gets the environment below and nothing else: no API key from the
# developer's shell leaks in, and every HTTP(S) request goes to a proxy on a
# port nothing listens on, so a collector that does reach for the network
# fails at once instead of talking to a real service.
run_collector() {
  local home="$1" id="$2" out="$3" status=0
  shift 3
  env -i \
    HOME="$home" \
    PATH="$WORK/bin" \
    LANG=C.UTF-8 \
    ${TZ+TZ="$TZ"} \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_LANGUAGE_FILE="$OMARCHY_LANGUAGE_FILE" \
    XDG_CONFIG_HOME="$home/.config" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CACHE_HOME="$home/.cache" \
    XDG_RUNTIME_DIR="$home/.run" \
    http_proxy=http://127.0.0.1:9 https_proxy=http://127.0.0.1:9 \
    HTTP_PROXY=http://127.0.0.1:9 HTTPS_PROXY=http://127.0.0.1:9 \
    ALL_PROXY=http://127.0.0.1:9 \
    "$@" \
    "$TIMEOUT" --kill-after=5 "$COLLECTOR_TIMEOUT" "$ROOT/bin/omarchy-agent-usage-$id" --force \
    >"$out.json" 2>"$out.err" || status=$?
  echo "$status" >"$out.status"
}

# Runs every collector against one home, in parallel, into a results dir.
run_all() {
  local home="$1" results="$2" id
  shift 2
  mkdir -p "$results" "$home/.cache" "$home/.run"
  for id in "${collectors[@]}"; do
    run_collector "$home" "$id" "$results/$id" "$@" &
  done
  wait
}

# ------------------------------------------------------------------ fixture

# One machine with usage on every provider id a collector claims, in every
# store pi, omp and opencode keep:
#
# - pi and omp's default session roots, a profiles/<name>/agent/sessions root
#   under each, and a pi tree PI_CODING_AGENT_DIR moves elsewhere, read as
#   well as the default one.
# - A forked pi session repeating its parent's lines with their ids and
#   timestamps, which count once.
# - A pi profile symlinked into the default root, so its sessions sit inside
#   another root: its lines carry no id, so only dropping the nested root
#   keeps them from counting twice.
# - Usage kept only as totalTokens, which still counts, and a line dated at
#   the epoch's zero, which counts nowhere.
# - A compaction's usage, which names no provider and bills the model of the
#   reply before it.
# - opencode's database with rows only in the original `message` store, rows
#   only in the V2 `session_message` store, rows migrated into both under one
#   id (counted once), compactions (counted like replies), thinking tokens
#   (counted as output), a forked session whose copies of its source's
#   messages count nowhere while its own reply does, and a row dated at zero,
#   which counts nowhere either.
# - Codex rollouts on the built-in provider, on `--oss`'s local daemon (a
#   cloud-tagged model and a local one), on a provider named `ollama-cloud`,
#   on LM Studio, and on a custom provider nothing can place.
# - DeepSeek Harness logs on its DeepSeek routes, pi-ai's openrouter route
#   and a hand-declared gateway; Kimchi harness sessions on its gateway,
#   `--provider openrouter` and a custom provider; and MiniMax Code replies
#   on its own route and on custom providers at MiniMax, OpenRouter, Z.ai,
#   this machine, an unplaceable gateway, and one gone from its config.
#
# Every row carries a unique tag (zqNNN) in its model name and a
# recognizable token total, 100 * provider + source, so a collector's
# modelUsage says exactly which rows it counted and how many times.
FIXTURE_HOME="$WORK/home"
mkdir -p "$FIXTURE_HOME"

python3 - "$FIXTURE_HOME" "$WORK/cells.json" <<'PY'
import json
import sqlite3
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
cells_path = Path(sys.argv[2])

# (provider, model stem, api, owner on pi/omp, owner on opencode). An owner of
# None means nobody may count it; "-" means the harness never records it.
#
# - pi's `openai` is an OpenAI API key, which no collector bills; opencode's
#   `openai` is the ChatGPT sign-in the Codex collector reads.
# - pi records an Antigravity sign-in as `google-antigravity`; opencode's
#   Antigravity plugin records a `google` provider (`google`, `google-vertex`)
#   with an `antigravity-` model.
PROVIDERS = [
  ("anthropic", "claude-pt", "", "claude", "claude"),
  ("openai-codex", "gpt-pt", "openai-codex-responses", "codex", "-"),
  ("openai", "gpt-pt", "openai-codex-responses", "codex", "-"),
  ("openai", "gpt-pt", "", "-", "codex"),
  ("opencode", "zen-pt", "", "opencode", "opencode"),
  ("opencode-go", "go-pt", "", "opencode", "opencode"),
  ("ollama-cloud", "cloud-pt", "", "ollama", "ollama"),
  ("ollama", "tagged-pt@:cloud", "", "ollama", "ollama"),
  ("ollama", "tagged-pt@:120b-cloud", "", "ollama", "ollama"),
  ("ollama", "plain-pt@:8b", "", "local", "local"),
  ("lmstudio", "plain-pt", "", "local", "local"),
  ("deepseek", "deepseek-pt", "", "deepseek", "deepseek"),
  ("zai", "glm-pt", "", "zai", "zai"),
  ("zhipu", "glm-pt", "", "zai", "zai"),
  ("minimax", "minimax-pt", "", "minimax", "minimax"),
  ("minimax-cn", "minimax-pt", "", "minimax", "minimax"),
  ("minimax-coding-plan", "minimax-pt", "", "minimax", "minimax"),
  ("minimax-cn-coding-plan", "minimax-pt", "", "minimax", "minimax"),
  ("openrouter", "router-pt", "", "openrouter", "openrouter"),
  ("google-antigravity", "antigravity-pt", "", "agy", "-"),
  ("google", "antigravity-pt", "", "-", "agy"),
  ("google-vertex", "antigravity-pt", "", "-", "agy"),
  ("devin", "devin-pt", "", "devin", "devin"),
  ("synthetic", "synthetic-pt", "", "synthetic", "synthetic"),
  ("mistral", "devstral-pt", "", "vibe", "vibe"),
  ("meta", "muse-spark-pt", "", "muse", "muse"),
  ("alibaba-coding-plan", "qwen-pt", "", "qwen", "qwen"),
  ("alibaba-coding-plan-cn", "qwen-pt", "", "qwen", "qwen"),
  ("alibaba-token-plan", "qwen-pt", "", "qwen", "qwen"),
  ("alibaba-token-plan-cn", "qwen-pt", "", "qwen", "qwen"),
  ("qwen-token-plan", "qwen-pt", "", "qwen", "qwen"),
  ("qwen-token-plan-cn", "qwen-pt", "", "qwen", "qwen"),
  ("qwen-token-plan-individual", "qwen-pt", "", "qwen", "qwen"),
  ("qwen-portal", "qwen-pt", "", "qwen", "qwen"),
  ("kimi-coding", "kimi-pt", "", "kimi", "kimi"),
  ("kimi-code-plan-global", "kimi-pt", "", "kimi", "kimi"),
  ("kimi-code-plan-cn", "kimi-pt", "", "kimi", "kimi"),
  # Moonshot's pay-as-you-go API counts under Kimi, as Claude Code's turns
  # to it do; Alibaba's pay-as-you-go keys carry no plan.
  ("alibaba", "qwen-pt", "", None, None),
  ("moonshotai", "kimi-pt", "", "kimi", "kimi"),
  ("moonshotai-cn", "kimi-pt", "", "kimi", "kimi"),
  ("acme-unclaimed", "acme-pt", "", None, None),
]

PI_SOURCES = [
  ("pi", home / ".pi/agent/sessions/project"),
  ("omp", home / ".omp/agent/sessions/project"),
  ("pi-profile", home / ".pi/profiles/work/agent/sessions/project"),
  ("omp-profile", home / ".omp/profiles/work/agent/sessions/project"),
  # PI_CODING_AGENT_DIR=$HOME/pi-moved on every fixture run.
  ("pi-moved", home / "pi-moved/sessions/project"),
  # ~/.pi/profiles/nest links here, inside the default root.
  ("pi-nested", home / ".pi/agent/sessions/nest-profile/agent/sessions/project"),
  ("omp-total", home / ".omp/agent/sessions/total"),
  ("omp-zero-stamp", home / ".omp/agent/sessions/zero"),
  ("pi-compaction", home / ".pi/agent/sessions/compacted"),
]
OC_SOURCES = ["opencode-message", "opencode-session_message", "opencode-migrated", "opencode-compaction",
              "opencode-reasoning", "opencode-fork-copy", "opencode-fork-reply", "opencode-zero-stamp",
              "opencode-message-fork-copy", "opencode-message-fork-reply"]

now = datetime.now(timezone.utc)
stamp = now.isoformat(timespec="milliseconds").replace("+00:00", "Z")
now_ms = int(time.time() * 1000) - 1000
# The forked session began a minute ago: its copies of the source session's
# messages predate it, its own reply doesn't.
fork_ms = now_ms - 60_000

cells = []
lines = {name: [] for name, _ in PI_SOURCES}
message_rows, session_rows = [], []


def model_for(stem, tag):
  # A stem of "name@:tag" keeps the Ollama tag after the unique marker, so a
  # collector that strips tags still sees which row it counted.
  base, _, suffix = stem.partition("@")
  return f"{base}-{tag}{suffix}"


for p, (provider, stem, api, pi_owner, oc_owner) in enumerate(PROVIDERS, 1):
  for s, (source, _) in enumerate(PI_SOURCES, 1):
    if pi_owner == "-":
      continue
    tag = f"zq{len(cells):03d}"
    tokens = 100 * p + s
    usage = {"input": tokens, "output": 0, "cacheRead": 0, "cacheWrite": 0}
    if source == "omp-total":
      usage = {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0, "totalTokens": tokens}
    message = {"role": "assistant", "provider": provider, "model": model_for(stem, tag), "usage": usage}
    if api:
      message["api"] = api
    line = {"type": "message", "id": f"{source}-{tag}", "timestamp": 0 if source == "omp-zero-stamp" else stamp, "message": message}
    if source == "pi-nested":
      del line["id"]
    if source == "pi-compaction":
      # A compaction names no provider: it ran on the model of the reply
      # before it, here one that spent nothing itself.
      lines[source].append({**line, "id": f"{source}-{tag}-reply", "message": {**message, "usage": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0}}})
      line = {"type": "compaction", "id": f"{source}-{tag}", "timestamp": stamp, "summary": "s", "firstKeptEntryId": "x", "tokensBefore": tokens, "usage": usage}
    lines[source].append(line)
    owner = None if source == "omp-zero-stamp" else pi_owner
    cells.append({"tag": tag, "provider": provider, "api": api, "source": source, "tokens": tokens, "owner": owner})
  for s, source in enumerate(OC_SOURCES, len(PI_SOURCES) + 1):
    if oc_owner == "-":
      continue
    tag = f"zq{len(cells):03d}"
    tokens = 100 * p + s
    model = model_for(stem, tag)
    counts = {"input": tokens, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}}
    if source == "opencode-reasoning":
      counts = {"input": tokens - 7, "output": 0, "reasoning": 7, "cache": {"read": 0, "write": 0}}
    created = 0 if source == "opencode-zero-stamp" else now_ms
    v1 = json.dumps({"role": "assistant", "providerID": provider, "modelID": model, "tokens": counts, "time": {"created": created}})
    v2 = json.dumps({"model": {"providerID": provider, "id": model}, "tokens": counts, "time": {"created": now_ms}})
    message_id = f"msg_{tag}"
    if source in ("opencode-message", "opencode-migrated", "opencode-reasoning", "opencode-zero-stamp"):
      message_rows.append((message_id, f"ses_{source}", now_ms, now_ms, v1))
    if source in ("opencode-session_message", "opencode-migrated"):
      session_rows.append((message_id, f"ses_{source}", "assistant", now_ms, v2))
    if source == "opencode-compaction":
      session_rows.append((message_id, f"ses_{source}", "compaction", now_ms, v2))
    if source == "opencode-fork-copy":
      session_rows.append((message_id, "ses_fork", "assistant", fork_ms - 5_000, v2))
    if source == "opencode-fork-reply":
      session_rows.append((message_id, "ses_fork", "assistant", now_ms, v2))
    if source == "opencode-message-fork-copy":
      # As opencode 1.19.3's `run --fork` writes one into the original store:
      # a plain new session, the copy under a new id, its time the source's.
      message_rows.append((message_id, "ses_message_fork", now_ms, now_ms, json.dumps({**json.loads(v1), "time": {"created": fork_ms - 5_000}})))
    if source == "opencode-message-fork-reply":
      message_rows.append((message_id, "ses_message_fork", now_ms, now_ms, v1))
    owner = None if source in ("opencode-fork-copy", "opencode-zero-stamp", "opencode-message-fork-copy") else oc_owner
    cells.append({"tag": tag, "provider": provider, "api": "", "source": source, "tokens": tokens, "owner": owner})

for source, directory in PI_SOURCES:
  directory.mkdir(parents=True, exist_ok=True)
  with (directory / "session.jsonl").open("w") as handle:
    for line in lines[source]:
      handle.write(json.dumps(line) + "\n")

# A fork of the default pi session, in another project: its parent's lines
# again, under the same ids and timestamps.
fork = home / ".pi/agent/sessions/forked"
fork.mkdir(parents=True)
with (fork / "session.jsonl").open("w") as handle:
  for line in lines["pi"]:
    handle.write(json.dumps(line) + "\n")

# Relative, so a copy of this home keeps pointing into itself.
(home / ".pi/profiles/nest").symlink_to("../agent/sessions/nest-profile")

# The schema the opencode collector's own tests build: the original store and
# the V2 one side by side, as a database opencode has migrated looks.
db = home / ".local/share/opencode/opencode.db"
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.execute("CREATE TABLE session_message (id text PRIMARY KEY, session_id text NOT NULL, type text NOT NULL, time_created integer NOT NULL, data text NOT NULL)")
conn.execute("CREATE TABLE session_v2 (id text PRIMARY KEY, fork_session_id text, time_created integer NOT NULL)")
conn.execute("INSERT INTO session_v2 VALUES ('ses_fork', 'ses_opencode-session_message', ?)", (fork_ms,))
conn.execute("CREATE TABLE session (id text PRIMARY KEY, parent_id text, title text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL)")
conn.execute("INSERT INTO session VALUES ('ses_message_fork', NULL, 'Mock reply (fork #1)', ?, ?)", (fork_ms, fork_ms))
conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", message_rows)
conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?)", session_rows)
conn.commit()
conn.close()


# Codex rollouts, as Codex 0.163 writes them: the built-in `openai` provider
# is the Codex collector's, `--oss` on the local daemon's `ollama` provider is
# the local collector's unless the model is cloud-tagged (Ollama Cloud's), a
# provider named `ollama-cloud` is Ollama Cloud's, LM Studio is local, and a
# custom provider nothing can place is nobody's.
CODEX_ROLLOUTS = [
  ("openai", "gpt-codex@", "codex"),
  ("ollama", "gpt-oss@:120b-cloud", "ollama"),
  ("ollama-cloud", "qwen-codex@", "ollama"),
  ("ollama", "plain-codex@:20b", "local"),
  ("lmstudio", "plain-codex@", "local"),
  ("acme-unclaimed", "acme-codex@", None),
]
rollouts = home / ".codex/sessions" / datetime.now().strftime("%Y/%m/%d")
rollouts.mkdir(parents=True)
for n, (provider, stem, owner) in enumerate(CODEX_ROLLOUTS):
  tag = f"zq{len(cells):03d}"
  tokens = 80000 + 100 * n
  base, _, suffix = stem.partition("@")
  lines = [
    {"timestamp": stamp, "type": "session_meta", "payload": {"model_provider": provider}},
    {"timestamp": stamp, "type": "turn_context", "payload": {"model": f"{base}-{tag}{suffix}"}},
    {"timestamp": stamp, "type": "event_msg", "payload": {"type": "user_message", "message": "go"}},
    {"timestamp": stamp, "type": "event_msg", "payload": {"type": "token_count", "info": {
      "last_token_usage": {"input_tokens": tokens, "output_tokens": 0}, "total_token_usage": {"input_tokens": tokens}}}},
  ]
  (rollouts / f"rollout-{tag}.jsonl").write_text("".join(json.dumps(line) + "\n" for line in lines))
  cells.append({"tag": tag, "provider": provider, "api": "", "source": "codex-rollout", "tokens": tokens, "owner": owner})


# DeepSeek Harness session logs, one per route, as dsh 0.2 writes them (left
# uncompressed): its DeepSeek routes and pi-ai's `deepseek` are DeepSeek's,
# pi-ai's `openrouter` OpenRouter's, and a hand-declared gateway nobody's.
DSH_ROUTES = [
  ("deepseek-official", "deepseek-dsh@", "deepseek"),
  ("deepseek", "deepseek-piai@", "deepseek"),
  ("openrouter", "router-dsh@", "openrouter"),
  ("acme-gateway", "acme-dsh@", None),
]
for n, (provider, stem, owner) in enumerate(DSH_ROUTES):
  tag = f"zq{len(cells):03d}"
  tokens = 81000 + 100 * n
  log = home / f".dsh/sessions/--home-me--/session-{tag}/session.v4.jsonl"
  log.parent.mkdir(parents=True)
  log.write_text("".join(json.dumps(record) + "\n" for record in (
    {"type": "session", "version": 4, "id": f"dsh-{tag}", "createdAt": now_ms, "isSeeded": False},
    {"type": "request/header", "seq": 1, "time": now_ms, "data": {"header": {"config": {"provider": provider, "model": model_for(stem, tag)}}}},
    {"type": "assistant/message", "seq": 2, "time": now_ms, "data": {"turn": 1, "step": 1, "usage": {"inputTokens": tokens}}},
  )))
  cells.append({"tag": tag, "provider": provider, "api": "", "source": "dsh", "tokens": tokens, "owner": owner})

# Kimchi's harness sessions, in pi's format: its own gateway routes are
# Kimchi's, a session run with `--provider openrouter` OpenRouter's, and one
# on a custom provider nobody's.
kimchi_lines = []
for n, (provider, stem, owner) in enumerate([
  ("kimchi-dev/zai", "glm-kimchi@", "kimchi"),
  ("openrouter", "router-kimchi@", "openrouter"),
  ("my-gateway", "acme-kimchi@", None),
]):
  tag = f"zq{len(cells):03d}"
  tokens = 82000 + 100 * n
  kimchi_lines.append({"type": "message", "id": f"kimchi-{tag}", "timestamp": stamp,
                       "message": {"role": "assistant", "provider": provider, "model": model_for(stem, tag), "usage": {"input": tokens}}})
  cells.append({"tag": tag, "provider": provider, "api": "", "source": "kimchi-harness", "tokens": tokens, "owner": owner})
kimchi_sessions = home / ".config/kimchi/harness/sessions/--home-me--"
kimchi_sessions.mkdir(parents=True)
(kimchi_sessions / "session.jsonl").write_text("".join(json.dumps(line) + "\n" for line in kimchi_lines))

# MiniMax Code sessions, one per route, and the custom providers its
# config.yaml declares: its own routes are MiniMax's, a custom provider
# whatever its baseURL's host bills (MiniMax, OpenRouter, Z.ai, this
# machine), and one at a gateway nothing can place, or gone from the config,
# nobody's.
MCODE_ROUTES = [
  ("minimax", "MiniMax-mcode@", "minimax"),
  ("custom_provider:mm", "MiniMax-custom@", "minimax"),
  ("custom_provider:router", "router-mcode@", "openrouter"),
  ("custom_provider:zed", "glm-mcode@", "zai"),
  ("custom_provider:box", "plain-mcode@", "local"),
  ("custom_provider:acme", "acme-mcode@", None),
  ("custom_provider:gone", "acme-gone@", None),
]
(home / ".minimax").mkdir()
(home / ".minimax/config.yaml").write_text("""logLevel: info
custom_provider:
  mm:
    name: mm
    kind: custom
    options:
      apiKey: sk-placeholder
      baseURL: https://api.minimax.io/anthropic
  router:
    name: router
    api: openai-completions
    options:
      apiKey: sk-placeholder
      baseURL: https://openrouter.ai/api/v1
  zed:
    options:
      baseURL: "https://api.z.ai/api/coding/paas/v4"
  box:
    options:
      baseURL: http://127.0.0.1:8080/v1 # llama.cpp
  acme:
    options:
      baseURL: https://llm.acme.example/v1
""")
for n, (provider, stem, owner) in enumerate(MCODE_ROUTES):
  tag = f"zq{len(cells):03d}"
  tokens = 83000 + 100 * n
  session = home / f".minimax/v2/sessions/2026/01/01/{tag}/messages.jsonl"
  session.parent.mkdir(parents=True)
  session.write_text("".join(json.dumps(line) + "\n" for line in (
    {"message": {"role": "user", "timestamp": now_ms, "content": "go"}},
    {"message": {"role": "assistant", "timestamp": now_ms, "provider": provider, "model": model_for(stem, tag), "usage": {"input": tokens}}},
  )))
  cells.append({"tag": tag, "provider": provider, "api": "", "source": "mcode", "tokens": tokens, "owner": owner})


# Codex 0.163 rollouts with a remote compaction, as it writes one: a
# token_usage_record for every response, the compaction's included, where the
# token_count after the compaction spends nothing and the next one counts only
# the reply. A record repeated under the same id and running total is one
# response.
CODEX_RECORD_ROLLOUTS = [
  ("openai", "gpt-record@", "codex"),
  ("ollama-cloud", "qwen-record@", "ollama"),
  ("lmstudio", "plain-record@", "local"),
]
for n, (provider, stem, owner) in enumerate(CODEX_RECORD_ROLLOUTS):
  tag = f"zq{len(cells):03d}"
  compaction, reply = 84000 + 100 * n, 1000 + n
  first = {"input_tokens": compaction, "output_tokens": 0}
  thread = {"input_tokens": compaction + reply, "output_tokens": 0}
  usage_record = {"timestamp": stamp, "type": "token_usage_record", "payload": {
    "turn_id": "turn-1", "response_id": "resp_mock_0002", "usage": {"input_tokens": reply, "output_tokens": 0}, "thread_token_usage": thread}}
  lines = [
    {"timestamp": stamp, "type": "session_meta", "payload": {"model_provider": provider, "source": "exec"}},
    {"timestamp": stamp, "type": "turn_context", "payload": {"model": model_for(stem, tag)}},
    {"timestamp": stamp, "type": "token_usage_record", "payload": {
      "turn_id": "turn-1", "response_id": "resp_mock_0001", "usage": first, "thread_token_usage": first}},
    {"timestamp": stamp, "type": "compacted", "payload": {"message": ""}},
    {"timestamp": stamp, "type": "event_msg", "payload": {"type": "token_count", "info": {
      "last_token_usage": {"input_tokens": 0, "output_tokens": 0}, "total_token_usage": {}}}},
    {"timestamp": stamp, "type": "event_msg", "payload": {"type": "item_completed", "item": {"type": "UserMessage", "id": "u1", "content": []}}},
    usage_record,
    {"timestamp": stamp, "type": "event_msg", "payload": {"type": "token_count", "info": {
      "last_token_usage": {"input_tokens": reply, "output_tokens": 0}, "total_token_usage": {"input_tokens": reply, "output_tokens": 0}}}},
    usage_record,
  ]
  (rollouts / f"rollout-{tag}.jsonl").write_text("".join(json.dumps(line) + "\n" for line in lines))
  cells.append({"tag": tag, "provider": provider, "api": "", "source": "codex-record-rollout", "tokens": compaction + reply, "owner": owner})

cells_path.write_text(json.dumps(cells))
PY

EMPTY_HOME="$WORK/empty"
mkdir -p "$EMPTY_HOME"

# The empty home runs in a zone whose day differs from the system zone's, so
# a collector dating its record by /etc/localtime rather than the caller's TZ
# shows. +14 and -12 hours are never both on the system's day; the days on
# either side of the run cover one that straddles that zone's midnight.
EMPTY_TZ=Pacific/Kiritimati
if [[ $(TZ=$EMPTY_TZ date +%F) == "$(env -u TZ date +%F)" ]]; then
  EMPTY_TZ=Etc/GMT+12
fi
TZ=$EMPTY_TZ date +%F >"$WORK/empty-days"
TZ=$EMPTY_TZ run_all "$EMPTY_HOME" "$WORK/empty-results"
TZ=$EMPTY_TZ date +%F >>"$WORK/empty-days"
run_all "$FIXTURE_HOME" "$WORK/results" PI_CODING_AGENT_DIR="$FIXTURE_HOME/pi-moved"

# The same machine with opencode's database moved by OPENCODE_DB. A relative
# name resolves beside the default one, as opencode itself resolves it.
RELOCATED_HOME="$WORK/relocated"
cp -a "$FIXTURE_HOME" "$RELOCATED_HOME"
rm -rf "$RELOCATED_HOME/.cache"
mkdir -p "$RELOCATED_HOME/.local/share/opencode/moved"
mv "$RELOCATED_HOME/.local/share/opencode/opencode.db" "$RELOCATED_HOME/.local/share/opencode/moved/elsewhere.db"
run_all "$RELOCATED_HOME" "$WORK/relocated-results" PI_CODING_AGENT_DIR="$RELOCATED_HOME/pi-moved" OPENCODE_DB=moved/elsewhere.db

# A local.json naming every claimed provider (and a self-hosted box of its
# own) must not pull any of them into the local collector. Fireworks counts
# its whole account rather than these rows, so no cell owns its pi turns, but
# naming fireworks or fireworks-ai in local.json must not count them twice.
CONFIGURED_HOME="$WORK/configured"
cp -a "$FIXTURE_HOME" "$CONFIGURED_HOME"
rm -rf "$CONFIGURED_HOME/.cache"
mkdir -p "$CONFIGURED_HOME/.config/omarchy/agents" "$CONFIGURED_HOME/.pi/agent/sessions/fireworks"
python3 - "$WORK/cells.json" "$CONFIGURED_HOME/.config/omarchy/agents/local.json" "$CONFIGURED_HOME/.pi/agent/sessions/fireworks/session.jsonl" <<'PY'
import json
import sys
from datetime import datetime, timezone

cells = json.load(open(sys.argv[1]))
providers = sorted({cell["provider"] for cell in cells if cell["owner"] and cell["owner"] != "local"} | {"fireworks", "fireworks-ai"})
json.dump({"providers": providers}, open(sys.argv[2], "w"))
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
with open(sys.argv[3], "w") as handle:
  for provider in ("fireworks", "fireworks-ai"):
    message = {"role": "assistant", "provider": provider, "model": f"{provider}-account-pt", "usage": {"input": 77, "output": 0, "cacheRead": 0, "cacheWrite": 0}}
    handle.write(json.dumps({"type": "message", "id": f"fw-{provider}", "timestamp": stamp, "message": message}) + "\n")
PY
mkdir -p "$CONFIGURED_HOME/.cache" "$CONFIGURED_HOME/.run"
run_collector "$CONFIGURED_HOME" local "$WORK/configured-local" PI_CODING_AGENT_DIR="$CONFIGURED_HOME/pi-moved"

# OpenRouter reads no local usage at all without a key, so the keyless run
# above can only show it missing everything. A placeholder key, with every
# request going to the dead proxy, shows what its own filter counts.
run_collector "$FIXTURE_HOME" openrouter "$WORK/keyed-openrouter" OPENROUTER_API_KEY=sk-or-placeholder PI_CODING_AGENT_DIR="$FIXTURE_HOME/pi-moved"


# Claude Code fronts whatever ANTHROPIC_BASE_URL names, and its transcripts
# record only the model that answered each reply. One home holds a reply by
# each kind of model (and a fork's copy of one), and every collector runs
# against it once per endpoint Claude Code can be sent to; each reply must
# land in exactly the collector that bills it there, or in none.
CLAUDE_HOME="$WORK/claude-code"
mkdir -p "$CLAUDE_HOME"
python3 - "$CLAUDE_HOME" "$WORK/claude-cells.json" "$WORK/claude-endpoints" <<'PY'
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
# (model, owner with no endpoint, owner behind a self-hosted one, owner
# behind a gateway nothing can place). A provider's own host owns them all.
MODELS = [
  ("claude-sonnet-zq900", "claude", "claude", "claude"),
  ("glm-zq901", "zai", "local", None),
  ("MiniMax-zq902", "minimax", "local", None),
  ("deepseek-zq903", "deepseek", "local", None),
  ("kimi-zq904", "kimi", "local", None),
  ("moonshot-zq905", "kimi", "local", None),
  ("gpt-oss-zq906:120b-cloud", "ollama", "ollama", "ollama"),
  ("qwen3-zq907", None, "local", None),
]
ENDPOINTS = {
  "": 1, "https://api.z.ai/api/anthropic": "zai", "https://ollama.com": "ollama", "https://openrouter.ai/api": "openrouter",
  "https://api.minimax.io/anthropic": "minimax", "https://api.deepseek.com/anthropic": "deepseek",
  "https://api.kimi.com/coding/": "kimi", "http://localhost:11434": 2, "https://llm-proxy.example.com/anthropic": 3,
}
projects = home / ".claude/projects/project"
projects.mkdir(parents=True)
lines, cells = [], []
for n, (model, *owners) in enumerate(MODELS):
  tokens = 90000 + 100 * n
  lines.append({"type": "user", "uuid": f"prompt-{n}", "sessionId": "main", "timestamp": stamp, "message": {"role": "user", "content": "go"}})
  lines.append({"type": "assistant", "sessionId": "main", "timestamp": stamp, "requestId": f"req-{n}",
                "message": {"id": f"msg-{n}", "role": "assistant", "model": model, "usage": {"input_tokens": tokens, "output_tokens": 0}}})
  for index, (url, owner) in enumerate(ENDPOINTS.items()):
    cells.append({"endpoint": index, "url": url, "tag": re.search(r"zq\d{3}", model).group(0), "model": model, "tokens": tokens,
                  "owner": owners[owner - 1] if isinstance(owner, int) else owner})
(projects / "main.jsonl").write_text("".join(json.dumps(line) + "\n" for line in lines))
# A fork copies the first reply into a session of its own.
(projects / "fork.jsonl").write_text(json.dumps({**lines[1], "sessionId": "fork"}) + "\n")
Path(sys.argv[2]).write_text(json.dumps(cells))
Path(sys.argv[3]).write_text("".join(url + "\n" for url in ENDPOINTS))
PY
mapfile -t claude_endpoints <"$WORK/claude-endpoints"
for endpoint in "${!claude_endpoints[@]}"; do
  url=${claude_endpoints[endpoint]}
  if [[ -n $url ]]; then
    run_all "$CLAUDE_HOME" "$WORK/claude-results-$endpoint" ANTHROPIC_BASE_URL="$url"
  else
    run_all "$CLAUDE_HOME" "$WORK/claude-results-$endpoint"
  fi
done

# ----------------------------------------------------------------- analysis

python3 - "$WORK" "${collectors[@]}" >"$WORK/report.tsv" <<'PY'
import json
import re
import sys
from pathlib import Path

work = Path(sys.argv[1])
collectors = sys.argv[2:]
cells = {cell["tag"]: cell for cell in json.load(open(work / "cells.json"))}
empty_days = set((work / "empty-days").read_text().split())

STATS = ["todayPrompts", "todaySessions", "todayTotalTokens", "todayTokensByModel", "recentDays",
         "totalPrompts", "totalSessions", "activeDays", "activeDates", "modelUsage"]
# The fields every record carries, per the contract's record table and the
# reference collector. retryAdvised, hasPromptStats, scope, balance and
# accounts are conditional and checked only for shape when present.
REQUIRED = ["schemaVersion", "id", "name", "updatedAt", "ready", "tierLabel", "usageStatusText",
            "authHelpText", "limits", "limitsStale", "limitsFetchedAt", "hasLocalStats"] + STATS
BUCKET = ["inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens"]

results = []


def report(check, ok, detail=""):
  results.append((check, ok, detail))


def load(prefix):
  status = (work / f"{prefix}.status").read_text().strip()
  raw = (work / f"{prefix}.json").read_text()
  err = (work / f"{prefix}.err").read_text().strip()
  if status != "0":
    return None, f"exited {status}{' (timed out)' if status in ('124', '137') else ''}: {err[-400:]}"
  try:
    record = json.loads(raw)
  except ValueError:
    return None, f"printed no JSON record: {raw[:200]!r} {err[-200:]}"
  if not isinstance(record, dict):
    return None, f"printed a non-object: {raw[:200]!r}"
  return record, ""


def shape_problems(cid, record):
  problems = [f"missing {key}" for key in REQUIRED if key not in record]
  if record.get("schemaVersion") != 1:
    problems.append(f"schemaVersion {record.get('schemaVersion')!r}")
  if record.get("id") != cid:
    problems.append(f"id {record.get('id')!r}")
  for key in ("ready", "limitsStale", "hasLocalStats"):
    if key in record and not isinstance(record[key], bool):
      problems.append(f"{key} is not a boolean")
  for key in ("retryAdvised", "hasPromptStats"):
    if key in record and not isinstance(record[key], bool):
      problems.append(f"{key} is not a boolean")
  if "scope" in record and record["scope"] != "account":
    problems.append(f"scope {record['scope']!r}")
  for key in ("name", "updatedAt", "tierLabel", "usageStatusText", "authHelpText"):
    if key in record and not isinstance(record[key], str):
      problems.append(f"{key} is not a string")
  if "limits" in record and not isinstance(record["limits"], list):
    problems.append("limits is not a list")
  if "recentDays" in record and (not isinstance(record["recentDays"], list) or len(record["recentDays"]) != 7):
    problems.append("recentDays is not seven days")
  if "modelUsage" in record and isinstance(record["modelUsage"], dict):
    for model, bucket in record["modelUsage"].items():
      if not isinstance(bucket, dict) or any(key not in bucket for key in BUCKET):
        problems.append(f"modelUsage[{model}] lacks the token buckets")
  elif "modelUsage" in record:
    problems.append("modelUsage is not an object")
  return problems


# 1. Every collector in an empty home: the unused-machine record.
for cid in collectors:
  record, error = load(f"empty-results/{cid}")
  if record is None:
    report("empty-home", False, f"{cid}: {error}")
    continue
  problems = shape_problems(cid, record)
  if record.get("ready") is not False:
    problems.append(f"ready {record.get('ready')!r}")
  if record.get("usageStatusText") != "":
    problems.append(f"usageStatusText {record.get('usageStatusText')!r} (authHelpText {record.get('authHelpText')!r})")
  elif record.get("authHelpText") != "":
    problems.append(f"authHelpText {record.get('authHelpText')!r} with no status")
  if record.get("limits"):
    problems.append("limits not empty")
  if record.get("tierLabel") != "":
    problems.append(f"tierLabel {record.get('tierLabel')!r}")
  if "balance" in record:
    problems.append("has a balance")
  if any(record.get(key) for key in ("todayPrompts", "todaySessions", "todayTotalTokens", "totalPrompts", "totalSessions", "activeDays")) \
      or record.get("todayTokensByModel") or record.get("modelUsage") or record.get("activeDates"):
    problems.append("stats not empty")
  if record.get("retryAdvised"):
    problems.append("retryAdvised with nothing to retry")
  days = record.get("recentDays") or [{}]
  if days[-1].get("date") not in empty_days:
    problems.append(f"recentDays ends {days[-1].get('date')!r}, not the caller's TZ day ({', '.join(sorted(empty_days))})")
  report("empty-home", not problems, f"{cid}: {'; '.join(problems)}" if problems else cid)


def counted(record):
  """tag -> tokens a record counted for that fixture row, and keys matching none."""
  per_tag, strays = {}, []
  for model, bucket in (record.get("modelUsage") or {}).items():
    total = sum(bucket.get(key) or 0 for key in BUCKET) if isinstance(bucket, dict) else 0
    tags = re.findall(r"zq\d{3}", model)
    if len(tags) != 1 or tags[0] not in cells:
      if total:
        strays.append(f"{model}={total}")
      continue
    per_tag[tags[0]] = per_tag.get(tags[0], 0) + total
  return per_tag, strays


# 2. The partition.
counts = {tag: {} for tag in cells}
collector_totals = {}
fixture_counts = {}
for cid in collectors:
  record, error = load(f"results/{cid}")
  if record is None:
    report("fixture-run", False, f"{cid}: {error}")
    continue
  problems = shape_problems(cid, record)
  report("fixture-shape", not problems, f"{cid}: {'; '.join(problems)}" if problems else cid)
  per_tag, strays = counted(record)
  fixture_counts[cid] = per_tag
  for tag, total in per_tag.items():
    counts[tag][cid] = total
  if strays:
    report("attribution", False, f"{cid}: modelUsage keys that name no fixture row: {', '.join(strays)}")
  today = record.get("todayTotalTokens") or 0
  collector_totals[cid] = today
  model_sum = sum(per_tag.values())
  if today != model_sum:
    report("today-matches-models", False, f"{cid}: todayTotalTokens {today} but modelUsage over fixture rows sums to {model_sum}")
  else:
    report("today-matches-models", True, cid)

claimed_total = 0
for tag, cell in sorted(cells.items()):
  owner, tokens = cell["owner"], cell["tokens"]
  label = f"{cell['provider']}{' api=' + cell['api'] if cell['api'] else ''} via {cell['source']} ({tag}, {tokens} tokens)"
  seen = counts[tag]
  if owner:
    claimed_total += tokens
  wrong = []
  for cid, total in sorted(seen.items()):
    times = total / tokens
    if cid != owner:
      wrong.append(f"{cid} counted it" + (f" {times:g}x" if times != 1 else ""))
    elif total != tokens:
      wrong.append(f"{cid} counted it {times:g}x")
  if owner is None:
    report("unclaimed", not wrong, f"{label}: {'; '.join(wrong)}" if wrong else label)
    continue
  if owner not in seen:
    wrong.insert(0, f"{owner} missed it")
  report("partition", not wrong, f"{label}, expected {owner}: {'; '.join(wrong)}" if wrong else label)

grand = sum(collector_totals.values())
report("sum", grand == claimed_total, f"claimed providers total {claimed_total}, collectors' todayTotalTokens sum to {grand}"
       + "".join(f"\n    {cid}={total}" for cid, total in sorted(collector_totals.items()) if total))

# 3. The database moved by OPENCODE_DB counts exactly the rows it did in place.
for cid in collectors:
  record, error = load(f"relocated-results/{cid}")
  if record is None:
    report("opencode-db-env", False, f"{cid}: {error}")
    continue
  if cid not in fixture_counts:
    continue
  per_tag, _ = counted(record)
  before = fixture_counts[cid]
  changed = []
  for tag in sorted(set(per_tag) | set(before)):
    if per_tag.get(tag, 0) != before.get(tag, 0):
      cell = cells[tag]
      changed.append(f"{cell['provider']} via {cell['source']} ({tag}) {before.get(tag, 0)} -> {per_tag.get(tag, 0)}")
  report("opencode-db-env", not changed, f"{cid}: {'; '.join(changed)}" if changed else cid)

# 4. A local.json naming every claimed provider.
record, error = load("configured-local")
if record is None:
  report("local-config", False, f"local: {error}")
else:
  per_tag, strays = counted(record)
  leaked = sorted({f"{cells[tag]['provider']}" for tag in per_tag if cells[tag]["owner"] != "local"} |
                  {stray.partition("-account-pt=")[0] for stray in strays if "-account-pt=" in stray})
  missed = sorted({cells[tag]["provider"] + " via " + cells[tag]["source"] for tag in cells if cells[tag]["owner"] == "local" and tag not in per_tag})
  problems = ([f"counts claimed providers it was configured with: {', '.join(leaked)}"] if leaked else []) + \
             ([f"missed {', '.join(missed)}"] if missed else [])
  report("local-config", not problems, f"local: {'; '.join(problems)}" if problems else "local")

# 5. OpenRouter with a key: its own filter, once each, and nothing else.
record, error = load("keyed-openrouter")
if record is None:
  report("openrouter-keyed", False, f"openrouter: {error}")
else:
  per_tag, strays = counted(record)
  problems = [f"stray {', '.join(strays)}"] if strays else []
  for tag, cell in sorted(cells.items()):
    total = per_tag.get(tag, 0)
    label = f"{cell['provider']} via {cell['source']} ({tag})"
    if cell["owner"] == "openrouter" and total != cell["tokens"]:
      problems.append(f"{label} counted {total / cell['tokens']:g}x")
    elif cell["owner"] != "openrouter" and total:
      problems.append(f"{label} counted, owned by {cell['owner']}")
  report("openrouter-keyed", not problems, f"openrouter: {'; '.join(problems)}" if problems else "openrouter")

# 6. Claude Code's replies, behind every endpoint it can be sent to.
claude_cells = json.load(open(work / "claude-cells.json"))
for endpoint in sorted({cell["endpoint"] for cell in claude_cells}):
  cells_here = {cell["tag"]: cell for cell in claude_cells if cell["endpoint"] == endpoint}
  url = next(iter(cells_here.values()))["url"] or "Anthropic (no ANTHROPIC_BASE_URL)"
  seen = {tag: {} for tag in cells_here}
  for cid in collectors:
    record, error = load(f"claude-results-{endpoint}/{cid}")
    if record is None:
      report("claude-code", False, f"{url}: {cid}: {error}")
      continue
    for model, bucket in (record.get("modelUsage") or {}).items():
      total = sum(bucket.get(key) or 0 for key in BUCKET) if isinstance(bucket, dict) else 0
      for tag in re.findall(r"zq\d{3}", model):
        if tag in seen and total:
          seen[tag][cid] = seen[tag].get(cid, 0) + total
  for tag, cell in sorted(cells_here.items()):
    owner, tokens = cell["owner"], cell["tokens"]
    wrong = [f"{cid} counted it {total / tokens:g}x" for cid, total in sorted(seen[tag].items()) if cid != owner or total != tokens]
    if owner and owner not in seen[tag]:
      wrong.insert(0, f"{owner} missed it")
    label = f"{cell['model']} sent to {url}, expected {owner or 'nobody'}"
    report("claude-code", not wrong, f"{label}: {'; '.join(wrong)}" if wrong else label)

for check, ok, detail in results:
  print(f"{check}\t{'ok' if ok else 'fail'}\t{detail}".replace("\n", "\\n"))
PY

# ------------------------------------------------------------------ verdict

declare -A DESCRIPTIONS=(
  [empty-home]="every collector prints the unused-machine record in an empty home: ready false, no plan, status or help, no limits, no balance, empty stats, the full field set, dated by the caller's TZ"
  [fixture-run]="every collector prints a record against the fixture home, offline and in time"
  [fixture-shape]="every collector's fixture record has the contract's full field set"
  [attribution]="every token a collector counts comes from a fixture row"
  [today-matches-models]="each collector's todayTotalTokens equals the fixture rows in its modelUsage"
  [partition]="each claimed provider's tokens are counted by exactly its collector, once, from every root and store, forks and nesting included"
  [unclaimed]="a provider no collector claims, a fork's copies of its source's messages, and rows dated at zero are counted by nobody"
  [sum]="the claimed providers' tokens equal the collectors' todayTotalTokens summed"
  [opencode-db-env]="with opencode's database moved by a relative OPENCODE_DB, every collector counts the same rows"
  [local-config]="a local.json naming claimed providers doesn't pull them into the local collector"
  [openrouter-keyed]="with a key, the OpenRouter collector counts exactly the OpenRouter rows, once each"
  [claude-code]="each Claude Code reply is counted once, by the collector that bills it behind every endpoint Claude Code can be sent to, or by none"
)
order=(empty-home fixture-run fixture-shape attribution today-matches-models partition unclaimed sum opencode-db-env local-config openrouter-keyed claude-code)

failed=()
details=""
for check in "${order[@]}"; do
  lines=$(awk -F'\t' -v c="$check" '$1 == c && $2 == "fail" { print "  " $3 }' "$WORK/report.tsv")
  if [[ -z $lines ]]; then
    pass "${DESCRIPTIONS[$check]}"
  else
    failed+=("$check")
    details+="${DESCRIPTIONS[$check]}:"$'\n'"${lines//\\n/$'\n'}"$'\n'
  fi
done

if (( ${#failed[@]} > 0 )); then
  fail "agent usage collectors partition tokens by provider (failing: ${failed[*]})" "$details"
fi

# ------------------------------------------------------- harness provider ids

# pi, omp and opencode each name a plan's provider their own way, so a plan
# a collector meters can reach it under several ids. One home holds a reply
# on each id below, written as pi 1.4.0, omp 18.12.6 and opencode 1.19.3
# wrote them for that provider, and each must be counted once, by its owner
# (Moonshot's pay-as-you-go API by Kimi).
IDS_HOME="$WORK/provider-ids"
mkdir -p "$IDS_HOME"
python3 - "$IDS_HOME" "$WORK/ids-cells.json" <<'PY'
import json
import sqlite3
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
now_ms = int(time.time() * 1000) - 1000
# (harness, provider, owner)
IDS = [
  ("pi", "zai-coding-cn", "zai"),
  ("omp", "zhipu-coding-plan", "zai"),
  ("omp", "kimi-code", "kimi"),
  ("omp", "muse-code", "muse"),
  ("omp", "moonshot", "kimi"),
  ("opencode", "zai-coding-plan", "zai"),
  ("opencode", "zhipuai-coding-plan", "zai"),
  ("opencode", "zhipuai", "zai"),
]
cells = []
rows = []
for n, (harness, provider, owner) in enumerate(IDS):
  tag = f"zq{700 + n}"
  model = f"ids-{tag}"
  tokens = 70000 + 100 * n
  usage = {"input": tokens, "output": 0, "cacheRead": 0, "cacheWrite": 0, "totalTokens": tokens, "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0, "total": 0}}
  if harness == "opencode":
    rows.append((f"msg_{tag}", f"ses_{tag}", now_ms, now_ms, json.dumps({
      "parentID": f"msg_{tag}_u", "role": "assistant", "mode": "build", "agent": "build", "cost": 0,
      "tokens": {"total": tokens, "input": tokens, "output": 0, "reasoning": 0, "cache": {"write": 0, "read": 0}},
      "modelID": model, "providerID": provider, "time": {"created": now_ms, "completed": now_ms}, "finish": "stop"})))
  elif harness == "omp":
    runtime = {"version": "18.12.6"}
    lines = [
      {"type": "session", "version": 3, "id": f"s-{tag}", "timestamp": stamp, "cwd": "/home/me"},
      {"type": "model_change", "id": f"mc-{tag}", "parentId": None, "timestamp": stamp, "runtime": runtime, "model": f"{provider}/{model}", "resolvedModelIsFallback": False},
      {"type": "message", "id": f"u-{tag}", "parentId": f"mc-{tag}", "timestamp": stamp, "runtime": runtime, "message": {"role": "user", "content": [{"type": "text", "text": "Say hi"}], "attribution": "user", "timestamp": now_ms}},
      {"type": "message", "id": f"a-{tag}", "parentId": f"u-{tag}", "timestamp": stamp, "runtime": runtime, "message": {
        "role": "assistant", "content": [{"type": "text", "text": "hi"}], "api": "openai-completions", "provider": provider, "model": model,
        "usage": usage, "stopReason": "stop", "timestamp": now_ms}},
    ]
    path = home / f".omp/agent/sessions/-/{tag}.jsonl"
  else:
    lines = [
      {"type": "session", "version": 3, "id": f"s-{tag}", "timestamp": stamp, "cwd": "/home/me"},
      {"type": "model_change", "id": f"mc-{tag}", "parentId": None, "timestamp": stamp, "provider": provider, "modelId": model},
      {"type": "message", "id": f"u-{tag}", "parentId": f"mc-{tag}", "timestamp": stamp, "message": {"role": "user", "content": [{"type": "text", "text": "Say hi"}], "timestamp": now_ms}},
      {"type": "message", "id": f"a-{tag}", "parentId": f"u-{tag}", "timestamp": stamp, "message": {
        "role": "assistant", "content": [{"type": "text", "text": "hi"}], "api": "openai-completions", "provider": provider, "model": model,
        "usage": usage, "stopReason": "stop", "timestamp": now_ms}},
    ]
    path = home / f".pi/agent/sessions/--home-me--/{tag}.jsonl"
  if harness != "opencode":
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("".join(json.dumps(line) + "\n" for line in lines))
  cells.append({"tag": tag, "harness": harness, "provider": provider, "tokens": tokens, "owner": owner})

db = home / ".local/share/opencode/opencode.db"
db.parent.mkdir(parents=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", rows)
conn.commit()
conn.close()
Path(sys.argv[2]).write_text(json.dumps(cells))
PY
run_all "$IDS_HOME" "$WORK/ids-results"

python3 - "$WORK" "${collectors[@]}" >"$WORK/ids-report.txt" <<'PY'
import json
import re
import sys
from pathlib import Path

work = Path(sys.argv[1])
cells = {cell["tag"]: cell for cell in json.load(open(work / "ids-cells.json"))}
seen = {tag: {} for tag in cells}
for cid in sys.argv[2:]:
  try:
    record = json.loads((work / f"ids-results/{cid}.json").read_text())
  except ValueError:
    print(f"{cid} printed no record: {(work / f'ids-results/{cid}.err').read_text()[-300:]}")
    continue
  for model, bucket in (record.get("modelUsage") or {}).items():
    total = sum(bucket.get(key) or 0 for key in ("inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens"))
    for tag in re.findall(r"zq\d{3}", model):
      if tag in seen and total:
        seen[tag][cid] = seen[tag].get(cid, 0) + total
for tag, cell in sorted(cells.items()):
  owner, tokens = cell["owner"], cell["tokens"]
  wrong = [f"{cid} counted it {total / tokens:g}x" for cid, total in sorted(seen[tag].items()) if cid != owner or total != tokens]
  if owner and owner not in seen[tag]:
    wrong.insert(0, f"{owner} missed it")
  if wrong:
    print(f"{cell['harness']}'s {cell['provider']} ({tag}), expected {owner or 'nobody'}: {'; '.join(wrong)}")
PY
if [[ -s $WORK/ids-report.txt ]]; then
  fail "each harness's own id for a plan is counted once, by the collector that meters it" "$(cat "$WORK/ids-report.txt")"
fi
pass "each harness's own id for a plan is counted once, by the collector that meters it"

# ----------------------------------------------------- harness stores' routes

# Kimi Code, Qwen Code, Hermes and Mistral Vibe keep stores of their own and
# record where each request went: each request on a route counts once, by
# the harness's own collector when its service billed it, by `local` on a
# server you run, and by nobody on any other provider or a gateway, since no
# other collector reads these stores.
HARNESS_HOME="$WORK/harnesses"
mkdir -p "$HARNESS_HOME"
python3 - "$HARNESS_HOME" "$WORK/harness-cells.json" <<'PY'
import json
import sqlite3
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
now = time.time()
now_ms = int(now * 1000)
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
cells = []


def cell(source, route, owner):
  tag = f"zq{900 + len(cells)}"
  tokens = 91000 + 100 * len(cells)
  cells.append({"tag": tag, "source": source, "route": route, "tokens": tokens, "owner": owner})
  return tag, tokens


# Kimi Code: a model alias per route in config.toml, one usage.record each.
KIMI_ROUTES = [
  ("plan", 'type = "kimi"\nbase_url = "https://api.kimi.com/coding/v1"', "kimi"),
  ("box", 'type = "kimi"\nbase_url = "http://192.168.1.20:8000/v1"', "local"),
  ("anth", 'type = "anthropic"', None),
  ("acme", 'type = "openai"\nbase_url = "https://llm.acme.example/v1"', None),
]
config, wire = [], []
for name, provider, owner in KIMI_ROUTES:
  tag, tokens = cell("kimi-code", name, owner)
  config.append(f'[providers.{name}]\n{provider}\napi_key = "k"\n\n[models."{name}/m-{tag}"]\nprovider = "{name}"\nmodel = "m-{tag}"\nmax_context_size = 1000\n')
  wire.append({"type": "usage.record", "agentId": "main", "model": f"{name}/m-{tag}", "usage": {"inputOther": tokens, "output": 0, "inputCacheRead": 0, "inputCacheCreation": 0}, "usageScope": "turn", "time": now_ms})
(home / ".kimi-code").mkdir()
(home / ".kimi-code" / "config.toml").write_text("\n".join(config))
path = home / ".kimi-code" / "sessions" / "wd_p_1" / "session_1" / "agents" / "main" / "wire.jsonl"
path.parent.mkdir(parents=True)
path.write_text("".join(json.dumps(line) + "\n" for line in wire))

# Qwen Code: settings.json's modelProviders say where each model goes.
QWEN_ROUTES = [
  ("openai", "https://coding-intl.dashscope.aliyuncs.com/v1", "qwen"),
  ("openai", None, None),
  ("openai", "http://localhost:1234/v1", "local"),
  ("openai", "https://openrouter.ai/api/v1", None),
  ("anthropic", None, None),
]
providers, lines = {}, []
for auth, url, owner in QWEN_ROUTES:
  tag, tokens = cell("qwen-code", f"{auth} {url}", owner)
  if url:
    providers.setdefault(auth, []).append({"id": f"q-{tag}", "baseUrl": url})
  lines.append({"uuid": tag, "sessionId": "s", "timestamp": stamp, "type": "system", "subtype": "ui_telemetry", "systemPayload": {"uiEvent": {
    "event.name": "qwen-code.api_response", "event.timestamp": stamp, "response_id": tag, "model": f"q-{tag}", "auth_type": auth,
    "input_token_count": tokens, "output_token_count": 0, "cached_content_token_count": 0}}})
(home / ".qwen" / "projects" / "p" / "chats").mkdir(parents=True)
(home / ".qwen" / "settings.json").write_text(json.dumps({"modelProviders": providers}))
(home / ".qwen" / "projects" / "p" / "chats" / "s.jsonl").write_text("".join(json.dumps(line) + "\n" for line in lines))

# Hermes: each session and request names the base URL it was billed through.
(home / ".hermes").mkdir()
conn = sqlite3.connect(home / ".hermes" / "state.db")
conn.executescript("""
CREATE TABLE sessions (id TEXT PRIMARY KEY, model TEXT, started_at REAL NOT NULL, billing_provider TEXT, billing_base_url TEXT);
CREATE TABLE messages (id INTEGER PRIMARY KEY, session_id TEXT NOT NULL, role TEXT NOT NULL, timestamp REAL NOT NULL);
CREATE TABLE session_model_usage (session_id TEXT NOT NULL, model TEXT NOT NULL, billing_provider TEXT NOT NULL DEFAULT '', billing_base_url TEXT NOT NULL DEFAULT '',
  input_tokens INTEGER NOT NULL DEFAULT 0, output_tokens INTEGER NOT NULL DEFAULT 0, cache_read_tokens INTEGER NOT NULL DEFAULT 0, cache_write_tokens INTEGER NOT NULL DEFAULT 0);
""")
HERMES_ROUTES = [
  ("nous", "https://inference-api.nousresearch.com/v1", "hermes"),
  ("custom", "http://127.0.0.1:8080/v1", "local"),
  ("openrouter", "https://openrouter.ai/api/v1", None),
]
for provider, url, owner in HERMES_ROUTES:
  tag, tokens = cell("hermes", provider, owner)
  conn.execute("INSERT INTO sessions VALUES (?, ?, ?, ?, ?)", (tag, f"h-{tag}", now, provider, url))
  conn.execute("INSERT INTO session_model_usage (session_id, model, billing_provider, billing_base_url, input_tokens) VALUES (?, ?, ?, ?, ?)", (tag, f"h-{tag}", provider, url, tokens))
conn.commit()
conn.close()

# Mistral Vibe: a legacy session per provider, its config dumped beside it.
VIBE_ROUTES = [
  ("mistral", {"name": "mistral", "backend": "mistral"}, "vibe"),
  ("llamacpp", {"name": "llamacpp", "api_base": "http://127.0.0.1:8080/v1", "backend": "generic"}, "local"),
  ("proxy", {"name": "proxy", "api_base": "https://llm.acme.example/v1", "backend": "generic"}, None),
]
for n, (provider, entry, owner) in enumerate(VIBE_ROUTES):
  tag, tokens = cell("vibe", provider, owner)
  session = home / ".vibe" / "logs" / "session" / f"session_20260101_12000{n}_{tag}"
  session.mkdir(parents=True)
  (session / "meta.json").write_text(json.dumps({"session_id": session.name, "start_time": stamp, "config": {
    "active_model": f"v-{tag}", "models": {f"v-{tag}": {"name": f"v-{tag}", "provider": provider, "alias": f"v-{tag}"}}, "providers": [entry]},
    "stats": {"session_prompt_tokens": tokens, "session_cached_tokens": 0, "session_completion_tokens": 0}}))

Path(sys.argv[2]).write_text(json.dumps(cells))
PY
run_all "$HARNESS_HOME" "$WORK/harness-results"

harness_report=$(python3 - "$WORK" "${collectors[@]}" <<'PY'
import json
import re
import sys
from pathlib import Path

work = Path(sys.argv[1])
cells = {cell["tag"]: cell for cell in json.load(open(work / "harness-cells.json"))}
seen = {tag: {} for tag in cells}
for cid in sys.argv[2:]:
  try:
    record = json.loads((work / "harness-results" / f"{cid}.json").read_text())
  except ValueError:
    print(f"{cid} printed no JSON record")
    continue
  for model, bucket in (record.get("modelUsage") or {}).items():
    total = sum(bucket.get(key) or 0 for key in ("inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens"))
    for tag in re.findall(r"zq9\d\d", model):
      if tag in seen and total:
        seen[tag][cid] = seen[tag].get(cid, 0) + total
for tag, cell in sorted(cells.items()):
  owner, tokens = cell["owner"], cell["tokens"]
  wrong = [f"{cid} counted it {total / tokens:g}x" for cid, total in sorted(seen[tag].items()) if cid != owner or total != tokens]
  if owner and owner not in seen[tag]:
    wrong.insert(0, f"{owner} missed it")
  if wrong:
    print(f"{cell['source']} on {cell['route']} ({tag}), expected {owner or 'nobody'}: {'; '.join(wrong)}")
PY
)
if [[ -z $harness_report ]]; then
  pass "each Kimi Code, Qwen Code, Hermes and Vibe request is counted once, by the collector that bills its recorded route, or by none"
else
  fail "each Kimi Code, Qwen Code, Hermes and Vibe request is counted once, by the collector that bills its recorded route, or by none" "$harness_report"
fi

# ------------------------------------------- Claude Code sent to Model Studio

# Alibaba's Model Studio documents pointing Claude Code at its
# Anthropic-compatible API (international, mainland and the Coding Plan's),
# the hosts Qwen Code's replies are billed under qwen from. Every reply in
# the Claude Code home above, whatever model answered, is then qwen's, once,
# and no other collector's.
ALIBABA_ENDPOINTS=(
  https://dashscope-intl.aliyuncs.com/apps/anthropic
  https://dashscope.aliyuncs.com/apps/anthropic
  https://coding.dashscope.aliyuncs.com/apps/anthropic
)
for endpoint in "${!ALIBABA_ENDPOINTS[@]}"; do
  run_all "$CLAUDE_HOME" "$WORK/alibaba-results-$endpoint" ANTHROPIC_BASE_URL="${ALIBABA_ENDPOINTS[endpoint]}"
done

alibaba_report=$(python3 - "$WORK" "${ALIBABA_ENDPOINTS[@]}" -- "${collectors[@]}" <<'PY'
import json
import re
import sys
from pathlib import Path

work = Path(sys.argv[1])
split = sys.argv.index("--")
endpoints, collectors = sys.argv[2:split], sys.argv[split + 1:]
tokens = {cell["tag"]: cell["tokens"] for cell in json.load(open(work / "claude-cells.json"))}
for index, url in enumerate(endpoints):
  seen = {tag: {} for tag in tokens}
  for cid in collectors:
    try:
      record = json.loads((work / f"alibaba-results-{index}" / f"{cid}.json").read_text())
    except ValueError:
      print(f"{url}: {cid} printed no JSON record")
      continue
    for model, bucket in (record.get("modelUsage") or {}).items():
      total = sum(bucket.get(key) or 0 for key in ("inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens"))
      for tag in re.findall(r"zq\d{3}", model):
        if tag in seen and total:
          seen[tag][cid] = seen[tag].get(cid, 0) + total
  for tag, expected in sorted(tokens.items()):
    wrong = [f"{cid} counted it {total / expected:g}x" for cid, total in sorted(seen[tag].items()) if cid != "qwen" or total != expected]
    if "qwen" not in seen[tag]:
      wrong.insert(0, "qwen missed it")
    if wrong:
      print(f"{tag} sent to {url}, expected qwen: {'; '.join(wrong)}")
PY
)
if [[ -z $alibaba_report ]]; then
  pass "each Claude Code reply sent to Model Studio's Anthropic API is counted once, by qwen"
else
  fail "each Claude Code reply sent to Model Studio's Anthropic API is counted once, by qwen" "$alibaba_report"
fi

# ------------------------------------------------- local.json and claimed ids

# The local collector drops every id another collector claims from what
# local.json names (CLAIMED_PROVIDERS), so the claimer counts its rows and
# local never does. That list is kept by hand: each collector's own provider
# ids (its PROVIDERS, PROVIDER or NATIVE_PROVIDER, the exact id in its pi/omp
# pattern and its opencode prefilter) must all be in it.
claimed_report=$(python3 - "$ROOT" <<'PY'
import ast
import re
import sys
from pathlib import Path

bin_dir = Path(sys.argv[1]) / "bin"

def literals(node):
  if isinstance(node, ast.Constant) and isinstance(node.value, str):
    return [node.value]
  if isinstance(node, (ast.Tuple, ast.List, ast.Set)):
    return [value for item in node.elts for value in literals(item)]
  return []

def assigned(tree, names):
  return [node.value for node in tree.body if isinstance(node, ast.Assign) and any(getattr(target, "id", "") in names for target in node.targets)]

local = ast.parse((bin_dir / "omarchy-agent-usage-local").read_text())
claimed = {pid for value in assigned(local, ("CLAIMED_PROVIDERS",)) for pid in literals(value)}
missing = [] if claimed else ["CLAIMED_PROVIDERS is not found in omarchy-agent-usage-local"]
for path in sorted(bin_dir.glob("omarchy-agent-usage-*")):
  cid = path.name.removeprefix("omarchy-agent-usage-")
  if cid in ("local", "update"):
    continue
  tree = ast.parse(path.read_text())
  ids = {pid for value in assigned(tree, ("PROVIDERS", "PROVIDER", "NATIVE_PROVIDER")) for pid in literals(value)}
  for node in ast.walk(tree):
    if isinstance(node, ast.Constant) and isinstance(node.value, str):
      ids.update(re.findall(r'"provider"\\s\*:\\s\*"([a-z0-9-]+)"', node.value))
    if isinstance(node, ast.Call) and getattr(node.func, "id", "") == "scan_opencode" and node.args:
      ids.update(value[:-1] for value in literals(node.args[0]) if value.endswith('"'))
  missing += [f"{pid} ({cid})" for pid in sorted(ids - claimed)]
if missing:
  print("CLAIMED_PROVIDERS lacks " + ", ".join(missing))
PY
)
if [[ -z $claimed_report ]]; then
  pass "local's CLAIMED_PROVIDERS holds every provider id another collector claims"
else
  fail "local's CLAIMED_PROVIDERS holds every provider id another collector claims" "$claimed_report"
fi

# A local.json naming each harness's own id for a plan leaves every row to
# the collector that meters it: counted once, never by local too.
CLAIMED_IDS_HOME="$WORK/provider-ids-configured"
cp -a "$IDS_HOME" "$CLAIMED_IDS_HOME"
rm -rf "$CLAIMED_IDS_HOME/.cache"
mkdir -p "$CLAIMED_IDS_HOME/.config/omarchy/agents"
python3 - "$WORK/ids-cells.json" "$CLAIMED_IDS_HOME/.config/omarchy/agents/local.json" <<'PY'
import json
import sys

cells = json.load(open(sys.argv[1]))
json.dump({"providers": sorted({cell["provider"] for cell in cells})}, open(sys.argv[2], "w"))
PY
mkdir -p "$CLAIMED_IDS_HOME/.cache" "$CLAIMED_IDS_HOME/.run" "$WORK/ids-configured-results"
for id in local kimi muse zai; do
  run_collector "$CLAIMED_IDS_HOME" "$id" "$WORK/ids-configured-results/$id" &
done
wait

claimed_ids_report=$(python3 - "$WORK" local kimi muse zai <<'PY'
import json
import re
import sys
from pathlib import Path

work = Path(sys.argv[1])
cells = {cell["tag"]: cell for cell in json.load(open(work / "ids-cells.json"))}
seen = {tag: {} for tag in cells}
for cid in sys.argv[2:]:
  try:
    record = json.loads((work / f"ids-configured-results/{cid}.json").read_text())
  except ValueError:
    print(f"{cid} printed no record: {(work / f'ids-configured-results/{cid}.err').read_text()[-300:]}")
    continue
  for model, bucket in (record.get("modelUsage") or {}).items():
    total = sum(bucket.get(key) or 0 for key in ("inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens"))
    for tag in re.findall(r"zq\d{3}", model):
      if tag in seen and total:
        seen[tag][cid] = seen[tag].get(cid, 0) + total
for tag, cell in sorted(cells.items()):
  owner, tokens = cell["owner"], cell["tokens"]
  wrong = [f"{cid} counted it {total / tokens:g}x" for cid, total in sorted(seen[tag].items()) if cid != owner or total != tokens]
  if owner not in seen[tag]:
    wrong.insert(0, f"{owner} missed it")
  if wrong:
    print(f"{cell['harness']}'s {cell['provider']} ({tag}), expected {owner}: {'; '.join(wrong)}")
PY
)
if [[ -z $claimed_ids_report ]]; then
  pass "a local.json naming a plan's harness ids leaves each row to the collector that meters it, counted once"
else
  fail "a local.json naming a plan's harness ids leaves each row to the collector that meters it, counted once" "$claimed_ids_report"
fi

# ------------------------------------------------- Claude Code cost-state

# A cost-state line's totals hold the requests no reply line records (a
# /compact, the session title): what it holds beyond the replies counts once,
# under the collector that bills that model behind the endpoint, as the
# replies do.
COST_HOME="$WORK/claude-cost"
mkdir -p "$COST_HOME"
python3 - "$COST_HOME" "$WORK/cost-cells.json" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
# (model, reply tokens, beyond them, owner with no endpoint, owner behind Z.ai)
MODELS = [("claude-sonnet-zq920", 1387, 3001387, "claude", "zai"), ("glm-zq921", 2390, 24387, "zai", "zai"), ("claude-haiku-zq922", 0, 917, "claude", "zai")]
lines, usage = [], {}
for n, (model, replied, beyond, *_) in enumerate(MODELS):
  lines.append({"type": "user", "uuid": f"cost-prompt-{n}", "sessionId": "cost", "timestamp": stamp, "message": {"role": "user", "content": "go"}})
  if replied:
    lines.append({"type": "assistant", "sessionId": "cost", "timestamp": stamp, "requestId": f"req-cost-{n}",
                  "message": {"id": f"msg-cost-{n}", "role": "assistant", "model": model, "usage": {"input_tokens": replied, "output_tokens": 0}}})
  usage[model + "[1m]"] = {"inputTokens": replied + beyond, "outputTokens": 0, "cacheReadInputTokens": 0, "cacheCreationInputTokens": 0, "costUSD": 0}
lines.append({"type": "cost-state", "sessionId": "cost", "startTime": 1792669864166, "modelUsage": usage})
projects = home / ".claude/projects/project"
projects.mkdir(parents=True)
(projects / "cost.jsonl").write_text("".join(json.dumps(line) + "\n" for line in lines))
Path(sys.argv[2]).write_text(json.dumps([{"tag": model.split("-")[-1], "tokens": replied + beyond, "owners": owners} for model, replied, beyond, *owners in MODELS]))
PY
run_all "$COST_HOME" "$WORK/cost-results-0"
run_all "$COST_HOME" "$WORK/cost-results-1" ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"

cost_report=$(python3 - "$WORK" "${collectors[@]}" <<'PY'
import json
import re
import sys
from pathlib import Path

work = Path(sys.argv[1])
cells = json.load(open(work / "cost-cells.json"))
for endpoint in (0, 1):
  seen = {cell["tag"]: {} for cell in cells}
  for cid in sys.argv[2:]:
    try:
      record = json.loads((work / f"cost-results-{endpoint}" / f"{cid}.json").read_text())
    except ValueError:
      print(f"endpoint {endpoint}: {cid} printed no JSON record")
      continue
    for model, bucket in (record.get("modelUsage") or {}).items():
      total = sum(bucket.get(key) or 0 for key in ("inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens"))
      for tag in re.findall(r"zq\d{3}", model):
        if tag in seen and total:
          seen[tag][cid] = seen[tag].get(cid, 0) + total
  for cell in cells:
    owner = cell["owners"][endpoint]
    wrong = [f"{cid} counted {total} of {cell['tokens']}" for cid, total in sorted(seen[cell["tag"]].items()) if cid != owner or total != cell["tokens"]]
    if owner not in seen[cell["tag"]]:
      wrong.insert(0, f"{owner} missed it")
    if wrong:
      print(f"{cell['tag']} at endpoint {endpoint}, expected {owner}: {'; '.join(wrong)}")
PY
)
if [[ -z $cost_report ]]; then
  pass "what a Claude Code cost-state holds beyond the replies is counted once, by the collector that bills its model"
else
  fail "what a Claude Code cost-state holds beyond the replies is counted once, by the collector that bills its model" "$cost_report"
fi

# Codex rollouts on a model_providers entry, as Codex 0.163 writes them: the
# config.toml base_url says who served them, so one at a provider's host is
# that provider's collector's whatever the entry's id (Z.ai, OpenRouter,
# DeepSeek, Moonshot, Model Studio, MiniMax, ollama.com), one on the user's
# own hardware is local's, and one at a host nothing can place nobody's. A
# provider gone from the config keeps the base_url it was last seen with.
CODEX_ROUTES_HOME="$WORK/codex-routes"
mkdir -p "$CODEX_ROUTES_HOME/.codex" "$CODEX_ROUTES_HOME/.local/state/omarchy/agents"
cat >"$CODEX_ROUTES_HOME/.codex/config.toml" <<'TOML'
model = "gpt-5.1-codex"
[model_providers.zai]
name = "zai"
base_url = "https://api.z.ai/api/coding/paas/v4"
wire_api = "responses"
[model_providers.openrouter]
name = "openrouter"
base_url = "https://openrouter.ai/api/v1"
wire_api = "responses"
[model_providers.dsk]
base_url = "https://api.deepseek.com/v1"
[model_providers.moon]
base_url = "https://api.moonshot.ai/v1"
[model_providers.dash]
base_url = "https://dashscope-intl.aliyuncs.com/compatible-mode/v1"
[model_providers.mm]
base_url = "https://api.minimax.io/v1"
[model_providers.ollama]
base_url = "https://ollama.com/v1"
[model_providers.box]
base_url = "http://192.168.1.20:8080/v1"
[model_providers.acme]
base_url = "https://llm.acme.example/v1"
TOML
python3 - "$CODEX_ROUTES_HOME" "$WORK/codex-routes-cells.json" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
(home / ".local/state/omarchy/agents/local-codex-providers.json").write_text(json.dumps(
  {"homes": {str(home / ".codex"): {"gone": "https://api.z.ai/api/paas/v4"}}}))
ROUTES = [
  ("openai", "gpt-5.1-codex", "codex"),
  ("zai", "glm-4.6", "zai"),
  ("openrouter", "z-ai/glm-4.6", "openrouter"),
  ("dsk", "deepseek-chat", "deepseek"),
  ("moon", "kimi-k2-0905-preview", "kimi"),
  ("dash", "qwen3-coder-plus", "qwen"),
  ("mm", "MiniMax-M2", "minimax"),
  ("ollama", "gpt-oss:120b", "ollama"),
  ("box", "qwen3-coder:30b", "local"),
  ("acme", "acme-coder", None),
  ("gone", "glm-4.5", "zai"),
]
rollouts = home / ".codex/sessions" / datetime.now().strftime("%Y/%m/%d")
rollouts.mkdir(parents=True)
cells = []
for n, (provider, model, owner) in enumerate(ROUTES):
  tag = f"zr{n:03d}"
  base, colon, suffix = model.partition(":")
  name = f"{base}-{tag}{colon}{suffix}"
  thread = f"01a16422-7868-7633-a566-{n:012d}"
  first = {"input_tokens": 8234 + n, "cached_input_tokens": 71, "cache_write_input_tokens": 31, "output_tokens": 51, "reasoning_output_tokens": 0, "total_tokens": 8285 + n}
  second = {"input_tokens": 9234 + n, "cached_input_tokens": 72, "cache_write_input_tokens": 32, "output_tokens": 52, "reasoning_output_tokens": 0, "total_tokens": 9286 + n}
  total = {key: first[key] + second[key] for key in first}
  lines = [
    {"timestamp": stamp, "type": "session_meta", "payload": {"session_id": thread, "id": thread, "originator": "codex_exec", "cli_version": "0.163.0", "source": "exec", "thread_source": "user", "model_provider": provider}},
    {"timestamp": stamp, "type": "turn_context", "payload": {"model": name}},
    {"timestamp": stamp, "type": "event_msg", "payload": {"type": "item_completed", "thread_id": thread, "item": {"type": "UserMessage", "id": f"u{n}", "content": [{"type": "text", "text": "go"}]}}},
    {"timestamp": stamp, "type": "token_usage_record", "payload": {"thread_id": thread, "response_id": "resp_mock_0001", "usage": first, "thread_token_usage": first}},
    {"timestamp": stamp, "type": "event_msg", "payload": {"type": "token_count", "info": {"total_token_usage": first, "last_token_usage": first}}},
    {"timestamp": stamp, "type": "token_usage_record", "payload": {"thread_id": thread, "response_id": "resp_mock_0002", "usage": second, "thread_token_usage": total}},
    {"timestamp": stamp, "type": "event_msg", "payload": {"type": "token_count", "info": {"total_token_usage": total, "last_token_usage": second}}},
  ]
  (rollouts / f"rollout-{tag}.jsonl").write_text("".join(json.dumps(line) + "\n" for line in lines))
  cells.append({"tag": tag, "provider": provider, "tokens": total["input_tokens"] + total["output_tokens"], "owner": owner})
json.dump(cells, open(sys.argv[2], "w"))
PY

codex_routes_report() {
  python3 - "$WORK/codex-routes-cells.json" "$@" <<'PY'
import json
import re
import sys
from pathlib import Path

cells = {cell["tag"]: cell for cell in json.load(open(sys.argv[1]))}
results = Path(sys.argv[2])
seen = {tag: {} for tag in cells}
for cid in sys.argv[3:]:
  try:
    record = json.loads((results / f"{cid}.json").read_text())
  except ValueError:
    print(f"{cid} printed no record: {(results / f'{cid}.err').read_text()[-300:]}")
    continue
  for model, bucket in (record.get("modelUsage") or {}).items():
    total = sum(bucket.get(key) or 0 for key in ("inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens"))
    for tag in re.findall(r"zr\d{3}", model):
      if tag in seen and total:
        seen[tag][cid] = seen[tag].get(cid, 0) + total
for tag, cell in sorted(cells.items()):
  owner, tokens = cell["owner"], cell["tokens"]
  wrong = [f"{cid} counted it {total / tokens:g}x" for cid, total in sorted(seen[tag].items()) if cid != owner or total != tokens]
  if owner is not None and owner not in seen[tag]:
    wrong.insert(0, f"{owner} missed it")
  if wrong:
    print(f"Codex provider {cell['provider']} ({tag}), expected {owner}: {'; '.join(wrong)}")
PY
}

run_all "$CODEX_ROUTES_HOME" "$WORK/codex-routes-results"
codex_routes=$(codex_routes_report "$WORK/codex-routes-results" "${collectors[@]}")
if [[ -z $codex_routes ]]; then
  pass "a Codex model_providers entry counts once, under the collector its base_url's host bills"
else
  fail "a Codex model_providers entry counts once, under the collector its base_url's host bills" "$codex_routes"
fi

# Moving a provider's base_url is a new scan: a cached one that counted it
# under Z.ai no longer stands once config.toml sends it elsewhere.
mkdir -p "$WORK/codex-routes-cached"
run_cached_zai() {
  env -i HOME="$CODEX_ROUTES_HOME" PATH="$WORK/bin" LANG=C.UTF-8 ${TZ+TZ="$TZ"} OMARCHY_PATH="$ROOT" OMARCHY_LANGUAGE_FILE="$OMARCHY_LANGUAGE_FILE" \
    XDG_CONFIG_HOME="$CODEX_ROUTES_HOME/.config" XDG_DATA_HOME="$CODEX_ROUTES_HOME/.local/share" XDG_STATE_HOME="$CODEX_ROUTES_HOME/.local/state" \
    XDG_CACHE_HOME="$CODEX_ROUTES_HOME/.cache" XDG_RUNTIME_DIR="$CODEX_ROUTES_HOME/.run" \
    http_proxy=http://127.0.0.1:9 https_proxy=http://127.0.0.1:9 HTTP_PROXY=http://127.0.0.1:9 HTTPS_PROXY=http://127.0.0.1:9 ALL_PROXY=http://127.0.0.1:9 \
    "$TIMEOUT" --kill-after=5 "$COLLECTOR_TIMEOUT" "$ROOT/bin/omarchy-agent-usage-zai" --limits-only \
    >"$WORK/codex-routes-cached/zai.json" 2>"$WORK/codex-routes-cached/zai.err" || true
}
run_cached_zai
sed -i 's#https://api.z.ai/api/coding/paas/v4#https://llm.acme.example/zai/v1#' "$CODEX_ROUTES_HOME/.codex/config.toml"
run_cached_zai
if codex_cached=$(python3 - "$WORK/codex-routes-cached/zai.json" <<'PY'
import json
import sys

try:
  usage = json.load(open(sys.argv[1])).get("modelUsage") or {}
except ValueError:
  usage = {"no record": {}}
models = sorted(model for model in usage if "zr" in model or model == "no record")
if models != ["glm-4.5-zr010"]:
  print(f"zai counted {models}, expected only glm-4.5-zr010")
PY
) && [[ -z $codex_cached ]]; then
  pass "moving a Codex provider's base_url off Z.ai rescans rather than keeping a cached count"
else
  fail "moving a Codex provider's base_url off Z.ai rescans rather than keeping a cached count" "$codex_cached"
fi

# --force reads every Codex rollout again in each collector that bills one,
# even one rewritten to the same size and mtime its per-file cache keeps.
python3 - "$CODEX_ROUTES_HOME" <<'PY'
import os
import sys
from pathlib import Path

for rollout in sorted((Path(sys.argv[1]) / ".codex" / "sessions").rglob("rollout-zr*.jsonl")):
  stat = rollout.stat()
  rollout.write_text(rollout.read_text().replace('"output_tokens": 51,', '"output_tokens": 91,').replace('"output_tokens": 103,', '"output_tokens": 143,'))
  os.utime(rollout, ns=(stat.st_atime_ns, stat.st_mtime_ns))
PY
run_all "$CODEX_ROUTES_HOME" "$WORK/codex-routes-forced"
if codex_forced=$(python3 - "$WORK/codex-routes-cells.json" "$WORK/codex-routes-forced" "${collectors[@]}" <<'PY'
import json
import re
import sys
from pathlib import Path

# Z.ai's coding endpoint moved off its host above, so that rollout is nobody's now.
cells = {cell["tag"]: {**cell, "tokens": cell["tokens"] + 40, "owner": None if cell["tag"] == "zr001" else cell["owner"]} for cell in json.load(open(sys.argv[1]))}
routed = {"zai", "openrouter", "deepseek", "kimi", "qwen", "minimax", "ollama"}
for cid in sys.argv[3:]:
  if cid not in routed:
    continue
  try:
    record = json.loads((Path(sys.argv[2]) / f"{cid}.json").read_text())
  except ValueError:
    print(f"{cid} printed no record")
    continue
  for model, bucket in (record.get("modelUsage") or {}).items():
    total = sum(bucket.get(key) or 0 for key in ("inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens"))
    for tag in re.findall(r"zr\d{3}", model):
      if tag in cells and cells[tag]["owner"] == cid and total != cells[tag]["tokens"]:
        print(f"{cid} counted {tag} as {total}, expected the rewritten {cells[tag]['tokens']}")
PY
) && [[ -z $codex_forced ]]; then
  pass "--force rereads a Codex rollout rewritten to the same size and mtime in every collector that bills one"
else
  fail "--force rereads a Codex rollout rewritten to the same size and mtime in every collector that bills one" "$codex_forced"
fi

# ------------------------------------- Claude Code and Codex sent to Synthetic

# Synthetic documents Claude Code on its Anthropic-compatible API
# (ANTHROPIC_BASE_URL=https://api.synthetic.new/anthropic, with hf:org/model
# ids and syn: aliases as the models) and an OpenAI-compatible one at
# /openai/v1. Behind that base URL every reply is synthetic's, a Claude-named
# one too; with no override an hf: or syn: model still is, and a Codex
# model_providers entry at the host is, whatever its id. The lines are shaped
# as Claude Code 2.1.308 and Codex 0.163 write them.
SYNTHETIC_HOME="$WORK/synthetic-routes"
mkdir -p "$SYNTHETIC_HOME/.codex"
cat >"$SYNTHETIC_HOME/.codex/config.toml" <<'TOML'
[model_providers.syn]
name = "syn"
base_url = "https://api.synthetic.new/openai/v1"
TOML
python3 - "$SYNTHETIC_HOME" "$WORK/synthetic-cells.json" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
# (model, owner with no override, owner behind Synthetic's base URL).
MODELS = [
  ("hf:moonshotai/Kimi-K2.5-zs900", "synthetic", "synthetic"),
  ("syn:large:text-zs901", "synthetic", "synthetic"),
  ("hf:zai-org/GLM-4.7-Flash-zs902", "synthetic", "synthetic"),
  ("claude-sonnet-4-5-zs903", "claude", "synthetic"),
  ("glm-4.6-zs904", "zai", "synthetic"),
]
session = "1baa699a-5508-4dc9-bbe8-9b8b236c5300"
lines, cells = [], []
for n, (model, bare, routed) in enumerate(MODELS):
  tokens = 8001234 + 1000 * n
  prompt = f"894c905e-cd07-4593-946b-c63e9a80{n:04d}"
  lines.append({"parentUuid": None, "isSidechain": False, "promptId": f"dcabb8e9-c1ea-4e48-a2ce-7a27caa1{n:04d}", "type": "user", "uuid": prompt,
                "timestamp": stamp, "origin": {"kind": "human"}, "promptSource": "typed", "userType": "external", "entrypoint": "cli",
                "sessionId": session, "version": "2.1.308", "message": {"role": "user", "content": "go"}})
  lines.append({"parentUuid": prompt, "isSidechain": False, "requestRef": f"78b6e39e-b112-4b92-a1cb-2489e2f2{n:04d}", "requestedModel": model,
                "type": "assistant", "uuid": f"da577048-3a3d-4f5e-aed2-0df4c92b{n:04d}", "timestamp": stamp, "userType": "external",
                "entrypoint": "cli", "sessionId": session, "version": "2.1.308",
                "message": {"id": f"msg_syn_{n:04d}", "type": "message", "role": "assistant", "model": model, "content": [{"type": "text", "text": "ok"}],
                            "stop_reason": "end_turn", "usage": {"input_tokens": tokens, "cache_creation_input_tokens": 31, "cache_read_input_tokens": 71,
                                                                 "output_tokens": 51, "service_tier": "standard"}}})
  cells.append({"tag": f"zs{900 + n}", "tokens": tokens + 31 + 71 + 51, "owners": [bare, routed]})
projects = home / ".claude/projects/-home-dhh-proj"
projects.mkdir(parents=True)
(projects / f"{session}.jsonl").write_text("".join(json.dumps(line) + "\n" for line in lines))

thread = "01a16375-5c70-7982-8b22-06dc854c1a00"
usage = {"input_tokens": 8234, "cached_input_tokens": 71, "cache_write_input_tokens": 31, "output_tokens": 51, "reasoning_output_tokens": 0, "total_tokens": 8285}
rollouts = home / ".codex/sessions" / datetime.now().strftime("%Y/%m/%d")
rollouts.mkdir(parents=True)
(rollouts / f"rollout-zs910-{thread}.jsonl").write_text("".join(json.dumps(line) + "\n" for line in [
  {"timestamp": stamp, "type": "session_meta", "payload": {"session_id": thread, "id": thread, "originator": "codex_exec", "cli_version": "0.163.0", "source": "exec", "thread_source": "user", "model_provider": "syn"}},
  {"timestamp": stamp, "type": "turn_context", "payload": {"model": "hf:zai-org/GLM-5.3-zs910"}},
  {"timestamp": stamp, "type": "event_msg", "payload": {"type": "item_completed", "thread_id": thread, "item": {"type": "UserMessage", "id": "u0", "content": [{"type": "text", "text": "go"}]}}},
  {"timestamp": stamp, "type": "token_usage_record", "payload": {"thread_id": thread, "response_id": "resp_syn_0001", "usage": usage, "thread_token_usage": usage}},
  {"timestamp": stamp, "type": "event_msg", "payload": {"type": "token_count", "info": {"total_token_usage": usage, "last_token_usage": usage}}},
]))
cells.append({"tag": "zs910", "tokens": usage["input_tokens"] + usage["output_tokens"], "owners": ["synthetic", "synthetic"]})
json.dump(cells, open(sys.argv[2], "w"))
PY
run_all "$SYNTHETIC_HOME" "$WORK/synthetic-results-0"
run_all "$SYNTHETIC_HOME" "$WORK/synthetic-results-1" ANTHROPIC_BASE_URL="https://api.synthetic.new/anthropic"

synthetic_report=$(python3 - "$WORK" "${collectors[@]}" <<'PY'
import json
import re
import sys
from pathlib import Path

work = Path(sys.argv[1])
cells = json.load(open(work / "synthetic-cells.json"))
for run, label in enumerate(("with no override", "sent to https://api.synthetic.new/anthropic")):
  seen = {cell["tag"]: {} for cell in cells}
  for cid in sys.argv[2:]:
    try:
      record = json.loads((work / f"synthetic-results-{run}" / f"{cid}.json").read_text())
    except ValueError:
      print(f"{label}: {cid} printed no JSON record")
      continue
    for model, bucket in (record.get("modelUsage") or {}).items():
      total = sum(bucket.get(key) or 0 for key in ("inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens"))
      for tag in re.findall(r"zs9\d\d", model):
        if tag in seen and total:
          seen[tag][cid] = seen[tag].get(cid, 0) + total
  for cell in cells:
    tag, owner, tokens = cell["tag"], cell["owners"][run], cell["tokens"]
    wrong = [f"{cid} counted it {total / tokens:g}x" for cid, total in sorted(seen[tag].items()) if cid != owner or total != tokens]
    if owner not in seen[tag]:
      wrong.insert(0, f"{owner} missed it")
    if wrong:
      print(f"{tag} {label}, expected {owner}: {'; '.join(wrong)}")
PY
)
if [[ -z $synthetic_report ]]; then
  pass "Claude Code and Codex set up as Synthetic documents count once, under synthetic"
else
  fail "Claude Code and Codex set up as Synthetic documents count once, under synthetic" "$synthetic_report"
fi

# ----------------------------------------------- prompts no reply answered

# A typed prompt whose request failed, or that got no reply at all, still
# counts once, under the collector billing the model the session was set to
# use for it, and holds its session in use: pi and omp write the failed reply
# with its provider and no usage, opencode the user row with its model. The
# lines are shaped as pi 1.4.0, omp 18.12.6 and opencode 1.19.3 wrote them
# against a server refusing the request with a 400. A prompt typed at an
# untrusted time counts nowhere.
UNANSWERED_HOME="$WORK/unanswered"
python3 - "$UNANSWERED_HOME" <<'PY'
import json
import sqlite3
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
now_ms = int(time.time() * 1000) - 1000
runtime = {"version": "18.12.6"}
zero = {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0, "totalTokens": 0, "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0, "total": 0}}


def spent(n):
  return {"input": 121101 + n, "output": 1251, "cacheRead": 1271, "cacheWrite": 0, "reasoning": 1204, "totalTokens": 123623 + n, "cost": zero["cost"]}


def user(n, text, at=None, omp=False):
  message = {"role": "user", "content": [{"type": "text", "text": text}], "timestamp": now_ms if at is None else at}
  if omp:
    message["attribution"] = "user"
  return {"type": "message", "id": f"u{n}", "timestamp": stamp if at is None else at, "message": message}


def reply(n, provider, model, usage):
  message = {"role": "assistant", "content": [{"type": "text", "text": "" if usage is zero else "hi"}], "api": "openai-completions",
             "provider": provider, "model": model, "usage": usage, "stopReason": "error" if usage is zero else "stop", "timestamp": now_ms}
  if usage is zero:
    message["errorMessage"] = '400: {"message":"refused","type":"invalid_request_error"}'
  return {"type": "message", "id": f"a{n}", "timestamp": stamp, "message": message}


def write(path, lines):
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join(json.dumps(line) + "\n" for line in lines))


pi = home / ".pi/agent/sessions/--home-me--"
omp = home / ".omp/agent/sessions/-"
# pi: a failed prompt, then an answered one, on Synthetic.
write(pi / "failed-then-answered.jsonl", [
  {"type": "session", "version": 3, "id": "s1", "timestamp": stamp, "cwd": "/home/me"},
  {"type": "model_change", "id": "m1", "parentId": None, "timestamp": stamp, "provider": "synthetic", "modelId": "e2e-failpi"},
  user(11, "FAILME"), reply(11, "synthetic", "e2e-failpi", zero),
  user(12, "Say hi"), reply(12, "synthetic", "e2e-failpi", spent(1)),
])
# pi: a prompt failed on Z.ai, then the session switched to DeepSeek, which
# answered the next one: one prompt each.
write(pi / "failed-then-switched.jsonl", [
  {"type": "session", "version": 3, "id": "s2", "timestamp": stamp, "cwd": "/home/me"},
  {"type": "model_change", "id": "m2", "parentId": None, "timestamp": stamp, "provider": "zai", "modelId": "e2e-failzai"},
  user(21, "FAILME"), reply(21, "zai", "e2e-failzai", zero),
  {"type": "model_change", "id": "m2b", "parentId": "a21", "timestamp": stamp, "provider": "deepseek", "modelId": "e2e-failswitch"},
  user(22, "Say hi"), reply(22, "deepseek", "e2e-failswitch", spent(2)),
])
# pi: a failed prompt typed at an untrusted time, the session's only one.
write(pi / "untimed.jsonl", [
  {"type": "session", "version": 3, "id": "s3", "timestamp": stamp, "cwd": "/home/me"},
  {"type": "model_change", "id": "m3", "parentId": None, "timestamp": stamp, "provider": "zai", "modelId": "e2e-untimed"},
  user(31, "FAILME", at=0), reply(31, "zai", "e2e-untimed", zero),
])
# omp: a failed prompt, then an answered one, on Z.ai, with a handoff
# compaction that records no usage.
write(omp / "failed-then-answered.jsonl", [
  {"type": "session", "version": 3, "id": "s4", "timestamp": stamp, "cwd": "/home/me"},
  {"type": "model_change", "id": "m4", "parentId": None, "timestamp": stamp, "runtime": runtime, "model": "zai/e2e-failomp", "resolvedModelIsFallback": False},
  user(41, "FAILME", omp=True), reply(41, "zai", "e2e-failomp", zero),
  user(42, "Say hi", omp=True), reply(42, "zai", "e2e-failomp", spent(4)),
  {"type": "compaction", "id": "c4", "parentId": "a42", "timestamp": stamp, "runtime": runtime, "summary": "s", "firstKeptEntryId": "a42", "tokensBefore": 123929, "tokensAfter": 2054, "method": "handoff"},
])
# omp: a prompt on DeepSeek that got no reply at all (the process died), so
# only the model switch says where it was going.
write(omp / "no-reply.jsonl", [
  {"type": "session", "version": 3, "id": "s5", "timestamp": stamp, "cwd": "/home/me"},
  {"type": "model_change", "id": "m5", "parentId": None, "timestamp": stamp, "runtime": runtime, "model": "deepseek/e2e-noreply", "resolvedModelIsFallback": False},
  user(51, "hello?", omp=True),
])

db = home / ".local/share/opencode/opencode.db"
db.parent.mkdir(parents=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.execute("CREATE TABLE session (id text PRIMARY KEY, parent_id text, title text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL)")
rows = []


def oc_user(session, n, provider, model):
  rows.append((f"msg_{session}_u{n}", session, now_ms + n, {"role": "user", "time": {"created": now_ms + n}, "agent": "build", "model": {"providerID": provider, "modelID": model}, "summary": {"diffs": []}}))


def oc_step(session, n, provider, model, tokens):
  data = {"parentID": f"msg_{session}_u{n}", "role": "assistant", "mode": "build", "agent": "build", "path": {"cwd": "/home/me", "root": "/"}, "cost": 0,
          "tokens": tokens, "modelID": model, "providerID": provider, "time": {"created": now_ms + n + 1, "completed": now_ms + n + 2}}
  if tokens["input"]:
    data["finish"] = "stop"
  else:
    data["error"] = {"name": "APIError", "data": {"message": "refused", "statusCode": 400, "isRetryable": False}}
  rows.append((f"msg_{session}_a{n}", session, now_ms + n + 1, data))


failed = {"input": 0, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}}
answered = {"total": 123827, "input": 121301, "output": 47, "reasoning": 1206, "cache": {"write": 0, "read": 1273}}
# A failed prompt, then `-c` and an answered one, on Synthetic.
oc_user("ses_failoc", 1, "synthetic", "oc-failoc")
oc_step("ses_failoc", 1, "synthetic", "oc-failoc", failed)
oc_user("ses_failoc", 3, "synthetic", "oc-failoc")
oc_step("ses_failoc", 3, "synthetic", "oc-failoc", answered)
# A session holding only a failed prompt, on Z.ai.
oc_user("ses_failzai", 1, "zai", "oc-failzai")
oc_step("ses_failzai", 1, "zai", "oc-failzai", failed)
for session in ("ses_failoc", "ses_failzai"):
  conn.execute("INSERT INTO session VALUES (?, NULL, 'FAILME', ?, ?)", (session, now_ms - 1000, now_ms - 1000))
conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [(mid, session, at, at, json.dumps(data)) for mid, session, at, data in rows])
conn.commit()
conn.close()
PY
run_all "$UNANSWERED_HOME" "$WORK/unanswered-results"

unanswered_report=$(python3 - "$WORK/unanswered-results" "${collectors[@]}" <<'PY'
import json
import sys
from pathlib import Path

results = Path(sys.argv[1])
# (prompts, sessions) each collector must count; every other one counts none.
expected = {"synthetic": (4, 2), "zai": (4, 3), "deepseek": (2, 2)}
for cid in sys.argv[2:]:
  try:
    record = json.loads((results / f"{cid}.json").read_text())
  except ValueError:
    print(f"{cid} printed no JSON record")
    continue
  want = expected.get(cid, (0, 0))
  got = (record.get("totalPrompts"), record.get("totalSessions"))
  today = (record.get("todayPrompts"), record.get("todaySessions"))
  if got != want or today != want:
    print(f"{cid}: prompts and sessions {got} (today {today}), expected {want}")
PY
)
if [[ -z $unanswered_report ]]; then
  pass "a prompt no reply answered in pi, omp or opencode counts once, under the model its session was set to use"
else
  fail "a prompt no reply answered in pi, omp or opencode counts once, under the model its session was set to use" "$unanswered_report"
fi

# ------------------------------ Codex's built-in provider and its own threads

# Codex 0.163 sends its built-in `openai` provider wherever config.toml's
# openai_base_url says (OPENAI_BASE_URL does nothing), and its rollouts still
# record only `"model_provider":"openai"`. Behind a provider's host every
# built-in rollout is that provider's; behind a self-hosted URL a model not
# OpenAI's is local's; behind a host nothing can place it counts nowhere,
# and OpenAI's own models stay codex's behind either. Dropping the key puts
# them back under codex. A guardian thread counts under the session that
# started it, in every collector. The lines are shaped as Codex 0.160 and
# 0.163 write them.
CODEX_NATIVE_HOME="$WORK/codex-native-routes"
mkdir -p "$CODEX_NATIVE_HOME/.codex"
python3 - "$CODEX_NATIVE_HOME" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
rollouts = home / ".codex/sessions" / datetime.now().strftime("%Y/%m/%d")
rollouts.mkdir(parents=True)


def rollout(tag, thread, meta, model, n, typed=True):
  usage = {"input_tokens": 9234 + n, "cached_input_tokens": 71, "cache_write_input_tokens": 31, "output_tokens": 51, "reasoning_output_tokens": 0, "total_tokens": 9285 + n}
  turn = f"01a1647f-6fd1-7341-86cf-b00a9315{n:04d}"
  item = {"type": "UserMessage", "id": f"01a1647f-7085-7231-a532-dda74a01{n:04d}", "content": [{"type": "text", "text": "go", "text_elements": []}]} if typed else {"type": "Reasoning", "id": f"rs_{n:04d}", "summary_text": [], "raw_content": []}
  lines = [
    {"timestamp": stamp, "ordinal": 0, "type": "session_meta", "payload": {"session_id": thread, "id": thread, "cli_version": "0.163.0", "history_mode": "paginated", **meta}},
    {"timestamp": stamp, "ordinal": 5, "type": "turn_context", "payload": {"model": model, "turn_id": turn}},
    {"timestamp": stamp, "ordinal": 8, "type": "event_msg", "payload": {"type": "item_completed", "thread_id": thread, "turn_id": turn, "item": item}},
    {"timestamp": stamp, "ordinal": 10, "type": "token_usage_record", "payload": {"thread_id": thread, "turn_id": turn, "session_id": meta.get("session_id", thread), "response_id": f"resp_zo_{n:04d}", "usage": usage, "turn_token_usage": usage, "thread_token_usage": usage}},
    {"timestamp": stamp, "ordinal": 13, "type": "event_msg", "payload": {"type": "token_count", "info": {"total_token_usage": usage, "last_token_usage": usage, "model_context_window": 258400}}},
  ]
  (rollouts / f"rollout-{tag}-{thread}.jsonl").write_text("".join(json.dumps(line) + "\n" for line in lines))


exec_meta = {"originator": "codex_exec", "source": "exec", "thread_source": "user", "model_provider": "openai"}
rollout("zo920", "01a1647f-6fb5-7081-a481-257bbb530920", exec_meta, "hf:zai-org/GLM-4.6-zo920", 0)
rollout("zo921", "01a1647f-6fb5-7081-a481-257bbb530921", exec_meta, "gpt-5.1-codex-zo921", 1)
parent = "01a116c6-3c98-7931-bbd3-71e4e2ed0922"
rollout("zo922", parent, {"originator": "codex-tui", "source": "cli", "thread_source": "user", "model_provider": "syn"}, "gpt-6.1-sol-zo922", 2)
rollout("zo923", "01a1284c-6fa4-7c13-8d29-e2d8b5660923",
        {"session_id": parent, "parent_thread_id": parent, "originator": "codex-tui", "source": {"subagent": {"other": "guardian"}}, "thread_source": "guardian_review", "model_provider": "syn"},
        "codex-auto-review-zo923", 3, typed=False)
PY
# (openai_base_url, then each tag's owner, then collector=prompts/sessions).
CODEX_NATIVE_RUNS=(
  "https://api.synthetic.new/openai/v1|zo920=synthetic zo921=synthetic zo922=synthetic zo923=synthetic|synthetic=3/3 codex=0/0 local=0/0"
  "http://127.0.0.1:18493/v1|zo920=local zo921=codex zo922=synthetic zo923=synthetic|synthetic=1/1 codex=1/1 local=1/1"
  "https://llm-proxy.example.com/v1|zo920= zo921=codex zo922=synthetic zo923=synthetic|synthetic=1/1 codex=1/1 local=0/0"
  "|zo920=codex zo921=codex zo922=synthetic zo923=synthetic|synthetic=1/1 codex=2/2 local=0/0"
)
codex_native_report=""
for run in "${!CODEX_NATIVE_RUNS[@]}"; do
  IFS='|' read -r base owners counts <<<"${CODEX_NATIVE_RUNS[$run]}"
  {
    if [[ -n $base ]]; then
      printf 'openai_base_url = "%s"\n\n' "$base"
    fi
    printf '[model_providers.syn]\nname = "syn"\nbase_url = "https://api.synthetic.new/openai/v1"\n'
  } >"$CODEX_NATIVE_HOME/.codex/config.toml"
  run_all "$CODEX_NATIVE_HOME" "$WORK/codex-native-results-$run"
  report=$(python3 - "$WORK/codex-native-results-$run" "${base:-no openai_base_url}" "$owners" "$counts" "${collectors[@]}" <<'PY'
import json
import re
import sys
from pathlib import Path

results, label = Path(sys.argv[1]), sys.argv[2]
owners = dict(pair.split("=") for pair in sys.argv[3].split())
counts = {cid: tuple(int(n) for n in want.split("/")) for cid, want in (pair.split("=") for pair in sys.argv[4].split())}
seen = {tag: {} for tag in owners}
for cid in sys.argv[5:]:
  try:
    record = json.loads((results / f"{cid}.json").read_text())
  except ValueError:
    print(f"{label}: {cid} printed no JSON record")
    continue
  if cid in counts and (record.get("totalPrompts"), record.get("totalSessions")) != counts[cid]:
    print(f"{label}: {cid} counted prompts and sessions {(record.get('totalPrompts'), record.get('totalSessions'))}, expected {counts[cid]}")
  for model, bucket in (record.get("modelUsage") or {}).items():
    total = sum(bucket.get(key) or 0 for key in ("inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens"))
    for tag in re.findall(r"zo92\d", model):
      if tag in seen and total:
        seen[tag][cid] = seen[tag].get(cid, 0) + total
for tag, owner in owners.items():
  wrong = [f"{cid} counted it" for cid in sorted(seen[tag]) if cid != owner]
  if owner and owner not in seen[tag]:
    wrong.insert(0, f"{owner} missed it")
  if wrong:
    print(f"{label}: {tag}, expected {owner or 'nobody'}: {'; '.join(wrong)}")
PY
)
  if [[ -n $report ]]; then
    codex_native_report+="$report"$'\n'
  fi
done
if [[ -z $codex_native_report ]]; then
  pass "Codex's built-in provider counts where openai_base_url sends it, and a guardian thread under its parent's session"
else
  fail "Codex's built-in provider counts where openai_base_url sends it, and a guardian thread under its parent's session" "$codex_native_report"
fi

# Kimchi's gateway bills what reaches it through any agent, so its usage is
# Kimchi's alone: pi and omp sessions on its provider ids (kimchi, kimchi-dev,
# kimchi-dev/<upstream>, kimchi-experimental) in pi's and omp's trees and its
# own harness, opencode's `kimchi` provider, and the Claude Code and Codex
# setups `kimchi claudecode` and `kimchi codex` write, sent to llm.kimchi.dev
# and llm.eu.kimchi.dev. Model names that would otherwise say Kimi, Z.ai,
# MiniMax, DeepSeek or Anthropic never take a turn the gateway served, and a
# lookalike id (kimchi-proxy) counts nowhere.
KIMCHI_HOME="$WORK/kimchi-gateway"
python3 - "$KIMCHI_HOME" <<'PY'
import json
import sqlite3
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
now_ms = int(time.time() * 1000) - 1000


def write(path, lines):
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join(json.dumps(line) + "\n" for line in lines))


# pi 1.4.0 and omp 18.12.6 lines: a model switch, a typed prompt, its reply.
def pi_session(path, provider, model, tokens, omp=False):
  switch = {"type": "model_change", "id": "m0", "parentId": None, "timestamp": stamp}
  switch.update({"runtime": {"version": "18.12.6"}, "model": f"{provider}/{model}"} if omp else {"provider": provider, "modelId": model})
  user = {"role": "user", "content": [{"type": "text", "text": "Say hi"}], "timestamp": now_ms}
  if omp:
    user["attribution"] = "user"
  write(path, [
    {"type": "session", "version": 3, "id": path.stem, "timestamp": stamp, "cwd": "/home/me"},
    switch,
    {"type": "message", "id": f"u-{path.stem}", "parentId": "m0", "timestamp": stamp, "message": user},
    {"type": "message", "id": f"a-{path.stem}", "parentId": f"u-{path.stem}", "timestamp": stamp, "message": {
      "role": "assistant", "content": [{"type": "text", "text": "hi"}], "api": "openai-completions", "provider": provider, "model": model,
      "usage": {"input": tokens, "output": 0, "cacheRead": 0, "cacheWrite": 0, "totalTokens": tokens}, "stopReason": "stop", "timestamp": now_ms}},
  ])


pi = home / ".pi/agent/sessions/--home-me--"
omp = home / ".omp/agent/sessions/-"
harness = home / ".config/kimchi/harness/sessions/--home-me--"
pi_session(pi / "pi-kimchi.jsonl", "kimchi", "zqk01-minimax-m3", 101)
pi_session(pi / "pi-kimchi-dev.jsonl", "kimchi-dev", "zqk02-kimi-k2.6", 102)
pi_session(pi / "pi-lookalike.jsonl", "kimchi-proxy", "zqk00-glm-5", 999)
pi_session(omp / "omp-kimchi.jsonl", "kimchi", "zqk03-kimi-k2.5", 103, omp=True)
pi_session(omp / "omp-upstream.jsonl", "kimchi-dev/zai", "zqk04-glm-5.2", 104, omp=True)
pi_session(omp / "omp-experimental.jsonl", "kimchi-experimental", "zqk05-deepseek-v4", 105, omp=True)
pi_session(harness / "harness-kimchi.jsonl", "kimchi", "zqk06-glm-5.2", 106)

# opencode 1.19.3 rows on the provider Kimchi's opencode setup adds.
db = home / ".local/share/opencode/opencode.db"
db.parent.mkdir(parents=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
user = {"role": "user", "time": {"created": now_ms}, "agent": "build", "model": {"providerID": "kimchi", "modelID": "zqk07-minimax-m3"}}
reply = {"parentID": "msg_k_u", "role": "assistant", "mode": "build", "agent": "build", "cost": 0, "modelID": "zqk07-minimax-m3", "providerID": "kimchi",
         "tokens": {"total": 107, "input": 107, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}}, "time": {"created": now_ms + 1, "completed": now_ms + 2}, "finish": "stop"}
conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [("msg_k_u", "ses_k", now_ms, now_ms, json.dumps(user)), ("msg_k_a", "ses_k", now_ms + 1, now_ms + 1, json.dumps(reply))])
conn.commit()
conn.close()

# Claude Code with the settings.json env `kimchi claudecode` writes, its
# replies on a Claude model and on models whose names say another provider.
lines = []
for n, (model, tokens) in enumerate((("claude-sonnet-4-5-zqk08", 108), ("kimi-k2.6-zqk09", 109), ("glm-5.2-zqk10", 110), ("MiniMax-M3-zqk11", 111), ("deepseek-v4-flash-zqk12", 112))):
  lines.append({"type": "user", "uuid": f"kc-prompt-{n}", "sessionId": "kc", "timestamp": stamp, "message": {"role": "user", "content": "go"}})
  lines.append({"type": "assistant", "sessionId": "kc", "timestamp": stamp, "requestId": f"kc-req-{n}",
                "message": {"id": f"kc-msg-{n}", "role": "assistant", "model": model, "usage": {"input_tokens": tokens, "output_tokens": 0}}})
write(home / ".claude/projects/project/kc.jsonl", lines)
(home / ".claude/settings.json").write_text(json.dumps({"env": {"ANTHROPIC_BASE_URL": "https://llm.eu.kimchi.dev/anthropic", "ANTHROPIC_API_KEY": ""}}))

# Codex as `kimchi codex` configures it.
(home / ".codex").mkdir()
(home / ".codex/config.toml").write_text('model_provider = "kimchi"\nmodel = "zqk13-minimax-m3"\n\n[model_providers.kimchi]\nname = "Kimchi Gateway"\nbase_url = "https://llm.kimchi.dev/openai/v1"\nwire_api = "responses"\n')
write(home / ".codex/sessions" / datetime.now().strftime("%Y/%m/%d") / "rollout-kimchi.jsonl", [
  {"timestamp": stamp, "type": "session_meta", "payload": {"model_provider": "kimchi"}},
  {"timestamp": stamp, "type": "turn_context", "payload": {"model": "zqk13-minimax-m3"}},
  {"timestamp": stamp, "type": "event_msg", "payload": {"type": "user_message", "message": "go"}},
  {"timestamp": stamp, "type": "event_msg", "payload": {"type": "token_count", "info": {
    "last_token_usage": {"input_tokens": 113, "cached_input_tokens": 0, "output_tokens": 0}, "total_token_usage": {"input_tokens": 113}}}},
])
PY
run_all "$KIMCHI_HOME" "$WORK/kimchi-gateway-results"

kimchi_gateway_report=$(python3 - "$WORK/kimchi-gateway-results" "${collectors[@]}" <<'PY'
import json
import re
import sys
from pathlib import Path

results = Path(sys.argv[1])
# Every zqkNN row once, under kimchi, and zqk00 under nobody: seven pi-format
# sessions, opencode's, Claude Code's and Codex's, one prompt per reply.
expected = {f"zqk{n:02d}": 100 + n for n in range(1, 14)}
seen = {}
for cid in sys.argv[2:]:
  try:
    record = json.loads((results / f"{cid}.json").read_text())
  except ValueError:
    print(f"{cid} printed no JSON record")
    continue
  for model, tokens in (record.get("todayTokensByModel") or {}).items():
    tag = re.search(r"zqk\d\d", model)
    if tag:
      seen.setdefault(tag.group(0), []).append((cid, tokens))
  if cid != "kimchi" and record.get("todayPrompts"):
    print(f"{cid} counted {record['todayPrompts']} of Kimchi's prompts")
  if cid == "kimchi" and (record.get("todayPrompts"), record.get("todaySessions")) != (13, 9):
    print(f"kimchi: prompts and sessions {(record.get('todayPrompts'), record.get('todaySessions'))}, expected (13, 9)")
for tag in sorted(set(expected) | set(seen)):
  want = [("kimchi", expected[tag])] if tag in expected else []
  if seen.get(tag, []) != want:
    print(f"{tag}: counted {seen.get(tag, [])}, expected {want}")
PY
)
if [[ -z $kimchi_gateway_report ]]; then
  pass "usage Kimchi's gateway billed through pi, omp, opencode, Claude Code or Codex counts once, under kimchi"
else
  fail "usage Kimchi's gateway billed through pi, omp, opencode, Claude Code or Codex counts once, under kimchi" "$kimchi_gateway_report"
fi

# ------------------------------------------- requests that never got a reply

# Shapes pi 1.4.0 and omp 18.12.6 wrote against a mock server. A prompt
# whose agent was killed mid-request leaves no assistant line, so it books
# on the model the session was on, never on the next provider's reply, and a
# fork copying it books it once. omp writes a reply that overflowed the
# model's context window twice under new ids, one response served once. A
# prompt omp refused before sending (Muse Code's invalid credential, an
# errorId and no duration) counts nowhere; one a server refused (a duration
# and a 400) counts.
STRANDED_HOME="$WORK/stranded"
python3 - "$STRANDED_HOME" <<'PY'
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
now_ms = int(time.time() * 1000) - 1000
cost = {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0, "total": 0}
zero = {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0, "totalTokens": 0, "cost": cost}


def spent(n):
  return {"input": 141601 + n, "output": 1456, "cacheRead": 1476, "cacheWrite": 0, "totalTokens": 144533 + n, "reasoningTokens": 1409, "cost": cost}


def user(n, omp=False):
  message = {"role": "user", "content": [{"type": "text", "text": "Say hi"}], "timestamp": now_ms}
  if omp:
    message["attribution"] = "user"
  return {"type": "message", "id": f"u{n}", "parentId": None, "timestamp": stamp, "message": message}


def reply(n, provider, model, usage, **extra):
  message = {"role": "assistant", "content": [{"type": "text", "text": "hi"}], "api": "openai-completions", "provider": provider, "model": model,
             "usage": usage, "stopReason": "stop", "timestamp": now_ms, **extra}
  return {"type": "message", "id": f"a{n}", "parentId": f"u{n}", "timestamp": stamp, "message": message}


def switch(n, provider, model, omp=False):
  if omp:
    return {"type": "model_change", "id": f"m{n}", "timestamp": stamp, "model": f"{provider}/{model}"}
  return {"type": "model_change", "id": f"m{n}", "timestamp": stamp, "provider": provider, "modelId": model}


def write(path, lines):
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join(json.dumps(line) + "\n" for line in lines))


pi = home / ".pi/agent/sessions/--home-me--"
omp = home / ".omp/agent/sessions/-"
# pi: killed waiting on Z.ai, then switched to DeepSeek, which answered.
write(pi / "hang-then-switched.jsonl", [
  {"type": "session", "version": 3, "id": "s1", "timestamp": stamp, "cwd": "/home/me"},
  switch(1, "zai", "e2e-hangpi2"), user(11),
  switch(12, "deepseek", "e2e-hangpi2ds"), user(12), reply(12, "deepseek", "e2e-hangpi2ds", spent(12), responseId="chatcmpl-12"),
])
# pi: killed waiting on Z.ai, then `--fork` onto DeepSeek, which answered.
parent = [
  {"type": "session", "version": 3, "id": "s2", "timestamp": stamp, "cwd": "/home/me"},
  switch(2, "zai", "e2e-hangfork"), user(21),
]
write(pi / "hang-parent.jsonl", parent)
write(pi / "hang-fork.jsonl", [
  {"type": "session", "version": 3, "id": "s3", "timestamp": stamp, "cwd": "/home/me", "parentSession": str(pi / "hang-parent.jsonl")},
  *parent[1:],
  switch(22, "deepseek", "e2e-hangforkds"), user(22), reply(22, "deepseek", "e2e-hangforkds", spent(22), responseId="chatcmpl-22"),
])
# omp: one response past the declared context window, written twice.
twice = reply(31, "deepseek", "e2e-dupb", spent(31), responseId="chatcmpl-31", duration=3.1, ttft=1.2, completedAt=now_ms)
again = json.loads(json.dumps(twice))
again["id"] = "a31b"
again["message"]["errorId"] = 0
write(omp / "overflow.jsonl", [
  {"type": "session", "id": "s4", "timestamp": stamp, "cwd": "/home/me"},
  switch(3, "deepseek", "e2e-dupb", omp=True), user(31, omp=True), twice, again,
])
# omp: Muse Code's credential refused before sending, twice.
refusal = {"stopReason": "error", "errorMessage": "Muse Code credential is invalid; sign in again", "errorId": 0, "completedAt": now_ms}
muse = [reply(n, "muse-code", "e2e-musecode-omp", zero) for n in (41, 42)]
for line in muse:
  line["message"].update(refusal)
write(omp / "refused-locally.jsonl", [
  {"type": "session", "id": "s5", "timestamp": stamp, "cwd": "/home/me"},
  switch(4, "muse-code", "e2e-musecode-omp", omp=True), user(41, omp=True), muse[0], user(42, omp=True), muse[1],
])
# omp: a 400 from Z.ai's server.
served = reply(51, "zai", "e2e-failomp", zero)
served["message"].update({"stopReason": "error", "errorMessage": "400 mock refused FAILME", "errorStatus": 400, "errorId": 400, "duration": 3.2, "completedAt": now_ms})
write(omp / "refused-by-server.jsonl", [
  {"type": "session", "id": "s6", "timestamp": stamp, "cwd": "/home/me"},
  switch(5, "zai", "e2e-failomp", omp=True), user(51, omp=True), served,
])
PY
run_all "$STRANDED_HOME" "$WORK/stranded-results"

stranded_report=$(python3 - "$WORK/stranded-results" "${collectors[@]}" <<'PY'
import json
import sys
from pathlib import Path

results = Path(sys.argv[1])
# (prompts, sessions, tokens) each collector must count; every other one none.
expected = {"zai": (3, 3, 0), "deepseek": (3, 3, (144533 + 12) + (144533 + 22) + (144533 + 31))}
for cid in sys.argv[2:]:
  try:
    record = json.loads((results / f"{cid}.json").read_text())
  except ValueError:
    print(f"{cid} printed no JSON record")
    continue
  want = expected.get(cid, (0, 0, 0))
  got = (record.get("todayPrompts"), record.get("todaySessions"), record.get("todayTotalTokens"))
  if got != want:
    print(f"{cid}: prompts, sessions and tokens {got}, expected {want}")
  if cid == "muse" and record.get("hasLocalStats"):
    print("muse: in use for prompts that never left the machine")
PY
)
if [[ -z $stranded_report ]]; then
  pass "a prompt killed mid-request, a reply omp wrote twice and a request omp never sent each count once or nowhere"
else
  fail "a prompt killed mid-request, a reply omp wrote twice and a request omp never sent each count once or nowhere" "$stranded_report"
fi

# A collector reads only its own share of opencode's `message` store. Finding
# the first step answering each prompt across providers once read every
# assistant row in the database on each collector's rebuild, so a collector
# with no rows there paid for everyone's history. Counted in SQLite VM steps,
# not seconds, so a slow machine can't flake it: a collector with one session
# among a thousand others' costs no more than a few gated scans of the table,
# and still books its prompt only where the first step is its own.
OC_SCALE_HOME="$WORK/oc-scale-home"
mkdir -p "$OC_SCALE_HOME"
oc_scale_report=$(python3 - "$ROOT" "$OC_SCALE_HOME" <<'PY'
import json
import os
import sqlite3
import sys
import time
from pathlib import Path

root, home = Path(sys.argv[1]), Path(sys.argv[2])
os.environ["HOME"] = str(home)
os.environ["XDG_DATA_HOME"] = str(home / ".local/share")
os.environ.pop("OPENCODE_DB", None)
sys.path.insert(0, str(root / "shell" / "plugins" / "agents"))
import collectors

db = home / ".local/share/opencode/opencode.db"
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
# The schema opencode 1.x creates, its session index included.
conn.execute("CREATE TABLE session (id text PRIMARY KEY, parent_id text, title text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL)")
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
conn.execute("CREATE INDEX message_session_time_created_id_idx ON message (session_id, time_created, id)")
now_ms = int(time.time() * 1000) - 60000
tokens = {"total": 1320, "input": 1200, "output": 20, "reasoning": 0, "cache": {"write": 0, "read": 100}}
rows = []


def prompt(session, n, providers):
  # A typed prompt and the tool loop answering it, one step per provider.
  at = now_ms + n * 100
  rows.append((f"msg_{session}_u{n}", session, at, {"role": "user", "time": {"created": at}, "agent": "build", "model": {"providerID": providers[0], "modelID": "m"}, "summary": {"diffs": []}}))
  for step, provider in enumerate(providers, 1):
    rows.append((f"msg_{session}_a{n}_{step}", session, at + step, {"parentID": f"msg_{session}_u{n}", "role": "assistant", "mode": "build", "agent": "build", "path": {"cwd": "/home/me", "root": "/"}, "cost": 0, "tokens": tokens, "modelID": "m", "providerID": provider, "time": {"created": at + step, "completed": at + step + 1}, "finish": "tool-calls"}))


sessions = [f"ses_other{s:04d}" for s in range(1000)]
for session in sessions:
  for n in range(3):
    prompt(session, n, ["anthropic"] * 4)
# The collector's one session: a prompt it answered first, and one whose
# first step was another provider's.
sessions.append("ses_mine")
prompt("ses_mine", 0, ["devin", "devin"])
prompt("ses_mine", 1, ["anthropic", "devin"])
for session in sessions:
  conn.execute("INSERT INTO session VALUES (?, NULL, 't', ?, ?)", (session, now_ms - 1000, now_ms - 1000))
conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [(mid, session, at, at, json.dumps(data)) for mid, session, at, data in rows])
conn.commit()
conn.close()

steps = [0]
connect = sqlite3.connect


def counted(*args, **kwargs):
  handle = connect(*args, **kwargs)
  handle.set_progress_handler(lambda: steps.__setitem__(0, steps[0] + 1), 100)
  return handle


def cost(run):
  steps[0] = 0
  sqlite3.connect = counted
  try:
    result = run()
  finally:
    sqlite3.connect = connect
  return steps[0], result


def gated_scan():
  handle = sqlite3.connect(db.as_uri() + "?mode=ro", uri=True)
  try:
    return handle.execute("SELECT m.id, m.data FROM message m WHERE m.data LIKE '%\"role\"%:%\"assistant\"%' AND m.data LIKE ?", ('%"providerID"%:%"devin"%',)).fetchall()
  finally:
    handle.close()


scan_cost, (found, complete) = cost(lambda: collectors.scan_opencode(['devin"'], lambda provider, model, entry: provider == "devin"))
gate_cost, _ = cost(gated_scan)
problems = []
if not complete:
  problems.append("the scan did not complete")
if (len(found), sum(row.prompts for row in found)) != (3, 1):
  problems.append(f"devin's rows {len(found)} with {sum(row.prompts for row in found)} prompts, expected 3 with 1")
if scan_cost > 6 * gate_cost:
  problems.append(f"scan_opencode took {scan_cost} progress ticks, over 6x the {gate_cost} of one gated scan")
print("\n".join(problems))
PY
)
if [[ -z $oc_scale_report ]]; then
  pass "a collector's opencode scan costs a few gated scans of the store, not a pass over every provider's steps"
else
  fail "a collector's opencode scan costs a few gated scans of the store, not a pass over every provider's steps" "$oc_scale_report"
fi

# ------------------- Codex profiles and a claimed id on the user's own hardware

# Codex 0.163 applies a <name>.config.toml profile only to a run given
# --profile, and that run's rollout still records only
# `"model_provider":"openai"`, so a profile's openai_base_url says nothing
# about plain `codex` runs: here it moves only the rollouts on the model the
# profile sets (zp941), while ChatGPT-plan rollouts (zp940), and a model no
# profile ties (zp943), stay codex's. A profile setting an OpenAI model can't
# be told from a plain run and moves nothing. A model_providers entry whose
# id another collector claims but whose base_url is this machine, as a
# self-hosted Kimchi gateway's `kimchi codex` setup writes it, is local's:
# the base URL decides (zp942). The lines are shaped as Codex 0.163 wrote
# them in real `codex exec` runs.
CODEX_PROFILE_HOME="$WORK/codex-profiles"
mkdir -p "$CODEX_PROFILE_HOME/.codex"
python3 - "$CODEX_PROFILE_HOME" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
rollouts = home / ".codex/sessions" / datetime.now().strftime("%Y/%m/%d")
rollouts.mkdir(parents=True)


def rollout(tag, provider, model, n):
  thread = f"01a164a4-8b38-7013-9a23-709319c3{n:04d}"
  turn = f"01a164a4-8b8b-71f1-b648-20be1fa2{n:04d}"
  usage = {"input_tokens": 18234 + n, "cached_input_tokens": 71, "cache_write_input_tokens": 31, "output_tokens": 51, "reasoning_output_tokens": 0, "total_tokens": 18285 + n}
  item = {"type": "UserMessage", "id": f"01a164a4-8c01-7231-a532-dda74a01{n:04d}", "content": [{"type": "text", "text": "go", "text_elements": []}]}
  lines = [
    {"timestamp": stamp, "ordinal": 0, "type": "session_meta", "payload": {"session_id": thread, "id": thread, "cli_version": "0.163.0", "history_mode": "paginated", "originator": "codex_exec", "source": "exec", "thread_source": "user", "model_provider": provider}},
    {"timestamp": stamp, "ordinal": 5, "type": "turn_context", "payload": {"model": model, "turn_id": turn}},
    {"timestamp": stamp, "ordinal": 8, "type": "event_msg", "payload": {"type": "item_completed", "thread_id": thread, "turn_id": turn, "item": item}},
    {"timestamp": stamp, "ordinal": 10, "type": "token_usage_record", "payload": {"thread_id": thread, "turn_id": turn, "session_id": thread, "response_id": f"resp_zp_{n:04d}", "usage": usage, "turn_token_usage": usage, "thread_token_usage": usage}},
  ]
  (rollouts / f"rollout-2026-10-22T13-24-27-{thread}.jsonl").write_text("".join(json.dumps(line) + "\n" for line in lines))


rollout("zp940", "openai", "gpt-5.1-codex-zp940", 940)
rollout("zp941", "openai", "hf:zai-org/GLM-4.6-zp941", 941)
rollout("zp942", "kimchi", "kimi-k2-zp942", 942)
rollout("zp943", "openai", "qwen3-coder-zp943", 943)
codex = home / ".codex"
(codex / "config.toml").write_text(
  'model = "gpt-5.1-codex-zp940"\n\n'
  '[model_providers.kimchi]\nname = "Kimchi Gateway"\nbase_url = "http://127.0.0.1:18491/openai/v1"\nwire_api = "responses"\n'
)
(codex / "syn.config.toml").write_text('model = "hf:zai-org/GLM-4.6-zp941"\nopenai_base_url = "https://api.synthetic.new/openai/v1"\n')
(codex / "or.config.toml").write_text('model = "gpt-5.1-codex-zp940"\nopenai_base_url = "https://openrouter.ai/api/v1"\n')
PY
run_all "$CODEX_PROFILE_HOME" "$WORK/codex-profile-results"
codex_profile_report=$(python3 - "$WORK/codex-profile-results" "${collectors[@]}" <<'PY'
import json
import re
import sys
from pathlib import Path

results = Path(sys.argv[1])
owners = {"zp940": "codex", "zp941": "synthetic", "zp942": "local", "zp943": "codex"}
counts = {"codex": (2, 2), "synthetic": (1, 1), "local": (1, 1), "openrouter": (0, 0), "kimchi": (0, 0)}
seen = {tag: set() for tag in owners}
for cid in sys.argv[2:]:
  try:
    record = json.loads((results / f"{cid}.json").read_text())
  except ValueError:
    print(f"{cid} printed no JSON record")
    continue
  if cid in counts and (record.get("totalPrompts"), record.get("totalSessions")) != counts[cid]:
    print(f"{cid} counted prompts and sessions {(record.get('totalPrompts'), record.get('totalSessions'))}, expected {counts[cid]}")
  for model, bucket in (record.get("modelUsage") or {}).items():
    if any(bucket.get(key) for key in ("inputTokens", "outputTokens", "cacheReadInputTokens", "cacheCreationInputTokens")):
      for tag in re.findall(r"zp94\d", model):
        seen[tag].add(cid)
for tag, owner in owners.items():
  if seen[tag] != {owner}:
    print(f"{tag}: counted by {sorted(seen[tag]) or 'nobody'}, expected {owner}")
PY
)
if [[ -z $codex_profile_report ]]; then
  pass "a Codex profile's openai_base_url moves only the rollouts on its model, and a claimed id on this machine is local's"
else
  fail "a Codex profile's openai_base_url moves only the rollouts on its model, and a claimed id on this machine is local's" "$codex_profile_report"
fi

# Kimchi 1.18 names each gateway route kimchi-dev/<upstream>, and the kimchi
# collector claims every such id by its prefix. A local.json naming one must
# not make local count those rows as well, while a self-hosted id beside it
# still counts. The replies are pi's own shape on Kimchi's gateway.
PREFIX_HOME="$WORK/kimchi-prefix"
mkdir -p "$PREFIX_HOME/.config/omarchy/agents" "$PREFIX_HOME/.pi/agent/sessions/-" "$PREFIX_HOME/.cache" "$PREFIX_HOME/.run"
echo '{"providers": ["Kimchi-Dev/MoonshotAI", "my-llama"]}' >"$PREFIX_HOME/.config/omarchy/agents/local.json"
python3 - "$PREFIX_HOME/.pi/agent/sessions/-/session.jsonl" <<'PY'
import json
import sys
from datetime import datetime, timezone

now = datetime.now(timezone.utc)
stamp = now.isoformat(timespec="milliseconds").replace("+00:00", "Z")
ms = int(now.timestamp() * 1000)
lines = [
  {"type": "session", "version": 3, "id": "01a16377-aaaa-72fe-95e0-9faf99826e64", "timestamp": stamp, "cwd": "/home/me"},
  {"type": "model_change", "id": "29d6576e", "parentId": None, "timestamp": stamp, "model": "kimchi/kimi-k2.5"},
]
for index, (provider, model, tokens) in enumerate((("kimchi-dev/moonshotai", "kimi-k2.5", 4201), ("my-llama", "llama-3.3", 3101))):
  lines.append({"type": "message", "id": f"u{index}", "timestamp": stamp, "message": {"role": "user", "content": [{"type": "text", "text": "Say hi"}], "attribution": "user", "timestamp": ms}})
  usage = {"input": tokens, "output": 82, "cacheRead": 102, "cacheWrite": 0, "totalTokens": tokens + 184, "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0, "total": 0}}
  lines.append({"type": "message", "id": f"a{index}", "parentId": f"u{index}", "timestamp": stamp, "message": {"role": "assistant", "content": [{"type": "text", "text": "Hi."}], "api": "openai-completions", "provider": provider, "model": model, "usage": usage, "stopReason": "stop", "timestamp": ms, "responseId": f"chatcmpl-{index}"}})
with open(sys.argv[1], "w") as handle:
  handle.writelines(json.dumps(line) + "\n" for line in lines)
PY
run_collector "$PREFIX_HOME" local "$WORK/prefix-local"
run_collector "$PREFIX_HOME" kimchi "$WORK/prefix-kimchi"
prefix_report=$(python3 - "$WORK/prefix-local.json" "$WORK/prefix-kimchi.json" <<'PY'
import json
import sys

problems = []
for path, expected in zip(sys.argv[1:], ({"llama-3.3"}, {"kimi-k2.5"})):
  try:
    models = set(json.load(open(path)).get("todayTokensByModel") or {})
  except (OSError, ValueError) as error:
    models = {f"unreadable: {error}"}
  if models != expected:
    problems.append(f"{path.rsplit('/', 1)[-1]} counts {sorted(models)}, expected {sorted(expected)}")
print("\n".join(problems))
PY
)
if [[ -z $prefix_report ]]; then
  pass "local leaves a configured kimchi-dev/<upstream> id to the kimchi collector"
else
  fail "local leaves a configured kimchi-dev/<upstream> id to the kimchi collector" "$prefix_report"
fi

# ------------------------------- A Codex rollout switching models mid-thread

# Behind a self-hosted openai_base_url, one built-in rollout can switch from
# an OpenAI model to a local one between turns (`/model`). Each typed prompt
# goes with the model that answered it, so codex books the first and local
# the second, and neither books the other's.
CODEX_MIXED_HOME="$WORK/codex-mixed-models"
mkdir -p "$CODEX_MIXED_HOME/.codex"
printf 'openai_base_url = "http://127.0.0.1:18495/v1"\n' >"$CODEX_MIXED_HOME/.codex/config.toml"
python3 - "$CODEX_MIXED_HOME" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
rollouts = home / ".codex/sessions" / datetime.now().strftime("%Y/%m/%d")
rollouts.mkdir(parents=True)
thread = "01a164b2-4c11-7a20-9d31-5e6f7a8b0950"
lines = [{"timestamp": stamp, "ordinal": 0, "type": "session_meta", "payload": {"session_id": thread, "id": thread, "cli_version": "0.163.0", "history_mode": "paginated", "originator": "codex-tui", "source": "cli", "thread_source": "user", "model_provider": "openai"}}]
total = {"input_tokens": 0, "cached_input_tokens": 0, "cache_write_input_tokens": 0, "output_tokens": 0, "reasoning_output_tokens": 0, "total_tokens": 0}
for n, model in enumerate(("gpt-5.1-codex-zm950", "qwen3-coder-zm951")):
  turn = f"01a164b2-4c8b-71f1-b648-20be1fa2{n:04d}"
  usage = {"input_tokens": 12234 + n, "cached_input_tokens": 71, "cache_write_input_tokens": 31, "output_tokens": 51, "reasoning_output_tokens": 0, "total_tokens": 12285 + n}
  total = {key: total[key] + usage[key] for key in total}
  item = {"type": "UserMessage", "id": f"01a164b2-4d01-7231-a532-dda74a01{n:04d}", "content": [{"type": "text", "text": "go", "text_elements": []}]}
  lines += [
    {"timestamp": stamp, "ordinal": 10 * n + 1, "type": "turn_context", "payload": {"model": model, "turn_id": turn}},
    {"timestamp": stamp, "ordinal": 10 * n + 2, "type": "event_msg", "payload": {"type": "item_completed", "thread_id": thread, "turn_id": turn, "item": item}},
    {"timestamp": stamp, "ordinal": 10 * n + 3, "type": "token_usage_record", "payload": {"thread_id": thread, "turn_id": turn, "session_id": thread, "response_id": f"resp_zm_{n:04d}", "usage": usage, "turn_token_usage": usage, "thread_token_usage": total}},
    {"timestamp": stamp, "ordinal": 10 * n + 4, "type": "event_msg", "payload": {"type": "token_count", "info": {"total_token_usage": total, "last_token_usage": usage, "model_context_window": 258400}}},
  ]
(rollouts / f"rollout-2026-10-22T14-02-11-{thread}.jsonl").write_text("".join(json.dumps(line) + "\n" for line in lines))
PY
run_collector "$CODEX_MIXED_HOME" codex "$WORK/codex-mixed-codex"
run_collector "$CODEX_MIXED_HOME" local "$WORK/codex-mixed-local"
codex_mixed_report=$(python3 - "$WORK/codex-mixed-codex.json" "$WORK/codex-mixed-local.json" <<'PY'
import json
import sys

problems = []
for path, model in zip(sys.argv[1:], ("gpt-5.1-codex-zm950", "qwen3-coder-zm951")):
  name = path.rsplit("/", 1)[-1]
  try:
    record = json.load(open(path))
  except (OSError, ValueError) as error:
    problems.append(f"{name} is unreadable: {error}")
    continue
  models = set(record.get("todayTokensByModel") or {})
  if models != {model}:
    problems.append(f"{name} counts {sorted(models)}, expected {[model]}")
  if (record.get("totalPrompts"), record.get("totalSessions")) != (1, 1):
    problems.append(f"{name} counted prompts and sessions {(record.get('totalPrompts'), record.get('totalSessions'))}, expected (1, 1)")
print("\n".join(problems))
PY
)
if [[ -z $codex_mixed_report ]]; then
  pass "a Codex rollout switching from an OpenAI model to a local one books each prompt once, with the model that answered it"
else
  fail "a Codex rollout switching from an OpenAI model to a local one books each prompt once, with the model that answered it" "$codex_mixed_report"
fi

# `codex exec -m <model> resume` and /model switch a thread's model with a
# thread_settings_applied event, as Codex 0.163 writes it, and the request a
# switch-time compaction sends goes out on the new model before that turn's
# turn_context names it. Behind a self-hosted openai_base_url the compaction
# is local's, as is a prompt typed after the switch that no request answered.
CODEX_SWITCH_HOME="$WORK/codex-switched-models"
mkdir -p "$CODEX_SWITCH_HOME/.codex"
printf 'openai_base_url = "http://127.0.0.1:18496/v1"\n' >"$CODEX_SWITCH_HOME/.codex/config.toml"
python3 - "$CODEX_SWITCH_HOME" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

home = Path(sys.argv[1])
stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
rollouts = home / ".codex/sessions" / datetime.now().strftime("%Y/%m/%d")
rollouts.mkdir(parents=True)


def context(model):
  return lambda thread, n: {"type": "turn_context", "payload": {"model": model, "turn_id": f"turn{n}"}}


def switch(model):
  return lambda thread, n: {"type": "event_msg", "payload": {"type": "thread_settings_applied", "thread_id": thread, "thread_settings": {
    "model": model, "model_provider_id": "openai", "approval_policy": "never", "approvals_reviewer": "auto_review",
    "collaboration_mode": {"mode": "default", "settings": {"model": model, "reasoning_effort": None, "developer_instructions": None}},
    "cwd": str(home), "disabled_plugin_ids": [], "runtime_workspace_roots": [str(home)]}}}


def typed(thread, n):
  item = {"type": "UserMessage", "id": f"01a164cc-7301-7231-a532-dda74a01{n:04d}", "content": [{"type": "text", "text": "go", "text_elements": []}]}
  return {"type": "event_msg", "payload": {"type": "item_completed", "thread_id": thread, "turn_id": f"turn{n}", "item": item}}


def compacted(thread, n):
  return {"type": "compacted", "payload": {"message": "", "replacement_history": []}}


def write(thread, steps):
  """A rollout of `steps`: line makers, and the input tokens of each request
  a token_usage_record names."""
  total = {"input_tokens": 0, "cached_input_tokens": 0, "cache_write_input_tokens": 0, "output_tokens": 0, "reasoning_output_tokens": 0, "total_tokens": 0}
  lines = [{"type": "session_meta", "payload": {"session_id": thread, "id": thread, "cli_version": "0.163.0", "history_mode": "paginated", "originator": "codex_exec", "source": "exec", "thread_source": "user", "model_provider": "openai"}}]
  for n, step in enumerate(steps):
    if isinstance(step, int):
      usage = {"input_tokens": step, "cached_input_tokens": 71, "cache_write_input_tokens": 31, "output_tokens": 51, "reasoning_output_tokens": 0, "total_tokens": step + 51}
      total = {key: total[key] + usage[key] for key in total}
      lines.append({"type": "token_usage_record", "payload": {"thread_id": thread, "turn_id": f"turn{n}", "session_id": thread, "response_id": f"resp_zs_{n:04d}", "usage": usage, "turn_token_usage": usage, "thread_token_usage": total}})
    else:
      lines.append(step(thread, n))
  (rollouts / f"rollout-2026-10-22T14-07-55-{thread}.jsonl").write_text("".join(json.dumps({"timestamp": stamp, **line}) + "\n" for line in lines))


local = "hf:zai-org/GLM-4.6-zs961"
write("01a164cc-54d9-7f81-80d2-0cbf0cd6a960", [
  context("gpt-5.1-codex-zs960"), switch("gpt-5.1-codex-zs960"), typed, 301234,
  switch(local), switch(local), 2234, compacted, context(local), switch(local), typed, 3234,
])
write("01a164cc-54d9-7f81-80d2-0cbf0cd6a962", [context("gpt-5.1-codex-zs962"), typed, 1234, switch(local), typed])
PY
run_collector "$CODEX_SWITCH_HOME" codex "$WORK/codex-switched-codex"
run_collector "$CODEX_SWITCH_HOME" local "$WORK/codex-switched-local"
codex_switched_report=$(python3 - "$WORK/codex-switched-codex.json" "$WORK/codex-switched-local.json" <<'PY'
import json
import sys

expected = {
  "codex-switched-codex.json": ({"gpt-5.1-codex-zs960": 301285, "gpt-5.1-codex-zs962": 1285}, 2, 2),
  "codex-switched-local.json": ({"hf:zai-org/GLM-4.6-zs961": 2285 + 3285}, 2, 2),
}
problems = []
for path in sys.argv[1:]:
  name = path.rsplit("/", 1)[-1]
  try:
    record = json.load(open(path))
  except (OSError, ValueError) as error:
    problems.append(f"{name} is unreadable: {error}")
    continue
  got = (record.get("todayTokensByModel"), record.get("totalPrompts"), record.get("totalSessions"))
  if got != expected[name]:
    problems.append(f"{name} counts tokens, prompts and sessions {got}, expected {expected[name]}")
print("\n".join(problems))
PY
)
if [[ -z $codex_switched_report ]]; then
  pass "a Codex model switch books the requests and prompts after thread_settings_applied to the model switched to"
else
  fail "a Codex model switch books the requests and prompts after thread_settings_applied to the model switched to" "$codex_switched_report"
fi

# --------------------- A pi or omp prompt a fork answered on another provider

# A fork copies its parent's messages with their ids and timestamps, so a
# prompt the parent's provider failed on and a fork answered after switching
# provider (`/model`) is one typed message. It counts once, under the
# collector of the reply that answered it, never also under the parent's
# provider, even when the fork holds no line of the parent's provider at all.
FORKED_HOME="$WORK/pi-forked-provider"
python3 - "$FORKED_HOME" <<'PY'
import json
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

home = Path(sys.argv[1])
now = datetime.now(timezone.utc)


def stamp(offset):
  return (now + timedelta(seconds=offset)).isoformat(timespec="milliseconds").replace("+00:00", "Z")


def millis(offset):
  return int((now + timedelta(seconds=offset)).timestamp() * 1000)


def user(entry_id, offset):
  return {"type": "message", "id": entry_id, "parentId": None, "timestamp": stamp(offset),
          "message": {"role": "user", "content": [{"type": "text", "text": "go"}], "timestamp": millis(offset)}}


def reply(entry_id, provider, model, offset, tokens, **extra):
  usage = {"input": tokens, "output": 1 if tokens else 0, "cacheRead": 0, "cacheWrite": 0, "totalTokens": tokens + 1 if tokens else 0,
           "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0, "total": 0}}
  message = {"role": "assistant", "content": [], "api": "openai-completions", "provider": provider, "model": model, "usage": usage,
             "stopReason": "stop" if tokens else "error", "timestamp": millis(offset), **extra}
  if not tokens:
    message["errorMessage"] = "400 status code (no body)"
  return {"type": "message", "id": entry_id, "parentId": None, "timestamp": stamp(offset), "message": message}


def write(path, header, lines):
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text("".join(json.dumps(line) + "\n" for line in [header, *lines]))


# pi 1.4.0: kimchi failed on the prompt, and the fork answered it on openrouter.
pi = home / ".pi/agent/sessions/--home-me--"
parent = [{"type": "model_change", "id": "zf1", "parentId": None, "timestamp": stamp(0), "provider": "kimchi", "modelId": "kimi-k2.5-zf950"},
          user("zf2", 1), reply("zf3", "kimchi", "kimi-k2.5-zf950", 2, 0)]
write(pi / "parent.jsonl", {"type": "session", "version": 3, "id": "zf-parent", "timestamp": stamp(0), "cwd": "/home/me"}, parent)
write(pi / "fork.jsonl", {"type": "session", "version": 3, "id": "zf-fork", "timestamp": stamp(3), "cwd": "/home/me", "parentSession": str(pi / "parent.jsonl")},
      parent + [{"type": "model_change", "id": "zf4", "parentId": None, "timestamp": stamp(3), "provider": "openrouter", "modelId": "z-ai/glm-zf951"},
                reply("zf5", "openrouter", "z-ai/glm-zf951", 4, 40)])
# omp 18.12: zai failed on the prompt, and a fork cut before that reply
# answered it on synthetic, so the fork holds no zai line.
omp = home / ".omp/agent/sessions/--home-me--"
prompt = user("zf6", 1)
write(omp / "parent.jsonl", {"type": "session", "version": 3, "id": "zf-oparent", "timestamp": stamp(0), "cwd": "/home/me"},
      [prompt, reply("zf7", "zai", "glm-zf952", 2, 0, errorStatus=400, duration=310)])
write(omp / "fork.jsonl", {"type": "session", "version": 3, "id": "zf-ofork", "timestamp": stamp(3), "cwd": "/home/me", "parentSession": str(omp / "parent.jsonl")},
      [prompt, {"type": "model_change", "id": "zf8", "parentId": None, "timestamp": stamp(3), "model": "synthetic/hf:zai-org/GLM-zf953"},
       reply("zf9", "synthetic", "hf:zai-org/GLM-zf953", 4, 50, duration=820)])
PY
for id in kimchi openrouter zai synthetic; do
  run_collector "$FORKED_HOME" "$id" "$WORK/pi-forked-$id"
done
forked_report=$(python3 - "$WORK" <<'PY'
import json
import sys

expected = {"kimchi": (0, 0), "openrouter": (1, 41), "zai": (0, 0), "synthetic": (1, 51)}
problems = []
for id, want in expected.items():
  try:
    record = json.load(open(f"{sys.argv[1]}/pi-forked-{id}.json"))
  except (OSError, ValueError) as error:
    problems.append(f"{id} is unreadable: {error}")
    continue
  got = (record.get("totalPrompts") or 0, record.get("todayTotalTokens") or 0)
  if got != want:
    problems.append(f"{id} counted (prompts, tokens) {got}, expected {want}")
print("\n".join(problems))
PY
)
if [[ -z $forked_report ]]; then
  pass "a pi or omp prompt a fork answered on another provider counts once, under the provider that answered it"
else
  fail "a pi or omp prompt a fork answered on another provider counts once, under the provider that answered it" "$forked_report"
fi
