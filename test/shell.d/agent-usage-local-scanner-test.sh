#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3
require_command rg

SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT

collector="$ROOT/bin/omarchy-agent-usage-local"
unset PI_CODING_AGENT_DIR OPENCODE_DB

# A fixture home with everything the collector reads inside it.
use_home() {
  export HOME="$1"
  export CODEX_HOME="$1/.codex"
  export XDG_CACHE_HOME="$1/.cache"
  export XDG_DATA_HOME="$1/.local/share"
  export XDG_CONFIG_HOME="$1/.config"
  mkdir -p "$CODEX_HOME/sessions/$(date +%Y/%m/%d)" "$XDG_CONFIG_HOME/omarchy/agents" "$XDG_DATA_HOME/opencode"
}

timestamp="$(date +%Y-%m-%d)T12:00:00Z"
rollouts="$(date +%Y/%m/%d)"

# rollout <name> <provider> <model> [<token_count lines>...]: a Codex rollout
# whose turns each spend 1000 input and 100 output tokens.
token_count() {
  local total=$1
  printf '{"timestamp":"%s","type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":1000,"output_tokens":100,"cached_input_tokens":0},"total_token_usage":{"input_tokens":%s}}}}\n' "$timestamp" "$total"
}
rollout() {
  local name=$1 provider=$2 model=$3
  {
    printf '{"timestamp":"%s","type":"session_meta","payload":{"model_provider":"%s"}}\n' "$timestamp" "$provider"
    printf '{"timestamp":"%s","type":"turn_context","payload":{"model":"%s"}}\n' "$timestamp" "$model"
    token_count 1000
  } >"$CODEX_HOME/sessions/$rollouts/rollout-$name.jsonl"
}

# ------------------------------------------------------------ unused machine

use_home "$SCRATCH/empty"
result=$("$collector")
[[ $(jq -c '[.ready, .name, .tierLabel, .limits, .usageStatusText, .authHelpText, .todayTotalTokens, (.recentDays | length), .modelUsage, has("balance")]' <<<"$result") == '[false,"Local models","",[],"","",0,7,{},false]' ]] ||
  fail "Local collector prints an empty, not-ready record on an unused machine" "$result"
pass "Local collector prints an empty, not-ready record on an unused machine"

# ------------------------------------------------------------------ Codex

use_home "$SCRATCH/codex"
cat >"$CODEX_HOME/config.toml" <<'EOF'
[model_providers.homelab]
base_url = "http://server.home:11434/v1"

[model_providers.openrouter]
base_url = "https://openrouter.ai/api/v1"
EOF

rollout homelab homelab qwen-net       # another machine on the LAN
rollout ollama ollama qwen-here        # this machine, a well-known runtime
rollout paid openrouter claude-paid    # a third-party API: neither collector
rollout sub openai gpt-sub             # the Codex subscription
rollout cloud ollama gpt-oss:120b-cloud  # Ollama Cloud, through the local daemon
# A quota update repeats the last turn's usage with an unchanged cumulative
# total; a real second turn moves it.
{ token_count 1000; token_count 2000; } >>"$CODEX_HOME/sessions/$rollouts/rollout-ollama.jsonl"
# A fork copies its parent's session_meta after its own; the first decides.
{
  printf '{"timestamp":"%s","type":"session_meta","payload":{"model_provider":"openai"}}\n' "$timestamp"
  printf '{"timestamp":"%s","type":"session_meta","payload":{"model_provider":"ollama"}}\n' "$timestamp"
  printf '{"timestamp":"%s","type":"turn_context","payload":{"model":"qwen-forked"}}\n' "$timestamp"
  token_count 1000
} >"$CODEX_HOME/sessions/$rollouts/rollout-fork.jsonl"

local_result=$("$collector")
[[ $(jq -c '[.modelUsage | keys[]]' <<<"$local_result") == '["qwen-here","qwen-net"]' ]] ||
  fail "Local collector counts LAN endpoints and known runtimes, nothing else" "$local_result"
