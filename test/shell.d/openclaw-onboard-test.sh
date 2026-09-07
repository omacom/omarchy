#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/home"
export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir/bin:$PATH"
export HOME="$tmp_dir/home"
# The wrapper's lock lives in the runtime directory; a real onboarding on this
# machine must not be what the test sees.
export XDG_RUNTIME_DIR="$tmp_dir"
export OMARCHY_OPENCLAW_ONBOARD_SETTLE_SECONDS=0
unit="$HOME/.config/systemd/user/openclaw-gateway.service"
export unit

# systemd and ss stand in for themselves. Once the wizard has written the unit
# it is running as pid 4242, and that same process holds the gateway port
# unless a test plants a different listener (an orphan) in $listener_file.
listener_file="$tmp_dir/listener"
export listener_file
cat >"$tmp_dir/bin/systemctl" <<'SCRIPT'
#!/bin/bash
printf 'systemctl:%s\n' "$*" >>"$TEST_LOG"
if [[ $* == *MainPID* ]]; then
  [[ -f $unit ]] && echo 4242 || echo 0
  exit 0
fi
[[ $* == *is-active* ]] && [[ -f $unit ]]
SCRIPT
chmod +x "$tmp_dir/bin/systemctl"
cat >"$tmp_dir/bin/ss" <<'SCRIPT'
#!/bin/bash
pid=
[[ -f $listener_file ]] && pid=$(cat "$listener_file")
[[ -z $pid && -f $unit ]] && pid=4242
[[ -n $pid ]] && echo "LISTEN 0 511 127.0.0.1:18789 0.0.0.0:* users:((\"node\",pid=$pid,fd=3))"
exit 0
SCRIPT
chmod +x "$tmp_dir/bin/ss"
export OMARCHY_OPENCLAW_ONBOARD_GATEWAY_TIMEOUT=1

# A finished onboarding hands the theme over; the stub records being asked,
# and whether the wrapper had let go of its lock by then, as the hook needs.
cat >"$tmp_dir/bin/omarchy-theme-set-openclaw" <<'SCRIPT'
#!/bin/bash
printf 'omarchy-theme-set-openclaw:%s\n' "$*" >>"$TEST_LOG"
exec 8>"$XDG_RUNTIME_DIR/omarchy-openclaw-onboard.lock"
flock -n 8 && echo lock-free >>"$TEST_LOG" || echo lock-held-at-handover >>"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/bin/omarchy-theme-set-openclaw"

# A wizard that configures OpenClaw, prints its outro, and then lingers forever
# on an open handle: the 2026.9.1 --skip-ui behaviour. It "installs the
# gateway" by writing the config a moment in, so the gateway only starts
# answering partway through, never at once.
cat >"$tmp_dir/bin/openclaw" <<'SCRIPT'
#!/bin/bash
printf 'openclaw:%s\n' "$*" >>"$TEST_LOG"
case $1 in
onboard)
  # The wrapper must hold its lock for as long as the wizard runs.
  exec 8>"$XDG_RUNTIME_DIR/omarchy-openclaw-onboard.lock"
  flock -n 8 && echo lock-free-during-wizard >>"$TEST_LOG" || echo lock-held >>"$TEST_LOG"
  ( sleep 1; mkdir -p "$HOME/.openclaw" "${unit%/*}"; touch "$HOME/.openclaw/openclaw.json" "$unit" ) &
  trap 'echo terminated >>"$TEST_LOG"; exit 143' TERM
  while :; do sleep 0.2; done
  ;;
dashboard)
  [[ -f $HOME/.openclaw/openclaw.json ]] && echo '{"ok":true,"port":18789}' || { echo '{"ok":false}'; exit 1; }
  ;;
esac
SCRIPT
chmod +x "$tmp_dir/bin/openclaw"

start=$SECONDS
rc=0
"$ROOT/bin/omarchy-openclaw-onboard" </dev/null >/dev/null 2>&1 || rc=$?
elapsed=$((SECONDS - start))

