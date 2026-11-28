#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Foot runs omarchy-agent-bell as its bell command, so the terminal that rang
# is the command's parent: this test's shell stands in for it.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"
notify_log="$test_tmp/notify"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
[[ $1 == "clients" ]] && printf '%s\n' "$OMARCHY_TEST_CLIENTS_JSON"
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_NOTIFY_LOG"
SH

cat >"$mock_bin/omarchy-i18n" <<'SH'
#!/bin/bash
[[ $1 == "agents.bellHeadline" ]] && echo "Your agent needs you"
SH
chmod +x "$mock_bin"/*

ring() {
  rm -f "$notify_log"
  PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$1" OMARCHY_TEST_NOTIFY_LOG="$notify_log" \
    bash "$ROOT/bin/omarchy-agent-bell"
}

ring "[
  {\"address\":\"0xother\",\"pid\":1,\"class\":\"org.omarchy.agent\",\"title\":\"Someone else\"},
  {\"address\":\"0xagent\",\"pid\":$$,\"class\":\"org.omarchy.agent\",\"title\":\"✳ Fix the flaky test\"}
]"

[[ -f $notify_log ]] || fail "an agent window that rings sends a notification"
mapfile -t args <"$notify_log"
[[ ${args[2]} == "Your agent needs you" ]] || fail "the notification says the agent needs you" "${args[*]}"
[[ ${args[3]} == "✳ Fix the flaky test" ]] || fail "the notification carries the agent window's title" "${args[*]}"
[[ ${args[*]} == *'--exec hyprctl dispatch hl.dsp.focus({ window = "address:0xagent" })'* ]] ||
  fail "clicking the notification focuses the window that rang, not another agent" "${args[*]}"
pass "an agent window that rings in the background asks for you"

ring "[{\"address\":\"0xshell\",\"pid\":$$,\"class\":\"foot\",\"title\":\"bash\"}]"
[[ ! -f $notify_log ]] || fail "a plain terminal's bell sends no notification"
pass "a plain terminal's bell stays quiet"

ring '[]'
[[ ! -f $notify_log ]] || fail "a bell from no known window sends no notification"
pass "a bell from an unknown window stays quiet"

ring "[
  {\"address\":\"0xagent\",\"pid\":$$,\"class\":\"org.omarchy.agent\",\"title\":\"codex\"},
  {\"address\":\"0xshell\",\"pid\":$$,\"class\":\"foot\",\"title\":\"bash\"}
]"
[[ ! -f $notify_log ]] || fail "a foot server that can't say which window rang sends no notification"
pass "a foot server's bell stays quiet, since any of its windows may have rung"

