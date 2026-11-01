#!/bin/bash

# Fixtures the agent usage collector tests share. Source it after
# base-test.sh:
#
#   source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
#   source "$SHELL_TEST_DIR/agent-usage-helpers.sh"
#   agent_sandbox
#
# The Python half, agent_usage_fixtures.py beside it, is importable from any
# heredoc once agent_sandbox has run. docs/testing.md describes both.
#
# Not a test of its own: the shell runner only picks up *-test.sh files.

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  echo "source test/shell.d/agent-usage-helpers.sh from a shell test; do not run it directly" >&2
  exit 1
fi

# Variables a developer's own shell may carry that point a collector at a
# real credential or store, matched by prefix, plus any *_API_KEY. Kept in
# step with DEVELOPER_PREFIXES in agent_usage_fixtures.py.
AGENT_DEVELOPER_PREFIXES='^(AGY_|ANTHROPIC_|CLAUDE_|CLOUD_CODE_|CODEX_|COPILOT_|CURSOR_|DEEPSEEK_|DEVIN_|DSH_|FIREWORKS_|GH_|GITHUB_|GROK_|HERMES_|KIMCHI_|KIMI_|MAVIS_|MINIMAX_|MISE_|MMX_|MUSE_|OLLAMA_|OPENAI_|OPENCLAW_|OPENCODE_|OPENROUTER_|PI_CODING_AGENT_|QWEN_|SYNTHETIC_|VIBE_|ZAI_|ZHIPU)'
AGENT_DEAD_PROXY=http://127.0.0.1:9

agent_sandbox_pids=()

# Sets up the scratch machine every agent usage test runs on:
#
# - SANDBOX, a temporary directory removed on exit, with one EXIT trap that
#   first stops every process handed to track_pid.
# - HOME and every XDG directory under $SANDBOX/home, exported.
# - Every developer variable naming an agent credential or store unset.
# - Requests that escape a fake go to a dead proxy; loopback stays direct.
# - PYTHONPATH reaching agent_usage_fixtures, and no bytecode written.
agent_sandbox() {
  local name

  require_command python3
  SANDBOX=$(mktemp -d)
  # Exported so the Python fixtures' sandbox() makes its homes in here too.
  export SANDBOX
  trap agent_sandbox_cleanup EXIT

  export HOME="$SANDBOX/home"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_DATA_HOME="$HOME/.local/share"
  export XDG_STATE_HOME="$HOME/.local/state"
  export XDG_CACHE_HOME="$HOME/.cache"
  export XDG_RUNTIME_DIR="$HOME/.run"
  mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$XDG_RUNTIME_DIR" "$SANDBOX/homes"

  while IFS= read -r name; do
    if [[ $name == *_API_KEY || $name =~ $AGENT_DEVELOPER_PREFIXES ]]; then
      unset "$name"
    fi
  done < <(compgen -e)

  export http_proxy=$AGENT_DEAD_PROXY https_proxy=$AGENT_DEAD_PROXY
  export HTTP_PROXY=$AGENT_DEAD_PROXY HTTPS_PROXY=$AGENT_DEAD_PROXY
  export no_proxy=127.0.0.1,localhost NO_PROXY=127.0.0.1,localhost

  export PYTHONPATH="$SHELL_TEST_DIR${PYTHONPATH:+:$PYTHONPATH}"
  export PYTHONDONTWRITEBYTECODE=1

  # What run_collector's isolated PATH holds besides a home's own bin/.
  mkdir -p "$SANDBOX/tools"
  for name in python3 rg jq sqlite3; do
    if command -v "$name" >/dev/null; then
      ln -s "$(command -v "$name")" "$SANDBOX/tools/$name"
    fi
  done
}

# Records background processes (a stub server, a lock holder) for the EXIT
# trap to stop before the sandbox goes.
track_pid() {
  agent_sandbox_pids+=("$@")
}

agent_sandbox_cleanup() {
  local pid
  for pid in "${agent_sandbox_pids[@]}"; do
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
  done
  if [[ -n ${SANDBOX:-} && -d $SANDBOX ]]; then
    # A test that made a file unreadable must not leave it behind.
    chmod -R u+rwX "$SANDBOX" 2>/dev/null || true
    rm -rf "$SANDBOX"
  fi
}

# Prints a new, empty home under the sandbox with its XDG directories and a
# bin/ for stubs: $SANDBOX/homes/<name>, or a fresh unique name.
new_home() {
  local home
  if [[ -n ${1:-} ]]; then
    home="$SANDBOX/homes/$1"
    mkdir -p "$home"
  else
    home=$(mktemp -d "$SANDBOX/homes/home.XXXXXX")
  fi
  mkdir -p "$home/.config" "$home/.local/share" "$home/.local/state" "$home/.cache" "$home/.run" "$home/bin"
  printf '%s\n' "$home"
}

