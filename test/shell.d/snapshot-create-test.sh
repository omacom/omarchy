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

cat >"$fake_bin/snapper" <<'STUB'
#!/bin/bash
printf 'snapper %s\n' "$*" >>"$TEST_LOG"
if [[ $* == *"list-configs"* ]]; then
  printf 'config,subvolume\n%s,/home\n' "$TEST_CONFIG"
elif [[ $* == *" create "* ]]; then
  echo "$TEST_ERROR" >&2
  exit 5
fi
STUB

for config in root home; do
  : >"$test_tmp/calls.log"
  status=0
  stderr=$(TEST_LOG="$test_tmp/calls.log" TEST_CONFIG="$config" \
    TEST_ERROR='IO Error (.snapshots is not a btrfs subvolume).' PATH="$fake_bin:$PATH" \
    bash "$snapshot" create 2>&1 >/dev/null) || status=$?

  (( status == 5 )) || fail "snapshot create preserves Snapper's failure status" "got $status"
  grep -qF 'IO Error (.snapshots is not a btrfs subvolume).' <<<"$stderr" ||
    fail "snapshot create preserves the original diagnostic" "$stderr"
  grep -qF "sudo snapper -c \"$config\" get-config" <<<"$stderr" ||
    fail "snapshot recovery identifies the affected config" "$stderr"
  grep -qF 'back it up and move it aside' <<<"$stderr" ||
    fail "snapshot recovery preserves existing snapshot data" "$stderr"
  grep -qF 'sudo btrfs subvolume create <subvolume>/.snapshots' <<<"$stderr" ||
    fail "snapshot recovery explains how to recreate the subvolume" "$stderr"
  ! grep -q ' cleanup ' "$test_tmp/calls.log" ||
    fail "snapshot create does not prune after creation fails"
done
pass "snapshot create explains regular snapshot directories for the affected config"

status=0
stderr=$(TEST_LOG="$test_tmp/calls.log" TEST_CONFIG=root \
  TEST_ERROR='IO Error (No space left on device).' PATH="$fake_bin:$PATH" \
  bash "$snapshot" create 2>&1 >/dev/null) || status=$?
(( status == 5 )) || fail "snapshot create preserves unrelated failure status" "got $status"
[[ $stderr == 'IO Error (No space left on device).' ]] ||
  fail "snapshot create does not suggest subvolume repairs for unrelated failures" "$stderr"
pass "snapshot create preserves unrelated errors without subvolume recovery advice"

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
