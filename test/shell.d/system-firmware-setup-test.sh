#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls.log"
mkdir -p "$mock_bin"

# CAN_ANSWER is what logind returns for CanRebootToFirmwareSetup,
# FAIL_SET_TRUE makes it refuse SetRebootToFirmwareSetup the way firmware
# without support does, and FAIL_SET_FALSE makes clearing the flag fail.
cat >"$mock_bin/busctl" <<'SH'
#!/bin/bash

printf 'busctl %s\n' "$*" >>"$CALL_LOG"
[[ $1 == --* ]] && shift

case $5 in
CanRebootToFirmwareSetup)
  [[ ${FAIL_CAN:-false} == "true" ]] && exit 1
  printf 's "%s"\n' "$CAN_ANSWER"
  ;;
SetRebootToFirmwareSetup)
  if [[ $7 == "true" && ${FAIL_SET_TRUE:-false} == "true" ]]; then
    echo "Call failed: Firmware does not support boot into firmware." >&2
    exit 1
  fi
  if [[ $7 == "false" && ${FAIL_SET_FALSE:-false} == "true" ]]; then
    exit 1
  fi
  ;;
esac
SH

cat >"$mock_bin/omarchy-system-reboot" <<'SH'
#!/bin/bash

echo omarchy-system-reboot >>"$CALL_LOG"
[[ ${FAIL_REBOOT:-false} == "true" ]] && exit 1
exit 0
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash

printf 'omarchy-notification-send %s\n' "$*" >>"$CALL_LOG"
SH
chmod +x "$mock_bin"/*

login1="org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager"

hw_firmware_setup() {
  : >"$call_log"
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-hw-firmware-setup"
}

for answer in yes challenge; do
  CAN_ANSWER=$answer hw_firmware_setup || fail "firmware setup is available when logind answers $answer"
  pass "firmware setup is available when logind answers $answer"
done

for answer in no na; do
  if CAN_ANSWER=$answer hw_firmware_setup; then
    fail "firmware setup is unavailable when logind answers $answer"
  fi
  pass "firmware setup is unavailable when logind answers $answer"
done

if FAIL_CAN=true hw_firmware_setup; then
  fail "firmware setup is unavailable when logind cannot be asked"
fi
pass "firmware setup is unavailable when logind cannot be asked"

run_firmware_setup() {
  : >"$call_log"
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-firmware-setup"
}

run_firmware_setup || fail "firmware setup reboot succeeds"
diff -u - "$call_log" <<EOF || fail "firmware setup is requested before the reboot closes any window"
busctl --allow-interactive-authorization=yes call $login1 SetRebootToFirmwareSetup b true
omarchy-system-reboot
EOF
pass "firmware setup is requested before the reboot closes any window"

if FAIL_SET_TRUE=true run_firmware_setup; then
  fail "firmware setup reboot aborts when the firmware refuses it"
fi
if grep -q '^omarchy-system-reboot' "$call_log"; then
  fail "firmware setup reboot leaves windows alone when the firmware refuses it" "$(cat "$call_log")"
fi
grep -q '^omarchy-notification-send -u critical .*Firmware does not support boot into firmware' "$call_log" || fail "firmware setup refusal is reported with logind's reason" "$(cat "$call_log")"
pass "firmware setup refusal leaves the session untouched and says why"

if FAIL_REBOOT=true run_firmware_setup; then
  fail "firmware setup reboot fails when the reboot cannot be scheduled"
fi
diff -u - "$call_log" <<EOF || fail "firmware setup is withdrawn and reported when the reboot cannot be scheduled"
busctl --allow-interactive-authorization=yes call $login1 SetRebootToFirmwareSetup b true
omarchy-system-reboot
busctl --allow-interactive-authorization=yes call $login1 SetRebootToFirmwareSetup b false
omarchy-notification-send -u critical Couldn't reboot into firmware setup The reboot couldn't be scheduled.
EOF
pass "firmware setup is withdrawn and reported when the reboot cannot be scheduled"

if FAIL_REBOOT=true FAIL_SET_FALSE=true run_firmware_setup; then
  fail "firmware setup reboot fails when neither the reboot nor the withdrawal succeeds"
fi
grep -q '^omarchy-notification-send -u critical .*next reboot will open firmware setup' "$call_log" || fail "firmware setup warns that the flag is still set" "$(cat "$call_log")"
pass "firmware setup warns when the flag cannot be withdrawn"