grep -q '^openclaw:onboard --flow quickstart --install-daemon --skip-ui$' "$TEST_LOG" ||
  fail "onboarding runs the classic quickstart wizard with the service install" "$(grep '^openclaw:onboard' "$TEST_LOG" || true)"
pass "onboarding runs the classic quickstart wizard with the service install"

[[ $rc == 0 ]] || fail "a wizard that lingers after the gateway is up is stopped and counts as success" "rc=$rc"
grep -q '^terminated$' "$TEST_LOG" ||
  fail "a wizard that lingers after the gateway is up is stopped and counts as success" "wizard was never signalled"
(( elapsed < 30 )) || fail "a wizard that lingers after the gateway is up is stopped and counts as success" "took ${elapsed}s"
pass "a wizard that lingers after the gateway is up is stopped and counts as success"

grep -q '^omarchy-theme-set-openclaw:--activate$' "$TEST_LOG" ||
  fail "a finished onboarding hands the Omarchy theme to OpenClaw" "$(grep theme "$TEST_LOG" || true)"
pass "a finished onboarding hands the Omarchy theme to OpenClaw"

# The theme hook stays off the config while the wizard runs, told by the
# wrapper's lock, and the wrapper lets go of it before its own hand-over.
grep -q '^lock-held$' "$TEST_LOG" || fail "the wrapper holds its lock while the wizard runs" "$(grep lock "$TEST_LOG" || true)"
grep -q '^lock-free$' "$TEST_LOG" || fail "the wrapper releases its lock before the hand-over" "$(grep lock "$TEST_LOG" || true)"
pass "the wrapper holds its lock for the wizard and releases it for the hand-over"

# The wizard only starts being stopped once the gateway actually answers: a
# stub that never writes the config is left alone and must be ended by its own
# exit, not the watcher.
: >"$TEST_LOG"
rm -rf "$HOME/.openclaw" "$unit" "$listener_file"
cat >"$tmp_dir/bin/openclaw" <<'SCRIPT'
#!/bin/bash
printf 'openclaw:%s\n' "$*" >>"$TEST_LOG"
[[ $1 == onboard ]] && { echo "Skipped for now."; exit 3; }
echo '{"ok":false}'; exit 1
SCRIPT
chmod +x "$tmp_dir/bin/openclaw"
rc=0
"$ROOT/bin/omarchy-openclaw-onboard" </dev/null >/dev/null 2>&1 || rc=$?
[[ $rc == 3 ]] || fail "an abandoned wizard passes its exit code through" "rc=$rc"
[[ ! -f $HOME/.openclaw/openclaw.json ]] || fail "an abandoned wizard passes its exit code through" "config appeared"
! grep -q '^terminated$' "$TEST_LOG" || fail "an abandoned wizard passes its exit code through" "watcher signalled it anyway"
pass "an abandoned wizard passes its exit code through"

# A wizard that finishes and exits on its own is simply waited for.
: >"$TEST_LOG"
cat >"$tmp_dir/bin/openclaw" <<'SCRIPT'
#!/bin/bash
printf 'openclaw:%s\n' "$*" >>"$TEST_LOG"
[[ $1 == onboard ]] && { mkdir -p "$HOME/.openclaw"; touch "$HOME/.openclaw/openclaw.json"; exit 0; }
echo '{"ok":true,"port":18789}'
SCRIPT
chmod +x "$tmp_dir/bin/openclaw"
rc=0
"$ROOT/bin/omarchy-openclaw-onboard" </dev/null >/dev/null 2>&1 || rc=$?
[[ $rc == 0 ]] || fail "a wizard that exits cleanly is waited for" "rc=$rc"
pass "a wizard that exits cleanly is waited for"

