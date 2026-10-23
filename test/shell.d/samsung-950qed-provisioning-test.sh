#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Root ignores OMARCHY_IMAGE_ROOT. Never run the provisioner on the host root.
if (( EUID == 0 )); then
  skip "root ignores fixture image paths; skipping clickpad provisioning"
  exit 0
fi

umask 022
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
fixture="$test_tmp/omarchy"
image="$test_tmp/image"
input="$test_tmp/input"
mkdir -p "$test_tmp/bin" "$test_tmp/dmi" "$input" \
  "$fixture/install/helpers" "$fixture/install/hardware/samsung" \
  "$fixture/default/udev" "$fixture/bin" "$fixture/migrations" \
  "$image/var/lib/omarchy/image"
cp "$ROOT/install/helpers/"{logging,image-target}.sh "$fixture/install/helpers/"
cp "$ROOT/default/udev/samsung-950qed-clickpad.rules" "$fixture/default/udev/"

# Execute the actual provisioner, leaf, matcher and migration; redirect only
# physical reads and the installed rule. No real privilege or input operation.
sed -e "s|/sys/class/dmi/id|$test_tmp/dmi|g" \
  -e "s|/sys/class/input|$input|g" \
  -e "s|/etc/udev/rules.d|$image/etc/udev/rules.d|g" \
  "$ROOT/install/hardware/samsung/fix-950qed-clickpad.sh" >"$fixture/install/hardware/samsung/fix-950qed-clickpad.sh"
sed "s|/sys/class/dmi/id|$test_tmp/dmi|g" \
  "$ROOT/bin/omarchy-hw-match" >"$fixture/bin/omarchy-hw-match"
sed -e "s|/sys/class/dmi/id|$test_tmp/dmi|g" \
  -e "s|/etc/udev/rules.d|$image/etc/udev/rules.d|g" \
  "$ROOT/migrations/1791965814.sh" >"$fixture/migrations/1791965814.sh"
cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
[[ $1 != "install" || ! -e $REFUSE_INSTALL ]] || exit 42
"$@"
SH
cat >"$test_tmp/bin/udevadm" <<'SH'
#!/bin/bash
printf 'udevadm %s\n' "$*" >>"$TEST_CALLS"
[[ ! -e $REFUSE_UDEV || $(cat "$REFUSE_UDEV") != "$1" ]] || exit 43
if [[ $1 == "trigger" ]]; then
  [[ $2 == "--action=change" && $# == 3 ]] || exit 44
  [[ $(cat "$3/device/name") == "ZNT0001:00 14E5:650E Mouse" ]] || exit 45
  printf 'LIBINPUT_IGNORE_DEVICE=1\n' >"$3/udev-properties"
elif [[ $1 == "settle" ]]; then
  touch "$SETTLED"
fi
SH
cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$TEST_CALLS"
SH
chmod +x "$test_tmp/bin/"* "$fixture/bin/omarchy-hw-match"
export OMARCHY_PATH="$fixture" OMARCHY_IMAGE_ROOT="$image"
export PATH="$test_tmp/bin:$fixture/bin:$PATH"
export TEST_CALLS="$test_tmp/calls" REFUSE_UDEV="$test_tmp/refuse-udev"
export REFUSE_INSTALL="$test_tmp/refuse-install" SETTLED="$test_tmp/settled"
unset OMARCHY_IMAGE_DEFERRED_HARDWARE

printf '%s\n' "SAMSUNG ELECTRONICS CO., LTD." >"$test_tmp/dmi/sys_vendor"
printf '950QED\n' >"$test_tmp/dmi/product_name"
printf '950QED\n' >"$test_tmp/dmi/product_family"
for node in event1 event4; do
  mkdir -p "$input/$node/device"
  printf 'ZNT0001:00 14E5:650E Mouse\n' >"$input/$node/device/name"
done
mkdir -p "$input/event2/device" "$input/event3/device"
printf 'ZNT0001:00 14E5:650E Touchpad\n' >"$input/event2/device/name"
printf 'Other Mouse\n' >"$input/event3/device/name"

queue="$image/var/lib/omarchy/image/deferred-steps"
rule="$image/etc/udev/rules.d/61-znt-clickpad-mouse.rules"
leaf=install/hardware/samsung/fix-950qed-clickpad.sh
reset_run() {
  rm -f "$TEST_CALLS" "$REFUSE_UDEV" "$REFUSE_INSTALL" "$SETTLED" "$input/"*/udev-properties
  printf '%s\n' "$leaf" >"$queue"
  chmod 0644 "$queue"
}
first_boot() {
  "$ROOT/bin/omarchy-provision-hardware" >"$test_tmp/stdout" 2>"$test_tmp/stderr"
}

reset_run
first_boot || fail "the real first-boot provisioner succeeds" "$(cat "$test_tmp/stderr")"
expected=$(printf 'udevadm control --reload-rules\nudevadm trigger --action=change %s/event1\nudevadm trigger --action=change %s/event4\nudevadm settle' "$input" "$input")
[[ $(cat "$TEST_CALLS") == "$expected" && -f $SETTLED && ! -e $queue ]] ||
  fail "first boot reloads, refreshes only both exact companions, waits, then clears its queue"
cmp -s "$rule" "$ROOT/default/udev/samsung-950qed-clickpad.rules" || fail "first boot installs the intended rule"
[[ -f $input/event1/udev-properties && -f $input/event4/udev-properties &&
  ! -e $input/event2/udev-properties && ! -e $input/event3/udev-properties ]] ||
  fail "the real Touchpad and unrelated Mouse never receive a refresh"
pass "real image first boot refreshes only the exact existing companion nodes before completing"

# Every refresh failure leaves the step queued, even though its rule is on disk.
for operation in control trigger settle; do
  reset_run
  printf '%s\n' "$operation" >"$REFUSE_UDEV"
  status=0
  first_boot || status=$?
  (( status == 75 )) && [[ $(cat "$queue") == "$leaf" && -f $rule && ! -e $SETTLED ]] ||
    fail "$operation failure propagates and stays pending" "status=$status"
  [[ $(tail -1 "$TEST_CALLS") == "udevadm $operation"* ]] || fail "no refresh step follows a failed $operation"
  rm "$REFUSE_UDEV"
  : >"$TEST_CALLS"
  first_boot || fail "the next boot retries failed $operation"
  [[ $(cat "$TEST_CALLS") == "$expected" && -f $SETTLED && ! -e $queue ]] ||
    fail "retry completes the refresh after $operation failure"
  pass "$operation failure retains deferred work and the next boot retries the exact-node refresh"
done

reset_run
touch "$REFUSE_INSTALL"
status=0
first_boot || status=$?
(( status == 75 )) && [[ $(cat "$queue") == "$leaf" && ! -e $TEST_CALLS ]] ||
  fail "denied rule installation stays pending without a udev refresh"
pass "first boot never refreshes input after an unsuccessful install"

reset_run
rm -f "$rule"
bash -euo pipefail -c 'source "$1"' bash "$fixture/$leaf"
[[ -f $rule && ! -e $TEST_CALLS && ! -e $SETTLED ]] || fail "normal installation never triggers existing devices"
pass "normal hardware installation keeps the reboot/coldplug boundary"

rm "$rule"
bash -euo pipefail "$fixture/migrations/1791965814.sh" >/dev/null
[[ $(cat "$TEST_CALLS") == "state set reboot-required" && ! -e $SETTLED ]] ||
  fail "active-session migration requests a reboot without udev operations"
: >"$TEST_CALLS"
bash -euo pipefail "$fixture/migrations/1791965814.sh" >/dev/null
[[ ! -s $TEST_CALLS ]] || fail "another user makes no privileged refresh or reboot request"
pass "active-session and subsequent-user migrations preserve their existing behavior"

reset_run
printf 'Other vendor\n' >"$test_tmp/dmi/sys_vendor"
first_boot || fail "another vendor's first boot succeeds without this fix"
[[ ! -s $TEST_CALLS && ! -e $SETTLED && ! -e $queue ]] || fail "other vendors get no udev operations"
pass "deferred first boot also retains the Samsung detection gate"
