#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-facetimehd.sh"
hw="$ROOT/bin/omarchy-hw-facetimehd"
all="$ROOT/install/hardware/all.sh"
manual="$ROOT/manual/44-mac-support.md"
other_packages="$ROOT/install/omarchy-other.packages"
guard="$ROOT/bin/omarchy-system-sleep-facetimehd"
dropin="$ROOT/default/systemd/system/omarchy-facetimehd-hibernate.conf"

grep -q 'apple/fix-facetimehd.sh' "$all" ||
  fail "the FaceTime HD fix runs during hardware setup"
grep -q 'omarchy-hw-facetimehd' "$leaf" ||
  fail "the install leaf keys off the FaceTime HD detector"
grep -q 'facetimehd-dkms' "$leaf" ||
  fail "the install leaf installs facetimehd-dkms"
grep -qx 'facetimehd-dkms' "$other_packages" ||
  fail "the ISO caches facetimehd-dkms"
grep -qx 'facetimehd-firmware-fetcher' "$other_packages" ||
  fail "the ISO caches facetimehd-firmware-fetcher"
! grep -qxE 'facetimehd-(firmware|data)' "$other_packages" ||
  fail "the ISO carries no Apple firmware, which may not be redistributed"
grep -q '14e4:1570' "$hw" ||
  fail "the detector matches the Broadcom 1570 PCI ID"
grep -q 'FaceTime HD' "$manual" ||
  fail "Mac support documents the FaceTime HD camera"
{ grep -Fxq 'ExecStartPre=/usr/bin/omarchy-system-sleep-facetimehd pre' "$dropin" &&
  grep -Fxq 'ExecStopPost=/usr/bin/omarchy-system-sleep-facetimehd post' "$dropin" &&
  grep -Fxq 'TimeoutStopSec=30s' "$dropin"; } ||
  fail "the hibernation drop-in runs the guard before the sleep and after it"
pass "the FaceTime HD fix is wired into hardware setup"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin"
: >"$calls"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

# Chatty like real lspci: keep writing well past the pipe buffer after the
# match, so a grep -q consumer would kill this stub with SIGPIPE and pipefail
# would read that as "no such hardware" (#6608).
if (( ${FACETIMEHD_HARDWARE:-0} == 1 )); then
  echo '02:00.0 Multimedia controller [0480]: Broadcom Inc. 720p FaceTime HD Camera [14e4:1570]'
fi
for _ in {1..4096}; do
  echo '00:00.0 Host bridge [0600]: Filler Device [ffff:0000]'
done
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash

printf 'omarchy-pkg-add' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
printf '%s\n' "$@" >>"$TEST_INSTALLED"
SH

# -T answers for what is installed or named in FACETIMEHD_PROVIDED, as an AUR package providing it would be.
cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash

satisfied() {
  grep -qxF -- "$1" "$TEST_INSTALLED" || [[ " ${FACETIMEHD_PROVIDED:-} " == *" $1 "* ]]
}

case "$1" in
  -T) for dep in "${@:2}"; do satisfied "$dep" || { echo "$dep"; exit 127; }; done ;;
  -Q) grep -qxF -- "$2" "$TEST_INSTALLED" ;;
  *) exit 2 ;;
esac
SH

cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash

printf 'systemctl' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

# Records the privileged call without making it, so nothing reaches this machine's /etc or systemd.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

