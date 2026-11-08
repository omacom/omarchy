#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/home/.claude"
notifications="$test_tmp/notifications"
cat >"$test_tmp/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_NOTIFICATIONS"
SH
chmod +x "$test_tmp/bin/omarchy-notification-send"

export HOME="$test_tmp/home"
export XDG_STATE_HOME="$test_tmp/state"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"
export OMARCHY_TEST_NOTIFICATIONS="$notifications"

accounts="$XDG_STATE_HOME/omarchy/agents/accounts"
usage="$XDG_STATE_HOME/omarchy/agents/usage"
mkdir -p "$accounts/claude/work" "$usage"

soon=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(minutes=72)).isoformat())')
later=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=4)).isoformat())')
gone=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) - dt.timedelta(minutes=5)).isoformat())')

registry() {
  cat >"$accounts/claude.json" <<JSON
{
  "active": "$1",
  "switch": "$2",
  "threshold": ${3:-95},
  "alert": "",
  "accounts": [
    {"id": "main", "label": "Main", "home": "", "primary": true},
    {"id": "work", "label": "Work", "home": "$accounts/claude/work", "primary": false}
  ]
}
JSON
}

# Session percent and reset for each account, as the usage record carries them.
record() {
  jq -nc --argjson main "$1" --arg mainReset "$2" --argjson work "$3" --arg workReset "$4" '{
    id: "claude",
    accounts: [
      {id: "main", limits: [{label: "Session (5-hour)", percent: $main, resetsAt: $mainReset}]},
      {id: "work", limits: [{label: "Session (5-hour)", percent: $work, resetsAt: $workReset}]}
    ]
  }' >"$usage/claude.json"
}

autoswitch() {
  : >"$notifications"
  omarchy-agent-account-state autoswitch claude
}

active() {
  jq -r .active "$accounts/claude.json"
}

# ---------------------------------------------------------------- manual mode

registry main manual
record 0.97 "$soon" 0.12 "$later"
[[ -z $(autoswitch) && $(active) == "main" ]] || fail "manual mode never moves the active account"
grep -q "Main is at 97% of a Claude limit Work is at 12%. Click to switch new sessions to it. --exec omarchy-agent-account-use claude work" "$notifications" ||
  fail "manual mode offers the switch as the notification's click" "$(cat "$notifications")"
pass "manual mode notifies with a one-click switch"

autoswitch >/dev/null
[[ ! -s $notifications ]] || fail "manual mode says it once" "$(cat "$notifications")"
pass "manual mode doesn't repeat itself"

# ------------------------------------------------------------------ auto mode

registry main auto
record 0.949 "$soon" 0.0 "$later"
[[ -z $(autoswitch) && ! -s $notifications ]] || fail "an account under the threshold stays put, however much room another has"
pass "an account under the threshold stays put"

record 0.96 "$soon" 0.12 "$later"
[[ $(autoswitch) == "claude" && $(active) == "work" ]] || fail "auto mode moves to the account with headroom"
grep -q "New Claude sessions now use Work (12%)\.$" "$notifications" && grep -qx "Running sessions stay on Main." "$notifications" ||
  fail "auto mode says where new sessions went" "$(cat "$notifications")"
pass "auto mode switches at the threshold"

# Main is still at 96%, but only the active account crossing starts anything.
record 0.96 "$soon" 0.30 "$later"
[[ -z $(autoswitch) && $(active) == "work" && ! -s $notifications ]] || fail "auto mode never flaps back"
pass "auto mode leaves a healthy active account alone"

# A stale 99% whose window already reset is an untouched allowance.
registry main auto
record 0.97 "$soon" 0.99 "$gone"
[[ $(autoswitch) == "claude" && $(active) == "work" ]] || fail "a window past its reset counts as empty"
pass "a window past its reset counts as empty"

# ------------------------------------------------------------------- exhausted

# Every account over: work resumes soonest on the one that frees up first.
registry main auto
record 0.97 "$later" 0.98 "$soon"
[[ $(autoswitch) == "claude" && $(active) == "work" ]] || fail "with every account over, auto mode goes to the one that frees up first"
grep -q "All Claude accounts are over 95% Claude sessions now use Work, the first to free up, in 1h 1[12]m." "$notifications" ||
  fail "the switch says when the account frees up" "$(cat "$notifications")"
