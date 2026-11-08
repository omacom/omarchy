#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

test_tmp=$(mktemp -d)
sleepers=()
cleanup() {
  for pid in "${sleepers[@]}"; do kill "$pid" 2>/dev/null || true; done
  rm -rf "$test_tmp"
}
trap cleanup EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/home/.claude" "$test_tmp/work" "$test_tmp/other" "$test_tmp/herdr"
herdr_state="$test_tmp/herdr"
export HOME="$test_tmp/home"
export XDG_RUNTIME_DIR="$test_tmp"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"
export OMARCHY_TEST_NOTIFICATIONS="$test_tmp/notifications"
export OMARCHY_TEST_HERDR="$herdr_state"
export XDG_STATE_HOME="$test_tmp/state" OMARCHY_RECONNECT_CHECK_SECONDS=3
export OMARCHY_RECONNECT_NOTICE_SECONDS=1 OMARCHY_RECONNECT_TIMEOUT_SECONDS=3 OMARCHY_RECONNECT_POLL_SECONDS=0.1 OMARCHY_RECONNECT_ANSWER_SECONDS=1 OMARCHY_RECONNECT_SETTLE_SECONDS=0.2

cat >"$test_tmp/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_NOTIFICATIONS"
SH

# A herdr whose panes run a small stand-in for Claude: each pane has a
# status, a visible screen and its scrollback, and answers /remote-control the
# way its `answer` file says (active, confirm, or anything else).
cat >"$test_tmp/bin/herdr" <<'SH'
#!/bin/bash
s=$OMARCHY_TEST_HERDR
box() { printf '%s\n' "────────────────────" "❯ $1" "────────────────────" "  ⏵⏵ bypass permissions on (shift+tab to cycle)" >"$s/$2.visible"; }
case "$1 $2" in
"agent list") jq -c '{result: {agents: .}}' "$s/agents.json" ;;
"pane process-info") jq -nc --argjson pid "$(cat "$s/$4.pid")" '{result: {process_info: {foreground_processes: [{name: "claude", pid: $pid}]}}}' ;;
"agent get") jq -nc --arg status "$(cat "$s/$3.status")" '{result: {agent: {agent: "claude", agent_status: $status}}}' ;;
"pane read")
  if [[ $5 == "visible" ]]; then cat "$s/$3.visible"; else cat "$s/$3.recent" "$s/$3.visible"; fi ;;
"pane send-text")
  echo "text $3 $4" >>"$s/log"
  box "$4" "$3" ;;
"pane send-keys")
  echo "keys $3 $4" >>"$s/log"
  if [[ $4 == "esc" ]]; then
    grep -q "Esc to continue" "$s/$3.visible" && box "" "$3"
  elif [[ -f $s/$3.confirming ]]; then
    rm "$s/$3.confirming"
    printf '%s\n' "  /remote-control is active · Continue here" >>"$s/$3.recent"
  elif grep -qx "❯ /remote-control" "$s/$3.visible" && [[ $(cat "$s/$3.answer") == "notyet" ]]; then
    # Too soon after the disconnect: a dialog, no transcript line, and the
    # next try works.
    printf '%s\n' "   Remote Control" "   × Remote Control isn't connected." \
      "   To try again, choose Continue, wait about 10 seconds for Remote Control to switch off, then run /remote-control." \
      "     Disconnect this session   Can archive it now and stop a later --resume reconnecting it" "   ❯ Continue" "   Enter to select · Esc to continue" >"$s/$3.visible"
    echo active >"$s/$3.answer"
  elif grep -qx "❯ /remote-control" "$s/$3.visible" && [[ $(cat "$s/$3.answer") == "available" ]]; then
    # Already connected: the command opens a dialog saying so.
    printf '%s\n' "   Remote Control" "   This session is available in the Claude mobile app and at https://claude.ai/code/session_x." \
      "     Disconnect this session" "     Show QR code   Scan with your phone to open this session" "   ❯ Continue" "   Enter to select · Esc to continue" >"$s/$3.visible"
  elif grep -qx "❯ /remote-control" "$s/$3.visible"; then
    printf '%s\n' "" "❯ /remote-control" "" >>"$s/$3.recent"
    case "$(cat "$s/$3.answer")" in
    active) printf '%s\n' "  /remote-control is active · Continue here" >>"$s/$3.recent" ;;
    confirm) printf '%s\n' "  Enable Remote Control for this account?" "  ❯ 1. Enable Remote Control" "    2. Never mind" >>"$s/$3.recent"; touch "$s/$3.confirming" ;;
    silent) echo available >"$s/$3.answer" ;;
    *) printf '%s\n' "  Unknown skill: remote-control" >>"$s/$3.recent" ;;
    esac
    box "" "$3"
  fi ;;