[[ $(jq -c '[.todayTotalTokens, .modelUsage["qwen-here"].inputTokens, .todayPrompts, .ready]' <<<"$local_result") == "[3300,2000,3,true]" ]] ||
  fail "Local collector counts a repeated Codex token_count once" "$local_result"
pass "Local collector counts self-hosted Codex turns once, leaving Ollama Cloud and the subscription out"

# The Local and Codex collectors partition the sessions directory: the
# subscription's turns are Codex's alone, and no model shows in both.
cat >"$SCRATCH/codex/codex" <<'EOF'
#!/bin/bash
while read -r request; do
  id=$(jq -r '.id // empty' <<<"$request")
  case "$(jq -r '.method // empty' <<<"$request")" in
    initialize) jq -cn --argjson id "$id" '{id: $id, result: {}}' ;;
    account/read) jq -cn --argjson id "$id" '{id: $id, result: {account: {}}}' ;;
    account/rateLimits/read) jq -cn --argjson id "$id" '{id: $id, result: {rateLimits: {}}}' ;;
  esac
done
EOF
chmod +x "$SCRATCH/codex/codex"
codex_result=$(PATH="$SCRATCH/codex:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --force)
[[ $(jq -c '[.modelUsage | keys[]]' <<<"$codex_result") == '["gpt-sub","qwen-forked"]' ]] ||
  fail "Codex collector keeps the subscription's own turns" "$codex_result"
overlap=$(jq -n --argjson a "$(jq -c '.modelUsage | keys' <<<"$local_result")" --argjson b "$(jq -c '.modelUsage | keys' <<<"$codex_result")" '[$a[] | select(. as $m | $b | index($m))] | length')
[[ $overlap == "0" ]] ||
  fail "Local and Codex collectors never count the same turn" "$local_result$codex_result"
pass "Local and Codex collectors partition rollouts without overlap"

# A reused rollout record is replayed, not reread: change a file's contents
# but not its size or mtime, and the old count stands.
file="$CODEX_HOME/sessions/$rollouts/rollout-homelab.jsonl"
touch -r "$file" "$SCRATCH/stamp"
sed -i 's/"output_tokens":100/"output_tokens":900/' "$file"
touch -r "$SCRATCH/stamp" "$file"
[[ $(jq -r '.modelUsage["qwen-net"].outputTokens' <<<"$("$collector" --limits-only)") == "100" ]] ||
  fail "Local collector replays an unchanged rollout from its file cache" "$("$collector" --limits-only)"
rm -f "$XDG_CACHE_HOME"/omarchy/agent-usage/local-scan-*.json
[[ $(jq -r '.modelUsage["qwen-net"].outputTokens' <<<"$("$collector")") == "100" ]] ||
  fail "Local collector replays an unchanged rollout after the scan cache expires" "$("$collector")"
[[ $(jq -r '.modelUsage["qwen-net"].outputTokens' <<<"$("$collector" --force)") == "900" ]] ||
  fail "Local collector --force rereads every rollout" "$("$collector" --force)"
pass "Local collector keeps a per-file Codex cache, and --force rereads"

# A provider the heuristics can't see is named in local.json, and takes
# effect without --force, since the classification is part of the scan key.
echo '{"providers":["mystery"]}' >"$XDG_CONFIG_HOME/omarchy/agents/local.json"
rollout mystery mystery qwen-custom
[[ $(jq -r '.modelUsage["qwen-custom"].inputTokens' <<<"$("$collector")") == "1000" ]] ||
  fail "Local collector honors configured provider ids" "$("$collector")"
pass "Local collector honors configured provider ids"

# A provider collector's id is never local, whatever local.json says.
echo '{"providers":["openrouter","openai"]}' >"$XDG_CONFIG_HOME/omarchy/agents/local.json"
[[ $(jq -c '[.modelUsage | keys[]]' <<<"$("$collector")") == '["qwen-here","qwen-net"]' ]] ||
  fail "Local collector never counts a provider another collector counts" "$("$collector")"
pass "Local collector never counts a provider another collector counts"

# ------------------------------------------------------------- pi and omp

use_home "$SCRATCH/pi"
sessions="$HOME/.pi/agent/sessions/--work--"
mkdir -p "$sessions" "$HOME/.omp/profiles/box/agent/sessions"
line() {
  printf '{"type":"message","id":"%s","timestamp":"%s","message":{"role":"assistant","provider":"%s","model":"%s","usage":{"input":%s,"output":10,"cacheRead":0,"cacheWrite":0}}}\n' "$1" "$timestamp" "$2" "$3" "$4"
}
{
  line a ollama qwen3:30b 100
  line b LMStudio qwen3:8b 200
  line c ollama glm-4.6:cloud 999
  line d ollama-cloud qwen3:30b 999
  line e anthropic claude 999
  # The Codex collector counts its API whatever the provider id says.
  printf '{"type":"message","id":"x","timestamp":"%s","message":{"role":"assistant","provider":"ollama","api":"openai-codex-responses","model":"gpt-5","usage":{"input":999}}}\n' "$timestamp"
} >"$sessions/one.jsonl"
{
  printf '{"type":"session","parentSession":"%s"}\n' "$sessions/one.jsonl"
  line a ollama qwen3:30b 100
  line f vllm llama-70b 300
} >"$HOME/.omp/profiles/box/agent/sessions/fork.jsonl"
printf '*\n' >"$HOME/.gitignore"
git -C "$HOME" init -q

result=$("$collector")
# a 110, b 210, f 310; the fork's copy of a counts once, Ollama Cloud models
# and the ollama-cloud provider belong to the ollama collector, and Anthropic
# to claude.
[[ $(jq -c '[.todayTotalTokens, .todayPrompts, .todaySessions, ([.modelUsage | keys[]])]' <<<"$result") == '[630,3,2,["llama-70b","qwen3:30b","qwen3:8b"]]' ]] ||
  fail "Local collector counts pi and omp sessions on local providers once" "$result"
pass "Local collector counts pi and omp sessions on local providers once, profiles included"

moved="$HOME/moved"
mkdir -p "$moved/sessions"
line g llamacpp gemma 40 >"$moved/sessions/moved.jsonl"
[[ $(jq -r '.modelUsage.gemma.inputTokens' <<<"$(PI_CODING_AGENT_DIR="$moved" "$collector" --force)") == "40" ]] ||
  fail "Local collector follows PI_CODING_AGENT_DIR" "$(PI_CODING_AGENT_DIR="$moved" "$collector" --force)"
pass "Local collector follows PI_CODING_AGENT_DIR"

# ---------------------------------------------------------------- opencode

use_home "$SCRATCH/opencode"
echo '{"providers":["homelab"]}' >"$XDG_CONFIG_HOME/omarchy/agents/local.json"
{ python3 - "$XDG_DATA_HOME/opencode/opencode.db" || true; } 2>/dev/null <<'PY'
import json, os, sqlite3, sys, time
conn = sqlite3.connect(sys.argv[1]); now = int(time.time() * 1000)
conn.execute("PRAGMA journal_mode=WAL")
conn.execute("CREATE TABLE message (id TEXT PRIMARY KEY, session_id TEXT NOT NULL, time_created INTEGER, time_updated INTEGER, data TEXT NOT NULL)")
conn.execute("CREATE TABLE session_message (id TEXT PRIMARY KEY, session_id TEXT, type TEXT, time_created INTEGER, data TEXT)")

def message(mid, provider, model, role="assistant", inp=0, out=0, reasoning=0):
  return (mid, "ses_1", now, now, json.dumps({
    "role": role, "providerID": provider, "modelID": model,
    "tokens": {"input": inp, "output": out, "reasoning": reasoning, "cache": {"read": 0, "write": 0}},
    "time": {"created": now},
  }))

conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
  message("m1", "ollama", "qwen-oc", inp=100, out=10, reasoning=5),
  message("m2", "homelab", "qwen-cfg", inp=50, out=5),
  message("m3", "anthropic", "claude-paid", inp=999, out=999),
  message("m4", "openai", "gpt-sub", inp=999, out=999),
  message("m5", "ollama", "qwen-oc", role="user", inp=999),
  message("m6", "ollama", "kimi-k2:1t-cloud", inp=999),
])
conn.execute("INSERT INTO message VALUES ('m7', 'ses_1', ?, ?, 'not json \"providerID\":\"ollama\"')", (now, now))
conn.execute("INSERT INTO session_message VALUES ('c1', 'ses_2', 'compaction', ?, ?)", (now, json.dumps({
  "model": {"providerID": "ollama", "id": "qwen-oc"}, "tokens": {"input": 30, "output": 0, "cache": {"read": 0, "write": 0}}, "time": {"created": now}})))
