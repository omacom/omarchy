#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export test_tmp
mkdir -p "$test_tmp/bin"
printf 'HOOKS+=(resume)\n' >"$test_tmp/mkinitcpio.conf"
touch "$test_tmp/image_size" "$test_tmp/swapfile"
# Execute the already-configured path with every writable path redirected.
sed '/^if ! $FORCE; then/,$d' "$ROOT/bin/omarchy-hibernation-setup" |
  sed -e "s|/sys/power/image_size|$test_tmp/image_size|g" \
    -e "s|/etc/mkinitcpio.conf.d/omarchy_resume.conf|$test_tmp/mkinitcpio.conf|g" \
    -e "s|/etc/limine-entry-tool.d/resume.conf|$test_tmp/resume.conf|g" \
    -e "s|/swap/swapfile|$test_tmp/swapfile|g" >"$test_tmp/setup"

sudo() {
  case "$1" in
    btrfs) printf '%s\n' "${TEST_OFFSET:-456}" ;;
    limine-mkinitcpio) echo rebuild >>"$test_tmp/rebuilds"; return "${TEST_REBUILD_STATUS:-0}" ;;
    /usr/bin/install) cp -- "${@: -2}" ;;
    *) "$@" ;;
  esac
}
findmnt() { printf '%s\n' '/dev/mapper/root[/swap]'; }
omarchy-cmd-missing() { return 1; }
export -f sudo findmnt omarchy-cmd-missing

printf 'KERNEL_CMDLINE[default]+=" resume=/dev/mapper/old resume_offset=123"\n' >"$test_tmp/resume.conf"
bash "$test_tmp/setup" >"$test_tmp/output"
grep -Fqx 'KERNEL_CMDLINE[default]+=" resume=/dev/mapper/root resume_offset=456"' "$test_tmp/resume.conf" || fail "resume device and stale offset are reconciled"
[[ $(wc -l <"$test_tmp/rebuilds") == 1 ]] || fail "changed resume parameters rebuild once"
pass "existing hibernation follows a relocated swapfile and rebuilds"

bash "$test_tmp/setup" >"$test_tmp/output"
[[ $(wc -l <"$test_tmp/rebuilds") == 1 ]] || fail "unchanged parameters avoid another rebuild"
pass "reconciliation is idempotent"

TEST_OFFSET=789 bash "$test_tmp/setup" --no-rebuild >"$test_tmp/output"
grep -q 'resume_offset=789' "$test_tmp/resume.conf" || fail "no-rebuild still repairs the offset"
[[ $(wc -l <"$test_tmp/rebuilds") == 1 ]] || fail "no-rebuild leaves rebuilding to the caller"
pass "no-rebuild repairs parameters without rebuilding"

cp "$test_tmp/resume.conf" "$test_tmp/before"
if TEST_OFFSET=invalid bash "$test_tmp/setup" >"$test_tmp/output" 2>&1; then
  fail "invalid swapfile mappings fail setup"
fi
cmp -s "$test_tmp/before" "$test_tmp/resume.conf" || fail "mapping failures preserve the previous parameters"
pass "invalid mappings fail without replacing boot configuration"

printf '# Custom setting\n' >>"$test_tmp/resume.conf"
cp "$test_tmp/resume.conf" "$test_tmp/before"
if bash "$test_tmp/setup" >"$test_tmp/output" 2>&1; then
  fail "custom resume drop-ins require manual reconciliation"
fi
cmp -s "$test_tmp/before" "$test_tmp/resume.conf" || fail "custom settings survive"
pass "custom drop-ins are preserved"

rm "$test_tmp/resume.conf"
if TEST_REBUILD_STATUS=1 bash "$test_tmp/setup" >"$test_tmp/output" 2>&1; then
  fail "rebuild failures are reported"
fi
[[ ! -e $test_tmp/resume.conf ]] || fail "failed rebuild restores the missing drop-in state"
bash "$test_tmp/setup" >"$test_tmp/output"
[[ -s $test_tmp/resume.conf ]] || fail "missing resume drop-in is recreated"
[[ $(wc -l <"$test_tmp/rebuilds") == 3 ]] || fail "retry rebuilds after a failed first attempt"
pass "missing drop-ins are repaired and failed rebuilds remain retryable"

cp "$test_tmp/resume.conf" "$test_tmp/before"
if TEST_OFFSET=999 TEST_REBUILD_STATUS=1 bash "$test_tmp/setup" >"$test_tmp/output" 2>&1; then
  fail "failed rebuild returns failure for an existing drop-in"
fi
cmp -s "$test_tmp/before" "$test_tmp/resume.conf" || fail "failed rebuild restores previous parameters"
TEST_OFFSET=999 bash "$test_tmp/setup" >"$test_tmp/output"
[[ $(wc -l <"$test_tmp/rebuilds") == 5 ]] || fail "retry rebuilds existing configuration after failure"
pass "existing parameters survive failed rebuilds and retries rebuild again"
