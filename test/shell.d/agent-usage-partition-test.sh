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
# - opencode's database with rows only in the original `message` store, rows
#   only in the V2 `session_message` store, rows migrated into both under one
#   id (counted once), compactions (counted like replies), thinking tokens
#   (counted as output), a forked session whose copies of its source's
#   messages count nowhere while its own reply does, and a row dated at zero,
#   which counts nowhere either.
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
#   Antigravity plugin records `google` with an `antigravity-` model.
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
  ("devin", "devin-pt", "", "devin", "devin"),
  ("synthetic", "synthetic-pt", "", "synthetic", "synthetic"),
  ("mistral", "devstral-pt", "", "vibe", "vibe"),
  ("meta", "muse-spark-pt", "", "muse", "muse"),
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
]
OC_SOURCES = ["opencode-message", "opencode-session_message", "opencode-migrated", "opencode-compaction",
              "opencode-reasoning", "opencode-fork-copy", "opencode-fork-reply", "opencode-zero-stamp"]

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
    owner = None if source in ("opencode-fork-copy", "opencode-zero-stamp") else oc_owner
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
conn.executemany("INSERT INTO message VALUES (?, ?, ?, ?, ?)", message_rows)
conn.executemany("INSERT INTO session_message VALUES (?, ?, ?, ?, ?)", session_rows)
conn.commit()
conn.close()

cells_path.write_text(json.dumps(cells))
PY

EMPTY_HOME="$WORK/empty"
mkdir -p "$EMPTY_HOME"

run_all "$EMPTY_HOME" "$WORK/empty-results"
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
# own) must not pull any of them into the local collector.
CONFIGURED_HOME="$WORK/configured"
cp -a "$FIXTURE_HOME" "$CONFIGURED_HOME"
rm -rf "$CONFIGURED_HOME/.cache"
mkdir -p "$CONFIGURED_HOME/.config/omarchy/agents"
python3 - "$WORK/cells.json" "$CONFIGURED_HOME/.config/omarchy/agents/local.json" <<'PY'
import json
import sys

cells = json.load(open(sys.argv[1]))
providers = sorted({cell["provider"] for cell in cells if cell["owner"] and cell["owner"] != "local"})
json.dump({"providers": providers}, open(sys.argv[2], "w"))
PY
mkdir -p "$CONFIGURED_HOME/.cache" "$CONFIGURED_HOME/.run"
run_collector "$CONFIGURED_HOME" local "$WORK/configured-local" PI_CODING_AGENT_DIR="$CONFIGURED_HOME/pi-moved"

# OpenRouter reads no local usage at all without a key, so the keyless run
# above can only show it missing everything. A placeholder key, with every
# request going to the dead proxy, shows what its own filter counts.
run_collector "$FIXTURE_HOME" openrouter "$WORK/keyed-openrouter" OPENROUTER_API_KEY=sk-or-placeholder PI_CODING_AGENT_DIR="$FIXTURE_HOME/pi-moved"

# ----------------------------------------------------------------- analysis

python3 - "$WORK" "${collectors[@]}" >"$WORK/report.tsv" <<'PY'
import json
import re
import sys
from pathlib import Path

work = Path(sys.argv[1])
collectors = sys.argv[2:]
cells = {cell["tag"]: cell for cell in json.load(open(work / "cells.json"))}

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
  if record.get("limits"):
    problems.append("limits not empty")
  if "balance" in record:
    problems.append("has a balance")
  if any(record.get(key) for key in ("todayPrompts", "todaySessions", "todayTotalTokens", "totalPrompts", "totalSessions", "activeDays")) \
      or record.get("todayTokensByModel") or record.get("modelUsage") or record.get("activeDates"):
    problems.append("stats not empty")
  if record.get("retryAdvised"):
    problems.append("retryAdvised with nothing to retry")
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
  per_tag, _ = counted(record)
  leaked = sorted({f"{cells[tag]['provider']}" for tag in per_tag if cells[tag]["owner"] != "local"})
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

for check, ok, detail in results:
  print(f"{check}\t{'ok' if ok else 'fail'}\t{detail}".replace("\n", "\\n"))
PY

# ------------------------------------------------------------------ verdict

declare -A DESCRIPTIONS=(
  [empty-home]="every collector prints the unused-machine record in an empty home: ready false, no status, no limits, no balance, empty stats, the full field set"
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
)
order=(empty-home fixture-run fixture-shape attribution today-matches-models partition unclaimed sum opencode-db-env local-config openrouter-keyed)

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
