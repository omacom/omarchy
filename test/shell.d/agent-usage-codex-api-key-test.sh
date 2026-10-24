#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

# Codex signed in with an OpenAI API key (codex login --with-api-key) has no
# ChatGPT plan, so its app-server refuses to read limits as it does for a home
# nobody is signed in to. account/read tells the two apart: it names the API key
# login, so the collector shows "API key" and nothing asks for a sign-in.
SANDBOX=$(mktemp -d) || fail "a temporary directory can be created"
trap 'rm -rf "${SANDBOX:?}"' EXIT

# A home whose codex app-server answers as Codex 0.163 does: account/read with
# ACCOUNT (no answer at all with ACCOUNT_READ_HANGS, as Codex 0.158 can), and
# account/rateLimits/read with LIMITS_ERROR.
home_with() { # ACCOUNT LIMITS_ERROR
  local home
  home=$(mktemp -d "$SANDBOX/home.XXXXXX")
  mkdir -p "$home/bin" "$home/.codex"
  printf '%s' '{"auth_mode":"apikey","OPENAI_API_KEY":"sk-test-secret-value"}' >"$home/.codex/auth.json"
  cat >"$home/bin/codex" <<EOF
#!/bin/bash
while read -r request; do
  id=\$(jq -r '.id // empty' <<<"\$request")
  case \$(jq -r '.method // empty' <<<"\$request") in
    initialize) jq -cn --argjson id "\$id" '{id: \$id, result: {}}' ;;
    account/read)
      [[ -n \${ACCOUNT_READ_HANGS:-} ]] ||
        jq -cn --argjson id "\$id" --argjson account '$1' '{id: \$id, result: {account: \$account, requiresOpenaiAuth: true}}'
      ;;
    account/rateLimits/read) jq -cn --argjson id "\$id" --arg message '$2' '{id: \$id, error: {code: -32600, message: \$message}}' ;;
  esac
done
EOF
  chmod +x "$home/bin/codex"
  printf '%s\n' "$home"
}

in_home() { # HOME COMMAND...
  local home=$1
  shift
  HOME="$home" CODEX_HOME="$home/.codex" XDG_CACHE_HOME="$home/.cache" XDG_STATE_HOME="$home/.state" XDG_DATA_HOME="$home/.local/share" \
    PATH="$home/bin:$PATH" env -u OPENAI_API_KEY -u CODEX_API_KEY -u CODEX_ACCESS_TOKEN "$@"
}

collect() { # HOME
  in_home "$1" "$ROOT/bin/omarchy-agent-usage-codex" --limits-only
}

key_refused="chatgpt authentication required to read rate limits"
nobody_refused="codex account authentication required to read rate limits"

home=$(home_with '{"type":"apiKey"}' "$key_refused")
record=$(collect "$home") || fail "the collector runs over an API key login" "$record"
jq -e '.ready == true and .tierLabel == "API key" and .usageStatusText == "" and .authHelpText == "" and .limits == []' <<<"$record" >/dev/null ||
  fail "an API key login reads as API key, without limits or a sign-in prompt" "$record"
[[ $record != *"sk-test-secret-value"* ]] || fail "the record never carries the key" "$record"
pass "an API key login reads as API key, without limits or a sign-in prompt"

# Refused limits still wait for a sign-in when account/read names no login
# (none, or a key that forced_login_method = "chatgpt" rules out), a ChatGPT
# login, or doesn't answer at all.
for account in null '{"type":"chatgpt","planType":"plus"}'; do
  home=$(home_with "$account" "$nobody_refused")
  record=$(collect "$home") || fail "the collector runs without an API key login" "$record"
  jq -e '.tierLabel != "API key" and .usageStatusText == "Waiting for auth" and .authHelpText != ""' <<<"$record" >/dev/null ||
    fail "a home without an API key login waits for a sign-in ($account)" "$record"
done
home=$(home_with '{"type":"apiKey"}' "$key_refused")
record=$(ACCOUNT_READ_HANGS=1 collect "$home") || fail "the collector runs when account/read goes unanswered" "$record"
jq -e '.usageStatusText == "Waiting for auth"' <<<"$record" >/dev/null ||
  fail "an unanswered account/read waits for a sign-in, as before" "$record"
pass "only a login Codex names as an API key reads as one"

# A registered account on a key reads the same way.
home=$(home_with '{"type":"apiKey"}' "$key_refused")
account=$(in_home "$home" env COLLECTOR="$ROOT/bin/omarchy-agent-usage-codex" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os

loader = importlib.machinery.SourceFileLoader("collector", os.environ["COLLECTOR"])
spec = importlib.util.spec_from_loader(loader.name, loader)
collector = importlib.util.module_from_spec(spec)
loader.exec_module(collector)
print(json.dumps(collector.account_limits({"id": "work", "home": os.environ["CODEX_HOME"], "active": True})))
PY
) || fail "a registered account's limits are read" "$account"
jq -e '.plan == "API key" and .usageStatusText == "" and .authHelpText == "" and .limits == []' <<<"$account" >/dev/null ||
  fail "a registered account on a key reads as API key" "$account"
pass "a registered account on a key reads as API key"
