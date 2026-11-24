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

# Guard against any package install during sign-in, ahead of every PATH the
# tests use, so nothing real installs and we can assert the log stays empty.
pkg_bin="$test_tmp/pkg-bin"
export OMARCHY_TEST_PKG_LOG="$test_tmp/pkg-log"
mkdir -p "$pkg_bin"
printf '#!/bin/bash\necho "pkexec $*" >>"$OMARCHY_TEST_PKG_LOG"\n' >"$pkg_bin/pkexec"
printf '#!/bin/bash\necho "pkg-add $*" >>"$OMARCHY_TEST_PKG_LOG"\n' >"$pkg_bin/omarchy-pkg-add"
printf '#!/bin/bash\nexit 1\n' >"$pkg_bin/omarchy-pkg-present"
printf '#!/bin/bash\nexit 0\n' >"$pkg_bin/omarchy-region-global"
chmod +x "$pkg_bin"/*

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
  printf '{"claudeAiOauth":{"refreshToken":"%s","rateLimitTier":"default_claude_max_5x","subscriptionType":"max"}}\n' "$OMARCHY_TEST_LOGIN_UUID-$$-$RANDOM" >"$home/.credentials.json"
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
# A session started as the primary, naming no home.
if [[ ${1:-} == "--hold" ]]; then
  sleep 30 &
  trap 'kill $! 2>/dev/null || true' TERM EXIT
  wait $!
  exit 0
fi
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

# Removing a sign-in hides the agent through the running shell and signs out
# through the CLIs and the keyring, none of which a test may reach.
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
echo "$*" >>"$OMARCHY_TEST_BAR_LOG"
SH
printf '#!/bin/bash\necho "$(basename "$0") $*" >>"$OMARCHY_TEST_LOGOUTS"\n' >"$mock_bin/cursor-agent"
cp "$mock_bin/cursor-agent" "$mock_bin/muse"
# The keyring holds an entry while its file exists, and can be made to refuse
# or to be unreachable, which it says on stderr as the real one does.
cat >"$mock_bin/secret-tool" <<'SH'
#!/bin/bash
if [[ -e $OMARCHY_TEST_KEYRING.broken ]]; then
  echo "secret-tool: Cannot autolaunch D-Bus without X11 \$DISPLAY" >&2
  exit 1
fi
case $1 in
lookup) [[ -e $OMARCHY_TEST_KEYRING ]] ;;
clear) [[ -e $OMARCHY_TEST_KEYRING.stuck ]] || rm -f "$OMARCHY_TEST_KEYRING" ;;
esac
SH

cat >"$mock_bin/omarchy-launch-browser" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_BROWSER_LOG"
SH

chmod +x "$mock_bin"/*

export HOME="$test_tmp/home"
export XDG_STATE_HOME="$test_tmp/state"
# No test reaches the running shell, whatever PATH it runs with.
export XDG_RUNTIME_DIR="$test_tmp/runtime"
mkdir -p "$XDG_RUNTIME_DIR"
export PATH="$pkg_bin:$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_NOTIFICATIONS="$notifications"
export OMARCHY_TEST_BROWSER_LOG="$test_tmp/browser"
export OMARCHY_TEST_BAR_LOG="$test_tmp/bar" OMARCHY_TEST_LOGOUTS="$test_tmp/logouts" OMARCHY_TEST_KEYRING="$test_tmp/keyring"
# A session started by an account launch pins its home through these, and
# a run from inside one (an agent working on Omarchy) must not inherit it.
unset CLAUDE_CONFIG_DIR CODEX_HOME GROK_HOME BROWSER
unset OMARCHY_AGENT_CLAUDE_HOME OMARCHY_AGENT_CODEX_HOME OMARCHY_AGENT_GROK_HOME

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
parked="$accounts/claude/.primary"
# Adding an account switches to it, and every Claude session runs in
# ~/.claude, so its login moved there and Main's waits in a home of its own.
[[ $(jq -r .oauthAccount.accountUuid "$HOME/.claude.json") == u-work && $(jq -r .claudeAiOauth.rateLimitTier "$HOME/.claude/.credentials.json") == default_claude_max_5x ]] ||
  fail "an added account's login moves into ~/.claude" "$(cat "$HOME/.claude.json")"
[[ ! -e $work/.credentials.json ]] || fail "a moved login leaves no copy behind, since a refresh token works once"
[[ $(jq -r .claudeAiOauth.rateLimitTier "$parked/.credentials.json") == default_claude_max_20x && $(jq -r .oauthAccount.accountUuid "$parked/.claude.json") == u-main ]] ||
  fail "Main's login waits in its own home"
[[ $(jq -c .mcpServers "$HOME/.claude.json") == '{"docs":{"command":"docs-mcp"}}' && $(jq -c .mcpServers "$parked/.claude.json") == '{"docs":{"command":"docs-mcp"}}' ]] ||
  fail "moving logins keeps the rest of ~/.claude.json, and Main's home carries its settings"
[[ $(stat -c %a "$HOME/.claude/.credentials.json") == 600 && $(stat -c %a "$parked/.credentials.json") == 600 ]] || fail "moved logins stay private"
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

# ~/.claude was signed in to another account by hand since the registry was
# made; adding that login again is still the account seated there.
jq '.oauthAccount.accountUuid = "u-relogged"' "$HOME/.claude.json" >"$test_tmp/relogged.json"
cp "$HOME/.claude.json" "$test_tmp/original.json"
mv "$test_tmp/relogged.json" "$HOME/.claude.json"
if OMARCHY_TEST_LOGIN_UUID=u-relogged OMARCHY_TEST_LOGIN_EMAIL=me@example.com \
  omarchy-agent-account-add claude Twin </dev/null >"$test_tmp/twin-output" 2>&1; then
  fail "a login matching ~/.claude's current sign-in is refused"
fi
grep -q "That's Work" "$test_tmp/twin-output" || fail "a login matching ~/.claude's current sign-in names the account seated there" "$(cat "$test_tmp/twin-output")"
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
pass "account ids stay clear of routing keywords"

# Its login is the one in ~/.claude now, so removing it hands sessions to the
# primary first rather than signing them out.
omarchy-agent-account-remove claude next-2 </dev/null >/dev/null
[[ $(jq -r .oauthAccount.accountUuid "$HOME/.claude.json") == u-main && $(jq -r '.seated + " " + .active' "$accounts/claude.json") == "main main" && ! -e $accounts/claude/next-2 ]] ||
  fail "removing the seated account moves sessions to the primary, then forgets it" "$(cat "$accounts/claude.json")"
pass "removing the account sessions use hands them to another first"

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
[[ $(omarchy-agent-account-exec codex) == "codex home=$accounts/codex/side args=" ]] ||
  fail "an added account becomes the one new sessions use" "$(omarchy-agent-account-exec codex)"
omarchy-agent-account-use codex main >/dev/null
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

claude_account() { jq -r .oauthAccount.accountUuid "$HOME/.claude.json"; }

omarchy-agent-account-use claude main >/dev/null
[[ $(claude_account) == u-main && $(jq -r .claudeAiOauth.rateLimitTier "$work/.credentials.json") == default_claude_max_5x && ! -e $parked/.credentials.json ]] ||
  fail "switching back puts Main's login in ~/.claude and Work's back in its own home"
use_output=$(omarchy-agent-account-use claude work)
[[ -z $(omarchy-agent-account-home claude) && $(claude_account) == u-work ]] || fail "Claude sessions start in ~/.claude, signed in as the account chosen"
[[ $use_output == "Claude sessions now use Work (Max 5x), running ones included." ]] || fail "use says running sessions follow" "$use_output"
grep -q "Claude sessions now use Work Running sessions use it too." "$notifications" || fail "switching says running sessions follow" "$(cat "$notifications")"
pass "use moves the chosen login into ~/.claude, so running sessions follow"

[[ $(omarchy-agent-account-exec claude --version) == "claude home=default args=--version" ]] || fail "claude at a prompt starts in ~/.claude"
[[ $(CLAUDE_CONFIG_DIR=/elsewhere omarchy-agent-account-exec claude) == "claude home=/elsewhere args=" ]] || fail "an explicit CLAUDE_CONFIG_DIR wins over the active account"
[[ $(omarchy-agent-account-exec codex) == "codex home=default args=" ]] || fail "codex stays on its primary until switched"
# A dispatcher exists only while its CLI is installed: no claude command before
# Claude Code is.
dispatchers="$HOME/.local/share/omarchy/agent-accounts/bin"
# Only the mocks, never a real agent the machine running the test has.
cli_only_path="$mock_bin:$ROOT/bin:/usr/bin"
if [[ ! -e /usr/bin/grok ]]; then
  mv "$mock_bin/grok" "$test_tmp/grok-aside"
  PATH=$cli_only_path omarchy-agent-account-dispatch
  [[ -x $dispatchers/claude && -x $dispatchers/codex && ! -e $dispatchers/grok ]] ||
    fail "only an installed CLI gets a dispatcher" "$(ls "$dispatchers")"
  # One left by a CLI removed outside Omarchy goes the first time it runs.
  printf '#!/bin/bash\nexec omarchy-agent-account-exec grok "$@"\n' >"$dispatchers/grok"
  chmod +x "$dispatchers/grok"
  if PATH="$dispatchers:$cli_only_path" "$dispatchers/grok" 2>"$test_tmp/grok-missing"; then
    fail "a dispatcher without its CLI fails"
  fi
  [[ ! -e $dispatchers/grok && $(<"$test_tmp/grok-missing") == "grok: command not found" ]] ||
    fail "a dispatcher without its CLI removes itself and answers as a shell would" "$(<"$test_tmp/grok-missing")"
  mv "$test_tmp/grok-aside" "$mock_bin/grok"
fi
PATH=$cli_only_path omarchy-agent-account-dispatch grok
[[ -x $dispatchers/grok ]] || fail "installing a CLI gives it a dispatcher"
pass "a dispatcher exists only while its CLI is installed"

# Started through its dispatcher, the CLI is the one past it on PATH, and the
# dispatchers stay first for whatever the agent runs, once.
[[ $(PATH="$dispatchers:$PATH" "$dispatchers/claude" --version) == "claude home=default args=--version" ]] ||
  fail "the claude dispatcher runs the real CLI as the active account"
agent_path=$(PATH="$dispatchers:$PATH:$dispatchers" OMARCHY_TEST_SHOW_PATH=1 "$dispatchers/claude")
[[ $agent_path == "$dispatchers:"* && :${agent_path#"$dispatchers:"}: != *":$dispatchers:"* ]] ||
  fail "an agent's own subprocesses dispatch too" "$agent_path"
pass "account dispatch follows the active account"

[[ $(OMARCHY_TEST_DEFAULT_AGENT=claude omarchy-agent --inline) == "claude home=default args=--permission-mode auto" ]] ||
  fail "omarchy-agent starts Claude in ~/.claude"
omarchy-agent-account-use codex side >/dev/null
[[ $(OMARCHY_TEST_DEFAULT_AGENT=codex omarchy-agent --inline) == "codex home=$accounts/codex/side args=--approve-for-me" ]] ||
  fail "omarchy-agent starts Codex as the active account"
pass "omarchy-agent follows the active account"

omarchy-agent-account-use claude next >/dev/null
[[ $(claude_account) == u-main ]] || fail "next cycles back to the primary"
pass "next cycles through accounts"

# With Claude as the default agent, the provider can be left out.
OMARCHY_TEST_DEFAULT_AGENT=claude omarchy-agent-account-use work >/dev/null
[[ $(claude_account) == u-work ]] || fail "use without a provider picks the default agent's account"
OMARCHY_TEST_DEFAULT_AGENT=claude omarchy-agent-account-use main >/dev/null
[[ $(claude_account) == u-main ]] || fail "use without a provider switches back to Main"
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
[[ $(jq -r .seated "$accounts/claude.json") == day-job && $(claude_account) == u-work && -d $work ]] ||
  fail "renaming leaves the account's login and home where they are"
OMARCHY_TEST_DEFAULT_AGENT=claude omarchy-agent-account-rename day-job Work >/dev/null
[[ $(jq -r .seated "$accounts/claude.json") == work ]] || fail "a renamed account can be renamed back"
omarchy-agent-account-rename claude main Personal >/dev/null
[[ $(omarchy-agent-account-list claude --json | jq -r '.[0].accounts[] | select(.primary) | "\(.id) \(.home)"') == "personal $parked" ]] ||
  fail "the primary account can be renamed and keeps its login where it is"
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

# ------------------------------------------------------ running sessions follow

[[ $(jq -r '.accounts[] | select(.id == "work") | .login' "$accounts/claude.json") == "$HOME/.claude" && $(jq -r '.accounts[] | select(.primary) | .login' "$accounts/claude.json") == "$parked" ]] ||
  fail "the registry says where each login is, for the usage collector" "$(cat "$accounts/claude.json")"

# A session started in Work's own home before logins moved still holds its
# token there, so the login stays put until that session quits.
omarchy-agent-account-use claude main >/dev/null
CLAUDE_CONFIG_DIR="$work" sleep 30 &
legacy=$!
use_output=$(omarchy-agent-account-use claude work)
[[ $(omarchy-agent-account-home claude) == "$work" && $(claude_account) == u-main && -f $work/.credentials.json ]] ||
  fail "a login a running session holds stays put, and new sessions start beside it"
[[ $use_output == *"Running sessions stay on Main."* && $use_output == *"(pid $legacy)"* ]] || fail "use names the sessions holding the login" "$use_output"
kill "$legacy"
wait "$legacy" 2>/dev/null || true
: >"$notifications"
omarchy-agent-account-state alert claude >/dev/null
[[ -z $(omarchy-agent-account-home claude) && $(claude_account) == u-work && ! -e $work/.credentials.json ]] ||
  fail "once those sessions quit, the next check moves the login into ~/.claude"
grep -q "Running sessions on Main moved over too." "$notifications" || fail "catching up says running sessions moved" "$(cat "$notifications")"
pass "a switch waits for sessions holding the login, then catches up"

# Claude's own refresh lock: one a crashed session left is taken over, and a
# live one is waited out, so a session never refreshes mid-move.
mkdir "$HOME/.claude/.oauth_refresh.lock"
touch -d '2 minutes ago' "$HOME/.claude/.oauth_refresh.lock"
omarchy-agent-account-use claude main >/dev/null
[[ $(claude_account) == u-main && ! -e $HOME/.claude/.oauth_refresh.lock ]] || fail "a stale refresh lock is taken over and released"
mkdir "$HOME/.claude/.oauth_refresh.lock"
(
  sleep 0.5
  claude_account >"$test_tmp/during-refresh"
  rmdir "$HOME/.claude/.oauth_refresh.lock"
) &
omarchy-agent-account-use claude work >/dev/null
wait
[[ $(cat "$test_tmp/during-refresh") == u-main && $(claude_account) == u-work ]] || fail "a move waits for a session renewing its sign-in"
pass "logins move under Claude's own locks"

# A move cut short can leave a copy behind, or the registry naming the wrong
# account; the next refresh puts both right from who ~/.claude is.
cp "$HOME/.claude/.credentials.json" "$work/.credentials.json"
jq '.seated = "main"' "$accounts/claude.json" >"$test_tmp/registry" && mv "$test_tmp/registry" "$accounts/claude.json"
omarchy-agent-account-state refresh claude
[[ $(jq -r .seated "$accounts/claude.json") == work && ! -e $work/.credentials.json && -f $parked/.credentials.json ]] ||
  fail "refresh seats whoever ~/.claude is signed in as and drops the copy" "$(cat "$accounts/claude.json")"
pass "an interrupted move is put right"

# Killed between writing Work's token into ~/.claude and its profile, the
# move leaves Main's profile beside Work's token. Only the token says who it
# is, so Main's parked login is kept and ~/.claude takes Work's profile.
omarchy-agent-account-use claude main >/dev/null
echo '{"claudeAiOauth":{"refreshToken":"main-token"}}' >"$HOME/.claude/.credentials.json"
echo '{"claudeAiOauth":{"refreshToken":"work-token"}}' >"$work/.credentials.json"
cp "$HOME/.claude/.credentials.json" "$parked/.credentials.json"
cp "$work/.credentials.json" "$HOME/.claude/.credentials.json"
omarchy-agent-account-state refresh claude
[[ $(jq -r .claudeAiOauth.refreshToken "$parked/.credentials.json") == main-token && $(jq -r .seated "$accounts/claude.json") == work ]] ||
  fail "a half-made move never costs the parked login" "$(cat "$accounts/claude.json")"
[[ ! -e $work/.credentials.json && $(claude_account) == u-work ]] || fail "a half-made move is finished from the token's side"
pass "a move killed halfway keeps every login"

# Putting a half-made move right is saved before its copy goes, even when the
# command that noticed it then fails.
omarchy-agent-account-use claude main >/dev/null
cp "$HOME/.claude/.credentials.json" "$parked/.credentials.json"
cp "$work/.credentials.json" "$HOME/.claude/.credentials.json"
if omarchy-agent-account-use claude nobody >/dev/null 2>&1; then
  fail "using an unknown account fails"
fi
[[ $(jq -r .seated "$accounts/claude.json") == work && ! -e $work/.credentials.json ]] ||
  fail "a failed command still keeps what settle put right" "$(cat "$accounts/claude.json")"
omarchy-agent-account-use claude main >/dev/null
pass "a correction survives the command that made it failing"

# ------------------------------------------------------- threshold and remove

OMARCHY_TEST_DEFAULT_AGENT=claude omarchy-agent-account-threshold 90 >/dev/null
[[ $(jq -r .threshold "$accounts/claude.json") == 90 ]] || fail "threshold sets when an account is announced"
if omarchy-agent-account-threshold claude soon >/dev/null 2>&1; then
  fail "threshold refuses anything but a percentage"
fi
pass "threshold sets when an account is announced"

omarchy-agent-account-use claude main >/dev/null
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
[[ -z $(omarchy-agent-account-home claude) && $(claude_account) == u-main ]] || fail "removing an account leaves ~/.claude as it was"
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

check=$(omarchy-agent-account-add --check)
[[ $check == $'claude additional\ncodex additional\ngrok additional\n'* && $'\n'$check$'\n' == *$'\nfireworks first\n'* ]] ||
  fail "--check says what adding would mean for each provider" "$check"
pass "--check says what adding would mean for each provider"

# Pay-as-you-go providers sign in with a pasted API key: checked first, then
# imported into OpenCode, without ever being a command argument.
fireworks_bin="$test_tmp/fireworks-bin"
mkdir -p "$fireworks_bin"
cat >"$fireworks_bin/omarchy-agent-usage-fireworks" <<SH
#!/bin/bash
echo "\$*" >>"$test_tmp/fireworks-check-args"
SH
cat >>"$fireworks_bin/omarchy-agent-usage-fireworks" <<'SH'
# A key saved elsewhere, as Z.ai's config file can hold one, would vouch for
# any key it was checked beside.
if [[ -f ${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/agents/fireworks.json ]]; then
  echo '{"usageStatusText":""}'
  exit
fi
case $FIREWORKS_API_KEY in
fw_good) echo '{"usageStatusText":""}' ;;
fw_offline) echo '{"usageStatusText":"Fireworks unavailable"}' ;;
*) echo '{"usageStatusText":"Sign-in expired"}' ;;
esac
SH
cat >"$fireworks_bin/mise" <<'SH'
#!/bin/bash
[[ $* == "where opencode" ]]
SH
cat >"$fireworks_bin/opencode" <<SH
#!/bin/bash
echo "\$* \$([[ \$2 == "import" ]] && jq -r '.[0].value.key')" >>"$test_tmp/fireworks-opencode"
SH
chmod +x "$fireworks_bin"/*

if PATH="$fireworks_bin:$PATH" omarchy-agent-account-add --events fireworks <<<"fw_bad" >"$test_tmp/fireworks-refused" 2>&1 ||
  [[ -e $test_tmp/fireworks-opencode ]] ||
  ! grep -qx "@@omarchy error Fireworks didn't accept that key." "$test_tmp/fireworks-refused"; then
  fail "a key Fireworks refuses is not saved, and says so" "$(cat "$test_tmp/fireworks-refused")"
fi
pass "a key Fireworks refuses is not saved, and says so"

# The check sees only the pasted key, not one saved elsewhere.
mkdir -p "$HOME/.config/omarchy/agents"
echo '{"apiKey":"fw_saved"}' >"$HOME/.config/omarchy/agents/fireworks.json"
if PATH="$fireworks_bin:$PATH" omarchy-agent-account-add --events fireworks <<<"fw_bad" >/dev/null 2>&1 || [[ -e $test_tmp/fireworks-opencode ]]; then
  fail "a saved key can't vouch for a pasted one"
fi
rm "$HOME/.config/omarchy/agents/fireworks.json"
pass "a saved key can't vouch for a pasted one"

# A key Fireworks couldn't be asked about isn't saved either, and says to retry.
if PATH="$fireworks_bin:$PATH" omarchy-agent-account-add --events fireworks <<<"fw_offline" >"$test_tmp/fireworks-unchecked" 2>&1 ||
  [[ -e $test_tmp/fireworks-opencode ]] ||
  ! grep -qx "@@omarchy error Couldn't reach Fireworks to check that key. Try again in a moment." "$test_tmp/fireworks-unchecked"; then
  fail "a key that couldn't be checked is not saved" "$(cat "$test_tmp/fireworks-unchecked")"
fi
pass "a key that couldn't be checked is not saved"

: >"$notifications"
: >"$test_tmp/fireworks-check-args"
PATH="$fireworks_bin:$PATH" omarchy-agent-account-add --events fireworks <<<"fw_good" >"$test_tmp/fireworks-output"
[[ ! -e $HOME/.pi/agent/auth.json ]] || fail "a Fireworks key is not saved for pi"
grep -q "^auth import fw_good$" "$test_tmp/fireworks-opencode" && grep -q "^auth switch fireworks-ai omarchy-" "$test_tmp/fireworks-opencode" ||
  fail "a Fireworks key is made opencode's active one" "$(cat "$test_tmp/fireworks-opencode")"
grep -q "^@@omarchy key " "$test_tmp/fireworks-output" && grep -qx "@@omarchy done Signed in to Fireworks." "$test_tmp/fireworks-output" ||
  fail "the panel is asked for the key and told the result" "$(cat "$test_tmp/fireworks-output")"
key_line=$(grep -n "^@@omarchy key " "$test_tmp/fireworks-output" | cut -d: -f1 | head -1)
status_line=$(grep -n "^@@omarchy status " "$test_tmp/fireworks-output" | cut -d: -f1 | tail -1)
(( key_line < status_line )) ||
  fail "key mode arrives before the sign-in status so the panel never flashes the browser prompt" "$(cat "$test_tmp/fireworks-output")"
[[ $(head -1 "$test_tmp/fireworks-check-args") == "--check-key" ]] ||
  fail "a Fireworks key is only checked, not read for its usage" "$(cat "$test_tmp/fireworks-check-args")"
grep -q "Fireworks is ready" "$notifications" && ! grep -q "OpenCode is ready" "$notifications" ||
  fail "a key's sign-in says the provider is ready, not OpenCode" "$(cat "$notifications")"
pass "a Fireworks key is saved in OpenCode"

# Removing a key's sign-in logs out each of the provider's OpenCode
# credentials, and only those.
remove_bin="$test_tmp/remove-bin"
mkdir -p "$remove_bin"
cat >"$remove_bin/opencode" <<SH
#!/bin/bash
case "\$1 \$2" in
"auth export") echo '[{"id":"omarchy-1","integrationID":"fireworks-ai","value":{"type":"key","key":"fw_secret"}},{"id":"or-1","integrationID":"openrouter","value":{"type":"key","key":"or_secret"}},{"id":"mm-cn","integrationID":"minimax-cn","value":{"type":"key","key":"mm_secret"}}]' ;;
"auth logout") echo "\$*" >>"$test_tmp/opencode-logout" ;;
esac
SH
chmod +x "$remove_bin"/*
PATH="$remove_bin:$PATH" omarchy-agent-account-remove fireworks </dev/null >"$test_tmp/fireworks-removed" 2>&1 ||
  fail "removing Fireworks works" "$(cat "$test_tmp/fireworks-removed")"
[[ $(cat "$test_tmp/opencode-logout") == "auth logout fireworks-ai omarchy-1" ]] && ! grep -q secret "$test_tmp/fireworks-removed" ||
  fail "removing Fireworks logs out its OpenCode key alone, printing no key" "$(cat "$test_tmp/opencode-logout" "$test_tmp/fireworks-removed")"
# MiniMax's usage is read from its regional and coding-plan ids too.
: >"$test_tmp/opencode-logout"
PATH="$remove_bin:$PATH" omarchy-agent-account-remove minimax </dev/null >/dev/null
[[ $(cat "$test_tmp/opencode-logout") == "auth logout minimax-cn mm-cn" ]] ||
  fail "removing MiniMax logs out a key under any id its usage is read from" "$(cat "$test_tmp/opencode-logout")"

grep -qx 'omarchy.agents showAgent fireworks false' "$OMARCHY_TEST_BAR_LOG" ||
  fail "removing Fireworks hides it, so a key read elsewhere doesn't bring it back" "$(cat "$OMARCHY_TEST_BAR_LOG")"

# Gemini has no logout, so its sign-in is cleared where agy keeps it, and a
# keyring that won't let it go fails the removal, hiding nothing.
mkdir -p "$HOME/.gemini/antigravity-cli"
echo '{}' >"$HOME/.gemini/antigravity-cli/antigravity-oauth-token"
touch "$OMARCHY_TEST_KEYRING" "$OMARCHY_TEST_KEYRING.stuck"
: >"$OMARCHY_TEST_BAR_LOG"
if omarchy-agent-account-remove gemini </dev/null >/dev/null 2>&1 || grep -q " false$" "$OMARCHY_TEST_BAR_LOG"; then
  fail "a keyring that keeps Gemini's sign-in fails the removal and hides nothing"
fi
rm "$OMARCHY_TEST_KEYRING.stuck"
# A keyring that can't be asked isn't one without the sign-in.
touch "$OMARCHY_TEST_KEYRING.broken"
if omarchy-agent-account-remove gemini </dev/null >/dev/null 2>&1 || grep -q " false$" "$OMARCHY_TEST_BAR_LOG" ||
  [[ ! -e $HOME/.gemini/antigravity-cli/antigravity-oauth-token ]]; then
  fail "a keyring that can't be asked fails the Gemini removal and touches nothing"
fi
rm "$OMARCHY_TEST_KEYRING.broken"
omarchy-agent-account-remove gemini </dev/null >/dev/null
[[ ! -e $HOME/.gemini/antigravity-cli/antigravity-oauth-token && ! -e $OMARCHY_TEST_KEYRING ]] ||
  fail "removing Gemini clears agy's keyring entry and token file"
pass "removing a sign-in without accounts forgets it where its CLI keeps it"

: >"$notifications"
OMARCHY_TEST_LOGIN_UUID=u-events OMARCHY_TEST_LOGIN_EMAIL=events@example.com \
  omarchy-agent-account-add --events claude Events </dev/null >"$test_tmp/events-output"
grep -qx "@@omarchy status Sign in as the account you're adding in the private window that opens." "$test_tmp/events-output" ||
  fail "--events reports progress as tagged lines" "$(cat "$test_tmp/events-output")"
grep -qx "@@omarchy done Added Events (events@example.com)." "$test_tmp/events-output" ||
  fail "--events reports the result as a tagged line" "$(cat "$test_tmp/events-output")"
grep -q "Claude Code is ready for more Tokens now flowing from Events account" "$notifications" ||
  fail "--events also notifies, in case the panel closed" "$(cat "$notifications")"
if OMARCHY_TEST_LOGIN_UUID=u-events OMARCHY_TEST_LOGIN_EMAIL=events@example.com \
  omarchy-agent-account-add --events claude Again </dev/null >"$test_tmp/events-dup" 2>&1; then
  fail "--events fails a duplicate"
fi
grep -q "^@@omarchy error That's Events" "$test_tmp/events-dup" || fail "--events reports a failure as a tagged line" "$(cat "$test_tmp/events-dup")"
pass "--events reports progress and results for the panel"

# An account that's added but can't be made active says so, rather than
# claiming tokens now flow from it.
: >"$notifications"
cat >"$mock_bin/omarchy-agent-account-state" <<SH
#!/bin/bash
[[ \$1 == use ]] && exit 1
exec "$ROOT/bin/omarchy-agent-account-state" "\$@"
SH
chmod +x "$mock_bin/omarchy-agent-account-state"
OMARCHY_TEST_LOGIN_UUID=u-stuck OMARCHY_TEST_LOGIN_EMAIL=stuck@example.com \
  omarchy-agent-account-add --events claude Stuck </dev/null >"$test_tmp/stuck-output"
rm "$mock_bin/omarchy-agent-account-state"
grep -qx "@@omarchy done Added Stuck (stuck@example.com), but couldn't switch new sessions to it." "$test_tmp/stuck-output" ||
  fail "an added account that can't be selected says so" "$(cat "$test_tmp/stuck-output")"
! grep -q "ready for more" "$notifications" || fail "an added account that can't be selected isn't announced as ready" "$(cat "$notifications")"
pass "an added account that can't be selected says so"

# A CLI that isn't installed isn't on PATH, though a dispatcher an earlier test
# wrote may be. The package installs before the login, through polkit since the
# panel has no terminal, rather than silently inside it. Only the mocks the add
# needs are on this PATH, not the mock Codex itself.
lazy_data="$test_tmp/lazy-mise"
lazy_bin="$test_tmp/lazy-bin"
lazy_pkexec="$test_tmp/lazy-pkexec"
lazy_path="$lazy_pkexec:$pkg_bin:$HOME/.local/share/omarchy/agent-accounts/bin:$lazy_bin:$ROOT/bin:/usr/bin"
mkdir -p "$lazy_bin" "$lazy_pkexec"
for helper in omarchy-notification-send omarchy-agent-usage-update omarchy-default-agent omarchy-launch-browser; do
  ln -s "$mock_bin/$helper" "$lazy_bin/$helper"
done
ln -s /usr/bin/true "$lazy_bin/herdr"
cat >"$lazy_bin/mise" <<SH
#!/bin/bash
echo "run codex \$1" >>"$test_tmp/lazy-log"
exec "$mock_bin/codex" "\$@"
SH
cat >"$lazy_pkexec/pkexec" <<SH
#!/bin/bash
echo "pkexec \$*" >>"$test_tmp/lazy-log"
if [[ -n \${OMARCHY_TEST_INSTALL_HANGS:-} ]]; then
  echo \$\$ >"\$OMARCHY_TEST_INSTALL_HANGS"
  exec sleep 30
fi
[[ -z \${OMARCHY_TEST_INSTALL_FAILS:-} ]] || exit 1
ln -s "$lazy_bin/mise" "$lazy_bin/codex"
SH
# The package is there once the mock install has put Codex on PATH.
cat >"$lazy_pkexec/omarchy-pkg-present" <<SH
#!/bin/bash
[[ -e $lazy_bin/codex ]]
SH
chmod +x "$lazy_bin/mise" "$lazy_pkexec/pkexec" "$lazy_pkexec/omarchy-pkg-present"

add_lazy() {
  PATH="$lazy_path" MISE_DATA_DIR="$lazy_data" omarchy-agent-account-add --events codex "$@" </dev/null
}

if OMARCHY_TEST_INSTALL_FAILS=1 add_lazy Lazy >"$test_tmp/lazy-failed" 2>&1; then
  fail "a CLI install that fails stops the add"
fi
grep -qx "@@omarchy error Installing the Codex CLI didn't finish." "$test_tmp/lazy-failed" ||
  fail "a failed CLI install is reported as a tagged error" "$(cat "$test_tmp/lazy-failed")"
grep -q "^run codex" "$test_tmp/lazy-log" && fail "a failed CLI install never starts the login" "$(cat "$test_tmp/lazy-log")"

OMARCHY_TEST_INSTALL_HANGS="$test_tmp/install.pid" PATH="$lazy_path" MISE_DATA_DIR="$lazy_data" \
  omarchy-agent-account-add --events codex Slow </dev/null >/dev/null 2>&1 &
adding=$!
for _ in {1..30}; do
  [[ -s $test_tmp/install.pid ]] && break
  sleep 0.1
done
# Cancel ends the add at once. The install itself runs as root once polkit
# lets it, and pacman is left to finish rather than cut off mid-transaction.
kill -TERM "$adding"
for _ in {1..20}; do
  kill -0 "$adding" 2>/dev/null || break
  sleep 0.1
done
cancelled=true
kill -0 "$adding" 2>/dev/null && cancelled=false
# Left running, the add would outlive the test and reach the real notifier.
kill "$(cat "$test_tmp/install.pid")" "$adding" 2>/dev/null
wait "$adding" 2>/dev/null || true
[[ $cancelled == "true" ]] || fail "cancelling ends the add during a CLI install"
grep -q "^run codex" "$test_tmp/lazy-log" && fail "a cancelled install never starts the login" "$(cat "$test_tmp/lazy-log")"

: >"$test_tmp/lazy-log"
OMARCHY_TEST_LOGIN_UUID=u-lazy OMARCHY_TEST_LOGIN_EMAIL=lazy@example.com add_lazy Lazy >"$test_tmp/lazy-output" 2>&1 ||
  fail "adding an account installs its CLI first" "$(cat "$test_tmp/lazy-output")"
[[ $(grep '^@@omarchy \(status\|progress\)' "$test_tmp/lazy-output" | head -3) == $'@@omarchy status Installing the Codex CLI…\n@@omarchy progress 0 0 0\n@@omarchy status Sign in as the account you\'re adding in the private window that opens.' ]] ||
  fail "a CLI install is reported before the sign-in" "$(cat "$test_tmp/lazy-output")"
# Through the packaged helper when it's installed, pacman itself until then.
[[ $(cat "$test_tmp/lazy-log") == @($'pkexec /usr/bin/omarchy-pkg-add-curated openai-codex\nrun codex login'|$'pkexec /usr/bin/pacman -S --noconfirm --needed -- openai-codex\nrun codex login') ]] ||
  fail "the CLI's package is installed before its login runs" "$(cat "$test_tmp/lazy-log")"
grep -qx "@@omarchy done Added Lazy (lazy@example.com)." "$test_tmp/lazy-output" ||
  fail "a sign-in after an install finishes as usual" "$(cat "$test_tmp/lazy-output")"

# Installed, by Omarchy or some other way: it signs in directly.
: >"$test_tmp/lazy-log"
OMARCHY_TEST_LOGIN_UUID=u-lazy-2 OMARCHY_TEST_LOGIN_EMAIL=lazy2@example.com add_lazy Lazier >"$test_tmp/lazy-again" 2>&1 ||
  fail "an installed CLI signs in directly" "$(cat "$test_tmp/lazy-again")"
rm "$lazy_bin/codex"
# One the user's own mise config asks for counts too.
mkdir -p "$lazy_data/shims"
ln -s "$lazy_bin/mise" "$lazy_data/shims/codex"
OMARCHY_TEST_LOGIN_UUID=u-lazy-3 OMARCHY_TEST_LOGIN_EMAIL=lazy3@example.com \
  PATH="$lazy_path:$lazy_data/shims" MISE_DATA_DIR="$lazy_data" omarchy-agent-account-add --events codex Mised </dev/null >>"$test_tmp/lazy-again" 2>&1 ||
  fail "a CLI from the user's own mise signs in directly" "$(cat "$test_tmp/lazy-again")"
rm "$lazy_data/shims/codex"
grep -q "^@@omarchy progress" "$test_tmp/lazy-again" && fail "an installed CLI isn't installed again" "$(cat "$test_tmp/lazy-again")"
grep -q "^pkexec" "$test_tmp/lazy-log" && fail "an installed CLI isn't installed again" "$(cat "$test_tmp/lazy-log")"
pass "a missing CLI is installed, with a way to cancel, before its sign-in"

# ------------------------------------------------------------------- reauth

: >"$OMARCHY_TEST_BROWSER_LOG"
before=$(omarchy-agent-account-list claude --json | jq '.[0].accounts | length')
omarchy-agent-account-use claude main >/dev/null
rm -f "$accounts/claude/events/.credentials.json"
OMARCHY_TEST_LOGIN_UUID=u-events OMARCHY_TEST_LOGIN_EMAIL=events@example.com \
  omarchy-agent-account-add --events --reauth events claude </dev/null >"$test_tmp/reauth-output"
grep -qx "@@omarchy done Signed in to Claude again." "$test_tmp/reauth-output" || fail "--reauth reports the sign-in" "$(cat "$test_tmp/reauth-output")"
[[ -s $accounts/claude/events/.credentials.json ]] || fail "--reauth signs in to the account's own home"
[[ $(omarchy-agent-account-list claude --json | jq '.[0].accounts | length') == "$before" ]] || fail "--reauth adds no account"
grep -qx -- "--private https://claude.com/oauth/authorize" "$OMARCHY_TEST_BROWSER_LOG" || fail "--reauth of an added account uses a private window"

# The account sessions use signs in again in ~/.claude, where its login is,
# and still in a private window: the normal browser is the primary's.
omarchy-agent-account-use claude events >/dev/null
: >"$OMARCHY_TEST_BROWSER_LOG"
rm -f "$HOME/.claude/.credentials.json"
OMARCHY_TEST_LOGIN_UUID=u-events OMARCHY_TEST_LOGIN_EMAIL=events@example.com \
  omarchy-agent-account-add --reauth events claude </dev/null >/dev/null
[[ -s $HOME/.claude/.credentials.json && $(claude_account) == u-events && $(jq -c .mcpServers "$HOME/.claude.json") != null && ! -e $HOME/.claude/.claude.json && ! -e $accounts/claude/events/.credentials.json ]] ||
  fail "--reauth of the seated account signs in to ~/.claude itself"
grep -qx -- "--private https://claude.com/oauth/authorize" "$OMARCHY_TEST_BROWSER_LOG" || fail "--reauth of a seated added account still uses a private window"
[[ -z $(ls -A "$accounts/claude/.pending") ]] || fail "--reauth leaves no scratch home behind"

# Whoever signs in in the private window would become every running session's
# account, so it has to be the account being signed in again.
if OMARCHY_TEST_LOGIN_UUID=u-stranger OMARCHY_TEST_LOGIN_EMAIL=stranger@example.com \
  omarchy-agent-account-add --reauth events claude </dev/null >"$test_tmp/wrong-reauth" 2>&1; then
  fail "--reauth as another account is refused"
fi
grep -q "That's stranger@example.com, not Events" "$test_tmp/wrong-reauth" && [[ $(claude_account) == u-events ]] ||
  fail "--reauth as another account says so and leaves ~/.claude alone" "$(cat "$test_tmp/wrong-reauth")"

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
[[ $(jq -r .oauthAccount.accountUuid "$parked/.claude.json") == u-main && $(claude_account) == u-events ]] ||
  fail "--reauth of the primary signs in where its login waits, leaving ~/.claude alone"

if omarchy-agent-account-add --reauth nobody claude </dev/null >/dev/null 2>&1; then
  fail "--reauth of an unknown account fails"
fi
pass "--reauth signs an existing account in again where it lives"

# ------------------------------------------------------------------- cancel

# Cancelling from the panel stops a login that's waiting on the browser, right
# away, and leaves no half-made account behind.
OMARCHY_TEST_LOGIN_HANGS="$test_tmp/login.pid" omarchy-agent-account-add --events claude Slow </dev/null >/dev/null 2>&1 &
adding=$!
for _ in {1..40}; do
  [[ -s $test_tmp/login.pid ]] && break
  sleep 0.05
done
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
omarchy-agent-account-use claude main >/dev/null
jq '.oauthAccount.emailAddress = "switched@example.com"' "$accounts/claude/events/.claude.json" >"$test_tmp/switched.json"
mv "$test_tmp/switched.json" "$accounts/claude/events/.claude.json"
omarchy-agent-account-state refresh claude
[[ $(jq -r '.accounts[] | select(.id == "events") | .email' "$accounts/claude.json") == "switched@example.com" ]] ||
  fail "refresh saves who each home is signed in as now"
pass "refresh saves who each home is signed in as now"

# Signing in never installs desktop apps on its own, whether from a terminal
# or from the panel (--events).
(
  export HOME="$test_tmp/events-first-home" XDG_STATE_HOME="$test_tmp/events-first-state"
  mkdir -p "$HOME/.codex"
  OMARCHY_TEST_LOGIN_UUID=acct-fast OMARCHY_TEST_LOGIN_EMAIL=fast@example.com \
    omarchy-agent-account-add --events codex </dev/null >"$test_tmp/events-first-output"
  grep -qx "@@omarchy done Signed in to Codex." "$test_tmp/events-first-output" ||
    fail "a panel first sign-in reports done" "$(cat "$test_tmp/events-first-output")"
)
[[ ! -s $OMARCHY_TEST_PKG_LOG ]] ||
  fail "signing in does not install desktop apps" "$(cat "$OMARCHY_TEST_PKG_LOG" 2>/dev/null)"
pass "signing in does not install desktop apps"

# ------------------------------------------------------------ removing the primary

# In a home of its own, so the accounts above stay as they are.
(
  export HOME="$test_tmp/rm-home" XDG_STATE_HOME="$test_tmp/rm-state"
  accounts="$XDG_STATE_HOME/omarchy/agents/accounts"
  : >"$OMARCHY_TEST_BAR_LOG"
  mkdir -p "$HOME/.claude" "$HOME/.codex"
  echo '{"oauthAccount":{"accountUuid":"u-main","emailAddress":"me@example.com"},"theme":"dark"}' >"$HOME/.claude.json"
  echo '{"claudeAiOauth":{"refreshToken":"main"}}' >"$HOME/.claude/.credentials.json"
  echo '{}' >"$HOME/.claude/settings.json"
  OMARCHY_TEST_LOGIN_UUID=u-side OMARCHY_TEST_LOGIN_EMAIL=side@example.com omarchy-agent-account-add claude Side </dev/null >/dev/null
  # Signing in from a terminal shows an agent a removal hid, as the panel does.
  grep -qx 'omarchy.agents showAgent claude true' "$OMARCHY_TEST_BAR_LOG" ||
    fail "a sign-in from a terminal shows the agent in the panel again" "$(cat "$OMARCHY_TEST_BAR_LOG")"

  # Side is seated, so it takes over as primary where it is, and Main's
  # parked login goes.
  omarchy-agent-account-remove claude main </dev/null >/dev/null
  [[ $(jq -c '[.accounts[] | {id, home, primary}]' "$accounts/claude.json") == '[{"id":"side","home":"","primary":true}]' ]] ||
    fail "removing the primary makes the account in ~/.claude the primary" "$(cat "$accounts/claude.json")"
  [[ $(jq -r .oauthAccount.accountUuid "$HOME/.claude.json") == u-side && ! -e $accounts/claude/.primary && ! -e $accounts/claude/side ]] ||
    fail "removing the primary deletes its login and leaves the new primary's in ~/.claude"
  ! grep -q " false$" "$OMARCHY_TEST_BAR_LOG" || fail "removing one of several accounts keeps the agent on the panel"

  # An account named like another agent is still the default agent's.
  OMARCHY_TEST_LOGIN_UUID=u-cursor OMARCHY_TEST_LOGIN_EMAIL=cursor@example.com omarchy-agent-account-add claude Cursor </dev/null >/dev/null
  # The panel names the agent outright, and means Cursor itself.
  omarchy-agent-account-remove --yes --agent cursor </dev/null >/dev/null
  [[ $(jq -c '[.accounts[].id]' "$accounts/claude.json") == '["side","cursor"]' && $(cat "$OMARCHY_TEST_LOGOUTS") == "cursor-agent logout" ]] ||
    fail "--agent cursor signs Cursor out and leaves the account named cursor" "$(cat "$accounts/claude.json" "$OMARCHY_TEST_LOGOUTS" 2>/dev/null)"
  : >"$OMARCHY_TEST_LOGOUTS"
  : >"$OMARCHY_TEST_BAR_LOG"
  omarchy-agent-account-remove cursor </dev/null >/dev/null
  [[ $(jq -c '[.accounts[].id]' "$accounts/claude.json") == '["side"]' && ! -s $OMARCHY_TEST_LOGOUTS ]] ||
    fail "remove <name> takes the default agent's account by that name before another agent" "$(cat "$accounts/claude.json" "$OMARCHY_TEST_LOGOUTS" 2>/dev/null)"

  # An account file that can't be read stops the sign-out before the login goes.
  cp "$HOME/.claude.json" "$test_tmp/claude-json"
  echo '{' >"$HOME/.claude.json"
  if omarchy-agent-account-remove claude side </dev/null >/dev/null 2>&1 || [[ ! -e $HOME/.claude/.credentials.json ]]; then
    fail "an unreadable ~/.claude.json fails the removal and keeps the login"
  fi
  mv "$test_tmp/claude-json" "$HOME/.claude.json"

  # The only account left is signed out here, and everything else stays.
  omarchy-agent-account-remove claude side </dev/null >/dev/null
  [[ ! -e $HOME/.claude/.credentials.json && $(jq -c '{oauthAccount, theme}' "$HOME/.claude.json") == '{"oauthAccount":null,"theme":"dark"}' && -f $HOME/.claude/settings.json ]] ||
    fail "removing the only account signs ~/.claude out and keeps the rest" "$(cat "$HOME/.claude.json")"
  grep -qx 'omarchy.agents showAgent claude false' "$OMARCHY_TEST_BAR_LOG" ||
    fail "removing the only account hides the agent" "$(cat "$OMARCHY_TEST_BAR_LOG")"

  # Codex keeps every login in its own home, so the new primary's moves in.
  CODEX_HOME="$HOME/.codex" OMARCHY_TEST_LOGIN_UUID=c-main OMARCHY_TEST_LOGIN_EMAIL=me@example.com codex login >/dev/null
  OMARCHY_TEST_LOGIN_UUID=c-side OMARCHY_TEST_LOGIN_EMAIL=side@example.com omarchy-agent-account-add codex Side </dev/null >/dev/null
  # A session started as the primary keeps its login until it quits.
  codex --hold >/dev/null 2>&1 &
  session=$!
  if omarchy-agent-account-remove codex main </dev/null >/dev/null 2>&1 || [[ $(jq -r .tokens.account_id "$HOME/.codex/auth.json") != c-main ]]; then
    fail "a session running as the Codex primary blocks replacing its login"
  fi
  kill "$session"; wait "$session" 2>/dev/null || true

  # A registry that can't be saved leaves the next primary's login in its own
  # home as well, so trying again still finds it.
  STATE="$ROOT/bin/omarchy-agent-account-state" python3 - <<'PY' || fail "a failed save while promoting keeps the next primary's login"
import importlib.machinery, importlib.util, json, os
loader = importlib.machinery.SourceFileLoader("state", os.environ["STATE"])
spec = importlib.util.spec_from_loader(loader.name, loader)
state = importlib.util.module_from_spec(spec)
loader.exec_module(state)

def broken_save(provider, registry):
  raise OSError("disk full")
state.save = broken_save
try:
  state.remove("codex", "main")
except OSError:
  pass
else:
  raise SystemExit("remove should fail when the registry can't be saved")
side = state.accounts_root() / "codex" / "side" / "auth.json"
assert side.is_file(), "the next primary's own home keeps its login"
assert json.loads(side.read_text())["tokens"]["account_id"] == "c-side"
PY
  omarchy-agent-account-remove codex main </dev/null >/dev/null
  [[ $(jq -r .tokens.account_id "$HOME/.codex/auth.json") == c-side && ! -e $accounts/codex/side ]] ||
    fail "removing the Codex primary moves the next account's login into ~/.codex"
  [[ $(omarchy-agent-account-exec codex) == "codex home=default args=" ]] || fail "Codex sessions start in ~/.codex as the new primary"
)
pass "any account can be removed, the primary handing its role on"
