#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq
require_command python3

LOCAL_HOME=$(mktemp -d)
trap 'rm -rf "$LOCAL_HOME"' EXIT
mkdir -p "$LOCAL_HOME/.codex/sessions/$(date +%Y/%m/%d)"

cat >"$LOCAL_HOME/.codex/config.toml" <<'EOF'
[model_providers.homelab]
base_url = "http://server.home:11434/v1"

[model_providers.openrouter]
base_url = "https://openrouter.ai/api/v1"
EOF

timestamp="$(date +%Y-%m-%d)T12:00:00Z"
rollout() {
  local name=$1 provider=$2 model=$3
  cat >"$LOCAL_HOME/.codex/sessions/$(date +%Y/%m/%d)/rollout-$name.jsonl" <<EOF
{"timestamp":"$timestamp","type":"session_meta","payload":{"model_provider":"$provider"}}
{"timestamp":"$timestamp","type":"turn_context","payload":{"model":"$model"}}
{"timestamp":"$timestamp","type":"event_msg","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":1000,"output_tokens":100,"cached_input_tokens":0,"cache_write_input_tokens":0}}}}
EOF
}

rollout homelab homelab qwen-net       # another machine on the LAN
rollout ollama ollama qwen-here        # this machine, well-known runtime
rollout paid openrouter claude-paid    # third-party API: neither collector
rollout sub openai gpt-sub             # the Codex subscription

env_args=(HOME="$LOCAL_HOME" CODEX_HOME="$LOCAL_HOME/.codex" XDG_CACHE_HOME="$LOCAL_HOME/.cache"
  XDG_DATA_HOME="$LOCAL_HOME/.local/share" XDG_CONFIG_HOME="$LOCAL_HOME/.config")

local_result=$(env "${env_args[@]}" "$ROOT/bin/omarchy-agent-usage-local")

[[ $(jq -r '.todayTotalTokens' <<<"$local_result") == "2200" ]] ||
  fail "Local collector counts self-hosted turns from this machine and the network" "$local_result"
[[ $(jq -r '.modelUsage | keys | sort | join(",")' <<<"$local_result") == "qwen-here,qwen-net" ]] ||
  fail "Local collector counts LAN endpoints and known runtimes, nothing else" "$local_result"
pass "Local collector counts self-hosted turns from this machine and the network"

[[ $(jq -r '.limits | length' <<<"$local_result") == "0" && $(jq -r '.tierLabel' <<<"$local_result") == "Self-hosted" ]] ||
  fail "Local collector reports no limits" "$local_result"
pass "Local collector reports no limits for unmetered work"

# A custom gateway the heuristics cannot see is named in config.
mkdir -p "$LOCAL_HOME/.config/omarchy/agents"
echo '{"providers":["mystery"]}' >"$LOCAL_HOME/.config/omarchy/agents/local.json"
rollout mystery mystery qwen-custom
# --force: the config changed inside the scan-reuse window, so a no-flag run
# would legitimately serve the previous scan.
local_result=$(env "${env_args[@]}" "$ROOT/bin/omarchy-agent-usage-local" --force)
[[ $(jq -r '.modelUsage["qwen-custom"].inputTokens' <<<"$local_result") == "1000" ]] ||
  fail "Local collector honors configured provider ids" "$local_result"
pass "Local collector honors configured provider ids"

# The local and Codex collectors partition the same sessions directory: every
# rollout is counted by exactly one of them, so the fix cannot lose a turn and
# the new tab cannot double-count one.
cat >"$LOCAL_HOME/codex" <<'EOF'
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
chmod +x "$LOCAL_HOME/codex"

codex_result=$(env "${env_args[@]}" PATH="$LOCAL_HOME:$PATH" "$ROOT/bin/omarchy-agent-usage-codex" --force)

[[ $(jq -r '.modelUsage | keys | join(",")' <<<"$codex_result") == "gpt-sub" ]] ||
  fail "Codex collector keeps only the subscription's own turns" "$codex_result"

