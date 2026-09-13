#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/config"
export TEST_LOG="$test_dir/calls" XDG_CONFIG_HOME="$test_dir/config" OMARCHY_PATH="$ROOT"
export TEST_CONTAINERS="" TEST_VOLUMES="" TEST_LOAD_STATE=not-found TEST_ENGINE_FAIL=0
cat >"$test_dir/bin/podman" <<'SH'
#!/bin/bash
echo "podman $*" >>"$TEST_LOG"
[[ $TEST_ENGINE_FAIL == 0 ]] || exit 125
case "$*" in
  '--remote=false info') ;;
  '--remote=false ps --all --format {{.Names}}') printf '%s\n' "$TEST_CONTAINERS" ;;
  '--remote=false volume ls --format {{.Name}}') printf '%s\n' "$TEST_VOLUMES" ;;
  *) exit 99 ;;
esac
SH
cat >"$test_dir/bin/systemctl" <<'SH'
#!/bin/bash
echo "systemctl $*" >>"$TEST_LOG"
[[ $* != *'--property=LoadState'* ]] || echo "$TEST_LOAD_STATE"
exit 0
SH
chmod +x "$test_dir/bin/"*
export PATH="$test_dir/bin:$PATH"

run_install() {
  : >"$TEST_LOG"
  "$ROOT/bin/omarchy-install-podman-dbs" "$@" >"$test_dir/output" 2>&1
}

for collision in redis omarchy-db-redis; do
  TEST_CONTAINERS=$collision
  ! run_install Redis || fail "existing $collision container must block installation"
  [[ ! -e $XDG_CONFIG_HOME/containers/systemd/omarchy-db-redis.container ]] || fail "container conflict wrote definitions"
done
TEST_CONTAINERS="" TEST_VOLUMES=omarchy-db-redis-data
! run_install Redis || fail "existing data volume must block installation"
TEST_VOLUMES="" TEST_LOAD_STATE=loaded
! run_install Redis || fail "existing systemd service must block installation"
TEST_LOAD_STATE=not-found TEST_ENGINE_FAIL=1
! run_install Redis || fail "engine query failure must block installation"
TEST_ENGINE_FAIL=0
! run_install Redis invalid || fail "invalid later selection must block entire batch"
! run_install MySQL MariaDB || fail "conflicting default ports must block entire batch"
[[ ! -e $XDG_CONFIG_HOME/containers/systemd/omarchy-db-redis.container ]] || fail "failed preflight wrote definitions"
pass "existing workloads and failed preflight are preserved"

run_install Redis PostgreSQL Redis || fail "database service installation" "$(cat "$test_dir/output")"
[[ $(grep -c '^systemctl --user start omarchy-db-redis.service$' "$TEST_LOG") == 1 ]] || fail "duplicate selection started twice"
[[ -f $XDG_CONFIG_HOME/containers/systemd/omarchy-db-postgres18-data.volume ]] || fail "persistent volume definition missing"
[[ -f $XDG_CONFIG_HOME/systemd/user/omarchy-db-redis.service.d/10-omarchy-lifecycle.conf ]] || fail "safe lifecycle override missing"
[[ $(stat -c %a "$XDG_CONFIG_HOME/containers/systemd/omarchy-db-redis.container") == 600 ]] || fail "database definition is not private"
! grep -q 'docker\|enable\|podman run' "$TEST_LOG" || fail "installer depends on Docker or bypasses Quadlet"
printf '\n# user customization\n' >>"$XDG_CONFIG_HOME/containers/systemd/omarchy-db-redis.container"
! run_install Redis || fail "reinstall must preserve custom definitions"
grep -q '# user customization' "$XDG_CONFIG_HOME/containers/systemd/omarchy-db-redis.container" || fail "custom definition overwritten"
pass "Quadlet install is native, private, deduplicated and preserves customization"

# Use the real generator to catch unsupported keys and accidental loss of
# persistent mounts, local-only ports, or protection against name replacement.
generator=/usr/lib/systemd/system-generators/podman-system-generator
if [[ -x $generator ]]; then
  QUADLET_UNIT_DIRS="$ROOT/default/podman/databases" "$generator" --user --dryrun >"$test_dir/generated" 2>"$test_dir/generator-log"
  [[ $(grep -c '^ExecStart=.*podman.* run ' "$test_dir/generated") == 6 ]] || fail "not all database units generated"
  [[ $(grep -c '^ExecStart=.*podman --remote=false volume create ' "$test_dir/generated") == 6 ]] || fail "volume units may target a remote engine"
  [[ $(grep -c '^ExecStart=.*--replace=false.*--cidfile=' "$test_dir/generated") == 6 ]] || fail "container identity guard missing"
  [[ $(grep -c '^ExecStart=.*--publish 127.0.0.1:' "$test_dir/generated") == 6 ]] || fail "database exposed beyond localhost"
  ! grep -q '^After=podman-user-wait-network-online' "$test_dir/generated" || fail "database waits for an inactive network target"
  pass "all six definitions generate rootless database services"
fi
