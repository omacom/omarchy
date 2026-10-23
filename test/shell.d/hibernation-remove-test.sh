#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/bin/omarchy-hibernation-remove"

[[ -f $script ]] || fail "omarchy-hibernation-remove is in the checkout" "$script"

# The sleep hook is for ordinary suspend. Remove must not delete it.
if grep -E '^[[:space:]]*sudo[[:space:]]+rm\b.*keyboard-backlight' "$script"; then
  fail "hibernation remove does not delete the keyboard-backlight sleep hook"
fi
pass "hibernation remove leaves the keyboard-backlight sleep hook"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fake="$tmp/root"
stub="$tmp/bin"
log="$tmp/calls.log"
rewritten="$tmp/omarchy-hibernation-remove"

mkdir -p "$stub"
cat >"$stub/sudo" <<'SH'
#!/bin/bash
printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
exec "$@"
SH
cat >"$stub/gum" <<'SH'
#!/bin/bash
printf 'gum' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
exit 0
SH
cat >"$stub/swapon" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$stub/btrfs" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$stub/limine-mkinitcpio" <<SH
#!/bin/bash
printf 'limine-mkinitcpio\n' >>"\$TEST_LOG"
if [[ -f $fake/etc/limine-entry-tool.d/resume.conf ]]; then
  printf 'resume.conf-present-at-rebuild\n' >>"\$TEST_LOG"
