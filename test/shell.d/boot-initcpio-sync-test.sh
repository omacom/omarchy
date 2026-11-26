#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

root="$test_tmp/root"
bin_dir="$test_tmp/bin"
log="$test_tmp/rebuild.log"
mkdir -p "$root/etc/initcpio/hooks" "$root/etc/initcpio/install" \
  "$root/etc/mkinitcpio.conf.d" "$root/usr/lib/modules/7.3.6-1-omarchy" "$bin_dir"

printf 'linux-omarchy\n' >"$root/usr/lib/modules/7.3.6-1-omarchy/pkgbase"
printf '#!/bin/sh\nrun_hook() { :; }\n' >"$root/etc/initcpio/hooks/omarchy-restore"
printf '#!/bin/sh\nbuild() { :; }\n' >"$root/etc/initcpio/install/omarchy-restore"
printf 'HOOKS=(base udev omarchy-restore)\n' >"$root/etc/mkinitcpio.conf.d/00-omarchy-hooks.conf"

cat >"$bin_dir/fake-backend" <<'SH'
#!/bin/bash
printf '%s\n' "${FAKE_BACKEND:-limine}"
SH
cat >"$bin_dir/fake-rebuild" <<'SH'
#!/bin/bash
printf 'rebuild\n' >>"$FAKE_LOG"
exit "${FAKE_REBUILD_STATUS:-0}"
SH
chmod +x "$bin_dir/fake-backend" "$bin_dir/fake-rebuild"

run_sync() {
  OMARCHY_INITCPIO_ROOT="$root" \
    OMARCHY_INITCPIO_BACKEND_CMD="$bin_dir/fake-backend" \
    OMARCHY_INITCPIO_REBUILD_CMD="$bin_dir/fake-rebuild" \
    FAKE_LOG="$log" \
    "$ROOT/bin/omarchy-boot-sync-initcpio" "$@"
}

state="$root/var/lib/omarchy/initcpio.sha256"

# 1. Unmanaged backend (e.g. ISO chroot / Apple Silicon) skips without writing state.
FAKE_BACKEND=none run_sync --pacman-hook
[[ ! -f $state && ! -f $log ]] || fail "unmanaged backend must skip without rebuilding or writing state"
pass "unmanaged backend skips without rebuilding or writing state"

# 2. First run on a managed machine seeds the state file without rebuilding.
run_sync --pacman-hook
[[ -s $state ]] || fail "first run must seed state file"
[[ ! -f $log ]] || fail "first run must not rebuild"
seed_hash=$(<"$state")
pass "first run seeds initcpio hash without rebuilding"

# 3. Unchanged inputs skip rebuild.
run_sync --pacman-hook
[[ ! -f $log ]] || fail "unchanged inputs must not trigger rebuild"
pass "unchanged inputs skip rebuild"

# 4. Non-.conf backup files (.pacnew) in mkinitcpio.conf.d do not trigger rebuild.
printf 'HOOKS=(different)\n' >"$root/etc/mkinitcpio.conf.d/00-omarchy-hooks.conf.pacnew"
run_sync --pacman-hook
[[ ! -f $log ]] || fail ".pacnew files must not trigger rebuild"
pass ".pacnew files in mkinitcpio.conf.d are ignored"

# 5. Editing an Omarchy initcpio hook triggers rebuild and updates stored hash.
printf '#!/bin/sh\nrun_hook() { echo updated; }\n' >"$root/etc/initcpio/hooks/omarchy-restore"
run_sync --pacman-hook >/dev/null
[[ $(wc -l <"$log") -eq 1 ]] || fail "changed initcpio hook must trigger one rebuild"
after_hook_hash=$(<"$state")
[[ $after_hook_hash != "$seed_hash" ]] || fail "stored hash must update after rebuild"
pass "changed Omarchy initcpio hook triggers rebuild and updates hash"

# 6. Running again with the same updated hook skips rebuild.
run_sync --pacman-hook
[[ $(wc -l <"$log") -eq 1 ]] || fail "subsequent unchanged run must skip rebuild"
pass "subsequent unchanged run skips rebuild"

# 7. Editing /etc/mkinitcpio.conf.d/*.conf triggers rebuild.
printf 'COMPRESSION="zstd"\n' >"$root/etc/mkinitcpio.conf.d/omarchy_compression.conf"
run_sync --pacman-hook >/dev/null
[[ $(wc -l <"$log") -eq 2 ]] || fail "changed mkinitcpio.conf.d drop-in must trigger rebuild"
after_conf_hash=$(<"$state")
[[ $after_conf_hash != "$after_hook_hash" ]] || fail "stored hash must update after conf rebuild"
pass "changed mkinitcpio.conf.d drop-in triggers rebuild"

# 8. Failed rebuild propagates non-zero status and keeps the old hash so next run retries.
printf 'COMPRESSION="lz4"\n' >"$root/etc/mkinitcpio.conf.d/omarchy_compression.conf"
if FAKE_REBUILD_STATUS=1 run_sync --pacman-hook >/dev/null 2>&1; then
  fail "failed rebuild must exit non-zero"
fi
[[ $(<"$state") == "$after_conf_hash" ]] || fail "failed rebuild must not advance stored hash"
run_sync --pacman-hook >/dev/null
[[ $(wc -l <"$log") -eq 4 ]] || fail "next run after failed rebuild must retry and succeed"
[[ $(<"$state") != "$after_conf_hash" ]] || fail "successful retry must update stored hash"
pass "failed rebuild preserves old hash and retries on next run"

# 9. No installed kernels skips cleanly even if inputs differ.
rm -rf "$root/usr/lib/modules/7.3.6-1-omarchy"
printf 'COMPRESSION="gzip"\n' >"$root/etc/mkinitcpio.conf.d/omarchy_compression.conf"
run_sync --pacman-hook
[[ $(wc -l <"$log") -eq 4 ]] || fail "missing kernels must skip rebuild"
pass "missing kernels skip rebuild"
