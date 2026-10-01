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
record 0.949 "$soon" 0.12 "$later"
[[ -z $(autoswitch) && ! -s $notifications ]] || fail "an account under the threshold stays put"
pass "an account under the threshold stays put"

record 0.96 "$soon" 0.12 "$later"
[[ $(autoswitch) == "claude" && $(active) == "work" ]] || fail "auto mode moves to the account with headroom"
grep -q "New Claude sessions now use Work (12%). Running sessions stay on Main." "$notifications" ||
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