overlap=$(jq -n --argjson a "$(jq -c '.modelUsage | keys' <<<"$local_result")" \
                --argjson b "$(jq -c '.modelUsage | keys' <<<"$codex_result")" \
                '$a - ($a - $b) | length')
[[ $overlap == "0" ]] ||
  fail "Local and Codex collectors must not count the same model twice" "$local_result$codex_result"
pass "Local and Codex collectors partition sessions without gaps or overlap"

# opencode records the provider id but not the endpoint, so the well-known
# runtimes and configured ids carry the filter - pushed into SQL, since these
# databases keep every historical message with its JSON.
OC_HOME=$(mktemp -d)
trap 'rm -rf "$LOCAL_HOME" "$OC_HOME"' EXIT
mkdir -p "$OC_HOME/.config/omarchy/agents"
echo '{"providers":["homelab"]}' >"$OC_HOME/.config/omarchy/agents/local.json"

python3 - "$OC_HOME/.local/share/opencode/opencode.db" <<'PY'
import json, sqlite3, sys, time
from pathlib import Path

db = Path(sys.argv[1])
db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db)
conn.execute("CREATE TABLE message (id text PRIMARY KEY, session_id text NOT NULL, time_created integer NOT NULL, time_updated integer NOT NULL, data text NOT NULL)")
now_ms = int(time.time() * 1000)

def message(mid, provider, model, role="assistant", inp=0, out=0, reasoning=0):
  return (mid, "ses_1", now_ms, now_ms, json.dumps({
    "role": role, "providerID": provider, "modelID": model,
    "tokens": {"input": inp, "output": out, "reasoning": reasoning, "cache": {"read": 0, "write": 0}},
    "time": {"created": now_ms},
  }))

conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", [
  message("m1", "ollama", "qwen-oc", inp=100, out=10, reasoning=5),
  message("m2", "homelab", "qwen-cfg", inp=50, out=5),
  message("m3", "anthropic", "claude-paid", inp=999, out=999),
  message("m4", "openai", "gpt-sub", inp=999, out=999),
  message("m5", "ollama", "qwen-oc", role="user", inp=999),
])
conn.execute("INSERT INTO message VALUES ('m6', 'ses_1', ?, ?, 'not json at all')", (now_ms, now_ms))
conn.commit(); conn.close()
PY

oc_env=(HOME="$OC_HOME" CODEX_HOME="$OC_HOME/.codex" XDG_CACHE_HOME="$OC_HOME/.cache"
  XDG_DATA_HOME="$OC_HOME/.local/share" XDG_CONFIG_HOME="$OC_HOME/.config")
oc=$(env "${oc_env[@]}" "$ROOT/bin/omarchy-agent-usage-local")

# 115 = 100 + 10 + 5 reasoning; 55 = 50 + 5. Paid providers and the user
# message contribute nothing, and the malformed row does not abort the scan.
[[ $(jq -r '.todayTotalTokens' <<<"$oc") == "170" ]] ||
  fail "Local collector counts opencode turns on self-hosted providers" "$oc"
[[ $(jq -r '.modelUsage | keys | sort | join(",")' <<<"$oc") == "qwen-cfg,qwen-oc" ]] ||
  fail "Local collector filters opencode rows to self-hosted providers" "$oc"
[[ $(jq -r '.modelUsage["qwen-oc"].outputTokens' <<<"$oc") == "15" ]] ||
  fail "Local collector counts opencode reasoning tokens as generated" "$oc"
pass "Local collector counts self-hosted opencode turns past paid and malformed rows"

# The scan is cached like every other collector's: one envelope per data-path
# set, readable, versioned, and bypassed by --force.
cache_file=$(ls "$OC_HOME/.cache/omarchy/agent-usage/"local-scan-*.json 2>/dev/null | head -n 1)
[[ -n $cache_file && $(stat -c %a "$cache_file") == "644" ]] ||
  fail "Local collector leaves a readable cache file behind" "$oc"
[[ $(jq -r '.schemaVersion' "$cache_file") == "1" && $(jq -r '.stats.todayTotalTokens' "$cache_file") == "170" ]] ||
  fail "Local collector writes a versioned cache envelope" "$oc"
