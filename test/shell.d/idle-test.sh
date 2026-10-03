#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')

assertEqual(idle.secondsFromConfig('42.9', 10), 42, 'idle floors configured seconds')
assertEqual(idle.secondsFromConfig('-1', 10), 10, 'idle rejects negative seconds')
assertEqual(idle.secondsFromConfig('nope', 10), 10, 'idle rejects invalid seconds')

assertDeepEqual(idle.eventParts({ data: 'a,b,c' }, 2), ['a', 'b', 'c'], 'idle parses raw event data')
assertDeepEqual(
  idle.eventParts({ parse: function(count) { return ['parsed', count] } }, 4),
  ['parsed', 4],
  'idle prefers event parser when available'
)

assertDeepEqual(
  idle.screensaverWindowsAfter({ a: true }, 'b', true),
  { windows: { a: true, b: true }, count: 2 },
  'idle adds visible screensaver windows'
)
assertDeepEqual(
  idle.screensaverWindowsAfter({ a: true, b: true }, 'a', false),
  { windows: { b: true }, count: 1 },
  'idle removes closed screensaver windows'
)
assertDeepEqual(
  idle.screensaverWindowsAfter({ a: true }, '', false),
  { windows: { a: true }, count: 1 },
  'idle leaves screensaver windows unchanged without an address'
)

assertEqual(idle.stayAwakeModeFromState(false, ''), 'allow', 'idle reads a missing state file as allow')
assertEqual(idle.stayAwakeModeFromState(true, ''), 'awake', 'idle reads a legacy empty state file as awake')
assertEqual(idle.stayAwakeModeFromState(true, 'awake\n'), 'awake', 'idle reads an awake state file as awake')
assertEqual(idle.stayAwakeModeFromState(true, '1:22:333\n'), 'awake', 'idle reads an update owner stamp as awake')
assertEqual(idle.stayAwakeModeFromState(true, 'agents\n'), 'agents', 'idle reads an agents state file as agents')

assertEqual(idle.stayAwakeStateContent('agents'), 'agents\n', 'idle persists the agents mode')
assertEqual(idle.stayAwakeStateContent('awake'), 'awake\n', 'idle persists the awake mode')
assertEqual(idle.stayAwakeStateContent('allow'), null, 'idle persists allow by removing the file')

assertEqual(idle.stayAwakeEffective('awake', false), true, 'idle stays awake in awake mode')
assertEqual(idle.stayAwakeEffective('agents', true), true, 'idle stays awake for working agents')
assertEqual(idle.stayAwakeEffective('agents', false), false, 'idle allows idle when no agent works')
assertEqual(idle.stayAwakeEffective('allow', true), false, 'idle allows idle in allow mode')

assertEqual(idle.nextStayAwakeMode('allow'), 'awake', 'idle cycles allow to awake')
assertEqual(idle.nextStayAwakeMode('awake'), 'agents', 'idle cycles awake to agents')
assertEqual(idle.nextStayAwakeMode('agents'), 'allow', 'idle cycles agents to allow')
JS

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mkdir -p "$test_home"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
[[ -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists enabled state"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
[[ ! -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists disabled state"

# The agents mode persists as file content and cycles between the three modes.
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" agents >/dev/null
[[ $(cat "$test_home/.local/state/omarchy/indicators/stay-awake") == "agents" ]] || fail "Stay Awake toggle persists the agents mode"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" status | grep -q '"mode":"agents"' || fail "Stay Awake status reports the agents mode"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" toggle >/dev/null
[[ ! -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle cycles agents back to allow"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" toggle >/dev/null
[[ $(cat "$test_home/.local/state/omarchy/indicators/stay-awake") == "awake" ]] || fail "Stay Awake toggle cycles allow to awake"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" toggle >/dev/null
[[ $(cat "$test_home/.local/state/omarchy/indicators/stay-awake") == "agents" ]] || fail "Stay Awake toggle cycles awake to agents"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null

# Legacy content still reads as stay-awake, and the update owner stamp with it.
: >"$test_home/.local/state/omarchy/indicators/stay-awake"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" status | grep -q '"mode":"stay-awake"' || fail "Stay Awake status reads a legacy file as stay-awake"
printf '1:22:333\n' >"$test_home/.local/state/omarchy/indicators/stay-awake"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" status | grep -q '"mode":"stay-awake"' || fail "Stay Awake status reads an update stamp as stay-awake"
HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null

if rg -q 'omarchy-shell' "$ROOT/bin/omarchy-toggle-idle"; then
  fail "Stay Awake toggle avoids reentrant shell IPC"
fi

pass "Stay Awake toggle persists state without reentrant shell IPC"

# omarchy-agents-working reports herdr's working state and fails open.
agents_bin="$test_tmp/agents-bin"
mkdir -p "$agents_bin"
export MOCK_HERDR_PRESENT=1 MOCK_HERDR_STATE=idle
cat >"$agents_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ $1 == "herdr" && ${MOCK_HERDR_PRESENT:-1} == 1 ]] && exit 1
exit 0
SH
cat >"$agents_bin/herdr" <<'SH'
#!/bin/bash
case "${MOCK_HERDR_STATE:-idle}" in
  working)
    echo '{"result":{"agents":[{"agent":"opencode","agent_status":"working"}]}}'
    ;;
  idle)
    echo '{"result":{"agents":[{"agent":"opencode","agent_status":"idle"}]}}'
    ;;
  *)
    echo "not json at all"
    exit 1
    ;;
esac
SH
chmod +x "$agents_bin"/*
export PATH="$agents_bin:$PATH"

export MOCK_HERDR_STATE=working
"$ROOT/bin/omarchy-agents-working" || fail "Agents working reports a working agent"
export MOCK_HERDR_STATE=idle
"$ROOT/bin/omarchy-agents-working" && fail "Agents working reports no working agent when idle"
export MOCK_HERDR_STATE=broken
"$ROOT/bin/omarchy-agents-working" && fail "Agents working fails open on unreadable herdr"
export MOCK_HERDR_PRESENT=0
"$ROOT/bin/omarchy-agents-working" && fail "Agents working fails open without herdr"

pass "Agents working reports herdr state and fails open"