pass "with every account over, the one that frees up first is used"

# It is the soonest itself now, so it stays, and says so once.
autoswitch >/dev/null
[[ $(active) == "work" ]] && grep -q "All Claude accounts are over 95% Staying on Work. Work resets in 1h 1[12]m." "$notifications" ||
  fail "the account that frees up first stays" "$(active) $(cat "$notifications")"
autoswitch >/dev/null
[[ $(active) == "work" && ! -s $notifications ]] || fail "exhaustion is said once"
pass "all accounts over the threshold is said once, without bouncing"

# A reset time a few minutes sooner isn't worth a switch.
registry main auto
record 0.97 "$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(minutes=80)).isoformat())')" 0.98 "$soon"
autoswitch >/dev/null
[[ $(active) == "main" ]] || fail "an account freeing up only minutes sooner isn't switched to"
pass "a switch while every account is over needs a real head start"

# Manual mode offers it as a click.
registry main manual
record 0.97 "$later" 0.98 "$soon"
[[ -z $(autoswitch) && $(active) == "main" ]] || fail "manual mode doesn't switch when every account is over"
grep -q "Work frees up first, in 1h 1[12]m. Click to switch to it. --exec omarchy-agent-account-use claude work" "$notifications" ||
  fail "manual mode offers the account that frees up first" "$(cat "$notifications")"
pass "manual mode offers the account that frees up first"

# Work's session is nearly empty and resets soon, but its full weekly window
# is what holds it over the threshold, so that reset is when it frees up.
registry main auto
jq -nc --arg later "$later" --arg soon "$soon" --arg week "$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(days=6)).isoformat())')" '{
  id: "claude",
  accounts: [
    {id: "main", limits: [{label: "Session (5-hour)", percent: 0.97, resetsAt: $later}]},
    {id: "work", limits: [{label: "Session (5-hour)", percent: 0.10, resetsAt: $soon}, {label: "Weekly (7-day)", percent: 1.0, resetsAt: $week}]}
  ]
}' >"$usage/claude.json"
autoswitch >/dev/null
grep -q "Main resets in 3h 5[89]m." "$notifications" || fail "exhaustion ignores a reset that doesn't free the account" "$(cat "$notifications")"
pass "exhaustion names when an account actually frees up"

record 0.20 "$later" 0.98 "$soon"
autoswitch >/dev/null
[[ $(jq -r .alert "$accounts/claude.json") == "" ]] || fail "dropping back under the threshold re-arms the alert"
pass "dropping back under the threshold re-arms the alert"

registry main auto 80
record 0.85 "$soon" 0.12 "$later"
[[ $(autoswitch) == "claude" ]] || fail "the threshold is configurable"
pass "the threshold is configurable"

# An account nobody is signed in to is never switched to, however much room
# its old numbers show.
registry main auto
record 0.97 "$soon" 0.10 "$later"
jq '.accounts[1].usageStatusText = "Waiting for auth"' "$usage/claude.json" >"$test_tmp/record.json"
mv "$test_tmp/record.json" "$usage/claude.json"
[[ -z $(autoswitch) && $(active) == "main" ]] || fail "a signed-out account is never switched to"
pass "a signed-out account is never switched to"

# With another account unknown, nobody can say every account is over.
registry main auto
record 0.97 "$later" 0.98 "$soon"
jq '.accounts[1].usageStatusText = "Waiting for auth"' "$usage/claude.json" >"$test_tmp/record.json"
mv "$test_tmp/record.json" "$usage/claude.json"
autoswitch >/dev/null
[[ ! -s $notifications ]] || fail "an unknown account keeps exhaustion unsaid" "$(cat "$notifications")"
pass "exhaustion is only said when every account is known to be over"

# Numbers kept from an earlier check may be out of date, but a stale account
# still counts: a parked account can't be checked until a session runs in it.
mkdir -p "$accounts/claude/side"
registry main auto
jq -nc --arg later "$later" --arg soon "$soon" '{
  id: "claude",
  accounts: [
    {id: "main", limits: [{label: "Session (5-hour)", percent: 0.97, resetsAt: $later}]},
    {id: "work", stale: true, limits: [{label: "Session (5-hour)", percent: 0.40, resetsAt: $soon}]}
  ]
}' >"$usage/claude.json"
autoswitch >/dev/null
[[ $(active) == "work" ]] || fail "a stale account with room is still switched to" "$(active)"
pass "a stale account with room still counts"