conn.commit()
# Killed with the rows still in the write-ahead log: an immutable open would
# not see them.
os.kill(os.getpid(), 9)
PY

oc=$("$collector")
# 115 = 100 + 10 + 5 reasoning; 55 = 50 + 5; the compaction's 30. Paid
# providers, a user message, a cloud model and a malformed row add nothing.
[[ $(jq -c '[.todayTotalTokens, ([.modelUsage | keys[]]), .modelUsage["qwen-oc"].outputTokens, .todaySessions]' <<<"$oc") == '[200,["qwen-cfg","qwen-oc"],15,2]' ]] ||
  fail "Local collector counts self-hosted opencode turns, compactions included, from a live database" "$oc"
pass "Local collector counts self-hosted opencode turns, compactions included, from a live database"

cache_file=$(ls "$XDG_CACHE_HOME"/omarchy/agent-usage/local-scan-*.json | head -n 1)
[[ $(stat -c %a "$cache_file") == "644" && $(jq -r '.stats.todayTotalTokens' "$cache_file") == "200" ]] ||
  fail "Local collector writes a readable scan cache" "$(cat "$cache_file")"

python3 - "$XDG_DATA_HOME/opencode/opencode.db" <<'PY'
import json, sqlite3, sys, time
conn = sqlite3.connect(sys.argv[1]); now = int(time.time() * 1000)
conn.execute("INSERT INTO message VALUES ('m8', 'ses_1', ?, ?, ?)", (now, now, json.dumps({
  "role": "assistant", "providerID": "ollama", "modelID": "qwen-oc",
  "tokens": {"input": 30, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}}, "time": {"created": now}})))
