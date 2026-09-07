#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT

stub_bin="$test_root/bin"
calls="$test_root/calls"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf 'package' >>"$CALLS"
printf '\t%s' "$@" >>"$CALLS"
printf '\n' >>"$CALLS"
STUB

cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
if [[ $1 == "show" && $2 == "-p" && $3 == "ActiveState" && $4 == "--value" && $5 == "omarchy-t1bridge-import.service" ]]; then
  if [[ ${IMPORT_ACTIVE:-0} == 1 ]]; then
    echo activating
  else
    echo inactive
  fi
  exit 0
fi
printf 'systemctl' >>"$CALLS"
printf '\t%s' "$@" >>"$CALLS"
printf '\n' >>"$CALLS"
STUB

cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash
if [[ $1 == "-Q" ]]; then
  exit 1
fi
if [[ $1 == "-Qq" ]]; then
  if [[ ${CONFLICT_PACKAGE:-} == "$2" ]]; then
    printf '%s\n' "$2"
    exit 0
  fi
  exit 1
fi
if [[ $1 == "-Si" && ( $2 == "libfprint-t1bridge" || $2 == "fprintd-t1bridge" ) ]]; then
  exit 0
fi
printf 'pacman' >>"$CALLS"
printf '\t%s' "$@" >>"$CALLS"
printf '\n' >>"$CALLS"
STUB

cat >"$stub_bin/ufw" <<'STUB'
#!/bin/bash
printf 'ufw' >>"$CALLS"
printf '\t%s' "$@" >>"$CALLS"
printf '\n' >>"$CALLS"
STUB