# ------------------------------------------------------- which account next

# Three accounts with room: the one whose windows clear soonest is used first,
# so allowance about to start over isn't lost; room still comes first, and an
# account at or over the threshold is never picked however soon it clears.
day=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(days=1)).isoformat())')
week=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(days=6)).isoformat())')
three() {
  cat >"$accounts/claude.json" <<JSON
{
  "active": "$1",
  "switch": "${2:-auto}",
  "threshold": 95,
  "alert": "",
  "accounts": [
    {"id": "main", "label": "Main", "home": "", "primary": true},
    {"id": "work", "label": "Work", "home": "$accounts/claude/work", "primary": false},
    {"id": "side", "label": "Side", "home": "$accounts/claude/side", "primary": false}
  ]
}
JSON
}
# Weekly percent and reset per account; the 5-hour window resets within hours
# for every account, so the week decides.
weekly() {
  jq -nc --argjson m "$1" --arg mr "$2" --argjson w "$3" --arg wr "$4" --argjson s "$5" --arg sr "$6" --arg soon "$soon" '{
    id: "claude",
    accounts: [
      {id: "main", limits: [{label: "Session (5-hour)", percent: 0.1, resetsAt: $soon}, {label: "Weekly (7-day)", percent: $m, resetsAt: $mr}]},
      {id: "work", limits: [{label: "Session (5-hour)", percent: 0.1, resetsAt: $soon}, {label: "Weekly (7-day)", percent: $w, resetsAt: $wr}]},
      {id: "side", limits: [{label: "Session (5-hour)", percent: 0.1, resetsAt: $soon}, {label: "Weekly (7-day)", percent: $s, resetsAt: $sr}]}
    ]
  }' >"$usage/claude.json"
}

three main
weekly 0.97 "$week" 0.20 "$week" 0.60 "$day"
autoswitch >/dev/null
[[ $(active) == "side" ]] || fail "the account that clears soonest is used first" "$(active)"
pass "the account whose week ends soonest is used first"

three main
weekly 0.97 "$week" 0.20 "$week" 0.95 "$day"
autoswitch >/dev/null
[[ $(active) == "work" ]] || fail "an account at the threshold is never picked" "$(active)"
three main
weekly 0.97 "$week" 0.20 "$week" 0.90 "$day"
autoswitch >/dev/null
[[ $(active) == "side" ]] || fail "resetting soonest comes before having more room" "$(active)"
pass "resetting soonest wins among accounts with room, and the threshold is never crossed"

# One whose week hasn't started loses nothing by waiting.
three main
jq -nc --arg week "$week" '{
  id: "claude",
  accounts: [
    {id: "main", limits: [{label: "Weekly (7-day)", percent: 0.97, resetsAt: $week}]},
    {id: "work", limits: [{label: "Weekly (7-day)", percent: 0.0, resetsAt: ""}]},
    {id: "side", limits: [{label: "Weekly (7-day)", percent: 0.30, resetsAt: $week}]}
  ]
}' >"$usage/claude.json"
autoswitch >/dev/null
[[ $(active) == "side" ]] || fail "an account with a running window goes before one that hasn't started" "$(active)"
pass "an account with nothing running out waits"

# ------------------------------------------------- only at the threshold

# Nothing moves before the active account reaches the threshold, however
# far under it another account is.
registry main auto
record 0.94 "$later" 0.0 "$later"
[[ -z $(autoswitch) && $(active) == "main" ]] || fail "auto mode never leaves before the threshold"
# Once switched, the account left behind is at the threshold, so it can't be
# switched back to until its window resets.
record 0.96 "$later" 0.20 "$later"
[[ $(autoswitch) == "claude" && $(active) == "work" ]] || fail "auto mode switches at the threshold"
record 0.96 "$later" 0.94 "$later"
[[ -z $(autoswitch) && $(active) == "work" ]] || fail "a switch never bounces back to an account at the threshold"
record 0.10 "$gone" 0.96 "$later"
[[ $(autoswitch) == "claude" && $(active) == "main" ]] || fail "the earlier account is used again once its window has reset"
pass "auto mode switches only at the threshold, without bouncing"

