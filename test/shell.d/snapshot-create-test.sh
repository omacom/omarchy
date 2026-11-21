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

cat >"$fake_bin/limine-snapper-sync" <<'STUB'
#!/bin/bash
printf 'limine-snapper-sync %s\n' "$*" >>"$TEST_LOG"
[[ -z ${FAKE_SYNC_FAILS:-} ]]
STUB
chmod +x "$fake_bin/limine-snapper-sync"

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
fi
STUB
chmod +x "$fake_bin/snapper"

: >"$test_tmp/calls.log"
stdout=$(TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" \
  bash "$snapshot" create)

grep -qFx 'snapper -c root create -c number -d 4.0.0' "$test_tmp/calls.log" ||
  fail "snapshot create snapshots each configured subvolume" "$(cat "$test_tmp/calls.log")"
grep -qFx 'snapper -c root cleanup number' "$test_tmp/calls.log" ||
  fail "snapshot create prunes older snapshots"
pass "snapshot create snapshots every configured Snapper config"

grep -q '^limine-snapper-sync' "$test_tmp/calls.log" ||
  fail "snapshot create syncs the Limine boot menu" "$(cat "$test_tmp/calls.log")"
grep -qF 'Snapshots can be selected during boot.' <<<"$stdout" ||
  fail "snapshot create reports a bootable snapshot after a good sync" "$stdout"
pass "snapshot create calls the snapshot bootable once the boot menu is synced"

# A rejected sync leaves the snapshot out of the boot menu (#16498), so it must
# not be called bootable, and must not fail the update that took it.
set +e
output=$(FAKE_SYNC_FAILS=1 TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" \
  bash "$snapshot" create 2>&1)
status=$?
set -e

(( status == 0 )) || fail "a failed boot-menu sync does not fail snapshot create" "got $status"
! grep -qF 'Snapshots can be selected during boot.' <<<"$output" ||
  fail "snapshot create does not call a snapshot bootable after a failed sync" "$output"
grep -qF 'journalctl -t limine-snapper-sync' <<<"$output" ||
  fail "snapshot create points at the sync journal when the sync fails" "$output"
pass "snapshot create warns instead of claiming a bootable snapshot when the sync fails"

# Snapper being deliberately absent is the one skip that stays quiet, and the
# update has to keep treating it as such.
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
grep -qF 'omarchy-snapshot create || (($? == 127))' "$ROOT/bin/omarchy-update" ||
  fail "update ignores only the missing-snapper exit code"
pass "snapshot create keeps the quiet 127 path for systems without snapper"

# The quattro upgrade runs under set -e, so a failed snapshot has to be warned
# past there too or it aborts the whole upgrade at the snapshot step.
grep -qF 'omarchy-snapshot create || (($? == 127))' "$ROOT/bin/omarchy-upgrade-to-quattro" ||
  fail "upgrade ignores only the missing-snapper exit code"
grep -qF 'Continuing the upgrade without a snapshot' "$ROOT/bin/omarchy-upgrade-to-quattro" ||
  fail "upgrade continues past a failed snapshot instead of aborting"
pass "upgrade to quattro survives a failed snapshot without passing it off"
