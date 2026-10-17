#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)

# Removing hibernation must not leave resume kernel parameters behind: a later
# setup keeps a stale resume_offset and the session is silently lost (#13583).
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
fake_etc="$test_tmp/etc"
mkdir -p "$stub_bin" "$fake_etc" "$test_tmp/sys/power"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
# Absolute tool paths bypass PATH stubbing: remap to a same-named stub when
# one exists (install), otherwise run for real (all paths are sandboxed).
case $1 in
/*)
  stub="$(dirname -- "$0")/$(basename -- "$1")"
  if [[ -x $stub ]]; then
    shift
    exec "$stub" "$@"
  fi
  ;;
esac
"$@"
SH

cat >"$stub_bin/install" <<'SH'
#!/bin/bash

# test stub: copy without ownership changes (unprivileged runs)
mode=""
positional=()
while [[ $# -gt 0 ]]; do
  case $1 in
  -o | -g)
    shift 2
    ;;
  -m)
    mode=$2
    shift 2
    ;;
  -*)
    shift
    ;;
  *)
    positional+=("$1")
    shift
    ;;
  esac
done
cp "${positional[0]}" "${positional[1]}" || exit 1
[[ -n $mode ]] && chmod "$mode" "${positional[1]}" || true
SH

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash

exit 0
SH

cat >"$stub_bin/btrfs" <<'SH'
#!/bin/bash

case "$1 $2" in
subvolume\ show) exit "${HIB_TEST_SUBVOL_EXISTS:-1}" ;;
subvolume\ create) mkdir -p "$3" ;;
subvolume\ delete) exit 0 ;;
filesystem\ mkswapfile) touch "${@: -1}" ;;
inspect-internal\ map-swapfile) printf '%s' "${HIB_TEST_OFFSET:-9999}" ;;
esac
SH

cat >"$stub_bin/swapon" <<'SH'
#!/bin/bash

exit 0
SH

cat >"$stub_bin/swapoff" <<'SH'
#!/bin/bash

exit 0
SH

cat >"$stub_bin/swaplabel" <<'SH'
#!/bin/bash

exit "${HIB_TEST_SWAPLABEL_FAIL:-1}"
SH

cat >"$stub_bin/chattr" <<'SH'
#!/bin/bash

exit 0
SH

cat >"$stub_bin/findmnt" <<'SH'
#!/bin/bash

echo '/dev/mapper/cryptroot[/@]'
SH

cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash

exit 0
SH

cat >"$stub_bin/omarchy-system-reboot" <<'SH'
#!/bin/bash

printf 'REBOOT\n' >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

export TEST_LOG="$calls"
export OMARCHY_PATH="$ROOT"

sandbox_script() { # source-path: rewrite absolute paths into the sandbox
  sed -e "s|/etc/limine-entry-tool.d|$test_tmp/etc/limine-entry-tool.d|g" \
    -e "s|/etc/mkinitcpio.conf.d|$test_tmp/etc/mkinitcpio.conf.d|g" \
    -e "s|/usr/lib/systemd/system-sleep|$test_tmp/usr/lib/systemd/system-sleep|g" \
    -e "s|/sys/power/image_size|$test_tmp/sys/power/image_size|g" \
    -e "s|/etc/fstab|$test_tmp/etc/fstab|g" \
    -e "s|/swap/swapfile|$test_tmp/swap/swapfile|g" \
    -e "s|\"/swap\"|\"$test_tmp/swap\"|g" \
    "$1"
}

seed_configured() {
  rm -rf "$test_tmp/etc" "$test_tmp/swap"
  mkdir -p "$test_tmp/etc/mkinitcpio.conf.d" "$test_tmp/etc/limine-entry-tool.d" "$test_tmp/swap"
  printf 'HOOKS+=(resume)\n' >"$test_tmp/etc/mkinitcpio.conf.d/omarchy_resume.conf"
  printf 'KERNEL_CMDLINE[default]+=" resume=/dev/mapper/cryptroot resume_offset=1111"\n' \
    >"$test_tmp/etc/limine-entry-tool.d/resume.conf"
  printf '/dev/mapper/root / btrfs defaults 0 0\n' >"$test_tmp/etc/fstab"
  : >"$calls"
}

# Hibernation is configured: remove must take the resume kernel parameters
# with it, or a later setup keeps pointing at the deleted swapfile.
seed_configured
touch "$test_tmp/swap/swapfile"
printf '%s none swap defaults,pri=0 0 0\n' "$test_tmp/swap/swapfile" >>"$test_tmp/etc/fstab"
sandbox_script "$ROOT/bin/omarchy-hibernation-remove" >"$test_tmp/remove.sh"
PATH="$stub_bin:$PATH" bash "$test_tmp/remove.sh" >/dev/null
[[ ! -e $test_tmp/etc/limine-entry-tool.d/resume.conf ]] ||
  fail "remove deletes the resume kernel parameters"
[[ ! -e $test_tmp/etc/mkinitcpio.conf.d/omarchy_resume.conf ]] ||
  fail "remove deletes the resume hook config"
grep -Fq 'limine-mkinitcpio' "$calls" ||
  fail "remove rebuilds the boot entries after cleanup" "$(cat "$calls")"
pass "remove deletes the resume kernel parameters"

# Nothing configured: remove stays quiet.
rm -rf "$test_tmp/etc"
mkdir -p "$test_tmp/etc"
: >"$calls"
PATH="$stub_bin:$PATH" bash "$test_tmp/remove.sh" >/dev/null
[[ ! -s $calls ]] || fail "remove without a setup touches nothing" "$(cat "$calls")"
pass "remove without a setup touches nothing"

# A stale resume.conf from a previous swapfile must not survive a fresh setup:
# the offset is recomputed from the current swapfile every time.
rm -rf "$test_tmp/etc" "$test_tmp/swap" "$test_tmp/usr"
mkdir -p "$test_tmp/etc" "$test_tmp/sys/power" "$test_tmp/usr/lib/systemd/system-sleep"
touch "$test_tmp/sys/power/image_size"
printf 'KERNEL_CMDLINE[default]+=" resume=/dev/mapper/cryptroot resume_offset=1111"\n' \
  >"$test_tmp/etc/resume.conf.stale"
mkdir -p "$test_tmp/etc/limine-entry-tool.d"
cp "$test_tmp/etc/resume.conf.stale" "$test_tmp/etc/limine-entry-tool.d/resume.conf"
printf '/dev/mapper/root / btrfs defaults 0 0\n' >"$test_tmp/etc/fstab"
sandbox_script "$ROOT/bin/omarchy-hibernation-setup" >"$test_tmp/setup.sh"
HIB_TEST_OFFSET=9999 PATH="$stub_bin:$PATH" bash "$test_tmp/setup.sh" --force >/dev/null
grep -Fq 'resume_offset=9999"' "$test_tmp/etc/limine-entry-tool.d/resume.conf" ||
  fail "setup refreshes a stale resume offset" "$(cat "$test_tmp/etc/limine-entry-tool.d/resume.conf" 2>&1)"
if grep -Fq 'REBOOT' "$calls"; then
  fail "setup --force never reboots" "$(cat "$calls")"
fi
pass "setup refreshes a stale resume offset"

# Fresh setup with no prior state still writes the parameters.
rm -rf "$test_tmp/etc" "$test_tmp/swap"
mkdir -p "$test_tmp/etc" "$test_tmp/usr/lib/systemd/system-sleep"
printf '/dev/mapper/root / btrfs defaults 0 0\n' >"$test_tmp/etc/fstab"
: >"$calls"
HIB_TEST_OFFSET=4242 PATH="$stub_bin:$PATH" bash "$test_tmp/setup.sh" --force >/dev/null
grep -Fq 'resume_offset=4242"' "$test_tmp/etc/limine-entry-tool.d/resume.conf" ||
  fail "fresh setup writes the resume parameters" "$(ls -R "$test_tmp/etc" 2>&1)"
grep -Fq 'limine-mkinitcpio' "$calls" ||
  fail "setup rebuilds the boot entries" "$(cat "$calls")"
pass "fresh setup writes the resume parameters"
