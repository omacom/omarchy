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
if [[ -n ${OMARCHY_TEST_SHOW_PATH:-} ]]; then
  echo "$PATH"
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

# Antigravity keeps its sign-in in the keyring; this one holds whatever the
# test puts there, never the developer's.
cat >"$mock_bin/secret-tool" <<'SH'
#!/bin/bash
[[ $* == "lookup service gemini username antigravity" ]] && printf '%s' "${OMARCHY_TEST_AGY_SECRET:-}"
SH

chmod +x "$mock_bin"/*

export HOME="$test_tmp/home"
export XDG_STATE_HOME="$test_tmp/state"
export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_NOTIFICATIONS="$notifications"
export OMARCHY_TEST_BROWSER_LOG="$test_tmp/browser"
# A session started by an account launch pins its home through these, and
# a run from inside one (an agent working on Omarchy) must not inherit it.
unset CLAUDE_CONFIG_DIR CODEX_HOME GROK_HOME BROWSER
unset OMARCHY_AGENT_CLAUDE_HOME OMARCHY_AGENT_CODEX_HOME OMARCHY_AGENT_GROK_HOME
# Where the other agents keep their sign-ins and keys follows from HOME alone.
unset XDG_CONFIG_HOME XDG_DATA_HOME GH_CONFIG_DIR GH_TOKEN GITHUB_TOKEN COPILOT_QUOTA_TOKEN COPILOT_HOME
unset CURSOR_AUTH_PATH MUSE_AUTH_PATH KIMI_CODE_HOME KIMI_SHARE_DIR AGY_DIR DEVIN_DATA_DIR
while read -r variable; do unset "$variable"; done < <(compgen -e | grep '_API_KEY$' || true)

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

# A shared folder can be the person's own symlink that points nowhere yet, such
# as a dotfiles link whose target hasn't synced. Adding an account must leave it
# alone rather than fail on it.
ln -s "$test_tmp/dotfiles/claude-skills" "$HOME/.claude/skills"

OMARCHY_TEST_LOGIN_UUID=u-work OMARCHY_TEST_LOGIN_EMAIL=work@example.com \
  omarchy-agent-account-add claude Work </dev/null >"$test_tmp/add-output" 2>&1 ||
  fail "adding an account works when a shared folder is a dangling symlink" "$(cat "$test_tmp/add-output")"
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
[[ $(readlink "$HOME/.claude/skills") == "$test_tmp/dotfiles/claude-skills" && $(readlink "$work/skills") == "$HOME/.claude/skills" ]] ||
  fail "a dangling shared symlink is left alone and still shared"
[[ -z $(find "$accounts/claude/.pending" -mindepth 1 -print -quit 2>/dev/null) ]] || fail "adding an account leaves no pending login behind"
pass "an added account shares everything but its login with the primary"

# A shared folder that isn't a folder at all (here a regular file) is still an
# error, and the half-made login home is cleaned up rather than left behind.
mv "$HOME/.claude/commands" "$test_tmp/commands-dir" 2>/dev/null || true
touch "$HOME/.claude/commands"
if OMARCHY_TEST_LOGIN_UUID=u-broken OMARCHY_TEST_LOGIN_EMAIL=broken@example.com \
  omarchy-agent-account-add claude Broken </dev/null >"$test_tmp/broken-output" 2>&1; then
  fail "a shared folder that is a file stops the add"
fi
grep -Fq "Couldn't set up a home for the new account." "$test_tmp/broken-output" ||
  fail "the failed add reports the shared-folder setup error" "$(cat "$test_tmp/broken-output")"
[[ -z $(find "$accounts/claude/.pending" -mindepth 1 -print -quit 2>/dev/null) ]] ||
  fail "a failed account setup leaves no pending login behind" "$(ls -A "$accounts/claude/.pending")"
rm "$HOME/.claude/commands"
if [[ -d $test_tmp/commands-dir ]]; then
  mv "$test_tmp/commands-dir" "$HOME/.claude/commands"
fi
pass "a failed account setup is refused and cleans up after itself"

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
grep -q "New Claude sessions now use Work Running sessions stay on" "$notifications" || fail "switching says where new sessions go"
pass "use makes an account active and says so"

[[ $(omarchy-agent-account-exec claude --version) == "claude home=$work args=--version" ]] || fail "claude at a prompt starts as the active account"
[[ $(CLAUDE_CONFIG_DIR=/elsewhere omarchy-agent-account-exec claude) == "claude home=/elsewhere args=" ]] || fail "an explicit CLAUDE_CONFIG_DIR wins over the active account"
[[ $(omarchy-agent-account-exec codex) == "codex home=default args=" ]] || fail "codex stays on its primary until switched"
# mise strips its shims before running a wrapper, so the agent would only see
# tools installed before it started.
[[ :$(MISE_DATA_DIR="$test_tmp/mise" OMARCHY_TEST_SHOW_PATH=1 omarchy-agent-account-exec claude): == *":$test_tmp/mise/shims:"* ]] ||
  fail "an agent finds mise tools installed after it started"
pass "account dispatch follows the active account"

[[ $(OMARCHY_TEST_DEFAULT_AGENT=claude omarchy-agent --inline) == "claude home=$work args=--permission-mode auto" ]] ||
  fail "omarchy-agent starts Claude as the active account"
omarchy-agent-account-use codex side >/dev/null
[[ $(OMARCHY_TEST_DEFAULT_AGENT=codex omarchy-agent --inline) == "codex home=$accounts/codex/side args=--approve-for-me" ]] ||
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
rename_output=$(omarchy-agent-account-rename claude work Day job)
# The suggested command names the provider, so it works whatever the default agent is.
[[ $rename_output == *"Switch to it with: omarchy agent account use claude day-job" ]] ||
  fail "rename suggests a use command that names the provider" "$rename_output"
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

# A registry that can't be saved leaves the new login pending for recovery,
# rather than in a home nothing can manage.
STATE="$ROOT/bin/omarchy-agent-account-state" python3 - <<'PY' || fail "a failed registration rolls the new home back to pending"
import importlib.machinery, importlib.util, json, os, sys
loader = importlib.machinery.SourceFileLoader("state", os.environ["STATE"])
spec = importlib.util.spec_from_loader(loader.name, loader)
state = importlib.util.module_from_spec(spec)
loader.exec_module(state)

pending = state.begin("claude")
(pending / ".claude.json").write_text(json.dumps({"oauthAccount": {"accountUuid": "u-stranded", "emailAddress": "stranded@example.com"}}))
(pending / ".credentials.json").write_text(json.dumps({"claudeAiOauth": {"accessToken": "test-token"}}))

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
# Remove the recoverable fixture before later tests.
import shutil
shutil.rmtree(pending)
PY
pass "a failed registration rolls the new home back to pending"

# A settings cache whose settings aren't an object costs only the plan.
STATE="$ROOT/bin/omarchy-agent-account-state" python3 - <<'PY' || fail "a Grok settings cache of the wrong shape reads as no plan"
import importlib.machinery, importlib.util, json, os, tempfile
from pathlib import Path
loader = importlib.machinery.SourceFileLoader("state", os.environ["STATE"])
spec = importlib.util.spec_from_loader(loader.name, loader)
state = importlib.util.module_from_spec(spec)
loader.exec_module(state)

home = Path(tempfile.mkdtemp(dir=os.environ["HOME"]))
(home / "auth.json").write_text(json.dumps({"https://auth.x.ai::client": {"user_id": "u-odd", "email": "odd@example.com"}}))
(home / "settings_cache.json").write_text(json.dumps({"payload": json.dumps({"settings": "x"})}))
found = state.grok_identity(home)
assert found["plan"] == "" and found["email"] == "odd@example.com", found
PY
pass "a Grok settings cache of the wrong shape reads as no plan"

# ------------------------------------------------------------ panel add flow

[[ $(omarchy-agent-account-add --check | sed -n 1,3p) == $'claude additional\ncodex additional\ngrok additional' ]] ||
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

# --reauth without an account is a mistake, not a request to add one.
: >"$OMARCHY_TEST_BROWSER_LOG"
before=$(omarchy-agent-account-list claude --json | jq '.[0].accounts | length')
for args in "--reauth" "--reauth --events"; do
  # shellcheck disable=SC2086
  if OMARCHY_TEST_LOGIN_UUID=u-stray OMARCHY_TEST_LOGIN_EMAIL=stray@example.com \
    omarchy-agent-account-add $args </dev/null >/dev/null 2>&1; then
    fail "--reauth needs an account: $args"
  fi
done
[[ $(omarchy-agent-account-list claude --json | jq '.[0].accounts | length') == "$before" && ! -s $OMARCHY_TEST_BROWSER_LOG ]] ||
  fail "--reauth without an account adds nothing and opens no sign-in"
pass "--reauth without an account is refused"

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

# ------------------------------------------------------- other agents' sign-ins

# A machine with nothing signed in yet. Every other agent's CLI is a lazy
# mise shim, so each stub logs being run: --check must never start one.
export HOME="$test_tmp/fresh"
export XDG_STATE_HOME="$test_tmp/fresh-state"
mkdir -p "$HOME"
lazy_log="$test_tmp/lazy"
: >"$lazy_log"
export OMARCHY_TEST_LAZY_LOG="$lazy_log"

cat >"$mock_bin/cursor-agent" <<'SH'
#!/bin/bash
echo "cursor-agent $*" >>"$OMARCHY_TEST_LAZY_LOG"
[[ $* == "login" ]] || exit 1
echo "If your browser didn't open, use this link:"
echo "https://cursor.com/loginDeepControl?challenge=abc"
mkdir -p "$HOME/.config/cursor"
echo '{"accessToken":"cursor-token"}' >"$HOME/.config/cursor/auth.json"
SH

# Kimi writes its whole login to stderr.
cat >"$mock_bin/kimi" <<'SH'
#!/bin/bash
echo "kimi $*" >>"$OMARCHY_TEST_LAZY_LOG"
[[ $* == "login" ]] || exit 1
echo "Opening browser for Kimi device login: https://www.kimi.com/code/authorize_device?user_code=5VO0-EJ1G" >&2
echo "If the browser did not open, paste the URL above and enter code: 5VO0-EJ1G" >&2
mkdir -p "$HOME/.kimi-code/credentials"
echo '{"access_token":"kimi-token"}' >"$HOME/.kimi-code/credentials/kimi-code.json"
SH

# Muse opens no browser at all.
cat >"$mock_bin/muse" <<'SH'
#!/bin/bash
echo "muse $*" >>"$OMARCHY_TEST_LAZY_LOG"
[[ $* == "login" ]] || exit 1
if [[ -n ${OMARCHY_TEST_LOGIN_HANGS:-} ]]; then
  echo $$ >"$OMARCHY_TEST_LOGIN_HANGS"
  exec sleep 30
fi
echo "Open this page to sign in:"
echo "  https://auth.meta.com/oauth/device/?code=PSBL-LCKQ"
echo "confirm this code matches:"
echo "  PSBL-LCKQ"
echo "Or https://auth.meta.com/elsewhere"
mkdir -p "$HOME/.config/muse"
echo '{"providers":{"meta":{"access_token":"muse-token"}}}' >"$HOME/.config/muse/auth.json"
SH

# gh without a terminal prints its device code and URL and opens nothing.
cat >"$mock_bin/gh" <<'SH'
#!/bin/bash
echo "gh $* GH_TOKEN=${GH_TOKEN-unset}" >>"$OMARCHY_TEST_LAZY_LOG"
[[ ${1:-} == "auth" && ${2:-} == "login" ]] || exit 1
echo "! First copy your one-time code: 9AC3-7061" >&2
echo "Open this URL to continue in your web browser: https://github.com/login/device" >&2
mkdir -p "$HOME/.config/gh"
printf 'github.com:\n    git_protocol: https\n    user: octocat\n' >"$HOME/.config/gh/hosts.yml"
SH

for cli in agy devin; do
  printf '#!/bin/bash\necho "%s $*" >>"$OMARCHY_TEST_LAZY_LOG"\nexit 1\n' "$cli" >"$mock_bin/$cli"
done

# agy and devin sign in only in a terminal of their own; this one lands the
# sign-in a moment after it opens, unless the test leaves it waiting.
cat >"$mock_bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
echo "$*" >>"$OMARCHY_TEST_TERMINAL_LOG"
[[ -n ${OMARCHY_TEST_TERMINAL_HANGS:-} ]] && exit 0
case "$1" in
agy) file="$HOME/.gemini/antigravity-cli/antigravity-oauth-token" ;;
devin) file="$HOME/.local/share/devin/credentials.toml" ;;
esac
(sleep 1; mkdir -p "${file%/*}"; echo '{"token":{"access_token":"t"}}' >"$file") &
SH
export OMARCHY_TEST_TERMINAL_LOG="$test_tmp/terminal"

chmod +x "$mock_bin"/*

expected=$'claude first\ncodex first\ngrok first\ncursor first\ncopilot first\nkimi first\nmuse first\nagy first\ndevin first'
expected+=$'\nzai key\nminimax key\nsynthetic key\nollama key\nopenrouter key\ndeepseek key\nfireworks key\nopencode key\nkimchi key'
[[ $(omarchy-agent-account-add --check) == "$expected" ]] ||
  fail "--check lists every provider, in order, on a machine with nothing signed in" "$(omarchy-agent-account-add --check)"
[[ $(OMARCHY_TEST_AGY_SECRET='{"token":{}}' omarchy-agent-account-add --check | grep '^agy ') == "agy signed" ]] ||
  fail "--check reads Antigravity's sign-in from the keyring"
[[ ! -s $lazy_log ]] || fail "--check never runs an agent's CLI" "$(cat "$lazy_log")"
pass "--check lists every provider without running any agent's CLI"

: >"$OMARCHY_TEST_BROWSER_LOG"
OMARCHY_TEST_DEFAULT_AGENT="" omarchy-agent-account-add --events cursor </dev/null >"$test_tmp/cursor-output" 2>/dev/null ||
  fail "a Cursor sign-in succeeds" "$(cat "$test_tmp/cursor-output")"
grep -qx "@@omarchy status Sign in to Cursor in the browser window that opens." "$test_tmp/cursor-output" &&
  grep -qx "https://cursor.com/loginDeepControl?challenge=abc" "$test_tmp/cursor-output" &&
  grep -qx "@@omarchy done Signed in to Cursor." "$test_tmp/cursor-output" ||
  fail "a Cursor sign-in reports its progress and the CLI's own link" "$(cat "$test_tmp/cursor-output")"
[[ ! -s $OMARCHY_TEST_BROWSER_LOG ]] || fail "Cursor opens its own sign-in page" "$(cat "$OMARCHY_TEST_BROWSER_LOG")"
[[ $(cat "$HOME/.config/omarchy/defaults/agent") == "cursor-agent" ]] ||
  fail "the first agent signed in on a machine with no default becomes the default, by its launcher's name"
pass "Cursor signs in through its own login"

omarchy-agent-account-add --events kimi </dev/null >"$test_tmp/kimi-output" 2>/dev/null
grep -q "enter code: 5VO0-EJ1G" "$test_tmp/kimi-output" && grep -qx "@@omarchy done Signed in to Kimi." "$test_tmp/kimi-output" ||
  fail "what Kimi writes to stderr reaches the panel" "$(cat "$test_tmp/kimi-output")"
[[ $(cat "$HOME/.config/omarchy/defaults/agent") == "cursor-agent" ]] || fail "a later sign-in leaves the default alone"
pass "Kimi's sign-in reaches the panel on stdout"

: >"$OMARCHY_TEST_BROWSER_LOG"
omarchy-agent-account-add --events muse </dev/null >"$test_tmp/muse-output" 2>/dev/null
grep -qx "  PSBL-LCKQ" "$test_tmp/muse-output" && grep -qx "@@omarchy done Signed in to Muse." "$test_tmp/muse-output" ||
  fail "a Muse sign-in passes its code through" "$(cat "$test_tmp/muse-output")"
[[ $(cat "$OMARCHY_TEST_BROWSER_LOG") == "https://auth.meta.com/oauth/device/?code=PSBL-LCKQ" ]] ||
  fail "Muse's sign-in page is opened for it, once" "$(cat "$OMARCHY_TEST_BROWSER_LOG")"
pass "Muse's sign-in page is opened for it"

: >"$OMARCHY_TEST_BROWSER_LOG"
: >"$lazy_log"
GH_TOKEN=exported omarchy-agent-account-add --events copilot </dev/null >"$test_tmp/copilot-output" 2>/dev/null
grep -q "one-time code: 9AC3-7061" "$test_tmp/copilot-output" && grep -qx "@@omarchy done Signed in to GitHub Copilot." "$test_tmp/copilot-output" ||
  fail "a Copilot sign-in passes gh's device code through" "$(cat "$test_tmp/copilot-output")"
[[ $(cat "$lazy_log") == "gh auth login --web --hostname github.com --git-protocol https GH_TOKEN=unset" ]] ||
  fail "Copilot signs in through gh, without an exported token in the way" "$(cat "$lazy_log")"
[[ $(cat "$OMARCHY_TEST_BROWSER_LOG") == "https://github.com/login/device" && -d $HOME/.copilot ]] ||
  fail "gh's device page is opened for it, and Copilot's usage gets asked for" "$(cat "$OMARCHY_TEST_BROWSER_LOG")"
pass "Copilot signs in through gh"

for agent in agy:Antigravity:agy devin:Devin:"devin auth login"; do
  IFS=: read -r id agent_name terminal_command <<<"$agent"
  : >"$OMARCHY_TEST_TERMINAL_LOG"
  omarchy-agent-account-add --events "$id" </dev/null >"$test_tmp/$id-output" 2>/dev/null
  grep -qx "@@omarchy status Finish signing in to $agent_name in the terminal window that opens." "$test_tmp/$id-output" &&
    grep -qx "@@omarchy done Signed in to $agent_name." "$test_tmp/$id-output" ||
    fail "$agent_name signs in in a terminal and is done once its sign-in lands" "$(cat "$test_tmp/$id-output")"
  [[ $(cat "$OMARCHY_TEST_TERMINAL_LOG") == "$terminal_command" ]] ||
    fail "$agent_name's sign-in runs in a terminal" "$(cat "$OMARCHY_TEST_TERMINAL_LOG")"
done
pass "Antigravity and Devin sign in in a terminal, and the panel waits for it"

: >"$lazy_log"
expected=$'cursor signed\ncopilot signed\nkimi signed\nmuse signed\nagy signed\ndevin signed'
[[ $(omarchy-agent-account-add --check | sed -n 4,9p) == "$expected" ]] ||
  fail "--check sees each sign-in where its usage collector reads it" "$(omarchy-agent-account-add --check)"
[[ ! -s $lazy_log ]] || fail "--check never runs an agent's CLI once signed in either" "$(cat "$lazy_log")"
pass "--check sees each sign-in where its usage collector reads it"

# Cancelling stops a wait on the terminal at once, and a login whose page the
# script opened, with the CLI itself.
rm -f "$HOME/.local/share/devin/credentials.toml"
OMARCHY_TEST_TERMINAL_HANGS=1 omarchy-agent-account-add --events devin </dev/null >"$test_tmp/devin-cancel" 2>&1 &
adding=$!
sleep 1
started=$EPOCHREALTIME
kill -TERM "$adding"
wait "$adding" || true
# Well inside the two seconds between looks at the sign-in.
now=$EPOCHREALTIME
(( ${now//[.,]/} - ${started//[.,]/} < 800000 )) || fail "cancelling stops waiting on the terminal at once"
! grep -q "^@@omarchy done" "$test_tmp/devin-cancel" || fail "a cancelled terminal sign-in isn't done"

OMARCHY_TEST_LOGIN_HANGS="$test_tmp/muse.pid" omarchy-agent-account-add --events muse </dev/null >/dev/null 2>&1 &
adding=$!
for _ in {1..20}; do
  [[ -s $test_tmp/muse.pid ]] && break
  sleep 0.1
done
kill -TERM "$adding"
wait "$adding" || true
login_pid=$(cat "$test_tmp/muse.pid")
for _ in {1..20}; do
  kill -0 "$login_pid" 2>/dev/null || break
  sleep 0.1
done
if kill -0 "$login_pid" 2>/dev/null; then
  kill "$login_pid"
  fail "cancelling stops a login whose page was opened for it"
fi
pass "cancelling stops a terminal wait and a login alike"

# ------------------------------------------------------------------- API keys

# The usage collector checks a pasted key with its provider; these report
# whatever the test says the provider answered, and what they were run with.
for id in openrouter kimchi zai; do
  cat >"$mock_bin/omarchy-agent-usage-$id" <<'SH'
#!/bin/bash
id=${0##*omarchy-agent-usage-}
printf '%s %s env=%s\n' "$id" "$*" "${OPENROUTER_API_KEY-unset}" >>"$OMARCHY_TEST_COLLECTOR_LOG"
printf '{"usageStatusText":"%s"}\n' "${OMARCHY_TEST_KEY_STATUS:-}"
SH
done
# Every jq run is logged, to show the key never rides on a command line.
cat >"$mock_bin/jq" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"\$OMARCHY_TEST_JQ_LOG"
exec $(command -v jq) "\$@"
SH
chmod +x "$mock_bin"/*
export OMARCHY_TEST_COLLECTOR_LOG="$test_tmp/collector" OMARCHY_TEST_JQ_LOG="$test_tmp/jq"
: >"$OMARCHY_TEST_JQ_LOG"

saved="$HOME/.config/omarchy/agents/openrouter.json"
mkdir -p "${saved%/*}"
echo '{"managementKey":"sk-management","apiKey":"sk-old"}' >"$saved"
chmod 644 "$saved"
: >"$notifications"
printf '  sk-or-pasted \n' | OPENROUTER_API_KEY=sk-exported omarchy-agent-account-add --events --key openrouter >"$test_tmp/key-output" 2>&1 ||
  fail "a pasted key is saved" "$(cat "$test_tmp/key-output")"
grep -qx "@@omarchy status Checking the key with OpenRouter…" "$test_tmp/key-output" &&
  grep -qx "@@omarchy done Saved the OpenRouter API key." "$test_tmp/key-output" ||
  fail "saving a key reports its progress" "$(cat "$test_tmp/key-output")"
[[ $(jq -c . "$saved") == '{"managementKey":"sk-management","apiKey":"sk-or-pasted"}' && $(stat -c %a "$saved") == 600 ]] ||
  fail "a pasted key is merged into the provider's file, readable only by you" "$(stat -c %a "$saved") $(cat "$saved")"
[[ $(cat "$OMARCHY_TEST_COLLECTOR_LOG") == "openrouter --force env=unset" ]] ||
  fail "the key is checked by its collector, without an exported key answering for it" "$(cat "$OMARCHY_TEST_COLLECTOR_LOG")"
! grep -q "sk-or-pasted" "$test_tmp/key-output" "$notifications" "$OMARCHY_TEST_JQ_LOG" "$OMARCHY_TEST_COLLECTOR_LOG" ||
  fail "the key is never printed or passed as an argument"
pass "a pasted key is saved beside what the file already holds"

cp -p "$saved" "$test_tmp/saved-before"
if printf 'sk-or-bad\n' | OMARCHY_TEST_KEY_STATUS="Sign-in expired" omarchy-agent-account-add --events --key openrouter >"$test_tmp/key-rejected" 2>&1; then
  fail "a key the provider refuses fails"
fi
grep -qx "@@omarchy error OpenRouter rejected the key." "$test_tmp/key-rejected" || fail "a refused key says so" "$(cat "$test_tmp/key-rejected")"
cmp -s "$saved" "$test_tmp/saved-before" && [[ $(stat -c %a "$saved") == 600 ]] ||
  fail "a refused key puts back the file that was there" "$(cat "$saved")"
OMARCHY_TEST_KEY_STATUS="Sign-in expired" omarchy-agent-account-add --events --key zai <<<"zai-bad" >/dev/null 2>&1 || true
[[ ! -e $HOME/.config/omarchy/agents/zai.json ]] || fail "a refused first key leaves no file behind"
pass "a refused key leaves the saved one as it was"

if omarchy-agent-account-add --events --key zai <<<"   " >"$test_tmp/key-empty" 2>&1; then
  fail "an empty key is refused"
fi
grep -qx "@@omarchy error No API key was pasted." "$test_tmp/key-empty" && [[ ! -e $HOME/.config/omarchy/agents/zai.json ]] ||
  fail "an empty key is refused and saves nothing" "$(cat "$test_tmp/key-empty")"
pass "an empty key is refused"

XDG_CONFIG_HOME="$test_tmp/elsewhere" omarchy-agent-account-add --events --key kimchi <<<"kimchi-key" >/dev/null 2>&1 ||
  fail "a Kimchi key is saved"
[[ $(jq -r .apiKey "$HOME/.config/kimchi/config.json") == "kimchi-key" ]] || fail "a Kimchi key is saved in Kimchi's own config"
pass "a Kimchi key is saved where Kimchi reads it"

[[ $(omarchy-agent-account-add --check | sed -n '10p;14p;18p') == $'zai key\nopenrouter keyed\nkimchi keyed' ]] ||
  fail "--check tells a provider with a saved key from one without" "$(omarchy-agent-account-add --check)"
pass "--check tells a provider with a saved key from one without"
