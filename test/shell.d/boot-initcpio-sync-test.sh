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

rebuild_count() {
  if [[ -f $log ]]; then
    wc -l <"$log"
  else
    echo 0
  fi
}

state="$root/var/lib/omarchy/initcpio.sha256"

# 1. Unmanaged backend (e.g. ISO chroot / Apple Silicon) skips without writing state.
FAKE_BACKEND=none run_sync --pacman-hook
[[ ! -f $state && ! -f $log ]] || fail "unmanaged backend must skip without rebuilding or writing state"
pass "unmanaged backend skips without rebuilding or writing state"

# 2. Missing state rebuilds once and writes the state file rather than skipping unknown inputs.
run_sync --pacman-hook >/dev/null
[[ -s $state ]] || fail "missing state must write state file after rebuild"
(( $(rebuild_count) == 1 )) || fail "missing state must rebuild once"
seed_hash=$(<"$state")
pass "missing state rebuilds once and records hash"

# 3. Unchanged inputs skip rebuild.
run_sync --pacman-hook
(( $(rebuild_count) == 1 )) || fail "unchanged inputs must not trigger rebuild"
pass "unchanged inputs skip rebuild"

# 4. Backup files (.pacnew/.pacsave/.pacorig) in mkinitcpio.conf.d and hook dirs are ignored.
printf 'HOOKS=(different)\n' >"$root/etc/mkinitcpio.conf.d/00-omarchy-hooks.conf.pacnew"
printf 'backup hook\n' >"$root/etc/initcpio/hooks/omarchy-restore.pacnew"
printf 'saved hook\n' >"$root/etc/initcpio/install/omarchy-restore.pacsave"
run_sync --pacman-hook
(( $(rebuild_count) == 1 )) || fail "backup files must not trigger rebuild"
pass "backup files in mkinitcpio.conf.d and initcpio hook dirs are ignored"

# 5. Editing an Omarchy initcpio hook triggers rebuild and updates stored hash.
printf '#!/bin/sh\nrun_hook() { echo updated; }\n' >"$root/etc/initcpio/hooks/omarchy-restore"
run_sync --pacman-hook >/dev/null
(( $(rebuild_count) == 2 )) || fail "changed initcpio hook must trigger rebuild"
after_hook_hash=$(<"$state")
[[ $after_hook_hash != "$seed_hash" ]] || fail "stored hash must update after rebuild"
pass "changed Omarchy initcpio hook triggers rebuild and updates hash"

# 6. Running again with the same updated hook skips rebuild.
run_sync --pacman-hook
(( $(rebuild_count) == 2 )) || fail "subsequent unchanged run must skip rebuild"
pass "subsequent unchanged run skips rebuild"

# 7. Symlinked drop-in: editing the target file changes the hash and triggers rebuild.
linked_target="$test_tmp/linked-compression.conf"
printf 'COMPRESSION="zstd"\n' >"$linked_target"
ln -s "$linked_target" "$root/etc/mkinitcpio.conf.d/omarchy_compression.conf"
run_sync --pacman-hook >/dev/null
(( $(rebuild_count) == 3 )) || fail "adding symlinked drop-in must trigger rebuild"
printf 'COMPRESSION="xz"\n' >"$linked_target"
run_sync --pacman-hook >/dev/null
(( $(rebuild_count) == 4 )) || fail "editing symlink target contents must trigger rebuild"
after_conf_hash=$(<"$state")
pass "editing symlinked drop-in target contents triggers rebuild"

# 8. --record after a full rebuild prevents double-rebuild on the subsequent settings hook.
printf 'COMPRESSION="lz4"\n' >"$linked_target"
run_sync --record
run_sync --pacman-hook
(( $(rebuild_count) == 4 )) || fail "recording inputs after an earlier full rebuild must skip a second rebuild"
after_record_hash=$(<"$state")
[[ $after_record_hash != "$after_conf_hash" ]] || fail "--record must advance stored hash"
pass "--record prevents double rebuild when an earlier full rebuild already ran"

# 9. Failed rebuild propagates non-zero status and keeps the old hash so next run retries.
printf 'COMPRESSION="cat"\n' >"$linked_target"
if FAKE_REBUILD_STATUS=1 run_sync --pacman-hook >/dev/null 2>&1; then
  fail "failed rebuild must exit non-zero"
fi
[[ $(<"$state") == "$after_record_hash" ]] || fail "failed rebuild must not advance stored hash"
run_sync --pacman-hook >/dev/null
(( $(rebuild_count) == 6 )) || fail "next run after failed rebuild must retry and succeed"
[[ $(<"$state") != "$after_record_hash" ]] || fail "successful retry must update stored hash"
pass "failed rebuild preserves old hash and retries on next run"

# 10. No installed kernels skips cleanly even if inputs differ.
rm -rf "$root/usr/lib/modules/7.3.6-1-omarchy"
printf 'COMPRESSION="gzip"\n' >"$linked_target"
run_sync --pacman-hook
(( $(rebuild_count) == 6 )) || fail "missing kernels must skip rebuild"
pass "missing kernels skip rebuild"
