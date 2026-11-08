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
record 0.949 "$soon" 0.70 "$later"
[[ -z $(autoswitch) && ! -s $notifications ]] || fail "an account under the threshold stays put"
record 0.79 "$soon" 0.12 "$later"
[[ -z $(autoswitch) && ! -s $notifications ]] || fail "an account more than 15 points under the threshold stays put"
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

registry main auto
record 0.97 "$later" 0.98 "$soon"
[[ -z $(autoswitch) && $(active) == "main" ]] || fail "with nowhere to go, auto mode stays put"
grep -q "All Claude accounts are over 95% Staying on Main. Work resets in 1h 1[12]m." "$notifications" ||
  fail "exhaustion names the account that frees up first" "$(cat "$notifications")"
autoswitch >/dev/null
[[ ! -s $notifications ]] || fail "exhaustion is said once"
pass "all accounts over the threshold is said once"

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

# Numbers kept from an earlier check may be out of date, so an account checked
# just now wins over a stale one showing more room; a stale one still counts
# when it's the only place left to go.
mkdir -p "$accounts/claude/side"
cat >"$accounts/claude.json" <<JSON
{
  "active": "main",
  "switch": "auto",
  "threshold": 95,
  "alert": "",
  "accounts": [
    {"id": "main", "label": "Main", "home": "", "primary": true},
    {"id": "work", "label": "Work", "home": "$accounts/claude/work", "primary": false},
    {"id": "side", "label": "Side", "home": "$accounts/claude/side", "primary": false}
  ]
}
JSON
jq -nc --arg later "$later" '{
  id: "claude",
  accounts: [
    {id: "main", limits: [{label: "Session (5-hour)", percent: 0.97, resetsAt: $later}]},
    {id: "work", stale: true, limits: [{label: "Session (5-hour)", percent: 0.10, resetsAt: $later}]},
    {id: "side", stale: false, limits: [{label: "Session (5-hour)", percent: 0.40, resetsAt: $later}]}
  ]
}' >"$usage/claude.json"
autoswitch >/dev/null
[[ $(active) == "side" ]] || fail "an account checked just now wins over a stale one" "$(active)"
pass "an account checked just now wins over a stale one"

# Room comes first: a fresh account within 15 points of the threshold loses to
# a stale one with plenty left.
jq '.active = "main" | .alert = ""' "$accounts/claude.json" >"$test_tmp/registry.json"
mv "$test_tmp/registry.json" "$accounts/claude.json"
jq -nc --arg later "$later" '{
  id: "claude",
  accounts: [
    {id: "main", limits: [{label: "Session (5-hour)", percent: 0.97, resetsAt: $later}]},
    {id: "work", stale: true, limits: [{label: "Session (5-hour)", percent: 0.10, resetsAt: $later}]},
    {id: "side", stale: false, limits: [{label: "Session (5-hour)", percent: 0.94, resetsAt: $later}]}
  ]
}' >"$usage/claude.json"
autoswitch >/dev/null
[[ $(active) == "work" ]] || fail "a stale account with room wins over a fresh one near the limit" "$(active)"
pass "a stale account with room wins over a fresh one near the limit"

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
weekly 0.97 "$week" 0.20 "$week" 0.85 "$day"
autoswitch >/dev/null
[[ $(active) == "work" ]] || fail "room comes before clearing soonest" "$(active)"
pass "room comes before clearing soonest, and the threshold is never crossed"

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

# ---------------------------------------------------------- leaving early

# Within 15 points of the threshold, auto mode leaves for an account at least
# 30 under it, one whose window has reset. The gap keeps it from flapping.
registry main auto
record 0.82 "$later" 0.20 "$later"
[[ $(autoswitch) == "claude" && $(active) == "work" ]] || fail "auto mode leaves early for an account that has reset"
record 0.82 "$later" 0.83 "$later"
[[ -z $(autoswitch) && $(active) == "work" ]] || fail "leaving early never flaps back to an account that hasn't reset"
record 0.82 "$later" 0.70 "$later"
[[ -z $(autoswitch) && $(active) == "work" ]] || fail "an account not yet near its limit stays put"
record 0.10 "$later" 0.84 "$later"
[[ $(autoswitch) == "claude" && $(active) == "main" ]] || fail "auto mode goes back once the earlier account has reset"
pass "auto mode leaves early for a reset account, without flapping"

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

# Leaving early hands a busy home a login still under the threshold, so the
# trade goes ahead.
for home in "$HOME/.claude" "$accounts/claude/work"; do
  echo "{\"claudeAiOauth\":{\"refreshToken\":\"$(basename "$home")\"}}" >"$home/.credentials.json"
done
CLAUDE_CONFIG_DIR="$accounts/claude/work" sleep 300 &
sleeper=$!
three main
weekly 0.85 "$week" 0.10 "$day" 0.98 "$week"
autoswitch >/dev/null
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