# Input reaches the wizard: it runs in the foreground, not backgrounded (which
# would stop it on SIGTTIN the moment it read stdin).
: >"$TEST_LOG"
rm -rf "$HOME/.openclaw" "$unit" "$listener_file"
cat >"$tmp_dir/bin/openclaw" <<'SCRIPT'
#!/bin/bash
printf 'openclaw:%s\n' "$*" >>"$TEST_LOG"
case $1 in
onboard)
  read -r answer
  printf 'answer:%s\n' "$answer" >>"$TEST_LOG"
  mkdir -p "$HOME/.openclaw"; touch "$HOME/.openclaw/openclaw.json"
  exit 0
  ;;
dashboard) echo '{"ok":true,"port":18789}' ;;
esac
SCRIPT
chmod +x "$tmp_dir/bin/openclaw"
printf 'gpt-5\n' | "$ROOT/bin/omarchy-openclaw-onboard" >/dev/null 2>&1
grep -q '^answer:gpt-5$' "$TEST_LOG" ||
  fail "the wizard reads terminal input" "$(grep '^answer' "$TEST_LOG" || echo 'no input reached it')"
pass "the wizard reads terminal input"

# An already-configured machine whose gateway answers is not onboarded again:
# the wizard's repair pass would otherwise be stopped mid-prompt the moment
# the watcher saw the pre-existing gateway.
: >"$TEST_LOG"
mkdir -p "$HOME/.openclaw" && touch "$HOME/.openclaw/openclaw.json"
cat >"$tmp_dir/bin/openclaw" <<'SCRIPT'
#!/bin/bash
printf 'openclaw:%s\n' "$*" >>"$TEST_LOG"
[[ $1 == onboard ]] && { echo wizard-ran >>"$TEST_LOG"; exit 0; }
echo '{"ok":true,"port":18789}'
SCRIPT
chmod +x "$tmp_dir/bin/openclaw"
rc=0
"$ROOT/bin/omarchy-openclaw-onboard" </dev/null >/dev/null 2>&1 || rc=$?
[[ $rc == 0 ]] || fail "an already-running OpenClaw is left alone" "rc=$rc"
! grep -q '^wizard-ran$' "$TEST_LOG" || fail "an already-running OpenClaw is left alone" "wizard ran anyway"
pass "an already-running OpenClaw is left alone"

# Setup applied but the gateway never answers: the wizard would linger
# forever, so it is stopped after the deadline and that is reported as failure.
: >"$TEST_LOG"
rm -rf "$HOME/.openclaw" "$unit" "$listener_file"
cat >"$tmp_dir/bin/openclaw" <<'SCRIPT'
#!/bin/bash
printf 'openclaw:%s\n' "$*" >>"$TEST_LOG"
case $1 in
onboard)
  mkdir -p "$HOME/.openclaw"; touch "$HOME/.openclaw/openclaw.json"
  trap 'echo terminated >>"$TEST_LOG"; exit 143' TERM
  while :; do sleep 0.2; done
  ;;
dashboard) echo '{"ok":false}'; exit 1 ;;
esac
SCRIPT
chmod +x "$tmp_dir/bin/openclaw"
start=$SECONDS
rc=0
err=$("$ROOT/bin/omarchy-openclaw-onboard" </dev/null 2>&1 >/dev/null) || rc=$?
elapsed=$((SECONDS - start))
[[ $rc == 1 ]] || fail "a gateway that never comes up ends the wait with a failure" "rc=$rc"
grep -q '^terminated$' "$TEST_LOG" || fail "a gateway that never comes up ends the wait with a failure" "wizard left running"
[[ $err == *"gateway status"* ]] || fail "a gateway that never comes up ends the wait with a failure" "no diagnostic: $err"
(( elapsed < 30 )) || fail "a gateway that never comes up ends the wait with a failure" "took ${elapsed}s"
pass "a gateway that never comes up ends the wait with a failure"