pass "Local collector caches its scan"

python3 - "$OC_HOME/.local/share/opencode/opencode.db" <<'PY'
import json, sqlite3, sys, time
conn = sqlite3.connect(sys.argv[1]); now_ms = int(time.time() * 1000)
conn.execute("INSERT INTO message VALUES (?, ?, ?, ?, ?)", ("m7", "ses_1", now_ms, now_ms, json.dumps({
  "role": "assistant", "providerID": "ollama", "modelID": "qwen-oc",
  "tokens": {"input": 30, "output": 0, "reasoning": 0, "cache": {"read": 0, "write": 0}},
  "time": {"created": now_ms}})))
conn.commit(); conn.close()
PY

[[ $(jq -r '.todayTotalTokens' <<<"$(env "${oc_env[@]}" "$ROOT/bin/omarchy-agent-usage-local")") == "170" ]] ||
  fail "Local collector reuses a seconds-old scan" "$oc"
[[ $(jq -r '.todayTotalTokens' <<<"$(env "${oc_env[@]}" "$ROOT/bin/omarchy-agent-usage-local" --force)") == "200" ]] ||
  fail "Local collector --force rescans past the cache" "$oc"
pass "Local collector --force rescans past the cache"

# A cache stamped with another local date holds another day's today* stats.
jq -c '.scanDate = "1999-01-01"' "$cache_file" >"$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
[[ $(jq -r '.scanDate' <<<"$(cat "$cache_file")") == "1999-01-01" ]] &&
  [[ $(jq -r '.todayTotalTokens' <<<"$(env "${oc_env[@]}" "$ROOT/bin/omarchy-agent-usage-local" --limits-only)") == "200" ]] ||
  fail "Local collector treats a cache from another day as a miss" "$oc"
pass "Local collector treats a cache from another day as a miss"

# A corrupt-but-parseable cache is a miss, not a garbage record.
printf '[]' >"$cache_file"
[[ $(jq -r '.todayTotalTokens' <<<"$(env "${oc_env[@]}" "$ROOT/bin/omarchy-agent-usage-local" --limits-only)") == "200" ]] ||
  fail "Local collector recovers from a corrupt cache file" "$oc"
pass "Local collector recovers from a corrupt cache file"

# An unwritable cache must not kill the collector: the record is the contract.
touch "$OC_HOME/not-a-dir"
broken=$(env "${oc_env[@]}" XDG_CACHE_HOME="$OC_HOME/not-a-dir" "$ROOT/bin/omarchy-agent-usage-local" 2>/dev/null)
[[ $(jq -r '.todayTotalTokens' <<<"$broken") == "200" ]] ||
  fail "Local collector still prints a record when the cache is unwritable" "$broken"
pass "Local collector survives an unwritable cache"

# A scan cut short by a database error must not be cached as the whole story.
BROKEN_HOME=$(mktemp -d)
trap 'rm -rf "$LOCAL_HOME" "$OC_HOME" "$BROKEN_HOME"' EXIT
python3 - "$BROKEN_HOME/.local/share/opencode/opencode.db" <<'PY'
import sqlite3, sys
from pathlib import Path
db = Path(sys.argv[1]); db.parent.mkdir(parents=True, exist_ok=True)
conn = sqlite3.connect(db); conn.execute("CREATE TABLE unrelated (id text PRIMARY KEY)")
conn.commit(); conn.close()
PY
env HOME="$BROKEN_HOME" CODEX_HOME="$BROKEN_HOME/.codex" XDG_CACHE_HOME="$BROKEN_HOME/.cache" \
  XDG_DATA_HOME="$BROKEN_HOME/.local/share" XDG_CONFIG_HOME="$BROKEN_HOME/.config" \
  "$ROOT/bin/omarchy-agent-usage-local" >/dev/null
[[ -z $(ls "$BROKEN_HOME/.cache/omarchy/agent-usage/"local-scan-*.json 2>/dev/null) ]] ||
  fail "Local collector must not cache an interrupted scan" "broken-db"
pass "Local collector does not cache an interrupted opencode scan"
