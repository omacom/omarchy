#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

snapshot="$ROOT/bin/omarchy-snapshot"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"

cat >"$fake_bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
chmod +x "$fake_bin/sudo"

cat >"$fake_bin/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
exit 1
STUB
chmod +x "$fake_bin/omarchy-cmd-missing"

cat >"$fake_bin/omarchy-version" <<'STUB'
#!/bin/bash
echo 4.0.0
STUB
chmod +x "$fake_bin/omarchy-version"

# Snapper with no configs: list-configs prints only the CSV header.
cat >"$fake_bin/snapper" <<'STUB'
#!/bin/bash
printf 'snapper %s\n' "$*" >>"$TEST_LOG"
if [[ "$*" == *"list-configs"* ]]; then
  echo "config,subvolume"
fi
STUB
chmod +x "$fake_bin/snapper"

# A snapshot that silently creates nothing reads as a successful snapshot, so
# an unconfigured Snapper has to fail loudly instead of passing for a backup.
: >"$test_tmp/calls.log"
set +e
stderr=$(TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" \
  bash "$snapshot" create 2>&1 >/dev/null)
status=$?
set -e

(( status != 0 )) || fail "snapshot create fails when Snapper has no configs"
grep -qF 'No Snapper configs found' <<<"$stderr" ||
  fail "snapshot create reports that no snapshot was created" "$stderr"
! grep -q '^snapper -c .* create ' "$test_tmp/calls.log" ||
  fail "snapshot create does not invent a config to snapshot"
pass "snapshot create fails loudly when Snapper is installed but unconfigured"

cat >"$fake_bin/snapper" <<'STUB'
#!/bin/bash
printf 'snapper %s\n' "$*" >>"$TEST_LOG"
if [[ "$*" == *"list-configs"* ]]; then
  echo "config,subvolume"
  echo "root,/"
elif [[ "$*" == *" create "*" -p" ]]; then
  echo 9
fi
STUB
chmod +x "$fake_bin/snapper"

: >"$test_tmp/calls.log"
TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" \
  bash "$snapshot" create >/dev/null

grep -qFx 'snapper -c root create -c number -d 4.0.0 -p' "$test_tmp/calls.log" ||
  fail "snapshot create snapshots each configured subvolume" "$(cat "$test_tmp/calls.log")"
grep -qFx 'snapper -c root cleanup number' "$test_tmp/calls.log" ||
  fail "snapshot create prunes older snapshots"
pass "snapshot create snapshots every configured Snapper config"

# On systemd-boot an update only goes ahead once its rollback point boots: the
# new root snapshot must have an entry after the sync.
printf '#!/bin/bash\necho systemd-boot\n' >"$fake_bin/omarchy-boot-backend"
printf '#!/bin/bash\nexit 0\n' >"$fake_bin/omarchy-boot-sync"
chmod +x "$fake_bin/omarchy-boot-backend" "$fake_bin/omarchy-boot-sync"
mkdir -p "$test_tmp/store"
touch "$test_tmp/snapper-plugin"
export OMARCHY_BOOT_SYSTEMD_MARKER="$test_tmp/snapper-plugin"
printf 'omarchy\tOmarchy\nsnapshot-9\tSnapshot 9\n' >"$test_tmp/store/entries"
TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" OMARCHY_BOOT_STORE="$test_tmp/store" \
  bash "$snapshot" create >/dev/null 2>&1 || fail "a snapshot with its boot entry succeeds"
printf 'omarchy\tOmarchy\nsnapshot-8\tSnapshot 8\n' >"$test_tmp/store/entries"
if TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" OMARCHY_BOOT_STORE="$test_tmp/store" \
  bash "$snapshot" create >/dev/null 2>&1; then
  fail "a snapshot without a boot entry fails"
fi
pass "on systemd-boot, snapshot create fails unless the new snapshot has a boot entry"

# Between the trial boot and the finish, systemd-boot starts the machine but
# nothing pins snapshots to its boot images yet: the update goes ahead on the
# snapshot Limine lists.
rm "$test_tmp/snapper-plugin"
TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" OMARCHY_BOOT_STORE="$test_tmp/store" \
  bash "$snapshot" create >/dev/null 2>&1 || fail "a snapshot while the switch finishes succeeds without a systemd-boot entry"
unset OMARCHY_BOOT_SYSTEMD_MARKER
rm "$fake_bin/omarchy-boot-backend" "$fake_bin/omarchy-boot-sync"
pass "until the switch finishes, snapshot create needs no systemd-boot entry"

# Snapper being deliberately absent has its own exit status, which the update
# lets pass quietly (update-sequence-test.sh holds it to that).
cat >"$fake_bin/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$fake_bin/omarchy-cmd-missing"

set +e
TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" \
  bash "$snapshot" create >/dev/null 2>&1
status=$?
set -e

(( status == 127 )) || fail "snapshot create exits 127 without snapper" "got $status"
pass "snapshot create keeps the quiet 127 path for systems without snapper"

# The quattro upgrade runs under set -e, so a failed snapshot has to be warned
# past there too or it aborts the whole upgrade at the snapshot step.
grep -qF 'omarchy-snapshot create || (($? == 127))' "$ROOT/bin/omarchy-upgrade-to-quattro" ||
  fail "upgrade ignores only the missing-snapper exit code"
grep -qF 'Continuing the upgrade without a snapshot' "$ROOT/bin/omarchy-upgrade-to-quattro" ||
  fail "upgrade continues past a failed snapshot instead of aborting"
pass "upgrade to quattro survives a failed snapshot without passing it off"