# A signal at this script alone takes the wizard down with it.
: >"$TEST_LOG"
rm -rf "$HOME/.openclaw" "$unit" "$listener_file"
cat >"$tmp_dir/bin/openclaw" <<'SCRIPT'
#!/bin/bash
printf 'openclaw:%s\n' "$*" >>"$TEST_LOG"
case $1 in
onboard) trap 'echo terminated >>"$TEST_LOG"; exit 143' TERM; while :; do sleep 0.2; done ;;
dashboard) echo '{"ok":false}'; exit 1 ;;
esac
SCRIPT
chmod +x "$tmp_dir/bin/openclaw"
"$ROOT/bin/omarchy-openclaw-onboard" </dev/null >/dev/null 2>&1 &
wrapper=$!
sleep 1
kill -TERM "$wrapper"
wait "$wrapper" 2>/dev/null || true
sleep 1
grep -q '^terminated$' "$TEST_LOG" || fail "stopping the wrapper stops the wizard" "wizard survived"
! pgrep -f "$tmp_dir/bin/openclaw onboard" >/dev/null || fail "stopping the wrapper stops the wizard" "wizard process still alive"
pass "stopping the wrapper stops the wizard"

# A config left by an earlier, incomplete setup does not start the gateway
# deadline: only this run applying setup does. The wizard here takes longer
# than the deadline at its prompts, never touches the old config, and must be
# left to finish on its own.
: >"$TEST_LOG"
mkdir -p "$HOME/.openclaw" && touch "$HOME/.openclaw/openclaw.json"
sleep 1
cat >"$tmp_dir/bin/openclaw" <<'SCRIPT'
#!/bin/bash
printf 'openclaw:%s\n' "$*" >>"$TEST_LOG"
case $1 in
onboard) trap 'echo terminated >>"$TEST_LOG"; exit 143' TERM; sleep 4; echo finished >>"$TEST_LOG"; exit 0 ;;
dashboard) echo '{"ok":false}'; exit 1 ;;
esac
SCRIPT
chmod +x "$tmp_dir/bin/openclaw"
rc=0
"$ROOT/bin/omarchy-openclaw-onboard" </dev/null >/dev/null 2>&1 || rc=$?
[[ $rc == 0 ]] || fail "a stale config does not start the gateway deadline" "rc=$rc"
grep -q '^finished$' "$TEST_LOG" || fail "a stale config does not start the gateway deadline" "wizard was cut short"
! grep -q '^terminated$' "$TEST_LOG" || fail "a stale config does not start the gateway deadline" "wizard was signalled"
pass "a stale config does not start the gateway deadline"

# A theme hook that was already writing when onboarding started holds the
# lock; onboarding waits, and the config the hook wrote meanwhile is not read
# as this run having applied setup: the wizard is still left to finish.
: >"$TEST_LOG"
rm -rf "$HOME/.openclaw" "$unit"
mkdir -p "$HOME/.openclaw" && touch "$HOME/.openclaw/openclaw.json"
exec 7>"$XDG_RUNTIME_DIR/omarchy-openclaw-onboard.lock"
flock -s 7
rc=0
"$ROOT/bin/omarchy-openclaw-onboard" </dev/null >/dev/null 2>&1 &
wrapper_pid=$!
sleep 1
! grep -q '^openclaw:onboard' "$TEST_LOG" || fail "onboarding waits for a hook that holds the lock" "wizard started under the hook's lock"
touch "$HOME/.openclaw/openclaw.json"
flock -u 7
wait "$wrapper_pid" || rc=$?
[[ $rc == 0 ]] || fail "a config the hook wrote while onboarding waited does not start the deadline" "rc=$rc"
grep -q '^finished$' "$TEST_LOG" || fail "a config the hook wrote while onboarding waited does not start the deadline" "wizard was cut short"
! grep -q '^terminated$' "$TEST_LOG" || fail "a config the hook wrote while onboarding waited does not start the deadline" "wizard was signalled"
pass "onboarding waits for a hook mid-write and starts from the config it left"

