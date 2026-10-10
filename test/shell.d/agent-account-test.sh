#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
notifications="$test_tmp/notifications"
mkdir -p "$mock_bin" "$test_tmp/home/.claude" "$test_tmp/home/.codex"
mkdir -p "$test_tmp/runtime"

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_NOTIFICATIONS"
SH

# The CLIs report which home they were started in, and a login writes the
# identity a real one would into whichever home it was given.
cat >"$mock_bin/claude" <<'SH'
#!/bin/bash
if [[ ${1:-} == "auth" && ${2:-} == "login" ]]; then
  "${BROWSER:-omarchy-test-default-browser}" "https://claude.com/oauth/authorize"
  if [[ -n ${OMARCHY_TEST_LOGIN_HANGS:-} ]]; then
    echo $$ >"$OMARCHY_TEST_LOGIN_HANGS"
    exec sleep 30
  fi
  [[ -n ${OMARCHY_TEST_LOGIN_UUID:-} ]] || exit 1
  home=${CLAUDE_CONFIG_DIR:-$HOME/.claude}
  account_file="$home/.claude.json"
  [[ -z ${CLAUDE_CONFIG_DIR:-} ]] && account_file="$HOME/.claude.json"
  printf '{"oauthAccount":{"accountUuid":"%s","emailAddress":"%s","organizationName":"Work"}}\n' \
    "$OMARCHY_TEST_LOGIN_UUID" "$OMARCHY_TEST_LOGIN_EMAIL" >"$account_file"
  echo '{"claudeAiOauth":{"rateLimitTier":"default_claude_max_5x","subscriptionType":"max"}}' >"$home/.credentials.json"
  exit 0
fi
echo "claude home=${CLAUDE_CONFIG_DIR:-default} args=$*"
SH

cat >"$mock_bin/codex" <<'SH'
#!/bin/bash
if [[ ${1:-} == "login" ]]; then
  "${BROWSER:-omarchy-test-default-browser}" "https://auth.openai.com/oauth/authorize"
  claims=$(printf '{"email":"%s","https://api.openai.com/auth":{"chatgpt_plan_type":"pro"}}' "$OMARCHY_TEST_LOGIN_EMAIL" | base64 -w0 | tr '+/' '-_' | tr -d '=')
  printf '{"auth_mode":"chatgpt","tokens":{"account_id":"%s","id_token":"h.%s.s"}}\n' "$OMARCHY_TEST_LOGIN_UUID" "$claims" >"${CODEX_HOME:-$HOME/.codex}/auth.json"
  exit 0
fi
echo "codex home=${CODEX_HOME:-default} args=$*"
SH

# Grok keys its login by issuer and keeps the plan in the settings it caches,
# as a JSON string inside that file.
cat >"$mock_bin/grok" <<'SH'
#!/bin/bash
if [[ ${1:-} == "login" ]]; then
  "${BROWSER:-omarchy-test-default-browser}" "https://auth.x.ai/oauth/authorize"
  home=${GROK_HOME:-$HOME/.grok}
  mkdir -p "$home"
  printf '{"https://auth.x.ai::client":{"key":"t","user_id":"%s","email":"%s"}}\n' \
    "${OMARCHY_TEST_LOGIN_UUID:-u-grok}" "${OMARCHY_TEST_LOGIN_EMAIL:-me@example.com}" >"$home/auth.json"
  printf '{"payload":"{\\"settings\\":{\\"subscription_tier_display\\":\\"SuperGrok\\"}}"}\n' >"$home/settings_cache.json"
  exit 0
fi
echo "grok home=${GROK_HOME:-default} args=$*"
SH

cat >"$mock_bin/omarchy-test-default-browser" <<'SH'
#!/bin/bash
printf 'default %s\n' "$*" >>"$OMARCHY_TEST_BROWSER_LOG"
SH

cat >"$mock_bin/omarchy-agent-usage-update" <<'SH'
#!/bin/bash
SH

cat >"$mock_bin/omarchy-default-agent" <<'SH'
#!/bin/bash
echo "${OMARCHY_TEST_DEFAULT_AGENT-claude}"
SH

cat >"$mock_bin/omarchy-launch-browser" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_BROWSER_LOG"
SH

