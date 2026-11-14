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

cat >"$fake_bin/swapon" <<'STUB'
#!/bin/bash
[[ ${FAIL_SWAP_PROBE:-0} == "0" ]] || exit 1
echo '{"swapdevices":[]}'
STUB
chmod +x "$fake_bin/swapon"

cat >"$fake_bin/findmnt" <<'STUB'
#!/bin/bash
if [[ ${@: -1} == "/swapfile" && ${OTHER_SWAP_FS:-0} == "1" ]]; then
  echo other-filesystem
else
  echo root-filesystem
fi
STUB
chmod +x "$fake_bin/findmnt"

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
TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" \
  bash "$snapshot" create >/dev/null

grep -qFx 'snapper -c root create -c number -d 4.0.0' "$test_tmp/calls.log" ||
  fail "snapshot create snapshots each configured subvolume" "$(cat "$test_tmp/calls.log")"
grep -qFx 'snapper -c root cleanup number' "$test_tmp/calls.log" ||
  fail "snapshot create prunes older snapshots"
pass "snapshot create snapshots every configured Snapper config"

cat >"$fake_bin/swapon" <<'STUB'
#!/bin/bash
[[ ${FAIL_SWAP_PROBE:-0} == "0" ]] || exit 1
echo '{"swapdevices":[{"name":"/swapfile","type":"file"}]}'
STUB

cat >"$fake_bin/btrfs" <<'STUB'
#!/bin/bash
[[ $* == "inspect-internal rootid /" || $* == "inspect-internal rootid /swapfile" ]] || exit 1
echo 256
STUB
chmod +x "$fake_bin/swapon" "$fake_bin/btrfs"

: >"$test_tmp/calls.log"
set +e
stderr=$(TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" \
  bash "$snapshot" create 2>&1 >/dev/null)
status=$?
set -e

(( status != 0 )) || fail "snapshot create fails before snapshotting a subvolume with an active swapfile"
grep -qF 'Cannot snapshot / while the active swapfile /swapfile is inside its Btrfs subvolume.' <<<"$stderr" ||
  fail "snapshot create explains the active Btrfs swapfile failure" "$stderr"
! grep -q '^snapper -c .* create ' "$test_tmp/calls.log" ||
  fail "snapshot create does not ask Snapper to snapshot a subvolume with an active swapfile"
pass "snapshot create identifies active swapfiles that prevent Btrfs snapshots"

: >"$test_tmp/calls.log"
OTHER_SWAP_FS=1 TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" bash "$snapshot" create >/dev/null
grep -q '^snapper -c root create ' "$test_tmp/calls.log" || fail "equal root IDs on another filesystem do not block snapshots"
: >"$test_tmp/calls.log"
if FAIL_SWAP_PROBE=1 TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" bash "$snapshot" create >"$test_tmp/out" 2>"$test_tmp/errors"; then
  fail "a failed swap probe cannot masquerade as an empty swap list"
fi
grep -Fq 'Could not inspect active swapfiles' "$test_tmp/errors" || fail "probe failure has a useful diagnostic"
! grep -q '^snapper -c root create ' "$test_tmp/calls.log" || fail "a failed probe starts no snapshot"
pass "snapshot checks distinguish filesystem identity and failed probes"

cat >"$fake_bin/btrfs" <<'STUB'
#!/bin/bash
case "$*" in
  "inspect-internal rootid /") echo 256 ;;
  "inspect-internal rootid /swapfile") echo 257 ;;
  *) exit 1 ;;
esac
STUB

: >"$test_tmp/calls.log"
TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" \
  bash "$snapshot" create >/dev/null

grep -qFx 'snapper -c root create -c number -d 4.0.0' "$test_tmp/calls.log" ||
  fail "snapshot create allows swapfiles isolated in their own Btrfs subvolume"
pass "snapshot create allows active swapfiles in a different Btrfs subvolume"

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