# ...while the same stale config being rewritten by this run does arm it.
: >"$TEST_LOG"
cat >"$tmp_dir/bin/openclaw" <<'SCRIPT'
#!/bin/bash
printf 'openclaw:%s\n' "$*" >>"$TEST_LOG"
case $1 in
onboard) touch "$HOME/.openclaw/openclaw.json"; trap 'echo terminated >>"$TEST_LOG"; exit 143' TERM; while :; do sleep 0.2; done ;;
dashboard) echo '{"ok":false}'; exit 1 ;;
esac
SCRIPT
chmod +x "$tmp_dir/bin/openclaw"
rc=0
"$ROOT/bin/omarchy-openclaw-onboard" </dev/null >/dev/null 2>&1 || rc=$?
[[ $rc == 1 ]] || fail "a config rewritten by this run arms the gateway deadline" "rc=$rc"
grep -q '^terminated$' "$TEST_LOG" || fail "a config rewritten by this run arms the gateway deadline" "wizard left running"
pass "a config rewritten by this run arms the gateway deadline"

# A gateway that answers while no config exists is not this run's: with no
# config `openclaw dashboard --json` still probes the default port, so a
# process left behind by something else (an earlier guided onboarding's
# foreground gateway) would otherwise end a wizard still at its first prompt.
: >"$TEST_LOG"
rm -rf "$HOME/.openclaw" "$unit" "$listener_file"
cat >"$tmp_dir/bin/openclaw" <<'SCRIPT'
#!/bin/bash
printf 'openclaw:%s\n' "$*" >>"$TEST_LOG"
case $1 in
onboard) trap 'echo terminated >>"$TEST_LOG"; exit 143' TERM; sleep 4; echo finished >>"$TEST_LOG"; exit 0 ;;
dashboard) echo '{"ok":true,"port":18789}' ;;
esac
SCRIPT
chmod +x "$tmp_dir/bin/openclaw"
rc=0
"$ROOT/bin/omarchy-openclaw-onboard" </dev/null >/dev/null 2>&1 || rc=$?
[[ $rc == 0 ]] || fail "an orphaned gateway answering with no config does not end the wizard" "rc=$rc"
grep -q '^finished$' "$TEST_LOG" || fail "an orphaned gateway answering with no config does not end the wizard" "wizard was cut short"
! grep -q '^terminated$' "$TEST_LOG" || fail "an orphaned gateway answering with no config does not end the wizard" "wizard was signalled"
pass "an orphaned gateway answering with no config does not end the wizard"

# And after setup, an orphan still bound to the port is not success even
# while the unit reports active: Type=simple counts it active from the fork,
# before it has discovered the port is taken. The port's owner has to be the
# unit's own main process. Here it never is, so the deadline ends the wait as
# a failure rather than opening the app on the orphan.
: >"$TEST_LOG"
rm -rf "$HOME/.openclaw" "$unit" "$listener_file"
echo 999 >"$listener_file"
cat >"$tmp_dir/bin/openclaw" <<'SCRIPT'
#!/bin/bash
printf 'openclaw:%s\n' "$*" >>"$TEST_LOG"
case $1 in
onboard) mkdir -p "$HOME/.openclaw" "${unit%/*}"; touch "$HOME/.openclaw/openclaw.json" "$unit"; trap 'echo terminated >>"$TEST_LOG"; exit 143' TERM; while :; do sleep 0.2; done ;;
dashboard) echo '{"ok":true,"port":18789}' ;;
esac
SCRIPT
chmod +x "$tmp_dir/bin/openclaw"
rc=0
"$ROOT/bin/omarchy-openclaw-onboard" </dev/null >/dev/null 2>&1 || rc=$?
[[ $rc == 1 ]] || fail "an orphan holding the port is not mistaken for the active unit" "rc=$rc"
grep -q '^terminated$' "$TEST_LOG" || fail "an orphan holding the port is not mistaken for the active unit" "wizard left running"
grep -q '^systemctl:--user show -p MainPID --value openclaw-gateway.service$' "$TEST_LOG" ||
  fail "an orphan holding the port is not mistaken for the active unit" "unit ownership never checked"
pass "an orphan holding the port is not mistaken for the active unit"
rm -f "$listener_file"