# run_collector <home> <id> [VAR=value ...] [-- args...]
#
# Runs bin/omarchy-agent-usage-<id> as a process, in an environment holding
# nothing but <home> and its XDG directories, OMARCHY_PATH, the caller's TZ,
# the dead proxy, and the VAR=value pairs given (a later PATH= replaces the default). PATH is
# <home>/bin, then python3, rg, jq and sqlite3. Runs with --force unless args
# follow `--` (then exactly those, none included). Prints the record; stderr
# lands in <home>/.run/<id>.err and is shown when the collector fails, whose
# status is returned.
run_collector() {
  local home="$1" id="$2" status=0 timeout_command
  local -a vars=() args=(--force)
  shift 2
  while (( $# > 0 )); do
    if [[ $1 == "--" ]]; then
      shift
      args=("$@")
      break
    fi
    vars+=("$1")
    shift
  done
  timeout_command=$(command -v timeout)
  mkdir -p "$home/.cache" "$home/.run" "$home/bin"
  env -i \
    HOME="$home" \
    PATH="$home/bin:$SANDBOX/tools" \
    LANG=C.UTF-8 \
    ${TZ+TZ="$TZ"} \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_LANGUAGE_FILE="$OMARCHY_LANGUAGE_FILE" \
    XDG_CONFIG_HOME="$home/.config" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CACHE_HOME="$home/.cache" \
    XDG_RUNTIME_DIR="$home/.run" \
    http_proxy=$AGENT_DEAD_PROXY https_proxy=$AGENT_DEAD_PROXY \
    HTTP_PROXY=$AGENT_DEAD_PROXY HTTPS_PROXY=$AGENT_DEAD_PROXY ALL_PROXY=$AGENT_DEAD_PROXY \
    no_proxy=127.0.0.1,localhost NO_PROXY=127.0.0.1,localhost \
    "${vars[@]}" \
    "$timeout_command" --kill-after=5 "${AGENT_COLLECTOR_TIMEOUT:-60}" "$ROOT/bin/omarchy-agent-usage-$id" "${args[@]}" \
    2>"$home/.run/$id.err" || status=$?
  if (( status != 0 )); then
    cat "$home/.run/$id.err" >&2
  fi
  return "$status"
}

# expect_jq "<description>" '<filter>' '<expected>' "$json"
#
# Passes when `jq -c <filter>` of the JSON prints exactly <expected>, and
# fails showing both and the JSON otherwise.
expect_jq() {
  local description="$1" filter="$2" expected="$3" json="$4" actual
  actual=$(jq -c "$filter" <<<"$json" 2>&1) || true
  if [[ $actual == "$expected" ]]; then
    pass "$description"
  else
    fail "$description" "expected: $expected"$'\n'"actual:   $actual"$'\n'"json:     $json"
  fi
}

# stub_cli <home> <name>, with the script's body on stdin: an executable
# <home>/bin/<name>, a bash script unless the body brings its own #! line.
# Prints its path.
stub_cli() {
  local home="$1" name="$2" body
  body=$(cat)
  mkdir -p "$home/bin"
  if [[ $body == '#!'* ]]; then
    printf '%s\n' "$body" >"$home/bin/$name"
  else
    printf '#!/bin/bash\n%s\n' "$body" >"$home/bin/$name"
  fi
  chmod +x "$home/bin/$name"
  printf '%s\n' "$home/bin/$name"
}

# fake_codex <home> [mode]
#
# A stand-in Codex app-server at <home>/bin/codex speaking its JSON-RPC on
# stdin and stdout. Its rate-limit answer follows CODEX_FAKE when set at run
# time, else <mode> (default ok):
#
#   ok       limits: CODEX_RATE_LIMITS (the rateLimits object) or 40% of a
#            5-hour window and 70% of a week, both resetting ahead
#   backend  an RPC error from OpenAI's side (a failed check)
#   auth     "not authenticated" (a refused sign-in)
#   empty    an answer with no limits in it
#   died     exits saying it couldn't reach OpenAI (unreachable)
#   crashed  exits with a panic of its own
#   silent   exits without a word
#   stall    never answers (the collector's 8-second timeout)
#
# account/read answers {planType: CODEX_PLAN or "pro"}; CODEX_ARGS_FILE gets
# the arguments it was started with. Every start appends its mode to
# <home>/codex-starts, so a reused probe can be told from a new one.
#
# Unless <home>/.codex/auth.json exists, it is written signed in to workspace
# ws-test as user-test, which the collector keys its limits cache by.
fake_codex() {
  local home="$1" mode="${2:-ok}"
  mkdir -p "$home/bin" "$home/.codex"
  if [[ ! -e $home/.codex/auth.json ]]; then
    python3 -c 'import sys, agent_usage_fixtures as f; f.write_json(sys.argv[1], {"tokens": {"account_id": "ws-test", "id_token": f.jwt({"https://api.openai.com/auth": {"chatgpt_user_id": "user-test"}})}})' \
      "$home/.codex/auth.json" >/dev/null || fail "sign the fake Codex home in"
  fi
  {
    printf '#!%s\n' "$(command -v python3)"
    python3 -c 'import json, sys; print(f"DEFAULT_MODE = {json.dumps(sys.argv[1])}\nSTARTS = {json.dumps(sys.argv[2])}")' "$mode" "$home/codex-starts"
    cat <<'PY'
import json, os, sys, time

mode = os.environ.get("CODEX_FAKE") or DEFAULT_MODE
with open(STARTS, "a") as log:
  log.write(mode + "\n")
if os.environ.get("CODEX_ARGS_FILE"):
  with open(os.environ["CODEX_ARGS_FILE"], "w") as args:
    args.write("\0".join(sys.argv[1:]))
now = int(time.time())


def reply(message, result=None, error=None):
  body = {"id": message["id"]}
  body["error" if error else "result"] = error or result
  print(json.dumps(body), flush=True)


for line in sys.stdin:
  message = json.loads(line)
  if "id" not in message:
    continue
  method = message.get("method")
  if method == "account/read":
    reply(message, {"account": {"planType": os.environ.get("CODEX_PLAN", "pro")}})
  elif method == "account/rateLimits/read":
    if mode == "died":
      print("error sending request for url (https://chatgpt.com/backend-api/wham/usage)", file=sys.stderr)
      sys.exit(1)
    if mode == "crashed":
      print("thread 'main' panicked at config.rs: unexpected argument", file=sys.stderr)
      sys.exit(1)
    if mode == "silent":
      sys.exit(0)
    if mode == "stall":
      continue
    if mode == "backend":
      reply(message, error={"code": -32603, "message": "failed to fetch codex rate limits"})
    elif mode == "auth":
      reply(message, error={"code": -32603, "message": "not authenticated"})
    elif mode == "empty":
      reply(message, {"rateLimits": None, "rateLimitsByLimitId": {}})
    else:
      limits = json.loads(os.environ["CODEX_RATE_LIMITS"]) if os.environ.get("CODEX_RATE_LIMITS") else {
        "planType": "pro",
        "primary": {"usedPercent": 40, "windowDurationMins": 300, "resetsAt": now + 3600},
        "secondary": {"usedPercent": 70, "windowDurationMins": 10080, "resetsAt": now + 7 * 86400},
      }
      reply(message, {"rateLimits": limits})
  else:
    reply(message, {})
PY
  } >"$home/bin/codex"
  chmod +x "$home/bin/codex"
}

# age_scan_cache <file-or-id> <seconds>
#
# Moves a scan cache's stamp <seconds> into the past (negative: into the
# future), as if it were made that long ago. Given an agent id, every scan
# cache of it under XDG_CACHE_HOME.
age_scan_cache() {
  python3 -c 'import sys, agent_usage_fixtures as f; f.age_scan_cache(sys.argv[1], float(sys.argv[2]))' "$1" "$2" >/dev/null ||
    fail "age the scan cache of $1"
}

# edit_limits_cache <id> <jq-filter>
#
# Rewrites every limits cache of <id> (<id>-limits*.json) with the filter,
# which can use $now_ms, $past (an ISO time an hour gone) and $future (one an
# hour ahead): '.limits[].resetsAt = $past' elapses every window, and
# '.fetchedAtMs = $now_ms - 60000' ages the answer a minute.
edit_limits_cache() {
  local id="$1" filter="$2" file now_ms past future found=0
  now_ms=$(python3 -c 'import time; print(int(time.time() * 1000))')
  past=$(python3 -c 'import datetime as d; print((d.datetime.now(d.timezone.utc) - d.timedelta(hours=1)).isoformat())')
  future=$(python3 -c 'import datetime as d; print((d.datetime.now(d.timezone.utc) + d.timedelta(hours=1)).isoformat())')
  for file in "$XDG_CACHE_HOME/omarchy/agent-usage/$id"-limits*.json; do
    [[ -f $file ]] || continue
    found=1
    jq --argjson now_ms "$now_ms" --arg past "$past" --arg future "$future" "$filter" "$file" >"$file.edit" &&
      mv "$file.edit" "$file" || fail "edit the $id limits cache with $filter"
  done
  (( found )) || fail "$id keeps a limits cache to edit"
}