install -m0755 "$hw" "$stub_bin/omarchy-hw-facetimehd"
chmod +x "$stub_bin"/*

# Detector: present
FACETIMEHD_HARDWARE=1 PATH="$stub_bin:$PATH" "$stub_bin/omarchy-hw-facetimehd"
pass "detector matches PCI 14e4:1570"

# Detector: absent
if FACETIMEHD_HARDWARE=0 PATH="$stub_bin:$PATH" "$stub_bin/omarchy-hw-facetimehd"; then
  fail "detector ignores machines without a FaceTime HD camera"
fi
pass "detector skips machines without a FaceTime HD camera"

installed="$test_tmp/installed"

run_leaf() {
  local hardware="$1" provided="${2:-}"
  : >"$calls"
  : >"$installed"
  FACETIMEHD_HARDWARE="$hardware" FACETIMEHD_PROVIDED="$provided" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    TEST_INSTALLED="$installed" OMARCHY_PATH="$ROOT" bash -euo pipefail -c 'source "$1"' _ "$leaf"
}

fetcher_enabled=$'sudo\tsystemctl\tenable\tfacetimehd-firmware-fetcher.service'

guarded() {
  local unit
  for unit in systemd-hibernate systemd-hybrid-sleep systemd-suspend-then-hibernate; do
    grep -Fxq "sudo"$'\t'"install"$'\t'"-Dm644"$'\t'"$dropin"$'\t'"/etc/systemd/system/$unit.service.d/omarchy-facetimehd.conf" "$calls" ||
      return 1
  done
  grep -Fxq $'sudo\tsystemctl\tdaemon-reload' "$calls"
}

run_leaf 1
grep -Fxq $'omarchy-pkg-add\tfacetimehd-dkms\tfacetimehd-firmware-fetcher' "$calls" ||
  fail "leaf installs the DKMS module and the firmware fetcher" "$(cat "$calls")"
grep -Fxq "$fetcher_enabled" "$calls" ||
  fail "leaf enables the fetch for a first boot with a network" "$(cat "$calls")"
guarded || fail "leaf guards every hibernating sleep" "$(cat "$calls")"
! grep -q $'sudo\tsystemctl\tstart' "$calls" ||
  fail "an install leaves the fetch to the boot that follows it" "$(cat "$calls")"
pass "leaf installs the DKMS module and the firmware fetcher, enables the fetch, and guards hibernation"

OMARCHY_IMAGE_DEFERRED_HARDWARE=1 run_leaf 1
grep -Fxq $'sudo\tsystemctl\tstart\t--no-block\tfacetimehd-firmware-fetcher.service' "$calls" ||
  fail "an image's first boot starts the fetch it enabled" "$(cat "$calls")"
pass "an image's first boot starts the fetch it enabled"

run_leaf 1 facetimehd-dkms
grep -Fxq $'omarchy-pkg-add\tfacetimehd-firmware-fetcher' "$calls" ||
  fail "leaf keeps a driver the AUR already provides" "$(cat "$calls")"
pass "leaf keeps a driver the AUR already provides"

run_leaf 1 bcwc-pcie
grep -Fxq $'omarchy-pkg-add\tfacetimehd-firmware-fetcher' "$calls" ||
  fail "leaf keeps the legacy bcwc-pcie driver" "$(cat "$calls")"
pass "leaf keeps the legacy bcwc-pcie driver"

run_leaf 1 facetimehd-data
grep -Fxq $'omarchy-pkg-add\tfacetimehd-dkms\tfacetimehd-firmware-fetcher' "$calls" ||
  fail "calibration from the AUR does not stand in for the firmware" "$(cat "$calls")"
pass "calibration from the AUR does not stand in for the firmware"

run_leaf 1 "facetimehd-dkms facetimehd-firmware"
! grep -q -e omarchy-pkg-add -e "$fetcher_enabled" "$calls" ||
  fail "leaf installs nothing where the driver and firmware are already provided" "$(cat "$calls")"
guarded || fail "a Mac keeping its AUR driver still has hibernation guarded" "$(cat "$calls")"
pass "leaf installs nothing where the driver and firmware are already provided, and still guards hibernation"

run_leaf 0
[[ ! -s $calls ]] || fail "non-matching hardware is a no-op" "$(cat "$calls")"
pass "leaf is a no-op on machines without a FaceTime HD camera"

# The guard, run as the hibernating sleep units run it, against a stand-in module, /proc and logind.
guard_root="$test_tmp/guard"
mkdir -p "$guard_root/proc/4242/fd" "$guard_root/module"
echo chromium >"$guard_root/proc/4242/comm"
ln -s /dev/video0 "$guard_root/proc/4242/fd/7"

cat >"$stub_bin/modprobe" <<'SH'
#!/bin/bash

printf 'modprobe' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
if [[ $1 == -r ]]; then [[ -z ${MODULE_BUSY:-} ]]; else [[ -z ${MODULE_LOAD_FAILS:-} ]]; fi
SH

cat >"$stub_bin/loginctl" <<'SH'
#!/bin/bash

echo '2 1000 mac seat0 1234 user tty1 no -'
echo '5 1000 mac -    9876 manager - no -'
SH

cat >"$stub_bin/runuser" <<'SH'
#!/bin/bash

printf 'runuser' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH
chmod +x "$stub_bin"/*

run_guard() {
  : >"$calls"
  PATH="$stub_bin:$PATH" TEST_LOG="$calls" OMARCHY_FACETIMEHD_MODULE="$guard_root/$1" \
    OMARCHY_FACETIMEHD_RUN="$guard_root/run" OMARCHY_FACETIMEHD_PROC="$guard_root/proc" \
    OMARCHY_FACETIMEHD_PCI="$guard_root/pci" OMARCHY_FACETIMEHD_PROBE_WAIT=0 \
    MODULE_BUSY="${3:-}" MODULE_LOAD_FAILS="${4:-}" "$guard" "$2" 2>"$test_tmp/guard.err"
}
mkdir -p "$guard_root/run"

# A camera the driver has bound and registered, as the kernel shows one.
camera="$guard_root/pci/0000:02:00.0"
mkdir -p "$camera/video4linux/video0" "$guard_root/drivers/facetimehd"
echo 0x14e4 >"$camera/vendor"
echo 0x1570 >"$camera/device"
ln -s "$guard_root/drivers/facetimehd" "$camera/driver"
sleeping="$guard_root/run/facetimehd.sleeping"
unloaded="$guard_root/run/facetimehd.unloaded"
activate="$guard_root/run/facetimehd-firmware-fetcher.activate"
fetch_started=$'systemctl\tstart\t--no-block\tfacetimehd-firmware-fetcher.service'

run_guard absent pre || fail "the guard lets a Mac without the driver loaded hibernate"
{ [[ -e $sleeping && ! -e $unloaded ]] && ! grep -q modprobe "$calls"; } ||
  fail "the guard marks the sleep in progress and leaves an unloaded driver alone" "$(cat "$calls")"
run_guard absent post
{ [[ ! -e $sleeping ]] && ! grep -q modprobe "$calls"; } ||
  fail "waking loads nothing that was not unloaded or asked for" "$(cat "$calls")"
pass "the guard lets a Mac without the driver loaded hibernate"

# A fetch finishing mid-sleep leaves its activation pending rather than loading the driver; waking resumes it.
run_guard absent pre
touch "$activate"
run_guard absent post
{ grep -Fxq "$fetch_started" "$calls" && ! grep -q modprobe "$calls" && [[ ! -e $sleeping ]]; } ||
  fail "waking resumes an activation the fetch held back" "$(cat "$calls")"
rm -f "$activate"
pass "waking resumes an activation the fetch held back during the sleep"

run_guard module pre || fail "the guard unloads an idle driver before hibernating" "$(cat "$test_tmp/guard.err")"
{ grep -Fxq $'modprobe\t-r\tfacetimehd' "$calls" && [[ -e $unloaded && -e $sleeping ]]; } ||
  fail "the guard unloads an idle driver before hibernating" "$(cat "$calls")"
run_guard module post
{ grep -Fxq $'modprobe\tfacetimehd' "$calls" && [[ ! -e $unloaded && ! -e $sleeping ]]; } ||
  fail "the guard loads the driver again after resuming" "$(cat "$calls")"
pass "the guard unloads an idle driver for hibernation and loads it again after"

run_guard module post
! grep -q -e modprobe -e systemctl "$calls" || fail "the guard does not load a driver it did not unload" "$(cat "$calls")"
pass "the guard does not load a driver it did not unload"

# A driver that will not load again after the sleep becomes the fetcher's pending activation, which it retries.
run_guard module pre
run_guard module post "" fails
{ [[ -e $activate && ! -e $unloaded && ! -e $sleeping ]] && grep -Fxq "$fetch_started" "$calls"; } ||
  fail "a failed reload is handed to the fetcher to retry" "$(cat "$calls")"
rm -f "$activate"
pass "a failed reload is handed to the fetcher to retry"

# The module loading again is not the camera coming back: one that fails to probe is handed over too.
rmdir "$camera/video4linux/video0"
run_guard module pre
run_guard module post
{ grep -Fxq $'modprobe\tfacetimehd' "$calls" && [[ -e $activate ]] && grep -Fxq "$fetch_started" "$calls"; } ||
  fail "a camera that does not come back after the sleep is handed to the fetcher" "$(cat "$calls")"
rm -f "$activate"
mkdir "$camera/video4linux/video0"
pass "a camera that does not come back after the sleep is handed to the fetcher"

# A post that cannot get the lock in time touches no shared state and hands the restore to the fetcher.
run_guard module pre
flock "$guard_root/run/facetimehd.lock" sleep 2 &
holder=$!
sleep 0.5
OMARCHY_FACETIMEHD_LOCK_WAIT=0 run_guard module post
wait "$holder"
{ ! grep -q modprobe "$calls" && [[ -e $activate && -e $unloaded && -e $sleeping ]] && grep -Fxq "$fetch_started" "$calls"; } ||
  fail "a post that cannot get the lock leaves the markers and hands the restore to the fetcher" "$(cat "$calls")"
rm -f "$activate" "$unloaded" "$sleeping"
pass "a post that cannot get the lock leaves the markers and hands the restore to the fetcher"

if run_guard module pre busy; then
  fail "the guard cancels hibernation while the camera is in use"
fi
grep -q 'chromium' "$test_tmp/guard.err" || fail "the refusal names the app using the camera" "$(cat "$test_tmp/guard.err")"
grep -q $'^runuser\t-u\tmac\t.*omarchy-notification-send\t-u\tcritical\tHibernation cancelled\tClose chromium' "$calls" ||
  fail "the refusal notifies the person at the seat" "$(cat "$calls")"
[[ $(grep -c '^runuser' "$calls") == 1 && ! -e $unloaded && ! -e $sleeping ]] ||
  fail "only the seat session is notified, and no sleep is left marked" "$(cat "$calls")"
pass "the guard cancels hibernation while the camera is in use, and says which app to close"