registry main manual
record 0.85 "$later" 0.10 "$later"
[[ -z $(autoswitch) && ! -s $notifications ]] || fail "manual mode only speaks at the threshold"
pass "manual mode doesn't nag before the threshold"

# ------------------------------------------- sessions running in a target home

# A trade hands the target's home the login ~/.claude held. With logins in
# every home, a session holding a home open, and the reconnect job stubbed.
reconnects="$test_tmp/reconnects"
cat >"$test_tmp/bin/reconnect-stub" <<'SH2'
#!/bin/bash
if [[ $1 == "--check" ]]; then
  echo check >>"$OMARCHY_TEST_RECONNECTS.checks"
  exit 0
fi
printf '%s\n' "$*" >>"$OMARCHY_TEST_RECONNECTS"
SH2
chmod +x "$test_tmp/bin/reconnect-stub"
export OMARCHY_AGENT_ACCOUNT_RECONNECT="$test_tmp/bin/reconnect-stub" OMARCHY_TEST_RECONNECTS="$reconnects"
for home in "$HOME/.claude" "$accounts/claude/work" "$accounts/claude/side"; do
  echo "{\"claudeAiOauth\":{\"refreshToken\":\"$(basename "$home")\"}}" >"$home/.credentials.json"
done
login() { jq -r .claudeAiOauth.refreshToken "$1/.credentials.json"; }
CLAUDE_CONFIG_DIR="$accounts/claude/work" sleep 300 &
sleeper=$!
waited_reconnect() { for _ in {1..50}; do [[ -s $reconnects ]] && return 0; sleep 0.1; done; return 1; }

# Work has the most room but a session of its own, which a trade would move
# onto Main's 97%. Side's home is free, so Side is taken and traded with.
: >"$reconnects"
three main
weekly 0.97 "$week" 0.10 "$day" 0.40 "$week"
autoswitch >/dev/null
[[ $(active) == "side" && $(login "$HOME/.claude") == "side" && $(login "$accounts/claude/work") == "work" ]] ||
  fail "a target whose home is free goes before one a trade would strand" "$(active) $(login "$HOME/.claude")"
waited_reconnect && grep -qx "$HOME/.claude $accounts/claude/side" "$reconnects" || fail "the moved homes' Remote Control is reconnected" "$(cat "$reconnects")"
[[ -s $reconnects.checks ]] || fail "every autoswitch check also checks Remote Control"
pass "a busy target's home is skipped for a free one"

# Put Main's login back in ~/.claude for the next cases.
for home in "$HOME/.claude" "$accounts/claude/side"; do
  echo "{\"claudeAiOauth\":{\"refreshToken\":\"$(basename "$home")\"}}" >"$home/.credentials.json"
done

# Only Work has room. New sessions go to it, ~/.claude stays where it is,
# and nothing is traded onto Work's running session.
: >"$reconnects"
three main
weekly 0.97 "$week" 0.10 "$day" 0.98 "$week"
autoswitch >/dev/null
[[ $(active) == "work" && $(login "$HOME/.claude") == ".claude" && $(login "$accounts/claude/work") == "work" ]] ||
  fail "a trade never moves a running session onto a login over the threshold"
grep -q "Sessions in ~/.claude stay on Main until the ones already running as Work quit" "$notifications" ||
  fail "the notice says why ~/.claude's sessions stayed" "$(cat "$notifications")"
[[ ! -s $reconnects ]] || fail "nothing to reconnect when nothing moved"
pass "a trade that would strand a running session waits"

# Once Work's session quits, the next check makes the move it owed.
kill "$sleeper"; wait "$sleeper" 2>/dev/null || true
autoswitch >/dev/null
[[ $(login "$HOME/.claude") == "work" && $(login "$accounts/claude/work") == ".claude" ]] ||
  fail "the owed move happens once the target's home is free"
[[ $(jq -r '.accounts[] | select(.primary) | .id' "$accounts/claude.json") == "work" ]] || fail "the registry follows the owed move"
grep -q "Sessions running in ~/.claude move with it" "$notifications" || fail "the owed move is announced" "$(cat "$notifications")"
waited_reconnect || fail "the owed move reconnects Remote Control"
pass "an owed move happens once the target's home is free"

