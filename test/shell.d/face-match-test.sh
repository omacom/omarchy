#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-face-match"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
seclib="$test_tmp/security"
log="$test_tmp/calls.log"
output="$test_tmp/output"
copy="$test_tmp/face-match.sh"
mkdir -p "$stub_bin" "$seclib/howdy"

# The helper names Howdy's root-only tree, the system interpreter and the key
# service; retarget them in a scratch copy so stubs stand in. The hint and the
# face-only wait act only while the helper holds root, which the copy reads
# from TEST_EUID.
# shellcheck disable=SC2016 # the literal is what the helper's source says
root_gate='(( EUID == 0 )) && valid_account "${PAM_USER:-}"'
(( $(grep -Fxc 'security_lib=/usr/lib/security' "$helper") == 1 )) || fail "the helper names Howdy's tree once"
(( $(grep -Fxc 'lock_pam=/etc/pam.d/omarchy-lock-face' "$helper") == 1 )) || fail "the helper names the lock's PAM service once"
(( $(grep -Fxc 'face_key=/usr/bin/omarchy-face-key' "$helper") == 1 )) || fail "the helper names the key service once"
(( $(grep -Fxc 'howdy_config=/etc/howdy/config.ini' "$helper") == 1 )) || fail "the helper names Howdy's /etc configuration once"
(( $(grep -Fxc 'laptop_closed=/usr/bin/omarchy-hw-laptop-closed' "$helper") == 1 )) || fail "the helper names the lid predicate once"
(( $(grep -Fc "$root_gate" "$helper") == 2 )) || fail "the hint and the face-only wait act only as root"
# shellcheck disable=SC2016 # the literal is what the helper's source says
(( $(grep -Fc '/usr/bin/python3 "$compare"' "$helper") == 1 )) || fail "the helper runs compare.py with the system interpreter once"
sed -e "s|^security_lib=/usr/lib/security$|security_lib=$seclib|" -e "s|/usr/bin/python3|$stub_bin/python3|" \
  -e "s|^lock_pam=/etc/pam.d/omarchy-lock-face$|lock_pam=$test_tmp/omarchy-lock-face|" \
  -e "s|^face_key=/usr/bin/omarchy-face-key$|face_key=$stub_bin/omarchy-face-key|" \
  -e "s|^howdy_config=/etc/howdy/config.ini$|howdy_config=$test_tmp/howdy-etc/config.ini|" \
  -e "s|^laptop_closed=/usr/bin/omarchy-hw-laptop-closed$|laptop_closed=$stub_bin/omarchy-hw-laptop-closed|" \
  -e "s|(( EUID == 0 )) && valid_account|(( TEST_EUID == 0 )) \&\& valid_account|" "$helper" >"$copy"
(( $(grep -Fc '(( TEST_EUID == 0 )) && valid_account' "$copy") == 2 )) || fail "the copy reads root from TEST_EUID"
pass "the helper names its fixed paths, and the test drives a retargeted copy"

cat >"$stub_bin/python3" <<'SH'
#!/bin/bash
printf 'python3 %s\n' "$*" >>"$TEST_LOG"
exit "$TEST_STATUS"
SH
cat >"$stub_bin/logger" <<'SH'
#!/bin/bash
printf 'logger %s\n' "$*" >>"$TEST_LOG"
SH
# The key service: TEST_KEY=pressed releases a waiting prompt and lets the
# helper take the press; anything else does neither. TEST_LID_AFTER_KEY shuts
# the lid while the prompt waits.
lid="$test_tmp/lid-closed"
cat >"$stub_bin/omarchy-face-key" <<SH
#!/bin/bash
printf 'key %s\n' "\$*" >>"\$TEST_LOG"
[[ \${TEST_LID_AFTER_KEY:-} != 1 ]] || : >"$lid"
case \$1 in
  wait | take) [[ \${TEST_KEY:-} == pressed ]] ;;
  drop) exit 0 ;;
  *) exit 1 ;;
