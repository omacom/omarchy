#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT

mapped_root="$test_tmp/omarchy"
stub_bin="$test_tmp/bin"
event_log="$test_tmp/events"
revoke_count="$test_tmp/revokes"
mkdir -p "$mapped_root/bin" "$stub_bin"
: >"$event_log"
: >"$revoke_count"

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
case ${1:-} in
  -h)
    if [[ ${TEST_SUDO_NO_N:-0} == 1 ]]; then
      echo 'usage: sudo [-ABbEHknPS] command'
    else
      echo 'usage: sudo [-ABbEHkNnPS] command'
    fi
    exit 0
    ;;
  -k)
    count=$(wc -l <"$TEST_REVOKE_COUNT")
    printf 'revoke\n' >>"$TEST_REVOKE_COUNT"
    printf 'SUDO:revoke\n' >>"$TEST_EVENT_LOG"
    if [[ ${TEST_FINAL_REVOKE_FAIL:-0} == 1 ]] && (( count >= 1 )); then exit 91; fi
    exit 0
    ;;
esac
[[ ${1:-} == -N && ${2:-} == -- ]] || exit 92
printf 'SUDO:transaction\n' >>"$TEST_EVENT_LOG"
[[ ${TEST_AUTH_FAIL:-0} != 1 ]] || exit 1
shift 2
exec "$@"
STUB

cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash
if [[ ${1:-} == -Slq ]]; then
  [[ ${TEST_QUERY_FAIL:-0} != 1 ]] || exit 41
  printf 'safe-package\n'
  exit 0
fi
printf 'PACMAN:%s\n' "$*" >>"$TEST_EVENT_LOG"
[[ ${TEST_TRANSACTION_FAIL:-0} != 1 ]] || exit 77
STUB

cat >"$stub_bin/yay" <<'STUB'
#!/bin/bash
[[ ${1:-} == -Qqe ]] || exit 93
[[ ${TEST_QUERY_FAIL:-0} != 1 ]] || exit 41
printf 'safe-package\n'
STUB

cat >"$stub_bin/fzf" <<'STUB'
#!/bin/bash
cat >/dev/null
printf 'FZF\n' >>"$TEST_EVENT_LOG"
case ${TEST_PICKER_RESULT:-select} in
  select) printf '%s\n' "${TEST_SELECTION:-safe-package}" ;;
  empty) ;;
  nomatch) printf 'ignored-partial-output\n'; exit 1 ;;
  cancel) exit 130 ;;
  error) exit 42 ;;
esac
STUB

