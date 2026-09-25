#!/bin/bash
# Full regression suite for the omarchy-thunderbolt PR fixes (T1-T7)
REPO=/opt/data/dev/omarchy-pr12510
cd "$REPO" || exit 1
sed 's|/sys/bus/thunderbolt/devices|/tmp/tbtest/sysfs/devices|' bin/omarchy-thunderbolt-check > /tmp/tbtest/check-test
sed 's|/sys/bus/thunderbolt/devices|/tmp/tbtest/sysfs/devices|' bin/omarchy-thunderbolt > /tmp/tbtest/menu-test
chmod +x /tmp/tbtest/check-test /tmp/tbtest/menu-test

export PATH=/tmp/tbtest/fakebin:$PATH
export HOME=/tmp/tbtest/home
pass=0; fail=0
check() { local name="$1"; shift; if eval "$@"; then echo "PASS: $name"; pass=$((pass+1)); else echo "FAIL: $name"; fail=$((fail+1)); fi }

reset_device() {
  rm -rf /tmp/tbtest/sysfs/devices/01-03 /tmp/tbtest/sysfs/devices/09-99
  mkdir -p /tmp/tbtest/sysfs/devices/01-03
  echo 0 > /tmp/tbtest/sysfs/devices/01-03/authorized
  echo "04:22:05:01:00:00" > /tmp/tbtest/sysfs/devices/01-03/unique_id
  echo "CalDigit TS4" > /tmp/tbtest/sysfs/devices/01-03/device_name
  echo "CalDigit" > /tmp/tbtest/sysfs/devices/01-03/vendor_name
  echo 4 > /tmp/tbtest/sysfs/devices/01-03/generation
}
reset_world() { rm -rf "${HOME:?}/.local/state/omarchy"; rm -f /tmp/tbtest/notify.log; }

reset_device; reset_world
/tmp/tbtest/check-test >/dev/null 2>&1
check "T1 toast fires on first unauthorized connect" "grep -q 'NOTIFY: sent toast' /tmp/tbtest/notify.log"
check "T1b exec words passed separately" "grep -q 'NOTIFY-EXEC: omarchy-launch-floating-terminal-with-presentation omarchy-thunderbolt' /tmp/tbtest/notify.log"
check "T1c state records device" "grep -q '04:22:05:01:00:00' '$HOME/.local/state/omarchy/thunderbolt/notified'"

rm -f /tmp/tbtest/notify.log
/tmp/tbtest/check-test >/dev/null 2>&1
check "T2 no duplicate toast while connected" "test ! -e /tmp/tbtest/notify.log"

rm -rf /tmp/tbtest/sysfs/devices/01-03
/tmp/tbtest/check-test >/dev/null 2>&1
check "T3 prune removes id after unplug" "test ! -s '$HOME/.local/state/omarchy/thunderbolt/notified'"

reset_device; rm -f /tmp/tbtest/notify.log
/tmp/tbtest/check-test >/dev/null 2>&1
check "T4 toast fires again on replug" "grep -q 'NOTIFY: sent toast' /tmp/tbtest/notify.log"

# T5: authorized=2 (stored key) => menu reports success
echo 0 > /tmp/tbtest/sysfs/devices/01-03/authorized
rm -f /tmp/tbtest/notify.log
/tmp/tbtest/menu-test >/dev/null 2>&1
check "T5 authorized=2 reports success" "grep -q 'is authorized for this system' /tmp/tbtest/notify.log"
check "T5b no false failure" "test \"$(grep -c 'Failed to authorize' /tmp/tbtest/notify.log)\" -eq 0"

# T6: nameless device (no device_name file) -> still notifies
rm -rf /tmp/tbtest/sysfs/devices/09-99
mkdir -p /tmp/tbtest/sysfs/devices/09-99
echo 0 > /tmp/tbtest/sysfs/devices/09-99/authorized
echo "aa:bb:cc:dd:ee:ff" > /tmp/tbtest/sysfs/devices/09-99/unique_id
reset_world
/tmp/tbtest/check-test >/dev/null 2>&1
check "T6 nameless device notifies (unique_id fallback)" "grep -q 'aa:bb:cc:dd:ee:ff' /tmp/tbtest/notify.log"
check "T6b nameless device recorded" "grep -q 'aa:bb:cc:dd:ee:ff' '$HOME/.local/state/omarchy/thunderbolt/notified'"

# T7: no thunderbolt bus -> quiet exit 0
mv /tmp/tbtest/sysfs/devices /tmp/tbtest/sysfs/devices.bak
out=$(/tmp/tbtest/check-test 2>&1); rc=$?
check "T7 no-thunderbolt exits 0 quietly" "test $rc -eq 0 -a -z \"$out\""
mv /tmp/tbtest/sysfs/devices.bak /tmp/tbtest/sysfs/devices

echo
echo "RESULT: $pass passed, $fail failed"