conn.commit(); conn.close()
PY
[[ $(jq -r '.todayTotalTokens' <<<"$("$collector")") == "200" ]] ||
  fail "Local collector reuses a seconds-old scan" "$("$collector")"
[[ $(jq -r '.todayTotalTokens' <<<"$("$collector" --force)") == "230" ]] ||
  fail "Local collector --force rescans past the cache" "$("$collector" --force)"
pass "Local collector reuses a recent scan and --force rescans"

jq -c '.scanDate = "1999-01-01" | .stats.todayTotalTokens = 1' "$cache_file" >"$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
[[ $(jq -r '.todayTotalTokens' <<<"$("$collector" --limits-only)") == "230" ]] ||
  fail "Local collector treats a scan from another day as a miss" "$("$collector" --limits-only)"
printf '[]' >"$cache_file"
[[ $(jq -r '.todayTotalTokens' <<<"$("$collector" --limits-only)") == "230" ]] ||
  fail "Local collector recovers from a corrupt cache file" "$("$collector" --limits-only)"
touch "$SCRATCH/not-a-dir"
[[ $(jq -r '.todayTotalTokens' <<<"$(XDG_CACHE_HOME="$SCRATCH/not-a-dir" "$collector" 2>/dev/null)") == "230" ]] ||
  fail "Local collector still prints a record when the cache is unwritable" "unwritable"