cat >"$stub_bin/omarchy-show-done" <<'STUB'
#!/bin/bash
printf 'DONE\n' >>"$TEST_EVENT_LOG"
STUB
chmod 0755 "$stub_bin"/*

sed "s#/usr/bin/sudo#$stub_bin/sudo#g" \
  "$ROOT/bin/omarchy-security-functions" >"$mapped_root/bin/omarchy-security-functions"
for command in install remove; do
  sed \
    -e "s#/usr/bin/sudo#$stub_bin/sudo#g" \
    -e "s#/usr/bin/pacman#$stub_bin/pacman#g" \
    -e "s#/usr/bin/yay#$stub_bin/yay#g" \
    -e "s#/usr/bin/fzf#$stub_bin/fzf#g" \
    -e "s#/usr/bin/omarchy-show-done#$stub_bin/omarchy-show-done#g" \
    "$ROOT/bin/omarchy-pkg-$command" >"$mapped_root/bin/omarchy-pkg-$command"
done
chmod 0755 "$mapped_root/bin"/*

run_picker() {
  local command=$1 expected=$2
  shift 2
  : >"$event_log"
  : >"$revoke_count"
  set +e
  env -i HOME="$test_tmp/home" OMARCHY_PATH="$mapped_root" \
    TEST_EVENT_LOG="$event_log" TEST_REVOKE_COUNT="$revoke_count" \
    "$@" "$mapped_root/bin/omarchy-pkg-$command" >/dev/null 2>&1
  status=$?
  set -e
  (( status == expected )) || fail "$command returned $status instead of $expected"
}

for command in install remove; do
  run_picker "$command" 0 TEST_PICKER_RESULT=select
  [[ $(grep -c '^SUDO:transaction$' "$event_log") == 1 ]] || fail "$command did not use one fixed transaction"
  if [[ $command == install ]]; then
    grep -Fxq 'PACMAN:-S --noconfirm -- safe-package' "$event_log" || fail "$command changed its fixed pacman transaction"
  else
    grep -Fxq 'PACMAN:-Rns --noconfirm -- safe-package' "$event_log" || fail "$command changed its fixed pacman transaction"
  fi
  [[ $(grep -c '^SUDO:revoke$' "$event_log") == 2 ]] || fail "$command did not revoke before and after work"

  run_picker "$command" 0 TEST_PICKER_RESULT=empty
  ! grep -q '^SUDO:transaction$' "$event_log" || fail "$command authenticated for an empty selection"
  run_picker "$command" 0 TEST_PICKER_RESULT=nomatch
  ! grep -q '^SUDO:transaction$' "$event_log" || fail "$command authenticated after no match"
  run_picker "$command" 0 TEST_PICKER_RESULT=cancel
  ! grep -q '^SUDO:transaction$' "$event_log" || fail "$command authenticated after Esc"

  run_picker "$command" 41 TEST_QUERY_FAIL=1
  run_picker "$command" 41 TEST_QUERY_FAIL=1 TEST_PICKER_RESULT=cancel
  ! grep -q '^FZF$' "$event_log" || fail "$command masked a query failure with picker cancellation"
  run_picker "$command" 42 TEST_PICKER_RESULT=error
  run_picker "$command" 1 TEST_SUDO_NO_N=1
  ! grep -q '^FZF$' "$event_log" || fail "$command reached picker without no-update sudo support"
  run_picker "$command" 2 TEST_SELECTION=--config
  ! grep -q '^SUDO:transaction$' "$event_log" || fail "$command authenticated an invalid selection"
  run_picker "$command" 1 TEST_AUTH_FAIL=1
  run_picker "$command" 77 TEST_TRANSACTION_FAIL=1
  run_picker "$command" 1 TEST_FINAL_REVOKE_FAIL=1
done
pass "package pickers distinguish cancellation and failures around one fixed transaction"

startup_marker="$test_tmp/startup-marker"
cat >"$test_tmp/bash-env" <<EOF
: >"$startup_marker"
EOF
for command in install remove; do
  run_picker "$command" 0 BASH_ENV="$test_tmp/bash-env" TEST_PICKER_RESULT=empty
  [[ ! -e $startup_marker ]] || fail "$command picker executed inherited Bash startup code"
done
pass "package picker enters through protected Bash before discovery"

for command in install remove; do
  : >"$event_log"
  set +e
  env -i HOME="$test_tmp/home" OMARCHY_PATH="$mapped_root" \
    TEST_EVENT_LOG="$event_log" TEST_REVOKE_COUNT="$revoke_count" \
    /usr/bin/bash "$mapped_root/bin/omarchy-pkg-$command" -p >/dev/null 2>&1
  status=$?
  set -e
  (( status == 126 )) || fail "$command accepted an ordinary Bash launch with a decoy -p argument"
  [[ ! -s $event_log ]] || fail "$command decoy -p launch reached discovery or sudo"
done
pass "package picker rejects ordinary Bash with a decoy privileged-mode argument"

for command in install remove; do
  : >"$event_log"
  set +e
  env -i HOME="$test_tmp/home" OMARCHY_PATH="$test_tmp/wrong-root" \
    TEST_EVENT_LOG="$event_log" TEST_REVOKE_COUNT="$revoke_count" \
    "$mapped_root/bin/omarchy-pkg-$command" >/dev/null 2>&1
  status=$?
  set -e
  (( status != 0 )) || fail "$command picker accepted a mismatched source root"
  [[ ! -s $event_log ]] || fail "$command mismatched source root reached discovery or sudo"
done
pass "package picker rejects a mismatched source root before work"