*) exit 1 ;;
esac
SH
chmod +x "$test_tmp/bin/omarchy-notification-send" "$test_tmp/bin/herdr"

# A pane: its id, the home its Claude reads (empty for ~/.claude), status,
# what Remote Control last said, what's typed in its prompt, its answer.
pane() {
  local id=$1 home=$2 status=$3 rc=$4 typed=$5 answer=${6:-active}
  if [[ -n $home ]]; then
    CLAUDE_CONFIG_DIR="$home" sleep 300 &
  else
    sleep 300 &
  fi
  sleepers+=($!)
  echo $! >"$herdr_state/$id.pid"
  echo "$status" >"$herdr_state/$id.status"
  echo "$answer" >"$herdr_state/$id.answer"
  case "$rc" in
  dropped) printf '%s\n' "  /remote-control is active · Continue here" "" "  Remote Control disconnected — signed-in claude.ai account or organization changed on this machine — run /remote-control to start a session for the current account" >"$herdr_state/$id.recent" ;;
  on) printf '%s\n' "  Remote Control disconnected — signed-in claude.ai account or organization changed on this machine" "❯ /remote-control" "  /remote-control is active · Continue here" >"$herdr_state/$id.recent" ;;
  *) printf '%s\n' "● Done." >"$herdr_state/$id.recent" ;;
  esac
  printf '%s\n' "────────────────────" "❯ $typed" "────────────────────" "  ⏵⏵ bypass permissions on (shift+tab to cycle)" >"$herdr_state/$id.visible"
  jq --arg id "$id" '. + [{agent: "claude", pane_id: $id, terminal_title_stripped: ("Session " + $id)}]' "$herdr_state/agents.json" >"$herdr_state/agents.next"
  mv "$herdr_state/agents.next" "$herdr_state/agents.json"
}