esac
SH
cat >"$stub_bin/omarchy-hw-laptop-closed" <<SH
#!/bin/bash
[[ -e $lid ]]
SH
chmod +x "$stub_bin"/*
: >"$seclib/howdy/compare.py"

# invoke <status> [user] [stdin]: sudo's or polkit's answer, after the Copilot
# key unless TEST_KEY says otherwise.
invoke() {
  local status=0

  : >"$log"
  printf '%s' "${3-}" | TEST_LOG="$log" TEST_STATUS="$1" TEST_KEY="${TEST_KEY-pressed}" PAM_USER="${2-alice}" \
    PATH="$stub_bin:/usr/bin:/bin" bash "$copy" >"$output" 2>&1 || status=$?
  return "$status"
}

# hint <euid> <key>
hint() {
  : >"$log"
  TEST_LOG="$log" TEST_EUID="$1" TEST_KEY="$2" PAM_USER=alice PATH="$stub_bin:/usr/bin:/bin" bash "$copy" --hint 2>&1
}

[[ $(hint 0 pressed) == "Press the Copilot key to use your face, or type your password." ]] ||
  fail "--hint names the key once the prompt waits for it" "$(cat "$log")"
grep -qE '^key wait --pam-pid [0-9]+ --user alice --detach --tty$' "$log" ||
  fail "the hint registers this conversation's prompt and leaves it waiting in the background" "$(cat "$log")"
[[ -z $(hint 0 none) ]] || fail "a prompt the key service did not take offers no face"
[[ -z $(hint 1000 pressed) && -z $(<"$log") ]] || fail "a hint line without root offers no face and registers nothing"
TEST_EUID=0 bash "$copy" --hint extra >/dev/null 2>&1 && fail "--hint takes nothing else"
pass "--hint registers the prompt with the key service and only then names the key"

invoke 0 alice "hunter2" && fail "a typed password declines the scan"
[[ -z $(<"$output") ]] || fail "a typed password prints nothing" "$(cat "$output")"
grep -qE '^key drop --pam-pid [0-9]+$' "$log" || fail "a typed password withdraws the prompt from the key service" "$(cat "$log")"
! grep -q '^python3\|^key take' "$log" || fail "a typed password never reaches the camera" "$(cat "$log")"
TEST_KEY=none invoke 0 alice "" && fail "an empty answer without the key declines the scan"
grep -qE '^key take --pam-pid [0-9]+$' "$log" || fail "an empty answer asks the key service for this prompt's press" "$(cat "$log")"
! grep -q '^python3' "$log" || fail "an empty answer without the key never reaches the camera" "$(cat "$log")"
[[ -z $(<"$output") ]] || fail "an empty answer without the key is just an empty password" "$(cat "$output")"
invoke 0 alice "" || fail "the key's empty answer consents"
grep -q '^python3' "$log" || fail "the key's empty answer runs the scan" "$(cat "$log")"
pass "typing a password keeps the camera dark; only the key's own empty answer starts the scan"

# wait_only <euid> <key> [PAM_USER]: the setup's face-only check, which asks
# for no password and waits for the key itself.
wait_only() {
  local status=0

  : >"$log"
  TEST_LOG="$log" TEST_STATUS=0 TEST_EUID="$1" TEST_KEY="$2" PAM_USER="${3-alice}" PATH="$stub_bin:/usr/bin:/bin" \
    bash "$copy" --wait </dev/null >"$output" 2>&1 || status=$?
  return "$status"
}

wait_only 0 pressed || fail "the face-only check scans once the key is pressed" "$(cat "$output" "$log")"
grep -qE '^key wait --pam-pid [0-9]+ --user alice$' "$log" ||
  fail "the face-only check waits for the key in the foreground, typing into no terminal" "$(cat "$log")"
grep -qxF "python3 $seclib/howdy/compare.py alice" "$log" || fail "the face-only check matches the PAM user's face" "$(cat "$log")"
[[ $(<"$output") == $'Scanning face…\nIdentified face as alice' ]] || fail "the face-only check tells the scan and the match" "$(cat "$output")"
wait_only 0 none && fail "the face-only check fails when its wait ends without the key"
! grep -q '^python3' "$log" || fail "the face-only check never scans without the key" "$(cat "$log")"
wait_only 1000 pressed && fail "the face-only check refuses without root"
[[ -z $(<"$log") ]] || fail "a face-only check without root registers nothing" "$(cat "$log")"
wait_only 0 pressed "" && fail "the face-only check refuses without a PAM user"
[[ -z $(<"$log") ]] || fail "a face-only check without a PAM user registers nothing" "$(cat "$log")"
TEST_EUID=0 PAM_USER=alice bash "$copy" --wait extra >/dev/null 2>&1 && fail "--wait takes nothing else"
pass "--wait, the setup's face-only check, waits for the key itself and asks for no password"

invoke 0 || fail "a match exits 0"
grep -qxF "python3 $seclib/howdy/compare.py alice" "$log" || fail "compare.py runs for the PAM user" "$(cat "$log")"
[[ $(<"$output") == $'Scanning face…\nIdentified face as alice' ]] || fail "the scan and the match are told on stdout for the PAM conversation" "$(cat "$output")"
grep -q 'logger.*Login approved for alice' "$log" || fail "a match is logged to auth" "$(cat "$log")"
pass "a matched face exits 0 and says so"

for case in "10:No face model known" "11:Face detection timeout reached" "13:Face detection image too dark" "99:Howdy failed with status 99"; do
  status=${case%%:*}
  message=${case#*:}
  invoke "$status" && fail "status $status fails"
  (( $? == status )) || fail "Howdy's status $status is passed through"
  [[ $(<"$output") == "Scanning face…"$'\n'"$message" ]] || fail "status $status is explained: $message" "$(cat "$output")"
done
invoke 12 && fail "an abort fails"
[[ $(<"$output") == "Scanning face…" ]] || fail "an abort stays silent like Howdy" "$(cat "$output")"
pass "Howdy's failure statuses pass through with Howdy's own messages"

for user in "" "." ".." "../root" "alice bob" "a/b"; do
  invoke 0 "$user" && fail "unsafe PAM_USER must fail: '$user'"
  ! grep -q '^python3' "$log" || fail "unsafe PAM_USER never reaches compare.py: '$user'" "$(cat "$log")"
done
pass "a missing or unsafe PAM_USER fails before Howdy runs"

# The privileged half reached through the sudoers grant: sudo's env_reset
# leaves SUDO_USER and no PAM_USER. The grant serves the lock screen alone.
invoke_elevated() {
  local status=0

  : >"$log"
  TEST_LOG="$log" TEST_STATUS="${TEST_STATUS:-0}" TEST_KEY="${TEST_KEY-pressed}" SUDO_USER=alice PATH="$stub_bin:/usr/bin:/bin" \
    env -u PAM_USER bash "$copy" </dev/null >"$output" 2>&1 || status=$?
  return "$status"
}

: >"$test_tmp/omarchy-lock-face"
invoke_elevated || fail "the grant scans while the lock screen uses the face" "$(cat "$output")"
grep -qE '^key wait --lock --pam-pid [0-9]+ --user alice$' "$log" || fail "the lock's scan waits for the key first" "$(cat "$log")"
grep -qxF "python3 $seclib/howdy/compare.py alice" "$log" || fail "the grant matches SUDO_USER's face" "$(cat "$log")"
[[ $(head -n1 "$output") == "Scanning face…" ]] || fail "the lock screen is told when the scan starts" "$(cat "$output")"
[[ $(tail -n1 "$log") =~ ^key\ scanned\ --lock\ --pam-pid\ [0-9]+\ --status\ 0$ ]] ||
  fail "a match is reported to the key service last, so it gives the key back at once" "$(cat "$log")"
TEST_STATUS=11 invoke_elevated && fail "a stranger's scan fails"
[[ $(tail -n1 "$log") =~ ^key\ scanned\ --lock\ --pam-pid\ [0-9]+\ --status\ 11$ ]] ||
  fail "a failed scan is reported with Howdy's status" "$(cat "$log")"
TEST_KEY=none invoke_elevated && fail "the lock's wait ending without the key fails"
! grep -q '^python3' "$log" || fail "the lock never scans without the key" "$(cat "$log")"
! grep -q '^key scanned' "$log" || fail "a wait that ended without the key started no scan to report" "$(cat "$log")"
rm "$test_tmp/omarchy-lock-face"
invoke_elevated && fail "the grant refuses while the lock screen does not use the face"
! grep -q '^python3' "$log" || fail "a refused grant never reaches compare.py" "$(cat "$log")"
grep -q 'lock screen' "$output" || fail "the refusal is explained" "$(cat "$output")"
invoke 0 alice || fail "sudo and polkit, which run the helper through pam_exec, scan without the lock service"
! grep -q '^key scanned' "$log" || fail "only the lock's scans are reported" "$(cat "$log")"
pass "the sudoers grant scans only while the lock screen uses the face"

# Howdy's own PAM module refuses before it scans while Howdy is disabled or
# the conversation comes over SSH. The helper takes its place, so it refuses
# then too, and whenever the lid is shut, the lock screen included: nothing
# registers, nothing waits, nothing scans.
# over_ssh <command...>: SSH_CONNECTION only in the helper's parent, since
# pam_exec builds the helper an environment of its own.
over_ssh() {
  SSH_CONNECTION="192.0.2.1 50000 192.0.2.2 22" bash -c 'env -u SSH_CONNECTION "$@"; exit $?' over-ssh "$@"
}
hint_over_ssh() {
  : >"$log"
  over_ssh env TEST_LOG="$log" TEST_EUID=0 TEST_KEY=pressed PAM_USER=alice PATH="$stub_bin:/usr/bin:/bin" bash "$copy" --hint 2>&1
}
# refused <description>: no path registers, waits for or scans a face.
refused() {
  [[ -z $(hint 0 pressed) && -z $(<"$log") ]] || fail "$1: the hint offers no face and registers nothing" "$(cat "$log")"
  invoke 0 alice "" && fail "$1: sudo's answer gets no scan"
  ! grep -q '^python3' "$log" || fail "$1: sudo's answer never reaches the camera" "$(cat "$log")"
  wait_only 0 pressed && fail "$1: the face-only check fails"
  ! grep -q '^key wait\|^python3' "$log" || fail "$1: the face-only check neither waits nor scans" "$(cat "$log")"
  : >"$test_tmp/omarchy-lock-face"
  invoke_elevated && fail "$1: the lock screen's check fails"
  ! grep -q '^key wait\|^python3' "$log" || fail "$1: the lock screen's check neither waits nor scans" "$(cat "$log")"
  rm "$test_tmp/omarchy-lock-face"
}

: >"$lid"
refused "with the lid shut"
rm "$lid"
: >"$test_tmp/omarchy-lock-face"
TEST_LID_AFTER_KEY=1 invoke_elevated && fail "a lid shut while the lock waited stops the scan"
grep -q '^key wait --lock' "$log" || fail "the lock waited with the lid open" "$(cat "$log")"
! grep -q '^python3' "$log" || fail "a lid shut while the lock waited never reaches the camera" "$(cat "$log")"
[[ $(<"$output") != *"Scanning face"* ]] || fail "a lid shut while the lock waited starts no scan" "$(cat "$output")"
grep -qE '^key scanned --lock --pam-pid [0-9]+ --status 1$' "$log" || fail "the scan the key would have started is reported as failed" "$(cat "$log")"
rm -f "$test_tmp/omarchy-lock-face" "$lid"
pass "with the lid shut, before the key or after it, no stack waits for or scans a face"

printf '[core]\ndisabled = true\n' >"$seclib/howdy/config.ini"
refused "with Howdy disabled"
printf '[video]\ndisabled = true\n[core]\n  disabled = False\n' >"$seclib/howdy/config.ini"
[[ -n $(hint 0 pressed) ]] || fail "only [core] disables Howdy" "$(cat "$log")"
mkdir -p "$test_tmp/howdy-etc"
printf '[core]\ndisabled = on\n' >"$test_tmp/howdy-etc/config.ini"
refused "with Howdy disabled in /etc/howdy"
rm -r "$test_tmp/howdy-etc"
pass "Howdy's disabled setting stops every stack, read from the configuration Howdy uses"

rm "$seclib/howdy/config.ini"
[[ -n $(hint 0 pressed) ]] || fail "outside SSH the hint offers the face" "$(cat "$log")"
[[ -z $(hint_over_ssh) && -z $(<"$log") ]] || fail "a sudo over SSH offers no face and registers nothing, as Howdy ignores SSH by default" "$(cat "$log")"
: >"$log"
printf '' | over_ssh env TEST_LOG="$log" TEST_STATUS=0 TEST_KEY=pressed PAM_USER=alice PATH="$stub_bin:/usr/bin:/bin" \
  bash "$copy" >"$output" 2>&1 && fail "a sudo over SSH gets no scan"
! grep -q '^python3' "$log" || fail "a sudo over SSH never reaches the camera" "$(cat "$log")"
printf '[core]\nignore_ssh = false\n' >"$seclib/howdy/config.ini"
[[ -n $(hint_over_ssh) ]] || fail "with ignore_ssh off, a sudo over SSH offers the face" "$(cat "$log")"
rm "$seclib/howdy/config.ini"
pass "a conversation over SSH gets no face while Howdy ignores SSH"

# Without a readable compare.py the helper elevates instead; that phase has its
# own suite (face-match-sudoers-test.sh). A stub sudo keeps it out of here.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_LOG"
exit 1
SH
chmod +x "$stub_bin/sudo"
rm "$seclib/howdy/compare.py"
invoke 0 "$(id -un)" && fail "a missing compare.py fails"
! grep -q '^python3' "$log" || fail "nothing runs without compare.py" "$(cat "$log")"
grep -q '^sudo' "$log" || fail "the session user's phase hands over to sudo" "$(cat "$log")"
pass "an unreadable Howdy tree hands over to the privileged half instead of running"