chmod +x "$mock_bin"/*

export HOME="$test_tmp/home"
export XDG_STATE_HOME="$test_tmp/state"
export XDG_RUNTIME_DIR="$test_tmp/runtime"
export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_NOTIFICATIONS="$notifications"
export OMARCHY_TEST_BROWSER_LOG="$test_tmp/browser"
unset CLAUDE_CONFIG_DIR CODEX_HOME GROK_HOME BROWSER

accounts="$XDG_STATE_HOME/omarchy/agents/accounts"

echo '{"oauthAccount":{"accountUuid":"u-main","emailAddress":"me@example.com","organizationName":"Me"},"mcpServers":{"docs":{"command":"docs-mcp"}}}' >"$HOME/.claude.json"
echo '{"claudeAiOauth":{"rateLimitTier":"default_claude_max_20x","subscriptionType":"max"}}' >"$HOME/.claude/.credentials.json"
echo '{"theme":"custom:omarchy"}' >"$HOME/.claude/settings.json"

# ---------------------------------------------------------------- single account

[[ -z $(omarchy-agent-account-home claude) ]] || fail "a machine with one account routes nowhere"
[[ ! -e $accounts/claude.json ]] || fail "reading the active home never creates a registry"
pass "a machine with one account launches exactly as before"

list=$(omarchy-agent-account-list claude --json)
[[ $(jq -c '.[0].accounts | map({id, label, plan, email, active, primary})' <<<"$list") == '[{"id":"main","label":"Main","plan":"Max 20x","email":"me@example.com","active":true,"primary":true}]' ]] ||
  fail "the existing login is listed as the primary account" "$list"
pass "the existing login is listed as the primary account"

# ------------------------------------------------------------------------- add

OMARCHY_TEST_LOGIN_UUID=u-work OMARCHY_TEST_LOGIN_EMAIL=work@example.com \
  omarchy-agent-account-add claude Work </dev/null >"$test_tmp/add-output"
grep -q "Added Work (work@example.com)" "$test_tmp/add-output" || fail "adding an account reports who signed in" "$(cat "$test_tmp/add-output")"
grep -q "private window that opens" "$test_tmp/add-output" || fail "adding an account says to sign in within the private window"
[[ $(head -1 "$OMARCHY_TEST_BROWSER_LOG") == "--private https://claude.com/oauth/authorize" ]] ||
  fail "a Claude login opens in a private window" "$(cat "$OMARCHY_TEST_BROWSER_LOG")"
pass "adding an account signs in through the CLI's own login"

work="$accounts/claude/work"
[[ -f $work/.credentials.json && ! -L $work/.credentials.json ]] || fail "an added account keeps its own credentials"
[[ $(readlink "$work/projects") == "$HOME/.claude/projects" ]] || fail "an added account shares conversation history with the primary"
[[ $(readlink "$work/settings.json") == "$HOME/.claude/settings.json" ]] || fail "an added account shares settings with the primary"
[[ $(readlink "$work/CLAUDE.md") == "$HOME/.claude/CLAUDE.md" && ! -e $HOME/.claude/CLAUDE.md ]] ||
  fail "a shared file the primary doesn't have yet is linked, so it's written there when it is"
[[ $(jq -c .mcpServers "$work/.claude.json") == '{"docs":{"command":"docs-mcp"}}' ]] || fail "an added account carries the primary's MCP servers"
[[ $(stat -c %a "$work") == 700 && $(stat -c %a "$accounts/claude.json") == 600 ]] || fail "account homes and the registry are private"
pass "an added account shares everything but its login with the primary"

if OMARCHY_TEST_LOGIN_UUID=u-work OMARCHY_TEST_LOGIN_EMAIL=work@example.com \
  omarchy-agent-account-add claude Again </dev/null >"$test_tmp/dup-output" 2>&1; then
  fail "adding the same account twice fails"
fi
grep -q "That's Work" "$test_tmp/dup-output" || fail "a duplicate login names the account it already is" "$(cat "$test_tmp/dup-output")"
[[ -z $(ls -A "$accounts/claude/.pending") ]] || fail "a duplicate login leaves no scratch home behind"
pass "adding an account that's already there is refused"

# Main was signed in to another account by hand since the registry was made;
# adding that login again is still the same subscription.
jq '.oauthAccount.accountUuid = "u-relogged"' "$HOME/.claude.json" >"$test_tmp/relogged.json"
cp "$HOME/.claude.json" "$test_tmp/original.json"
mv "$test_tmp/relogged.json" "$HOME/.claude.json"
if OMARCHY_TEST_LOGIN_UUID=u-relogged OMARCHY_TEST_LOGIN_EMAIL=me@example.com \
  omarchy-agent-account-add claude Twin </dev/null >"$test_tmp/twin-output" 2>&1; then
  fail "a login matching Main's current sign-in is refused"
fi
grep -q "That's Main" "$test_tmp/twin-output" || fail "a login matching Main's current sign-in names Main" "$(cat "$test_tmp/twin-output")"
mv "$test_tmp/original.json" "$HOME/.claude.json"
pass "duplicates are judged by who each home is signed in as now"

if OMARCHY_TEST_LOGIN_UUID="" omarchy-agent-account-add claude Nope </dev/null >/dev/null 2>&1; then
  fail "an abandoned login adds nothing"
fi
[[ $(omarchy-agent-account-list claude --json | jq '.[0].accounts | length') == 2 ]] || fail "an abandoned login adds nothing"
pass "an abandoned login adds nothing"

OMARCHY_TEST_LOGIN_UUID=u-next OMARCHY_TEST_LOGIN_EMAIL=next@example.com \
  omarchy-agent-account-add claude Next </dev/null >/dev/null
[[ $(omarchy-agent-account-list claude --json | jq -r '.[0].accounts[] | select(.label == "Next") | .id') == "next-2" ]] ||
  fail "an account label can't take an id that routing already answers to"
omarchy-agent-account-remove claude next-2 </dev/null >/dev/null
pass "account ids stay clear of routing keywords"

OMARCHY_TEST_LOGIN_UUID=acct-1 OMARCHY_TEST_LOGIN_EMAIL=me@example.com \
  omarchy-agent-account-add codex </dev/null >"$test_tmp/first-codex"
[[ -f $HOME/.codex/auth.json && ! -d $accounts/codex ]] || fail "the first Codex account signs in to ~/.codex itself"
grep -qx "default https://auth.openai.com/oauth/authorize" "$OMARCHY_TEST_BROWSER_LOG" ||
  fail "the first Codex account signs in through the normal browser" "$(cat "$OMARCHY_TEST_BROWSER_LOG")"
[[ ! -e $HOME/.config/omarchy/defaults/agent ]] || fail "a first sign-in leaves an existing default agent alone"
pass "the first account of a provider signs in to its own home in the normal browser"

OMARCHY_TEST_LOGIN_UUID=acct-2 OMARCHY_TEST_LOGIN_EMAIL=side@example.com \
  omarchy-agent-account-add codex Side </dev/null >/dev/null
[[ $(omarchy-agent-account-list codex --json | jq -c '.[0].accounts[1] | {id, email, plan}') == '{"id":"side","email":"side@example.com","plan":"Pro"}' ]] ||
  fail "a Codex account reads its identity from the login's token claims"
[[ $(readlink "$accounts/codex/side/sessions") == "$HOME/.codex/sessions" ]] || fail "a Codex account shares sessions with the primary"
grep -qx -- "--private https://auth.openai.com/oauth/authorize" "$OMARCHY_TEST_BROWSER_LOG" ||
  fail "a Codex login opens in a private window" "$(cat "$OMARCHY_TEST_BROWSER_LOG")"
pass "Codex accounts are added the same way"

OMARCHY_TEST_DEFAULT_AGENT="" omarchy-agent-account-add grok </dev/null >/dev/null
[[ $(cat "$HOME/.config/omarchy/defaults/agent") == "grok" ]] ||
  fail "the first agent signed in on a machine with no default becomes the default"
[[ -s $HOME/.grok/auth.json ]] && grep -qx "default https://auth.x.ai/oauth/authorize" "$OMARCHY_TEST_BROWSER_LOG" ||
  fail "a first Grok sign-in lands in ~/.grok through the normal browser"
pass "Grok signs in its first account"

OMARCHY_TEST_LOGIN_UUID=u-grok-2 OMARCHY_TEST_LOGIN_EMAIL=side@example.com \
  omarchy-agent-account-add grok Side </dev/null >/dev/null
[[ $(omarchy-agent-account-list grok --json | jq -c '.[0].accounts[1] | {id, email, plan}') == '{"id":"side","email":"side@example.com","plan":"SuperGrok"}' ]] ||
  fail "a Grok account reads its identity and plan from its own home" "$(omarchy-agent-account-list grok --json)"
[[ $(readlink "$accounts/grok/side/sessions") == "$HOME/.grok/sessions" ]] ||
  fail "a Grok account shares sessions with the primary"
grep -qx -- "--private https://auth.x.ai/oauth/authorize" "$OMARCHY_TEST_BROWSER_LOG" ||
  fail "a second Grok login opens in a private window" "$(cat "$OMARCHY_TEST_BROWSER_LOG")"
omarchy-agent-account-use grok side >/dev/null
[[ $(omarchy-agent-account-exec grok --version) == "grok home=$accounts/grok/side args=--version" ]] || fail "grok starts as the active Grok account" "$(omarchy-agent-account-exec grok --version)"
omarchy-agent-account-use grok main >/dev/null
pass "Grok accounts are added and used like the others"

# ---------------------------------------------------------------------- routing

omarchy-agent-account-use claude work >/dev/null
[[ $(omarchy-agent-account-home claude) == "$work" ]] || fail "the active account's home is what launches use"
grep -q "New Claude sessions now use Work (Max 5x)" "$notifications" || fail "switching says where new sessions go"
pass "use makes an account active and says so"

[[ $(omarchy-agent-account-exec claude --version) == "claude home=$work args=--version" ]] || fail "claude at a prompt starts as the active account"
[[ $(CLAUDE_CONFIG_DIR=/elsewhere omarchy-agent-account-exec claude) == "claude home=/elsewhere args=" ]] || fail "an explicit CLAUDE_CONFIG_DIR wins over the active account"
[[ $(omarchy-agent-account-exec codex) == "codex home=default args=" ]] || fail "codex stays on its primary until switched"
pass "account dispatch follows the active account"

# The GUI command goes through mise's dispatcher on a real install. Model that
# boundary here while retaining the real CLI fixtures for login tests.
mkdir -p "$test_tmp/dispatch"
for provider in claude codex; do
  printf '#!/bin/bash\nPATH=%q exec omarchy-agent-account-exec %q "$@"\n' "$PATH" "$provider" >"$test_tmp/dispatch/$provider"
  chmod +x "$test_tmp/dispatch/$provider"
done
[[ $(PATH="$test_tmp/dispatch:$PATH" OMARCHY_TEST_DEFAULT_AGENT=claude omarchy-agent --inline) == "claude home=$work args=--permission-mode auto" ]] ||
  fail "omarchy-agent starts Claude as the active account"
omarchy-agent-account-use codex side >/dev/null
[[ $(PATH="$test_tmp/dispatch:$PATH" OMARCHY_TEST_DEFAULT_AGENT=codex omarchy-agent --inline) == "codex home=$accounts/codex/side args=--approve-for-me" ]] ||
  fail "omarchy-agent starts Codex as the active account"
pass "omarchy-agent follows the active account"

omarchy-agent-account-use claude next >/dev/null
[[ -z $(omarchy-agent-account-home claude) ]] || fail "next cycles back to the primary"
pass "next cycles through accounts"

# With Claude as the default agent, the provider can be left out.
OMARCHY_TEST_DEFAULT_AGENT=claude omarchy-agent-account-use work >/dev/null
[[ $(omarchy-agent-account-home claude) == "$work" ]] || fail "use without a provider picks the default agent's account"
OMARCHY_TEST_DEFAULT_AGENT=claude omarchy-agent-account-use main >/dev/null
[[ -z $(omarchy-agent-account-home claude) ]] || fail "use without a provider switches back to Main"
OMARCHY_TEST_DEFAULT_AGENT=codex omarchy-agent-account-use main >/dev/null
[[ -z $(omarchy-agent-account-home codex) ]] || fail "the default agent decides which provider a short use means"
if OMARCHY_TEST_DEFAULT_AGENT=pi omarchy-agent-account-use work >/dev/null 2>&1; then
  fail "a default agent with no accounts still needs the provider named"
fi
pass "the provider defaults to your default agent"

# ----------------------------------------------------------------------- rename

omarchy-agent-account-use claude work >/dev/null
omarchy-agent-account-rename claude work Day job >/dev/null
[[ $(omarchy-agent-account-list claude --json | jq -c '.[0] | {active, renamed: (.accounts[] | select(.id == "day-job") | .label)}') == '{"active":"day-job","renamed":"Day job"}' ]] ||
  fail "renaming changes the label and the id it answers to, and the active account follows"
[[ $(omarchy-agent-account-home claude) == "$work" ]] || fail "renaming leaves the account's home where running sessions expect it"
OMARCHY_TEST_DEFAULT_AGENT=claude omarchy-agent-account-rename day-job Work >/dev/null
[[ $(omarchy-agent-account-home claude) == "$work" ]] || fail "a renamed account can be renamed back"
omarchy-agent-account-rename claude main Personal >/dev/null
[[ $(omarchy-agent-account-list claude --json | jq -r '.[0].accounts[] | select(.primary) | "\(.id) \(.home)"') == "personal $HOME/.claude" ]] ||
  fail "the primary account can be renamed and keeps ~/.claude"
omarchy-agent-account-rename claude personal Main >/dev/null
# `primary` reaches the first login whatever it's called, as the manual says.
omarchy-agent-account-rename claude primary Hey >/dev/null ||
  fail "primary names the primary account"
omarchy-agent-account-rename claude primary Main >/dev/null
[[ $(omarchy-agent-account-list claude --json | jq -r '.[0].accounts[] | select(.primary) | .id') == "main" ]] ||
  fail "primary still reaches the primary account after a rename"
if omarchy-agent-account-rename claude work "" >/dev/null 2>&1; then
  fail "an account can't be renamed to nothing"
fi
pass "rename relabels an account without moving it"

# ------------------------------------------------------------ mode and remove

OMARCHY_TEST_DEFAULT_AGENT=claude omarchy-agent-account-mode auto 90 >/dev/null
[[ $(jq -c '{switch, threshold}' "$accounts/claude.json") == '{"switch":"auto","threshold":90}' ]] || fail "mode sets switching and threshold"
if omarchy-agent-account-mode claude sometimes >/dev/null 2>&1; then
  fail "mode refuses an unknown switch mode"
fi
pass "mode sets how switching happens"

if omarchy-agent-account-remove claude main </dev/null >/dev/null 2>&1; then
  fail "the primary account can't be removed"
fi
omarchy-agent-account-use claude work >/dev/null
# A session still running in the account keeps its login until it quits.
CLAUDE_CONFIG_DIR="$work" sleep 30 &
session=$!
if omarchy-agent-account-remove claude work </dev/null >/dev/null 2>"$test_tmp/in-use"; then
  fail "an account a running session uses can't be removed"
fi
[[ -d $work ]] && grep -q "Quit it first" "$test_tmp/in-use" || fail "removing an account in use leaves it and says why" "$(cat "$test_tmp/in-use")"
kill "$session"; wait "$session" 2>/dev/null || true
omarchy-agent-account-remove claude work </dev/null >/dev/null
[[ ! -e $work && -d $HOME/.claude/projects && -f $HOME/.claude/settings.json ]] || fail "removing an account deletes its home and nothing it links to"
[[ -z $(omarchy-agent-account-home claude) ]] || fail "removing the active account falls back to the primary"
pass "remove forgets an added account without touching shared files"

# A registry that can't be saved leaves the new login pending, where the add
# command cleans it up, rather than in a home nothing can manage.
STATE="$ROOT/bin/omarchy-agent-account-state" python3 - <<'PY' || fail "a failed registration rolls the new home back to pending"
import importlib.machinery, importlib.util, json, os, sys
loader = importlib.machinery.SourceFileLoader("state", os.environ["STATE"])
spec = importlib.util.spec_from_loader(loader.name, loader)
state = importlib.util.module_from_spec(spec)
loader.exec_module(state)

pending = state.begin("claude")
(pending / ".claude.json").write_text(json.dumps({"oauthAccount": {"accountUuid": "u-stranded", "emailAddress": "stranded@example.com"}}))

def broken_save(provider, registry):
  raise OSError("disk full")
state.save = broken_save

try:
  state.register("claude", "Stranded", pending)
except OSError:
  pass
else:
  sys.exit("register should fail when the registry can't be saved")
assert pending.is_dir(), "the login goes back to pending"
assert not (state.accounts_root() / "claude" / "stranded").exists(), "no home is left outside the registry"
# The add command would remove it on exit; this test stands in for it.
import shutil
shutil.rmtree(pending)
PY
pass "a failed registration rolls the new home back to pending"

# Exercise the add command's EXIT trap after the real register rollback.
cat >"$mock_bin/omarchy-agent-account-state" <<'SH'
#!/bin/bash
if [[ $1 != "register" ]]; then
  exec "$ROOT/bin/omarchy-agent-account-state" "$@"
fi
STATE="$ROOT/bin/omarchy-agent-account-state" python3 - "$@" <<'PY'
import importlib.machinery, importlib.util, os, sys
loader = importlib.machinery.SourceFileLoader("state", os.environ["STATE"])
spec = importlib.util.spec_from_loader(loader.name, loader)
state = importlib.util.module_from_spec(spec)
loader.exec_module(state)
def broken_save(provider, registry):
  raise OSError("fixture registry save failure")
state.save = broken_save
raise SystemExit(state.main(sys.argv[1:]))
PY
SH
chmod +x "$mock_bin/omarchy-agent-account-state"
if OMARCHY_TEST_LOGIN_UUID=u-cli-rollback OMARCHY_TEST_LOGIN_EMAIL=rollback@example.com \
  omarchy-agent-account-add claude Rollback </dev/null >"$test_tmp/rollback-output" 2>&1; then
  fail "a failed registry write fails the add command"
fi
[[ -z $(find "$accounts/claude/.pending" -mindepth 1 -maxdepth 1 -print) ]] ||
  fail "the add command removes the rolled-back pending login"
rm "$mock_bin/omarchy-agent-account-state"
pass "the add command cleans a failed registration without leaving sign-in files"

# ------------------------------------------------------------ panel add flow

[[ $(omarchy-agent-account-add --check) == $'claude additional\ncodex additional\ngrok additional' ]] ||
  fail "--check says what adding would mean for each provider" "$(omarchy-agent-account-add --check)"
pass "--check says what adding would mean for each provider"

: >"$notifications"
OMARCHY_TEST_LOGIN_UUID=u-events OMARCHY_TEST_LOGIN_EMAIL=events@example.com \
  omarchy-agent-account-add --events claude Events </dev/null >"$test_tmp/events-output"
grep -qx "@@omarchy status Sign in as the account you're adding in the private window that opens." "$test_tmp/events-output" ||
  fail "--events reports progress as tagged lines" "$(cat "$test_tmp/events-output")"
grep -qx "@@omarchy done Added Events (events@example.com)." "$test_tmp/events-output" ||
  fail "--events reports the result as a tagged line" "$(cat "$test_tmp/events-output")"
grep -q "Added Events (events@example.com)." "$notifications" || fail "--events also notifies, in case the panel closed"
if OMARCHY_TEST_LOGIN_UUID=u-events OMARCHY_TEST_LOGIN_EMAIL=events@example.com \
  omarchy-agent-account-add --events claude Again </dev/null >"$test_tmp/events-dup" 2>&1; then
  fail "--events fails a duplicate"
fi
grep -q "^@@omarchy error That's Events" "$test_tmp/events-dup" || fail "--events reports a failure as a tagged line" "$(cat "$test_tmp/events-dup")"
pass "--events reports progress and results for the panel"

# ------------------------------------------------------------------- reauth

: >"$OMARCHY_TEST_BROWSER_LOG"
before=$(omarchy-agent-account-list claude --json | jq '.[0].accounts | length')
rm -f "$accounts/claude/events/.credentials.json"
OMARCHY_TEST_LOGIN_UUID=u-events OMARCHY_TEST_LOGIN_EMAIL=events@example.com \
  omarchy-agent-account-add --events --reauth events claude </dev/null >"$test_tmp/reauth-output"
grep -qx "@@omarchy done Signed in to Claude again." "$test_tmp/reauth-output" || fail "--reauth reports the sign-in" "$(cat "$test_tmp/reauth-output")"
[[ -s $accounts/claude/events/.credentials.json ]] || fail "--reauth signs in to the account's own home"
[[ $(omarchy-agent-account-list claude --json | jq '.[0].accounts | length') == "$before" ]] || fail "--reauth adds no account"
grep -qx -- "--private https://claude.com/oauth/authorize" "$OMARCHY_TEST_BROWSER_LOG" || fail "--reauth of an added account uses a private window"

: >"$OMARCHY_TEST_BROWSER_LOG"
OMARCHY_TEST_LOGIN_UUID=u-main OMARCHY_TEST_LOGIN_EMAIL=me@example.com \
  omarchy-agent-account-add --reauth main claude </dev/null >/dev/null
grep -qx "default https://claude.com/oauth/authorize" "$OMARCHY_TEST_BROWSER_LOG" || fail "--reauth of the primary uses the normal browser"

if omarchy-agent-account-add --reauth nobody claude </dev/null >/dev/null 2>&1; then
  fail "--reauth of an unknown account fails"
fi
pass "--reauth signs an existing account in again where it lives"

# ------------------------------------------------------------------- cancel

# Cancelling from the panel stops a login that's waiting on the browser, right
# away, and leaves no half-made account behind.
OMARCHY_TEST_LOGIN_HANGS="$test_tmp/login.pid" omarchy-agent-account-add --events claude Slow </dev/null >/dev/null 2>&1 &
adding=$!
sleep 1
started=$(date +%s)
kill -TERM "$adding"
wait "$adding" || true
(( $(date +%s) - started < 3 )) || fail "cancelling stops a waiting login at once"
login_pid=$(cat "$test_tmp/login.pid")
for _ in {1..20}; do
  kill -0 "$login_pid" 2>/dev/null || break
  sleep 0.1
done
if kill -0 "$login_pid" 2>/dev/null; then
  kill "$login_pid"
  fail "cancelling stops the login itself"
fi
[[ -z $(ls -A "$accounts/claude/.pending") ]] || fail "cancelling leaves no half-made account"
pass "cancelling a sign-in stops the login and cleans up"

# ------------------------------------------------------------------ one account

# With one account, the usage record keeps its limits at the top level, and
# the list still shows them.
solo="$test_tmp/solo"
mkdir -p "$solo/omarchy/agents/usage"
echo '{"id":"claude","limits":[{"label":"Session (5-hour)","percent":0.4,"resetsAt":""}]}' >"$solo/omarchy/agents/usage/claude.json"
[[ $(XDG_STATE_HOME="$solo" omarchy-agent-account-list claude --json | jq -c '.[0].accounts[0].limits[0].percent') == "0.4" ]] ||
  fail "a single account's limits are listed from the record's top level"
pass "a single account's limits are listed"

# ------------------------------------------------------------- signed out

# A login that's gone is gone, whatever the registry remembered about it.
rm -f "$HOME/.codex/auth.json"
[[ $(omarchy-agent-account-add --check | grep '^codex ') == "codex first" ]] ||
  fail "a signed-out primary counts as a first sign-in again" "$(omarchy-agent-account-add --check)"
pass "a signed-out account no longer counts as signed in"

# --------------------------------------------------------------- refresh

# A home signed in to someone else since it was added is saved as who it is
# now, which is what the usage records name it by.
jq '.oauthAccount.emailAddress = "switched@example.com"' "$accounts/claude/events/.claude.json" >"$test_tmp/switched.json"
mv "$test_tmp/switched.json" "$accounts/claude/events/.claude.json"
omarchy-agent-account-state refresh claude
[[ $(jq -r '.accounts[] | select(.id == "events") | .email' "$accounts/claude.json") == "switched@example.com" ]] ||
  fail "refresh saves who each home is signed in as now"
pass "refresh saves who each home is signed in as now"

# Exercise real flock/pidfd lifetime boundaries with pipe barriers. No sleeps
# decide when a session has started, and no fixture reads real credentials.
python3 - "$ROOT" "$test_tmp" <<'PY'
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import pty
import select
import signal
import subprocess
import sys

root, temporary = map(Path, sys.argv[1:])
script = root / "bin/omarchy-agent-account-state"
area = temporary / "session-boundaries"
area.mkdir()
environment = dict(os.environ, HOME=str(area), XDG_STATE_HOME=str(area / "state"))
for variable in ("CLAUDE_CONFIG_DIR", "OMARCHY_AGENT_CLAUDE_HOME"):
  environment.pop(variable, None)
os.environ.update(environment)
loader = importlib.machinery.SourceFileLoader("account_state", str(script))
spec = importlib.util.spec_from_loader(loader.name, loader)
state = importlib.util.module_from_spec(spec)
loader.exec_module(state)
home = state.accounts_root() / "claude/side"
registry_file = state.registry_path("claude")
processes = []

def reset():
  home.mkdir(parents=True, exist_ok=True, mode=0o700)
  (home / "credentials").write_text("private fixture")
  state.save("claude", {"active": "side", "accounts": [{"id": "main", "label": "Main", "primary": True}, {"id": "side", "label": "Side", "home": str(home)}]})

def run(*arguments, **options):
  return subprocess.run([str(script), *arguments], env=environment, text=True, capture_output=True, timeout=5, **options)

def barrier_read(descriptor):
  assert select.select([descriptor], [], [], 5)[0], "session barrier timed out"
  return os.read(descriptor, 4096)

def launch(paused=False, terminal=False, setup_failure=False, closed_stdio=False):
  ready_read, ready_write = os.pipe()
  release_read, release_write = os.pipe()
  selected_read, selected_write = os.pipe()
  proceed_read, proceed_write = os.pipe()
  program = '''import os,signal,sys
signal.signal(signal.SIGTERM, lambda *_: sys.exit(73))
signal.signal(signal.SIGINT, lambda *_: sys.exit(74))
signal.signal(signal.SIGHUP, lambda *_: sys.exit(75))
os.write(int(sys.argv[1]), (str(os.getpid()) + ":" + str(all(os.isatty(fd) for fd in (0,1,2)))).encode())
os.read(int(sys.argv[2]), 1)
'''
  if closed_stdio:
    # Re-exec without the provider env so /proc cannot conceal a lost claim.
    # The same PID must remain protected through both real exec transitions.
    program = "import os,sys; environment=dict(os.environ); environment.pop('CLAUDE_CONFIG_DIR',None); environment.pop('OMARCHY_AGENT_CLAUDE_HOME',None); os.execve(sys.executable,[sys.executable,'-c'," + repr(program) + ",sys.argv[1],sys.argv[2]],environment)"
  launcher = '''import importlib.machinery,importlib.util,os,sys
loader=importlib.machinery.SourceFileLoader("state",sys.argv[1])
spec=importlib.util.spec_from_loader(loader.name,loader)
state=importlib.util.module_from_spec(spec);loader.exec_module(state)
if sys.argv[2] == "closed":
  for descriptor in (0,1,2): os.close(descriptor)
if sys.argv[2] == "failure":
  def fail(): raise OSError("injected guardian setup failure")
  state.os.setsid=fail
elif sys.argv[2] == "paused":
  original=state.guard_session
  def guard(claim):
    os.write(int(sys.argv[3]),b"claimed")
    os.read(int(sys.argv[4]),1)
    original(claim)
  state.guard_session=guard
state.exec_account("claude",sys.argv[5:])
'''
  arguments = [sys.executable, "-c", launcher, str(script), "failure" if setup_failure else "paused" if paused else "closed" if closed_stdio else "normal", str(selected_write), str(proceed_read), sys.executable, "-c", program, str(ready_write), str(release_read)]
  master, slave = pty.openpty() if terminal else (None, None)
  process = subprocess.Popen(arguments, env=environment, pass_fds=(ready_write, release_read, selected_write, proceed_read), stdin=slave or subprocess.DEVNULL, stdout=slave or subprocess.PIPE, stderr=slave or subprocess.PIPE)
  processes.append(process)
  if slave is not None: os.close(slave)
  for descriptor in (ready_write, release_read, selected_write, proceed_read): os.close(descriptor)
  return process, ready_read, release_write, selected_read, proceed_write, master

def finish(session, requested_signal=None):
  process, ready, release, selected, proceed, master = session
  if requested_signal:
    process.send_signal(requested_signal)
  else:
    os.write(release, b"1")
  process.wait(timeout=5)
  for descriptor in (ready, release, selected, proceed, master):
    if descriptor is not None: os.close(descriptor)
  # Wait on the stable inode itself, rather than racing guardian scheduling.
  claim = state.session_claim("claude", home)
  try:
    import fcntl
    fcntl.flock(claim, fcntl.LOCK_EX)
  finally:
    os.close(claim)

try:
  reset()
  claim = state.session_claim("claude", home)
  claim_inode = os.fstat(claim).st_ino
  claim_directory = state.state_root() / "session-claims/claude"
  claim_file = next(claim_directory.iterdir())
  assert claim_file.stat().st_mode & 0o777 == 0o600
  for directory in (state.state_root(), claim_directory.parent, claim_directory):
    assert directory.stat().st_mode & 0o777 == 0o700 and directory.stat().st_uid == os.getuid()
  alias = area / "home-alias"
  alias.symlink_to(home, target_is_directory=True)
  try:
    state.session_claim("claude", alias, exclusive=True)
    raise AssertionError("canonical home aliases must use the same inode")
  except BlockingIOError:
    pass
  os.close(claim)
  outside = area / "outside-file"
  outside.write_text("untouched")
  alternate = area / "custom-home"
  link_name = state.hashlib.sha256(os.fsencode(alternate.resolve())).hexdigest() + ".lock"
  (claim_directory / link_name).symlink_to(outside)
  try:
    state.session_claim("claude", alternate)
    raise AssertionError("claim symlinks must be rejected")
  except OSError:
    pass
  assert outside.read_text() == "untouched"
  print("ok - canonical claims share stable private inodes and reject symlink substitution")
  first = launch(paused=True)
  assert barrier_read(first[3]) == b"claimed"
  removal = subprocess.Popen([str(script), "remove", "claude", "side"], env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  processes.append(removal)
  try:
    removal.wait(timeout=0.1)
    raise AssertionError("removal passed the launcher-held registry lock")
  except subprocess.TimeoutExpired:
    pass
  os.write(first[4], b"1")
  assert barrier_read(first[1]).decode().split(":")[0] == str(first[0].pid), "exec preserves the launcher PID"
  _, error = removal.communicate(timeout=5)
  assert removal.returncode == 1 and b"Quit it first" in error and home.is_dir()
  assert run("use", "claude", "main").returncode == 0, "registry edits remain responsive during a session"
  assert run("rename", "claude", "side", "Renamed").returncode == 0
  assert run("remove", "claude", "renamed").returncode == 1, "renaming does not change home claim identity"
  finish(first)
  assert run("remove", "claude", "renamed").returncode == 0
  assert claim_file.is_file() and claim_file.stat().st_ino == claim_inode, "removal must not unlink the stable claim inode"
  print("ok - claim and readiness close the startup/removal gap while registry edits and renames remain responsive")

  # A terminal broker can wait arbitrarily long before it dispatches the CLI.
  # Carry only explicit overrides/unsets, never an unclaimed registry home.
  broker = area / "broker-bin"
  broker.mkdir()
  (broker / "omarchy-default-agent").write_text("#!/bin/bash\necho claude\n")
  (broker / "omarchy-cmd-missing").write_text("#!/bin/bash\nexit 1\n")
  (broker / "omarchy-launch-tui").write_text('''#!/bin/bash
printf '%s\\n' "$@" >"$BROKER_ARGUMENTS"
printf 'waiting' >&$BROKER_READY
read -r -n 1 <&$BROKER_PROCEED
shift
exec "$@"
''')
  (broker / "claude").write_text('''#!/bin/bash
exec omarchy-agent-account-state exec claude python3 -c 'import os,sys;os.write(int(os.environ["CLI_READY"]),os.environ.get("CLAUDE_CONFIG_DIR", "default").encode());os.read(int(os.environ["CLI_RELEASE"]),1)'
''')
  for path in broker.iterdir(): path.chmod(0o755)
  for explicit in (False, True, "revoked"):
    reset()
    if explicit == "revoked":
      assert run("remove", "claude", "side").returncode == 0
    ready_read, ready_write = os.pipe()
    proceed_read, proceed_write = os.pipe()
    cli_read, cli_write = os.pipe()
    release_read, release_write = os.pipe()
    gui_env = dict(environment, PATH=f"{broker}:{root / 'bin'}:/usr/bin", BROKER_ARGUMENTS=str(area / "broker-arguments"), BROKER_READY=str(ready_write), BROKER_PROCEED=str(proceed_read), CLI_READY=str(cli_write), CLI_RELEASE=str(release_read))
    if explicit: gui_env["CLAUDE_CONFIG_DIR"] = str(home)
    gui = subprocess.Popen([str(root / "bin/omarchy-agent")], env=gui_env, pass_fds=(ready_write, proceed_read, cli_write, release_read), stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    processes.append(gui)
    for descriptor in (ready_write, proceed_read, cli_write, release_read): os.close(descriptor)
    assert barrier_read(ready_read) == b"waiting"
    if not explicit:
      assert str(home) not in (area / "broker-arguments").read_text(), "GUI broker must not embed an unclaimed selected home"
    if explicit is True:
      assert run("remove", "claude", "side").returncode == 1, "the legacy process guard also protects a broker's explicit override"
    elif not explicit:
      assert run("remove", "claude", "side").returncode == 0
    other = home.parent / "other"
    other.mkdir(exist_ok=True, mode=0o700)
    accounts = [{"id": "main", "label": "Main", "primary": True}, {"id": "other", "label": "Other", "home": str(other)}]
    if explicit is True:
      accounts.append({"id": "side", "label": "Side", "home": str(home)})
    state.save("claude", {"active": "other", "accounts": accounts})
    os.write(proceed_write, b"1")
    if explicit == "revoked":
      gui.communicate(timeout=5)
      assert gui.returncode == 1 and barrier_read(cli_read) == b"" and not home.exists(), "a revoked explicit GUI home must fail"
    else:
      selected = home if explicit else other
      assert barrier_read(cli_read) == os.fsencode(selected), "terminal startup follows current selection or a deliberate explicit override"
      assert run("remove", "claude", "side" if explicit else "other").returncode == 1
      os.write(release_write, b"1")
      gui.communicate(timeout=5)
      assert gui.returncode == 0
      claim = state.session_claim("claude", selected)
      import fcntl
      fcntl.flock(claim, fcntl.LOCK_EX)
      os.close(claim)
    for descriptor in (ready_read, proceed_write, cli_read, release_write): os.close(descriptor)
  print("ok - a paused GUI broker resolves current selection at CLI startup and rejects revoked explicit managed homes")

  reset()
  interrupted = launch(paused=True)
  assert barrier_read(interrupted[3]) == b"claimed"
  interrupted[0].terminate()
  interrupted[0].wait(timeout=5)
  for descriptor in interrupted[1:5]: os.close(descriptor)
  assert run("remove", "claude", "side").returncode == 0
  print("ok - interruption before guardian startup releases the claim without launching the CLI")

  reset()
  closed = launch(closed_stdio=True)
  assert barrier_read(closed[1]) == f"{closed[0].pid}:False".encode()
  assert not state.home_in_use("claude", home), "legacy environment scanning must not mask the closed-stdio regression"
  try:
    state.session_claim("claude", home, exclusive=True)
    raise AssertionError("closed stdio must not overwrite the guardian's claim or pidfd")
  except BlockingIOError:
    pass
  assert run("remove", "claude", "side").returncode == 1 and home.is_dir()
  finish(closed)
  assert run("remove", "claude", "side").returncode == 0
  print("ok - closed stdio preserves the guardian claim across same-PID exec without legacy environment protection")

  external_alias = state.accounts_root() / "../custom"
  external_alias.resolve().mkdir(mode=0o700)
  for variable in ("CLAUDE_CONFIG_DIR", "OMARCHY_AGENT_CLAUDE_HOME"):
    custom_env = dict(environment, **{variable: str(external_alias)})
    result = subprocess.run([str(script), "exec", "claude", sys.executable, "-c", "import os; print(os.environ['CLAUDE_CONFIG_DIR']); print(os.environ['OMARCHY_AGENT_CLAUDE_HOME'])"], env=custom_env, capture_output=True, text=True, timeout=5)
    assert result.returncode == 0 and result.stdout.splitlines() == [str(external_alias), str(external_alias)], "legitimate external .. aliases retain explicit and inherited home semantics"
  print("ok - external custom home aliases with dot-dot remain valid through explicit and inherited selection")

  reset()
  for command in (["/usr/bin/yes"], [str(script), "exec", "claude", "/usr/bin/yes"]):
    native = subprocess.Popen(command, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    processes.append(native)
    native.stdout.close()
    native.wait(timeout=5)
    assert native.returncode == -signal.SIGPIPE, "dispatch must preserve native broken-pipe termination"
    assert native.stderr.read() == b"", "native SIGPIPE must not become a printed Broken pipe error"
    native.stderr.close()
  claim = state.session_claim("claude", home)
  import fcntl
  fcntl.flock(claim, fcntl.LOCK_EX)
  os.close(claim)
  print("ok - native closed-reader SIGPIPE termination matches direct exec and releases the claim")

  reset()
  failure = launch(setup_failure=True)
  failure[0].wait(timeout=5)
  assert failure[0].returncode != 0 and barrier_read(failure[1]) == b"", "guardian setup failure never launches the CLI"
  for descriptor in failure[1:5]: os.close(descriptor)
  assert run("remove", "claude", "side").returncode == 0
  reset()
  failed_exec = run("exec", "claude", "/nonexistent/agent")
  assert failed_exec.returncode != 0
  claim = state.session_claim("claude", home)
  import fcntl
  fcntl.flock(claim, fcntl.LOCK_EX)
  os.close(claim)
  assert run("remove", "claude", "side").returncode == 0
  print("ok - guardian setup and exec failures release the claim without starting an unprotected session")

  for sent, expected in ((signal.SIGTERM, 73), (signal.SIGINT, 74), (signal.SIGHUP, 75)):
    reset()
    session = launch(terminal=True)
    assert barrier_read(session[1]) == f"{session[0].pid}:True".encode(), "stdin/stdout/stderr remain the caller's TTY"
    assert run("remove", "claude", "side").returncode == 1
    finish(session, sent)
    assert session[0].returncode == expected, "signals reach the actual CLI at the original PID"
    assert run("remove", "claude", "side").returncode == 0
  print("ok - terminal descriptors, launcher PID, signals and exit statuses survive the guardian")

  reset()
  sessions = [launch(), launch()]
  for session in sessions: barrier_read(session[1])
  assert run("remove", "claude", "side").returncode == 1
  # Don't ask finish to acquire EX while the other session is still alive.
  os.write(sessions[0][2], b"1")
  sessions[0][0].wait(timeout=5)
  assert run("remove", "claude", "side").returncode == 1
  finish(sessions[1])
  for descriptor in sessions[0][1:5]: os.close(descriptor)
  assert run("remove", "claude", "side").returncode == 0
  for variable in ("CLAUDE_CONFIG_DIR", "OMARCHY_AGENT_CLAUDE_HOME"):
    revoked = dict(environment, **{variable: str(home)})
    result = subprocess.run([str(script), "exec", "claude", "/bin/true"], env=revoked, capture_output=True, timeout=5)
    assert result.returncode == 1 and not home.exists(), "revoked managed homes cannot be recreated by stale pins"
  print("ok - every concurrent session protects its home and stale explicit or inherited homes fail after removal")

  reset()
  original_save, original_rename, original_cleanup = state.save, Path.rename, state.shutil.rmtree
  before = registry_file.read_bytes()
  def fail_save(*_): raise OSError("injected registry save failure")
  state.save = fail_save
  try:
    state.remove("claude", "side")
    raise AssertionError("save failure must be reported")
  except OSError:
    pass
  finally:
    state.save = original_save
  assert home.is_dir() and (home / "credentials").read_text() == "private fixture" and registry_file.read_bytes() == before
  def fail_rename(path, target):
    if path == home: raise OSError("injected rename failure")
    return original_rename(path, target)
  Path.rename = fail_rename
  try:
    state.remove("claude", "side")
    raise AssertionError("rename failure must be reported")
  except OSError:
    pass
  finally:
    Path.rename = original_rename
  assert home.is_dir() and registry_file.read_bytes() == before
  def fail_cleanup(*_): raise OSError("injected cleanup failure")
  state.shutil.rmtree = fail_cleanup
  try:
    state.remove("claude", "side")
    raise AssertionError("cleanup failure must be reported")
  except state.AccountError as error:
    assert "private files remain" in str(error)
  finally:
    state.shutil.rmtree = original_cleanup
  retained = list(home.parent.glob(".removed-side-*"))
  assert len(retained) == 1 and (retained[0] / "credentials").read_text() == "private fixture"
  assert not state.find(state.load("claude"), "side")
  print("ok - removal restores credentials on save failure and reports rename or retained-file cleanup failures")
finally:
  for process in processes:
    if process.poll() is None:
      process.kill()
      process.wait(timeout=5)
PY