fi
SH
chmod +x "$stub"/*

# Paths are hard-coded; rewrite them onto a scratch tree, then run that copy.
# The source is still $ROOT/bin/omarchy-hibernation-remove.
sed -e "s#/etc/#$fake/etc/#g" -e "s#SWAP_SUBVOLUME=\"/swap\"#SWAP_SUBVOLUME=\"$fake/swap\"#" "$script" >"$rewritten"
chmod +x "$rewritten"

reset_tree() {
  rm -rf "$fake"
  mkdir -p "$fake/etc/mkinitcpio.conf.d" "$fake/etc/limine-entry-tool.d" \
    "$fake/usr/lib/systemd/system-sleep" "$fake/swap"
  printf 'UUID=fake / ext4 defaults 0 1\n' >"$fake/etc/fstab"
  : >"$log"
}

run_remove() {
  PATH="$stub:$PATH" TEST_LOG="$log" bash "$rewritten"
}

# --- full setup: hook + both drop-ins + swapfile + backlight ---------------

reset_tree
printf 'HOOKS+=(resume)\n' >"$fake/etc/mkinitcpio.conf.d/omarchy_resume.conf"
printf 'KERNEL_CMDLINE[default]+=" resume=/dev/mapper/root resume_offset=123"\n' \
  >"$fake/etc/limine-entry-tool.d/resume.conf"
printf 'KERNEL_CMDLINE[default]+=" rtc_cmos.use_acpi_alarm=1"\n' \
  >"$fake/etc/limine-entry-tool.d/rtc-alarm.conf"
: >"$fake/swap/swapfile"
: >"$fake/usr/lib/systemd/system-sleep/keyboard-backlight"

run_remove >/dev/null

[[ ! -f $fake/etc/limine-entry-tool.d/resume.conf ]] ||
  fail "remove deletes resume.conf"
[[ -f $fake/etc/limine-entry-tool.d/rtc-alarm.conf ]] ||
  fail "remove leaves rtc-alarm.conf"
[[ ! -f $fake/etc/mkinitcpio.conf.d/omarchy_resume.conf ]] ||
  fail "remove deletes the mkinitcpio resume hook"
[[ ! -f $fake/swap/swapfile ]] ||
  fail "remove deletes the swapfile"
[[ -f $fake/usr/lib/systemd/system-sleep/keyboard-backlight ]] ||
  fail "keyboard-backlight sleep hook is still present"

grep -Fxq 'limine-mkinitcpio' "$log" ||
  fail "remove runs limine-mkinitcpio"
if grep -Fxq 'resume.conf-present-at-rebuild' "$log"; then
  fail "resume.conf is gone before limine-mkinitcpio"
fi
if grep -q 'keyboard-backlight' "$log"; then
  fail "remove does not mention keyboard-backlight at runtime"
fi

rm_line=$(grep -n $'sudo\trm\t-f\t' "$log" | grep 'limine-entry-tool.d/resume.conf' | head -n1 | cut -d: -f1)
rebuild_line=$(grep -n $'sudo\tlimine-mkinitcpio$' "$log" | head -n1 | cut -d: -f1)
if [[ -z $rm_line || -z $rebuild_line ]] || (( rm_line >= rebuild_line )); then
  fail "resume.conf is removed before limine-mkinitcpio" "$(cat "$log")"
fi

pass "remove deletes resume.conf before limine-mkinitcpio"

# --- drop-ins only (hook already gone) -------------------------------------

reset_tree
printf 'KERNEL_CMDLINE[default]+=" resume=/dev/mapper/root resume_offset=123"\n' \
  >"$fake/etc/limine-entry-tool.d/resume.conf"
printf 'KERNEL_CMDLINE[default]+=" rtc_cmos.use_acpi_alarm=1"\n' \
  >"$fake/etc/limine-entry-tool.d/rtc-alarm.conf"

run_remove >/dev/null

[[ ! -f $fake/etc/limine-entry-tool.d/resume.conf ]] ||
  fail "remove still deletes leftover resume.conf when the hook is already gone"
[[ -f $fake/etc/limine-entry-tool.d/rtc-alarm.conf ]] ||
  fail "remove leaves rtc-alarm.conf when the hook is already gone"
grep -Fxq 'limine-mkinitcpio' "$log" ||
  fail "remove rebuilds after deleting leftover resume.conf"
if grep -Fxq 'resume.conf-present-at-rebuild' "$log"; then
  fail "leftover resume.conf is gone before limine-mkinitcpio"
fi
pass "remove deletes leftover resume.conf even when the mkinitcpio hook is already gone"

# --- nothing configured ----------------------------------------------------

reset_tree
output=$(run_remove)
[[ $output == *"Hibernation is not set up"* ]] ||
  fail "remove reports hibernation is not set up when nothing is present" "$output"
if grep -q 'limine-mkinitcpio' "$log"; then
  fail "remove does not rebuild when hibernation is not set up"
fi
pass "remove is a no-op when hibernation is not set up"

reset_tree
printf 'KERNEL_CMDLINE[default]+=" rtc_cmos.use_acpi_alarm=1"\n' \
  >"$fake/etc/limine-entry-tool.d/rtc-alarm.conf"

output=$(run_remove)
[[ $output == *"Hibernation is not set up"* ]] ||
  fail "remove reports hibernation is not set up when only rtc-alarm.conf is present" "$output"
[[ -f $fake/etc/limine-entry-tool.d/rtc-alarm.conf ]] ||
  fail "remove leaves rtc-alarm.conf when hibernation is not set up"
if grep -q 'limine-mkinitcpio' "$log"; then
  fail "remove does not rebuild when only rtc-alarm.conf is present"
fi
pass "remove is a no-op when only rtc-alarm.conf is present"

reset_tree
printf 'HOOKS+=(resume)\n' >"$fake/etc/mkinitcpio.conf.d/omarchy_resume.conf"
printf 'KERNEL_CMDLINE[default]+=" resume=/dev/mapper/root resume_offset=123"\n' \
  >"$fake/etc/limine-entry-tool.d/resume.conf"
# A non-writable directory does not stop root, so the stub refuses this unlink.
cat >"$stub/rm" <<'SH'
#!/bin/bash
for arg in "$@"; do
  case "$arg" in
    */limine-entry-tool.d/resume.conf)
      printf 'rm: cannot remove %s: Permission denied\n' "$arg" >&2
      exit 1
      ;;
  esac
done
exec /usr/bin/rm "$@"
SH
chmod +x "$stub/rm"

status=0
output=$(run_remove) || status=$?
rm -f "$stub/rm"

if (( status == 0 )); then
  fail "remove fails when resume.conf cannot be deleted" "$output"
fi
[[ -f $fake/etc/limine-entry-tool.d/resume.conf ]] ||
  fail "resume.conf remains when deletion fails"
if grep -q 'limine-mkinitcpio' "$log"; then
  fail "remove does not rebuild when resume.conf deletion fails"
fi
[[ $output != *"Hibernation removed"* ]] ||
  fail "remove does not report success when resume.conf deletion fails" "$output"
pass "remove stops when resume.conf cannot be deleted"
