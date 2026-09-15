#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1789490499.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/id" <<'STUB'
#!/bin/bash
printf '%s\n' "${STUB_GROUPS:-wheel}"
STUB
cat >"$stub_bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
[[ ${STUB_VOXTYPE_INSTALLED:-1} == "1" ]]
STUB
cat >"$stub_bin/voxtype" <<'STUB'
#!/bin/bash
[[ $1 == "config" && $2 == "get" && $3 == "hotkey.enabled" ]] || exit 2
printf '%s\n' "${STUB_HOTKEY_ENABLED:-false}"
STUB
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
cat >"$stub_bin/gpasswd" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${GPASSWD_CALLS:?}"
STUB
cat >"$stub_bin/omarchy-state" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${STATE_CALLS:?}"
STUB
chmod +x "$stub_bin"/*

gpasswd_calls="$test_dir/gpasswd-calls"
state_calls="$test_dir/state-calls"

run_migration() {
  rm -f "$gpasswd_calls" "$state_calls"
  USER=tester STUB_GROUPS="$1" STUB_HOTKEY_ENABLED="${2:-false}" STUB_VOXTYPE_INSTALLED="${3:-1}" \
    GPASSWD_CALLS="$gpasswd_calls" STATE_CALLS="$state_calls" \
    PATH="$stub_bin:$PATH" bash -euo pipefail "$migration"
}

run_migration "wheel" true >/dev/null
grep -qxF -- "-a tester input" "$gpasswd_calls" || fail "migration restores input for the Voxtype hotkey"
grep -qxF "set reboot-required" "$state_calls" || fail "migration flags the session change for reboot"
pass "migration restores input for an opted-in Voxtype hotkey"

run_migration "wheel input" true >/dev/null
[[ ! -e $gpasswd_calls ]] || fail "migration does not re-add membership the user already has"
[[ ! -e $state_calls ]] || fail "migration does not flag a reboot when nothing changed"
pass "migration is idempotent once input membership is present"

run_migration "wheel" false >/dev/null
[[ ! -e $gpasswd_calls ]] || fail "migration leaves the compositor-bound default out of the input group"
[[ ! -e $state_calls ]] || fail "the compositor-bound default does not flag a reboot"
pass "migration keeps Omarchy's default Voxtype setup out of the input group"

run_migration "wheel" true 0 >/dev/null
[[ ! -e $gpasswd_calls ]] || fail "migration does nothing when Voxtype is not installed"
[[ ! -e $state_calls ]] || fail "an absent Voxtype does not flag a reboot"
pass "migration does nothing when Voxtype is not installed"
