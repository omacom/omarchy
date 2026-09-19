#!/bin/bash

set -euo pipefail

# Backfill .hermes-bootstrap-complete on a usable Hermes Desktop runtime that
# the packaged install path left unmarked. Stub the package probe and a venv;
# never invoke install.sh or a desktop session.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

for command in git jq; do require_command "$command"; done

migration="$ROOT/migrations/1789746834.sh"
[[ -f $migration ]] || fail "Hermes bootstrap marker migration exists"
[[ $(stat -c %a "$migration") == "644" ]] || fail "migration is a plain 0644 file"
! grep -q '^#!' "$migration" || fail "migration has no shebang"

test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == hermes-desktop && ${OMARCHY_TEST_DESKTOP_INSTALLED:-0} == 1 ]]
SH
cat >"$mock_bin/install.sh" <<'SH'
#!/bin/bash
printf 'install.sh\n' >>"$OMARCHY_TEST_CALLS"
exit 1
SH
chmod +x "$mock_bin"/*

setup_runtime() {
  local home=$1
  local hermes_home=$home/.hermes
  local runtime=$hermes_home/hermes-agent

  mkdir -p "$runtime/venv/bin" "$home/.local/bin"
  git -C "$runtime" init -q -b main
  printf 'runtime\n' >"$runtime/README"
  git -C "$runtime" add README
  git -C "$runtime" -c user.name=Test -c user.email=test@example.invalid commit -qm fixture
  cat >"$runtime/venv/bin/hermes" <<'SH'
#!/bin/bash
if [[ ${1:-} == chat && ${2:-} == --help ]]; then
  echo "[-q QUERY, --query QUERY] [--tui]"
  exit 0
fi
echo "hermes-agent 0.0.0-test"
SH
  chmod +x "$runtime/venv/bin/hermes"
  printf '#!/bin/bash\nexec /usr/bin/python3 "$@"\n' >"$runtime/venv/bin/python"
  chmod +x "$runtime/venv/bin/python"
  printf '#!/bin/bash\nexec "%s/venv/bin/hermes" "$@"\n' "$runtime" >"$home/.local/bin/hermes"
  chmod +x "$home/.local/bin/hermes"
}

run_migration() {
  local home=$1
  : >"$test_tmp/calls"
  OMARCHY_TEST_DESKTOP_INSTALLED="${OMARCHY_TEST_DESKTOP_INSTALLED:-1}" \
    OMARCHY_TEST_CALLS="$test_tmp/calls" \
    HOME="$home" \
    PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    bash -euo pipefail "$migration"
}

assert_marker() {
  local runtime=$1
  local commit
  commit=$(git -C "$runtime" rev-parse HEAD)
  [[ -f $runtime/.hermes-bootstrap-complete ]] || fail "$2: bootstrap marker is missing"
  jq -e --arg commit "$commit" '
    .schemaVersion == 1
    and .pinnedCommit == $commit
    and .pinnedBranch == "main"
    and (.completedAt | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]+)?Z$"))
  ' "$runtime/.hermes-bootstrap-complete" >/dev/null ||
    fail "$2: bootstrap marker schema" "$(cat "$runtime/.hermes-bootstrap-complete")"
}

home=$test_tmp/no-desktop
setup_runtime "$home"
OMARCHY_TEST_DESKTOP_INSTALLED=0 run_migration "$home" >/dev/null || fail "migration exits clean without Hermes Desktop"
[[ ! -e $home/.hermes/hermes-agent/.hermes-bootstrap-complete ]] || fail "a machine without Hermes Desktop is left unmarked"
[[ ! -s $test_tmp/calls ]] || fail "migration never reaches install.sh"
pass "migration only applies where Omarchy installed Hermes Desktop"

home=$test_tmp/unusable
mkdir -p "$home/.hermes/hermes-agent"
run_migration "$home" >/dev/null || fail "migration exits clean without a usable runtime"
[[ ! -e $home/.hermes/hermes-agent/.hermes-bootstrap-complete ]] || fail "an unusable runtime is not stamped"
[[ ! -s $test_tmp/calls ]] || fail "an unusable runtime does not run install.sh"
pass "migration leaves an unusable runtime unmarked"

home=$test_tmp/usable
setup_runtime "$home"
runtime=$home/.hermes/hermes-agent
run_migration "$home" >/dev/null || fail "migration stamps a usable unmarked runtime"
assert_marker "$runtime" "usable unmarked runtime"
[[ ! -s $test_tmp/calls ]] || fail "stamping does not re-run install.sh"
OMARCHY_TEST_DESKTOP_INSTALLED=1 HOME="$home" PATH="$home/.local/bin:$mock_bin:$ROOT/bin:$PATH" \
  bash "$ROOT/bin/omarchy-install-hermes-cli" --check ||
  fail "omarchy-install-hermes-cli --check after migration"
pass "migration writes the desktop bootstrap marker without reinstalling"

before=$(cat "$runtime/.hermes-bootstrap-complete")
run_migration "$home" >/dev/null || fail "rerunning the migration succeeds"
[[ $(cat "$runtime/.hermes-bootstrap-complete") == "$before" ]] || fail "rerunning the migration leaves the same marker"
pass "migration is idempotent once the marker exists"