# Switching by hand while ~/.claude's login still has room hands a busy home a
# login under the threshold, so the trade goes ahead.
for home in "$HOME/.claude" "$accounts/claude/work"; do
  echo "{\"claudeAiOauth\":{\"refreshToken\":\"$(basename "$home")\"}}" >"$home/.credentials.json"
done
CLAUDE_CONFIG_DIR="$accounts/claude/work" sleep 300 &
sleeper=$!
three main
weekly 0.85 "$week" 0.10 "$day" 0.98 "$week"
omarchy-agent-account-state use claude work >/dev/null
[[ $(active) == "work" && $(login "$HOME/.claude") == "work" && $(login "$accounts/claude/work") == ".claude" ]] ||
  fail "a busy home may take a login that is still under the threshold"
kill "$sleeper"; wait "$sleeper" 2>/dev/null || true
pass "a busy home takes a login that still has room"

# While a sign-in holds its lock, nothing switches: switching without the
# trade would start new sessions in the target's home and strand ~/.claude.
for home in "$HOME/.claude" "$accounts/claude/side"; do
  echo "{\"claudeAiOauth\":{\"refreshToken\":\"$(basename "$home")\"}}" >"$home/.credentials.json"
done
three main
weekly 0.97 "$week" 0.98 "$week" 0.40 "$week"
exec 7>"$accounts/.claude.signin.lock"
flock 7
[[ -z $(autoswitch) && $(active) == "main" && $(login "$HOME/.claude") == ".claude" ]] || fail "a sign-in in progress holds the switch back"
flock -u 7
exec 7>&-
[[ $(autoswitch) == "claude" && $(active) == "side" && $(login "$HOME/.claude") == "side" ]] || fail "the switch happens on the next check"
pass "a switch waits for a sign-in rather than leaving ~/.claude behind"

# Every account over, and the one freeing up first has a session in its home:
# the next soonest with a free home takes ~/.claude's sessions, and Work's own
# session keeps the login that frees up first.
for home in "$HOME/.claude" "$accounts/claude/work" "$accounts/claude/side"; do
  echo "{\"claudeAiOauth\":{\"refreshToken\":\"$(basename "$home")\"}}" >"$home/.credentials.json"
done
CLAUDE_CONFIG_DIR="$accounts/claude/work" sleep 300 &
sleeper=$!
two_hours=$(python3 -c 'import datetime as dt; print((dt.datetime.now(dt.timezone.utc) + dt.timedelta(hours=2)).isoformat())')
three main
weekly 0.97 "$week" 0.98 "$soon" 0.99 "$two_hours"
autoswitch >/dev/null
[[ $(active) == "side" && $(login "$HOME/.claude") == "side" && $(login "$accounts/claude/work") == "work" ]] ||
  fail "with every account over, a free home goes before a busy one" "$(active) $(login "$HOME/.claude")"
kill "$sleeper"; wait "$sleeper" 2>/dev/null || true
pass "with every account over, a busy home is still never handed a worse login"

# Left to itself, the reconnect job runs as a systemd unit of its own, so a
# oneshot service or the panel that ran the switch can't take it down.
unset OMARCHY_AGENT_ACCOUNT_RECONNECT
printf '#!/bin/bash\necho "{\\"result\\":{\\"agents\\":[]}}"\n' >"$test_tmp/bin/herdr"
chmod +x "$test_tmp/bin/herdr"
cat >"$test_tmp/bin/systemd-run" <<'SH2'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_RECONNECTS"
SH2
chmod +x "$test_tmp/bin/systemd-run"
: >"$reconnects"
for home in "$HOME/.claude" "$accounts/claude/work" "$accounts/claude/side"; do
  echo "{\"claudeAiOauth\":{\"refreshToken\":\"$(basename "$home")\"}}" >"$home/.credentials.json"
done
three main
weekly 0.97 "$week" 0.10 "$day" 0.40 "$week"
autoswitch >/dev/null
grep -q -- "^--user .* -- $ROOT/bin/omarchy-agent-account-reconnect $HOME/.claude $accounts/claude/work$" "$reconnects" ||
  fail "the reconnect job starts as a user unit, from beside the switcher" "$(cat "$reconnects")"
pass "the reconnect job runs as a unit of its own"