chmod +x "$stub_bin"/*
export CALLS="$calls"

run_hardware_leaf() {
  local model=$1 sandbox="$test_root/hardware-${1//,/-}" script
  mkdir -p "$sandbox/dmi" "$sandbox/etc/systemd/system" "$sandbox/etc/systemd/user" "$sandbox/var/lib/omarchy"
  printf '%s\n' "$model" >"$sandbox/dmi/product_name"
  printf '%s\n' "${TEST_VENDOR:-Apple Inc.}" >"$sandbox/dmi/sys_vendor"
  sed \
    -e "s|/var/lib/dkms/|$sandbox/var/lib/dkms/|g" \
    -e "s|/etc/|$sandbox/etc/|g" \
    -e "s|/usr/lib/|$sandbox/usr/lib/|g" \
    "$ROOT/install/hardware/apple/t1-preflight.sh" >"$sandbox/t1-preflight.sh"
  if [[ -n ${CONFLICT_FILE:-} ]]; then
    mkdir -p "$(dirname "$sandbox/$CONFLICT_FILE")"
    touch "$sandbox/$CONFLICT_FILE"
  fi
  script="$sandbox/t1.sh"
  sed \
    -e "s|/sys/class/dmi/id/product_name|$sandbox/dmi/product_name|g" \
    -e "s|/sys/class/dmi/id/sys_vendor|$sandbox/dmi/sys_vendor|g" \
    -e "s|\$OMARCHY_INSTALL/hardware/apple/t1-preflight.sh|$sandbox/t1-preflight.sh|g" \
    -e "s|/var/lib/omarchy|$sandbox/var/lib/omarchy|g" \
    -e "s|/etc/systemd/system|$sandbox/etc/systemd/system|g" \
    -e "s|/etc/systemd/user|$sandbox/etc/systemd/user|g" \
    -e "s|/etc/systemd/network|$sandbox/etc/systemd/network|g" \
    -e 's|install -d -m 0755 -o root -g root|install -d -m 0755|' \
    "$ROOT/install/hardware/apple/t1.sh" >"$script"
  PATH="$stub_bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_INSTALL="$ROOT/install" \
    bash -euo pipefail -c 'source "$1"' bash "$script" >/dev/null || return 1
  printf '%s\n' "$sandbox"
}

for model in MacBookPro13,2 MacBookPro13,3 MacBookPro14,2 MacBookPro14,3; do
  : >"$calls"
  sandbox=$(run_hardware_leaf "$model")
  [[ $(<"$calls") == $'package\tlinux-headers\tt1bridge-dkms\tt1bridge\tlibfprint-t1bridge\tfprintd-t1bridge\nufw\tallow\tin\ton\tt1bridge0\tproto\ttcp\tfrom\tfe80::aede:48ff:fe33:4455\tto\tany\tport\t61500\tcomment\tomarchy-t1bridge\nsystemctl\tdaemon-reload' ]] ||
    fail "T1 hardware setup installs the core and standard fingerprint packages" "$(<"$calls")"
  grep -qxF t1bridge "$sandbox/var/lib/omarchy/provisioning/groups" ||
    fail "T1 hardware setup records renderer socket membership"
  [[ -f $sandbox/etc/systemd/user/t1-touchbar.service.d/20-omarchy-desktop-provider.conf ]] ||
    fail "T1 hardware setup installs the desktop-provider drop-in"
  link_override="$sandbox/etc/systemd/network/50-t1bridge-ncm.link.d/20-omarchy-private-link.conf"
  [[ $(<"$link_override") == $'[Link]\nNamePolicy=\nName=t1bridge0' ]] ||
    fail "T1 link naming and the scoped firewall rule must agree"
  [[ $(<"$sandbox/var/lib/omarchy/t1bridge-import/enabled") == "enabled" ]] ||
    fail "T1 hardware setup arms the automatic importer"
  [[ -f $sandbox/etc/systemd/system/omarchy-t1bridge-import.service ]] ||
    fail "T1 hardware setup installs its one-shot wrapper"
  [[ -f $sandbox/etc/systemd/system/t1-xart-storage@.service.d/20-omarchy-machine-data-import.conf ]] ||
    fail "T1 hardware setup orders import after private-link storage"
done
pass "all four Touch Bar T1 models arm the same first-boot handoff"

for package in linux-headers t1bridge-dkms t1bridge libfprint-t1bridge fprintd-t1bridge; do
  grep -qxF "$package" "$ROOT/install/omarchy-other.packages" ||
    fail "T1 package $package must be available in the ISO's offline mirror"
done
pass "the ISO package list includes the complete T1 cohort and kernel headers"

for model in MacBookPro13,1 MacBookPro14,1 MacBookPro15,1 ThinkPadT14; do
  : >"$calls"
  sandbox=$(run_hardware_leaf "$model")
  [[ ! -s $calls ]] || fail "non-T1 hardware does not install or configure T1Bridge" "$(<"$calls")"
  [[ ! -e $sandbox/var/lib/omarchy/t1bridge-import/enabled ]] ||
    fail "non-T1 hardware does not arm the importer"
done
pass "hardware detection excludes non-Touch-Bar and non-T1 models"

: >"$calls"
TEST_VENDOR="Other vendor" run_hardware_leaf MacBookPro13,3 >/dev/null
[[ ! -s $calls ]] || fail "T1 setup requires the Apple vendor"
pass "matching model names from other vendors do not trigger installation"

for package in libfprint libfprint-git fprintd apple-ib-drv-dkms apple-ib-drv-git apple-bce-dkms apple-bce-dkms-git; do
  : >"$calls"
  if CONFLICT_PACKAGE="$package" run_hardware_leaf MacBookPro13,3 2>"$test_root/conflict-error"; then
    fail "existing $package must stop unattended setup"
  fi
  [[ ! -s $calls ]] || fail "a package conflict stops before mutations"
done
pass "existing fingerprint and legacy driver packages are preserved"

for path in var/lib/dkms/t1-touchbar-display etc/udev/rules.d/99-ibridge.rules etc/systemd/system/touchbar-rs.service usr/lib/systemd/user/dfrd.service; do
  : >"$calls"
  if CONFLICT_FILE="$path" run_hardware_leaf MacBookPro13,3 2>"$test_root/conflict-error"; then
    fail "local competing stack must stop unattended setup"
  fi
  [[ ! -s $calls ]] || fail "a local stack conflict stops before mutations"
  rm "$test_root/hardware-MacBookPro13-3/$path"
done
pass "local driver, rule, and service installations stop setup before mutations"

rollback_root="$test_root/hardware-MacBookPro13-3"
mkdir -p "$rollback_root/etc/systemd/system" "$rollback_root/etc/udev/rules.d"
ln -s /dev/null "$rollback_root/etc/systemd/system/dfrd.service"
touch "$rollback_root/etc/udev/rules.d/99-ibridge.rules.pre-dfrd"
: >"$calls"
run_hardware_leaf MacBookPro13,3 >/dev/null
[[ -s $calls ]] || fail "masked services and inactive backups allow installation"
pass "masked services and rollback backups do not count as competitors"

systemctl_stub="$test_root/systemctl"
cat >"$systemctl_stub" <<'STUB'
#!/bin/bash
printf 'systemctl' >>"$CALLS"
printf '\t%s' "$@" >>"$CALLS"
printf '\n' >>"$CALLS"

if [[ $1 == "show" ]]; then
  case $2 in
    --property=LoadState) printf '%s\n' "${MOCK_LOAD_STATE:-loaded}" ;;
    --property=Result) printf '%s\n' "${MOCK_SERVICE_RESULT:-success}" ;;
    --property=ExecMainStatus) printf '%s\n' "${MOCK_EXIT_STATUS:-0}" ;;
    *) exit 1 ;;
  esac
fi
STUB
chmod +x "$systemctl_stub"

attempt_state="$test_root/attempt-state"
attempt="$test_root/omarchy-t1bridge-import-attempt"
sed \
  -e 's/if (( EUID != 0 )); then/if false; then/' \
  -e "s|state_dir=/var/lib/omarchy/t1bridge-import|state_dir=$attempt_state|" \
  -e "s|lock_file=/run/lock/omarchy-t1bridge-import.lock|lock_file=$test_root/import.lock|" \
  -e "s|/usr/bin/systemctl|$systemctl_stub|g" \
  -e 's|/usr/bin/install -d -m 0755 -o root -g root|/usr/bin/install -d -m 0755|' \
  -e '/\/usr\/bin\/chown root:root/d' \
  "$ROOT/bin/omarchy-t1bridge-import-attempt" >"$attempt"
chmod +x "$attempt"

: >"$calls"
MOCK_EXIT_STATUS=0 "$attempt"
[[ $(<"$attempt_state/result") == "success" ]] || fail "successful import records only success"
[[ $(stat -c %a "$attempt_state/result") == "644" ]] || fail "downstream result is readable without exposing protected storage"

MOCK_EXIT_STATUS=24 MOCK_SERVICE_RESULT=exit-code "$attempt"
[[ $(<"$attempt_state/result") == "failure" ]] || fail "failed import records only a generic failure"
! grep -q '24' "$attempt_state/result" || fail "downstream state does not persist an undocumented T1Bridge exit code"

MOCK_LOAD_STATE=not-found "$attempt"
[[ $(<"$attempt_state/result") == "failure" ]] || fail "missing packaged importer records a generic failure"
pass "one root attempt invokes the static importer and persists no numeric semantics"

notification_calls="$test_root/notification-calls"
cat >"$stub_bin/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf 'send\n' >>"$NOTIFICATION_CALLS"
printf '%s\n' "$@" >>"$NOTIFICATION_CALLS"
STUB
cat >"$stub_bin/omarchy-notification-dismiss" <<'STUB'
#!/bin/bash
printf 'dismiss\n' >>"$NOTIFICATION_CALLS"
STUB
chmod +x "$stub_bin/omarchy-notification-send" "$stub_bin/omarchy-notification-dismiss"

notify_state="$test_root/notify-system-state"
notify_user_state="$test_root/notify-user-state"
notify="$test_root/omarchy-t1bridge-import-notify"
sed \
  -e "s|state_dir=/var/lib/omarchy/t1bridge-import|state_dir=$notify_state|" \
  "$ROOT/bin/omarchy-t1bridge-import-notify" >"$notify"
chmod +x "$notify"
mkdir -p "$notify_state"
printf 'enabled\n' >"$notify_state/enabled"
printf 'failure\n' >"$notify_state/result"
: >"$notification_calls"

NOTIFICATION_CALLS="$notification_calls" XDG_STATE_HOME="$notify_user_state" PATH="$stub_bin:$PATH" "$notify"
[[ $(grep -c '^send$' "$notification_calls") == 1 ]] || fail "one failed automatic attempt sends one notification"
[[ $(tail -n 1 "$notification_calls") == "omarchy-t1bridge-import-retry" ]] ||
  fail "the failure notification exposes exactly the deterministic retry command"

NOTIFICATION_CALLS="$notification_calls" XDG_STATE_HOME="$notify_user_state" PATH="$stub_bin:$PATH" "$notify"
[[ $(grep -c '^send$' "$notification_calls") == 1 ]] || fail "an unchanged failure is not announced twice"

NOTIFICATION_CALLS="$notification_calls" XDG_STATE_HOME="$notify_user_state" PATH="$stub_bin:$PATH" "$notify" --force
[[ $(grep -c '^send$' "$notification_calls") == 2 ]] || fail "one requested retry refreshes the failure notification once"

printf 'success\n' >"$notify_state/result"
NOTIFICATION_CALLS="$notification_calls" XDG_STATE_HOME="$notify_user_state" PATH="$stub_bin:$PATH" "$notify" --force
[[ $(grep -c '^send$' "$notification_calls") == 2 ]] || fail "successful setup stays silent"
[[ $(grep -c '^dismiss$' "$notification_calls") == 1 ]] || fail "success clears the stale failure notification"
pass "failure-only notification is deduplicated and has one retry action"

rm "$notify_state/result"
: >"$notification_calls"
IMPORT_ACTIVE=1 NOTIFICATION_CALLS="$notification_calls" XDG_STATE_HOME="$notify_user_state" PATH="$stub_bin:$PATH" "$notify"
[[ ! -s $notification_calls ]] || fail "an active first-boot import stays silent" "$(<"$notification_calls")"
pass "an active first-boot import cannot race the failure notification"

grep -qxF 'TimeoutStartSec=180' "$ROOT/install/hardware/apple/omarchy-t1bridge-import.service" ||
  fail "the import wrapper outlives the bounded importer service"
pass "the import wrapper has time to record the bounded importer result"

retry_calls="$test_root/retry-calls"
cat >"$stub_bin/pkexec" <<'STUB'
#!/bin/bash
printf 'pkexec' >>"$RETRY_CALLS"
printf '\t%s' "$@" >>"$RETRY_CALLS"
printf '\n' >>"$RETRY_CALLS"
STUB
cat >"$stub_bin/omarchy-t1bridge-import-notify" <<'STUB'
#!/bin/bash
printf 'notify' >>"$RETRY_CALLS"
printf '\t%s' "$@" >>"$RETRY_CALLS"
printf '\n' >>"$RETRY_CALLS"
STUB
chmod +x "$stub_bin/pkexec" "$stub_bin/omarchy-t1bridge-import-notify"

: >"$retry_calls"
RETRY_CALLS="$retry_calls" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-t1bridge-import-retry"
expected=$'pkexec\t/usr/bin/omarchy-t1bridge-import-attempt\nnotify\t--force'
[[ $(<"$retry_calls") == "$expected" ]] || fail "retry runs one privileged attempt and one notification refresh" "$(<"$retry_calls")"
pass "retry action performs exactly one attempt without a loop or agent"