pass "Local collector treats stale, corrupt and unwritable caches as misses"

# A scan cut short by a database error is not cached as the whole story.
use_home "$SCRATCH/broken"
echo "not a database" >"$XDG_DATA_HOME/opencode/opencode.db"
"$collector" >/dev/null
[[ -z $(ls "$XDG_CACHE_HOME"/omarchy/agent-usage/local-scan-*.json 2>/dev/null) ]] ||
  fail "Local collector does not cache an interrupted opencode scan" "broken-db"
pass "Local collector does not cache an interrupted opencode scan"

# ------------------------------------------------------- claimed providers

# A local.json naming the ids the provider collectors claim leaves exactly
# their rows out: every MiniMax and Mistral id, pi's google-antigravity, and
# opencode's google provider only on its antigravity- models, which the agy
# collector counts. An id no collector matches, like minimax-coding, and pi's
# google rows, which agy never reads, stay local's.
use_home "$SCRATCH/claimed"
echo '{"providers":["google","google-antigravity","google-vertex","mistral","minimax-cn","minimax-coding-plan","minimax-cn-coding-plan","minimax-coding"]}' >"$XDG_CONFIG_HOME/omarchy/agents/local.json"
python3 - "$XDG_DATA_HOME/opencode/opencode.db" <<'PY'
import json, sqlite3, sys, time
conn = sqlite3.connect(sys.argv[1]); now = int(time.time() * 1000)
conn.execute("CREATE TABLE message (id TEXT PRIMARY KEY, session_id TEXT NOT NULL, time_created INTEGER, time_updated INTEGER, data TEXT NOT NULL)")
conn.execute("CREATE TABLE session_message (id TEXT PRIMARY KEY, session_id TEXT, type TEXT, time_created INTEGER, data TEXT)")

def message(mid, provider, model, inp):
  return (mid, "ses_1", now, now, json.dumps({
    "role": "assistant", "providerID": provider, "modelID": model,
    "tokens": {"input": inp, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
    "time": {"created": now},
  }))

conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
  message("m1", "google", "gemini-oc", 10),
  message("m2", "google", "antigravity-claude", 999),
  message("m3", "google-vertex", "antigravity-gemini", 999),
  message("m4", "mistral", "devstral", 999),
  message("m5", "minimax-cn", "MiniMax-M3", 999),
  message("m6", "minimax-coding-plan", "MiniMax-M3", 999),
  message("m7", "minimax-cn-coding-plan", "MiniMax-M3", 999),
  message("m8", "minimax-coding", "minimax-gateway", 20),
])
conn.execute("INSERT INTO session_message VALUES ('s1', 'ses_2', 'assistant', ?, ?)", (now, json.dumps({
  "model": {"providerID": "google", "id": "antigravity-gemini"}, "tokens": {"input": 999, "output": 0, "cache": {"read": 0, "write": 0}}, "time": {"created": now}})))
conn.execute("INSERT INTO session_message VALUES ('s2', 'ses_2', 'assistant', ?, ?)", (now, json.dumps({
  "model": {"providerID": "google-vertex", "id": "gemini-vertex"}, "tokens": {"input": 30, "output": 0, "cache": {"read": 0, "write": 0}}, "time": {"created": now}})))
conn.commit(); conn.close()
PY
mkdir -p "$HOME/.pi/agent/sessions/--claimed--"
{
  line p1 google-antigravity antigravity-pi 999
  line p2 mistral devstral 999
  line p3 google antigravity-pi-gemini 40
} >"$HOME/.pi/agent/sessions/--claimed--/one.jsonl"
claimed=$("$collector")
[[ $(jq -c '[.todayTotalTokens, ([.modelUsage | keys[]])]' <<<"$claimed") == '[110,["antigravity-pi-gemini","gemini-oc","gemini-vertex","minimax-gateway"]]' ]] ||
  fail "Local collector leaves out exactly the rows another collector claims" "$claimed"
pass "Local collector leaves out exactly the rows another collector claims"
