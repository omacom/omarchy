#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
modules_dir="$test_tmp/modules"
calls="$test_tmp/calls"
output="$test_tmp/output"
mkdir -p "$stub_bin" "$test_home/.local/state/omarchy" "$modules_dir/installed-kernel"
touch "$modules_dir/installed-kernel/vmlinuz"

cat >"$stub_bin/uname" <<'SH'
#!/bin/bash
printf '%s\n' "$TEST_RUNNING_KERNEL"
SH

cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash
[[ $1 == "-Qo" && $TEST_KERNEL_OWNED == "true" ]]
SH

cat >"$stub_bin/pgrep" <<'SH'
#!/bin/bash
printf '4242\n'
SH

cat >"$stub_bin/readlink" <<'SH'
#!/bin/bash
if [[ $TEST_HYPRLAND_UPDATED == "true" ]]; then
  printf '/usr/bin/Hyprland (deleted)\n'
else
  printf '/usr/bin/Hyprland\n'
fi
SH

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
printf 'gum %s\n' "$*" >>"$TEST_CALLS"
exit "$TEST_CONFIRM_STATUS"
SH

cat >"$stub_bin/omarchy-system-reboot" <<'SH'
#!/bin/bash
printf 'omarchy-system-reboot\n' >>"$TEST_CALLS"
SH

cat >"$stub_bin/omarchy-restart-shell" <<'SH'
#!/bin/bash
printf 'omarchy-restart-shell\n' >>"$TEST_CALLS"
SH

chmod +x "$stub_bin"/*

run_restart_check() {
  local running_kernel="$1"
  local hyprland_updated="$2"
  local reboot_marker="$3"
  local confirm_status="$4"

  : >"$calls"
  rm -f "$test_home/.local/state/omarchy/reboot-required"
  [[ $reboot_marker == "true" ]] && touch "$test_home/.local/state/omarchy/reboot-required"

  HOME="$test_home" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_MODULES_PATH="$modules_dir" \
    TEST_CALLS="$calls" \
    TEST_RUNNING_KERNEL="$running_kernel" \
    TEST_KERNEL_OWNED=true \
    TEST_HYPRLAND_UPDATED="$hyprland_updated" \
    TEST_CONFIRM_STATUS="$confirm_status" \
    "$ROOT/bin/omarchy-update-restart" >"$output"
}

assert_single_prompt() {
  [[ $(grep -c '^gum confirm Reboot now to activate these updates?$' "$calls") == 1 ]] ||
    fail "$1" "$(cat "$calls")"
}

run_restart_check installed-kernel false false 1
! grep -q '^gum ' "$calls" || fail "current kernel and Hyprland skip the reboot prompt"
grep -Fx 'omarchy-restart-shell' "$calls" >/dev/null || fail "updates without reboot reasons restart the shell"
pass "updates without reboot reasons skip the reboot prompt"

run_restart_check running-kernel false false 1
assert_single_prompt "a kernel update produces one reboot prompt"
grep -Fx '  - Linux kernel update' "$output" >/dev/null || fail "the reboot summary identifies the kernel update"
! grep -q '^  - Hyprland update$' "$output" || fail "the kernel-only summary excludes Hyprland"
pass "a kernel update produces one reboot prompt"

run_restart_check installed-kernel true false 1
assert_single_prompt "a Hyprland update produces one reboot prompt"
grep -Fx '  - Hyprland update' "$output" >/dev/null || fail "the reboot summary identifies the Hyprland update"
! grep -q '^  - Linux kernel update$' "$output" || fail "the Hyprland-only summary excludes the kernel"
pass "a Hyprland update produces one reboot prompt"

run_restart_check installed-kernel false true 1
assert_single_prompt "a reboot marker produces one reboot prompt"
grep -Fx '  - system changes' "$output" >/dev/null || fail "the reboot summary identifies marked system changes"
[[ -f $test_home/.local/state/omarchy/reboot-required ]] || fail "declining preserves the reboot marker"
pass "a reboot marker independently produces one reboot prompt"

run_restart_check running-kernel true true 1
assert_single_prompt "combined reboot reasons produce one prompt"
for reason in 'Linux kernel update' 'system changes' 'Hyprland update'; do
  grep -Fx "  - $reason" "$output" >/dev/null || fail "the combined summary includes $reason"
done
! grep -q '^omarchy-system-reboot$' "$calls" || fail "declining the combined prompt avoids rebooting"
grep -Fx 'omarchy-restart-shell' "$calls" >/dev/null || fail "declining the combined prompt continues post-update restarts"
pass "declining the combined prompt does not offer or schedule another reboot"

run_restart_check running-kernel true true 0
assert_single_prompt "accepting combined reboot reasons produces one prompt"
[[ $(grep -c '^omarchy-system-reboot$' "$calls") == 1 ]] || fail "accepting the combined prompt schedules one reboot" "$(cat "$calls")"
! grep -q '^omarchy-restart-shell$' "$calls" || fail "an accepted reboot exits before post-update restarts"
pass "accepting the combined prompt schedules one reboot"
