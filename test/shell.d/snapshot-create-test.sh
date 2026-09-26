#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

snapshot="$ROOT/bin/omarchy-snapshot"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin" "$test_tmp/snapper-configs"

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

# Snapper with no configs: list-configs prints only the CSV header, exit 0.
# No config file on disk — the setup hint is safe to print.
cat >"$fake_bin/snapper" <<'STUB'
#!/bin/bash
printf 'snapper %s\n' "$*" >>"$TEST_LOG"
if [[ "$*" == *"list-configs"* ]]; then
  echo "config,subvolume"
  exit 0
fi
STUB
chmod +x "$fake_bin/snapper"

: >"$test_tmp/calls.log"
set +e
stderr=$(
  TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" \
    OMARCHY_SNAPPER_CONFIG_PATH="$test_tmp/snapper-configs/root" \
    OMARCHY_SNAPPER_CONF_PATH="$test_tmp/snapper.conf" \
    bash "$snapshot" create 2>&1 >/dev/null
)
status=$?
set -e

(( status == 1 )) || fail "snapshot create fails when Snapper has no configs" "got $status"
grep -qF 'No Snapper configs found' <<<"$stderr" ||
  fail "snapshot create reports that no snapshot was created" "$stderr"
grep -qF 'install/config/snapper.sh' <<<"$stderr" ||
  fail "snapshot create points at snapper setup only when no config file exists" "$stderr"
! grep -q '^snapper -c .* create ' "$test_tmp/calls.log" ||
  fail "snapshot create does not invent a config to snapshot"
pass "snapshot create fails loudly when Snapper is installed but unconfigured"

# Header-only list while a root config file already exists must not recommend
# snapper.sh — that script overwrites the file (#10421 remainder).
: >"$test_tmp/snapper-configs/root"
: >"$test_tmp/calls.log"
set +e
stderr=$(
  TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" \
    OMARCHY_SNAPPER_CONFIG_PATH="$test_tmp/snapper-configs/root" \
    OMARCHY_SNAPPER_CONF_PATH="$test_tmp/snapper.conf" \
    bash "$snapshot" create 2>&1 >/dev/null
)
status=$?
set -e

(( status == 1 )) || fail "snapshot create fails when a config file is unlisted" "got $status"
grep -qF 'No Snapper configs found' <<<"$stderr" ||
  fail "snapshot create still reports that no snapshot was created" "$stderr"
grep -qF "$test_tmp/snapper-configs/root" <<<"$stderr" ||
  fail "snapshot create names the existing config file" "$stderr"
grep -qF "$test_tmp/snapper.conf" <<<"$stderr" ||
  fail "snapshot create points at SNAPPER_CONFIGS registration" "$stderr"
! grep -qF 'install/config/snapper.sh' <<<"$stderr" ||
  fail "snapshot create does not suggest overwriting an existing root config" "$stderr"
! grep -q '^snapper -c .* create ' "$test_tmp/calls.log" ||
  fail "snapshot create does not invent a config when the file is unlisted"
pass "snapshot create does not recommend snapper.sh when a root config already exists"

# sudo failure must not be reported as "no configs" — that path used to run
# install/config/snapper.sh, which overwrites a working root config.
cat >"$fake_bin/sudo" <<'STUB'
#!/bin/bash
echo "sudo: a terminal is required to read the password" >&2
echo "sudo: a password is required" >&2
exit 1
STUB
chmod +x "$fake_bin/sudo"

: >"$test_tmp/calls.log"
set +e
stderr=$(
  TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" \
    OMARCHY_PATH=/usr/share/omarchy \
    OMARCHY_SNAPPER_CONFIG_PATH="$test_tmp/snapper-configs/root" \
    bash "$snapshot" create 2>&1 >/dev/null
)
status=$?
set -e

(( status == 1 )) || fail "snapshot create fails when sudo cannot list configs" "got $status"
grep -qF 'Could not list Snapper configs.' <<<"$stderr" ||
  fail "snapshot create reports a list failure instead of empty configs" "$stderr"
! grep -qF 'is sudo available' <<<"$stderr" ||
  fail "list-failure message stays cause-neutral" "$stderr"
! grep -qF 'No Snapper configs found' <<<"$stderr" ||
  fail "snapshot create does not claim configs are missing when sudo failed" "$stderr"
! grep -qF 'install/config/snapper.sh' <<<"$stderr" ||
  fail "snapshot create does not suggest overwriting snapper config after sudo failure" "$stderr"
! grep -q '^snapper ' "$test_tmp/calls.log" ||
  fail "snapshot create does not reach snapper when sudo fails"
pass "snapshot create distinguishes sudo failure from missing configs"

# D-Bus / snapper failure after sudo succeeds must use the same neutral message.
cat >"$fake_bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
chmod +x "$fake_bin/sudo"

cat >"$fake_bin/snapper" <<'STUB'
#!/bin/bash
printf 'snapper %s\n' "$*" >>"$TEST_LOG"
if [[ "$*" == *"list-configs"* ]]; then
  echo "Failure (org.freedesktop.DBus.Error.FileNotFound)." >&2
  exit 1
fi
STUB
chmod +x "$fake_bin/snapper"

: >"$test_tmp/calls.log"
set +e
stderr=$(
  TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" \
    bash "$snapshot" create 2>&1 >/dev/null
)
status=$?
set -e

(( status == 1 )) || fail "snapshot create fails when snapper cannot list configs" "got $status"
grep -qF 'Could not list Snapper configs.' <<<"$stderr" ||
  fail "snapshot create reports a list failure for snapper errors" "$stderr"
! grep -qF 'is sudo available' <<<"$stderr" ||
  fail "snapper list failure does not blame sudo" "$stderr"
! grep -qF 'No Snapper configs found' <<<"$stderr" ||
  fail "snapper list failure is not reported as missing configs" "$stderr"
! grep -qF 'install/config/snapper.sh' <<<"$stderr" ||
  fail "snapper list failure does not suggest overwriting snapper config" "$stderr"
pass "snapshot create distinguishes snapper list failure from missing configs"

# Restore happy-path stubs.
cat >"$fake_bin/snapper" <<'STUB'
#!/bin/bash
printf 'snapper %s\n' "$*" >>"$TEST_LOG"
if [[ "$*" == *"list-configs"* ]]; then
  echo "config,subvolume"
  echo "root,/"
  exit 0
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