reset_panes() {
  for pid in "${sleepers[@]}"; do kill "$pid" 2>/dev/null || true; done
  sleepers=()
  rm -f "$herdr_state"/*
  echo '[]' >"$herdr_state/agents.json"
  : >"$herdr_state/log" >"$OMARCHY_TEST_NOTIFICATIONS"
}

reconnect() {
  omarchy-agent-account-reconnect "$HOME/.claude" "$test_tmp/work" || true
}

# ------------------------------------------------------------- reconnecting

reset_panes
pane p1 "" idle dropped ""
pane p2 "$test_tmp/work" done dropped "" confirm
pane p3 "$test_tmp/other" idle dropped ""
pane p4 "$test_tmp/work" idle on ""
pane p5 "" idle none ""
reconnect
grep -qx "text p1 /remote-control" "$herdr_state/log" && grep -qx "keys p1 enter" "$herdr_state/log" ||
  fail "an idle session in a moved home gets /remote-control" "$(cat "$herdr_state/log")"
[[ $(grep -c "keys p2 enter" "$herdr_state/log") == 2 ]] || fail "Claude's own Enable Remote Control confirmation is accepted" "$(cat "$herdr_state/log")"
! grep -q " p3 \| p4 \| p5 " "$herdr_state/log" ||
  fail "sessions in other homes, already reconnected, or without Remote Control are left alone" "$(cat "$herdr_state/log")"
grep -q "Remote Control reconnected Session p1, Session p2" "$OMARCHY_TEST_NOTIFICATIONS" || fail "reconnecting says where" "$(cat "$OMARCHY_TEST_NOTIFICATIONS")"
pass "Remote Control comes back in the sessions whose login moved"

# An empty prompt shows a dim suggestion ("Try ..."); that isn't a draft.
reset_panes
pane s1 "" idle dropped ""
printf '%s\n' "────────────────────" $'❯\u00a0\e[0m\e[2mTry "fix lint errors"\e[0m' "────────────────────" "  ⏵⏵ bypass permissions on" >"$herdr_state/s1.visible"
reconnect
grep -qx "keys s1 enter" "$herdr_state/log" || fail "a dim suggestion in the prompt counts as empty" "$(cat "$herdr_state/log")"
pass "the prompt's dim suggestion isn't mistaken for a draft"

# A named session carries its name in the box's top rule.
reset_panes
pane n2 "" idle dropped ""
printf '%s\n' "──────────────────── Zapfast ─" "❯ " "────────────────────" "  ⏵⏵ bypass permissions on" >"$herdr_state/n2.visible"
reconnect
grep -qx "text n2 /remote-control" "$herdr_state/log" || fail "a prompt box with the session's name in its rule is still a prompt" "$(cat "$herdr_state/log")"
pass "a named session's prompt box is recognized"

# --------------------------------------------------------- never interrupting

# Working, a question open, a draft in the prompt, a menu open: nothing is
# typed, and the timeout says which session needs it.
reset_panes
pane w1 "" working dropped ""
pane w2 "" blocked dropped ""
pane w3 "" idle dropped "half a thought"
pane w4 "" idle dropped ""
printf '%s\n' "  Select model" "  ❯ 1. Default" "────────────────────" "❯ " "────────────────────" "  Enter to confirm · Esc to exit" >"$herdr_state/w4.visible"
reconnect
[[ ! -s $herdr_state/log ]] || fail "a session that isn't idle at an empty prompt is never typed into" "$(cat "$herdr_state/log")"
[[ $(grep -c "Remote Control didn't reconnect" "$OMARCHY_TEST_NOTIFICATIONS") == 4 ]] && grep -q "Session w3 stayed busy" "$OMARCHY_TEST_NOTIFICATIONS" ||
  fail "a session that never goes idle is named when giving up" "$(cat "$OMARCHY_TEST_NOTIFICATIONS")"
pass "a busy session is waited for, never typed into"

# One that goes idle later is reconnected then.
reset_panes
pane l1 "" working dropped ""
(sleep 1; echo idle >"$herdr_state/l1.status") &
later=$!
reconnect
wait "$later"
grep -qx "keys l1 enter" "$herdr_state/log" || fail "a session is reconnected once it goes idle" "$(cat "$herdr_state/log")"
pass "a session is reconnected once it goes idle"

# Typed before the old link has switched off, /remote-control opens a dialog
# asking to wait. Esc is its own default; then it's tried once more.
reset_panes
pane n1 "" idle dropped "" notyet
reconnect
[[ $(grep -c "keys n1 enter" "$herdr_state/log") == 2 && $(grep -c "keys n1 esc" "$herdr_state/log") == 1 ]] ||
  fail "the switching-off dialog is dismissed with Esc and the command tried again" "$(cat "$herdr_state/log")"
! grep -q "keys n1 down\|keys n1 up" "$herdr_state/log" || fail "the dialog's Disconnect choice is never reached"
grep -q "Remote Control reconnected Session n1" "$OMARCHY_TEST_NOTIFICATIONS" || fail "the second try reconnects" "$(cat "$OMARCHY_TEST_NOTIFICATIONS")"
pass "a link still switching off is waited for and tried again"

# A session that picks its old link back up says nothing; the command run
# again shows it's connected, and that dialog is closed with Esc.
reset_panes
pane q1 "" idle dropped "" silent
reconnect
[[ $(grep -c "keys q1 enter" "$herdr_state/log") == 2 && $(grep -c "keys q1 esc" "$herdr_state/log") == 1 ]] ||
  fail "a silent reconnect is confirmed by the connected dialog" "$(cat "$herdr_state/log")"
grep -q "Remote Control reconnected Session q1" "$OMARCHY_TEST_NOTIFICATIONS" || fail "a confirmed silent reconnect counts" "$(cat "$OMARCHY_TEST_NOTIFICATIONS")"
pass "a reconnect that says nothing is confirmed before it counts"

# Background agents listed under the prompt box aren't a menu.
reset_panes
pane b1 "" idle dropped ""
printf '%s\n' "  ◯ opus-medium  Waiting for background test run   3h 29m" "  ◯ opus-medium  Removing worktree   45m" "  ◯ opus-medium  Checking CI   2m" "  ◯ opus-medium  Reading docs   1m" >>"$herdr_state/b1.visible"
reconnect
grep -qx "keys b1 enter" "$herdr_state/log" || fail "a footer of background agents doesn't hold the reconnect back" "$(cat "$herdr_state/log")"
pass "background agents under the prompt don't count as a menu"

# ---------------------------------------------------------------- the unexpected

# Anything but "is active" or the exact confirmation stops it: no more keys.
reset_panes
pane u1 "" idle dropped "" unknown
reconnect
[[ $(grep -c "keys u1" "$herdr_state/log") == 1 ]] || fail "an unexpected answer gets no more keys" "$(cat "$herdr_state/log")"
grep -q "Session u1 didn't answer as expected" "$OMARCHY_TEST_NOTIFICATIONS" || fail "an unexpected answer is reported" "$(cat "$OMARCHY_TEST_NOTIFICATIONS")"
pass "an unexpected answer stops the reconnect"

# Text that doesn't land in the prompt as typed is never submitted.
reset_panes
pane t1 "" idle dropped ""
cat >"$test_tmp/bin/herdr-real" <"$test_tmp/bin/herdr"
chmod +x "$test_tmp/bin/herdr-real"
cat >"$test_tmp/bin/herdr" <<'SH'
#!/bin/bash
if [[ $1 == "pane" && $2 == "send-text" ]]; then
  echo "text $3 $4" >>"$OMARCHY_TEST_HERDR/log"
  exit 0
fi
exec herdr-real "$@"
SH
reconnect
grep -qx "text t1 /remote-control" "$herdr_state/log" && ! grep -q "keys t1" "$herdr_state/log" ||
  fail "text that doesn't show up in the prompt is never submitted" "$(cat "$herdr_state/log")"
mv "$test_tmp/bin/herdr-real" "$test_tmp/bin/herdr"
pass "nothing is submitted unless the prompt shows exactly /remote-control"

# Without herdr there's nothing to find, and the job ends at once.
reset_panes
PATH="$test_tmp/nobin:/usr/bin:/bin" python3 "$ROOT/bin/omarchy-agent-account-reconnect" "$HOME/.claude" || fail "no herdr, nothing to do"
pass "without herdr the job does nothing"

# ----------------------------------------------------- every tick, no switch

# What Claude keeps for a running session: its id, and its Remote Control
# link while one is up.
claude_state() {
  local id=$1 sid=$2 bridge=$3 pid
  pid=$(cat "$herdr_state/$id.pid")
  mkdir -p "$HOME/.claude/sessions"
  if [[ -n $bridge ]]; then
    jq -nc --arg sid "$sid" --arg b "$bridge" '{sessionId: $sid, bridgeSessionId: $b}' >"$HOME/.claude/sessions/$pid.json"
  else
    jq -nc --arg sid "$sid" '{sessionId: $sid, bridgeSessionId: null}' >"$HOME/.claude/sessions/$pid.json"
  fi
}
check() {
  omarchy-agent-account-reconnect --check --attached || true
}

# Nothing to do: no keys, no word, and no background run started.
reset_panes
rm -rf "$XDG_STATE_HOME" "$HOME/.claude/sessions"
cat >"$test_tmp/bin/systemd-run" <<'SH'
#!/bin/bash
echo "systemd-run $*" >>"$OMARCHY_TEST_HERDR/log"
SH
chmod +x "$test_tmp/bin/systemd-run"
pane c1 "" idle none ""
claude_state c1 sid-1 session_abc
pane c2 "" idle none ""
claude_state c2 sid-2 ""
omarchy-agent-account-reconnect --check
[[ ! -s $herdr_state/log && ! -s $OMARCHY_TEST_NOTIFICATIONS ]] || fail "a check with nothing to do does nothing" "$(cat "$herdr_state/log" "$OMARCHY_TEST_NOTIFICATIONS")"
pass "a check with nothing to do is quiet"

# The link c1 had is gone, with nothing on its screen saying so.
claude_state c1 sid-1 ""
omarchy-agent-account-reconnect --check
grep -q "^systemd-run --user .* --check --attached$" "$herdr_state/log" || fail "a check starts its fixing run as a unit of its own" "$(cat "$herdr_state/log")"
: >"$herdr_state/log"
check
grep -qx "keys c1 enter" "$herdr_state/log" || fail "a session whose link vanished gets /remote-control" "$(cat "$herdr_state/log")"
! grep -q " c2 " "$herdr_state/log" || fail "a session that never had Remote Control is left alone" "$(cat "$herdr_state/log")"
grep -q "Remote Control reconnected Session c1" "$OMARCHY_TEST_NOTIFICATIONS" || fail "a check says what it reconnected" "$(cat "$OMARCHY_TEST_NOTIFICATIONS")"
pass "a session that had Remote Control gets it back without any switch"

# A resumed session keeps its sessionId, so it's known to have had it.
reset_panes
pane r1 "" idle none ""
claude_state r1 sid-1 ""
check
grep -qx "keys r1 enter" "$herdr_state/log" || fail "a resumed session gets its Remote Control back" "$(cat "$herdr_state/log")"
pass "a resumed session gets its Remote Control back"

# A pane that says its link dropped counts, even unseen before; one that only
# talks about Remote Control doesn't, and one under another HOME is never
# touched.
reset_panes
pane d1 "" idle dropped ""
claude_state d1 sid-d1 ""
pane d2 "" idle none ""
claude_state d2 sid-d2 ""
printf '%s\n' "● Agreed. Remote Control disconnected earlier, so it gets checked every 5 minutes." >"$herdr_state/d2.recent"
HOME="$test_tmp/other" sleep 300 &
sleepers+=($!)
echo $! >"$herdr_state/d3.pid"; echo idle >"$herdr_state/d3.status"; echo active >"$herdr_state/d3.answer"
cp "$herdr_state/d1.recent" "$herdr_state/d3.recent"; cp "$herdr_state/d1.visible" "$herdr_state/d3.visible"
jq '. + [{agent: "claude", pane_id: "d3", terminal_title_stripped: "Session d3"}]' "$herdr_state/agents.json" >"$herdr_state/agents.next" && mv "$herdr_state/agents.next" "$herdr_state/agents.json"
check
grep -qx "keys d1 enter" "$herdr_state/log" || fail "a pane showing the drop is reconnected" "$(cat "$herdr_state/log")"
! grep -q " d2 \| d3 " "$herdr_state/log" || fail "talk about Remote Control and other users' sessions are left alone" "$(cat "$herdr_state/log")"
pass "only Claude's own drop line, in this user's sessions, counts"

# Busy at the prompt: left for the next tick, without a word.
reset_panes
pane b2 "" working dropped ""
claude_state b2 sid-b2 ""
check
[[ ! -s $herdr_state/log && ! -s $OMARCHY_TEST_NOTIFICATIONS ]] || fail "a busy session is left for the next tick, quietly" "$(cat "$herdr_state/log" "$OMARCHY_TEST_NOTIFICATIONS")"
pass "a check leaves a busy session for the next tick"

# An unexpected answer is said once, then the session is left alone.
reset_panes
pane g1 "" idle dropped "" unknown
claude_state g1 sid-g1 ""
check
grep -q "Session g1 didn't answer as expected" "$OMARCHY_TEST_NOTIFICATIONS" || fail "an unexpected answer is reported" "$(cat "$OMARCHY_TEST_NOTIFICATIONS")"
: >"$herdr_state/log" >"$OMARCHY_TEST_NOTIFICATIONS"
check
[[ ! -s $herdr_state/log && ! -s $OMARCHY_TEST_NOTIFICATIONS ]] || fail "a session that answered unexpectedly isn't retried every tick" "$(cat "$herdr_state/log" "$OMARCHY_TEST_NOTIFICATIONS")"
pass "an unexpected answer isn't repeated every tick"
