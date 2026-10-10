#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_path="$test_tmp/bin"
mkdir -p "$mock_path"

cat >"$mock_path/sudo" <<'EOF'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_TMP/calls"
if [[ ${SUDO_CANCEL:-} == 1 && $* == "true" ]]; then
  kill -s INT "$PPID"
  exit 1
fi
if [[ ${DAEMON_DISABLE_FAIL:-} == 1 && $* == "systemctl disable --now tailscaled.service" ]]; then
  exit 2
fi
if [[ ${SUDO_FAIL:-} == 1 ]]; then
  exit 1
fi
exit 0
EOF

cat >"$mock_path/tailscale" <<'EOF'
#!/bin/bash
printf 'tailscale %s\n' "$*" >>"$TEST_TMP/calls"
EOF

cat >"$mock_path/systemctl" <<'EOF'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$TEST_TMP/calls"
if [[ $* == "list-unit-files --no-legend tailscaled.service" ]]; then
  [[ ${UNIT_QUERY_FAIL:-} != 1 ]] || exit 2
  if [[ ${UNIT_MISSING:-} != 1 ]]; then
    printf 'tailscaled.service enabled enabled\n'
  fi
fi
EOF

cat >"$mock_path/omarchy-plugin-disable" <<'EOF'
#!/bin/bash
printf 'plugin-disable %s\n' "$*" >>"$TEST_TMP/calls"
[[ ${PLUGIN_FAIL:-} != 1 ]]
EOF

cat >"$mock_path/omarchy-webapp-remove" <<'EOF'
#!/bin/bash
printf 'webapp-remove %s\n' "$*" >>"$TEST_TMP/calls"
EOF

cat >"$mock_path/omarchy-pkg-drop" <<'EOF'
#!/bin/bash
printf 'pkg-drop %s\n' "$*" >>"$TEST_TMP/calls"
EOF

chmod +x "$mock_path"/*

run_remove() {
  rm -f "$test_tmp/calls" "$test_tmp/out"
  PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" \
    bash "$ROOT/bin/omarchy-remove-service-tailscale" >"$test_tmp/out" 2>&1 || return $?
}

status=0
SUDO_CANCEL=1 run_remove || status=$?
(( status == 130 )) || fail "cancelled sudo exits 130 so the presentation wrapper skips Done" "status=$status"
[[ -e $test_tmp/calls ]] || fail "cancelled sudo still authenticates"
[[ $(<"$test_tmp/calls") == "sudo true" ]] || fail "cancelled sudo does not tear Tailscale down" "$(<"$test_tmp/calls")"
if grep -q 'Tailscale has been removed.' "$test_tmp/out"; then
  fail "cancelled sudo does not claim Tailscale was removed" "$(<"$test_tmp/out")"
fi
pass "cancelled sudo aborts before teardown"

status=0
SUDO_FAIL=1 run_remove || status=$?
(( status == 1 )) || fail "sudo policy failure keeps its error status" "status=$status"
[[ $(<"$test_tmp/calls") == "sudo true" ]] || fail "sudo policy failure must not tear down"
pass "sudo policy failure remains an error, not cancellation"

status=0
SUDO_FAIL=0 run_remove || status=$?
(( status == 0 )) || fail "authenticated sudo removes Tailscale" "status=$status"
expected=$'sudo true\nsystemctl list-unit-files --no-legend tailscaled.service\ntailscale down\nsystemctl --user disable --now omarchy-tailscale-receive.service\nsudo systemctl disable --now tailscaled.service\nplugin-disable omarchy.tailscale\nwebapp-remove Tailscale\npkg-drop tailscale'
[[ $(<"$test_tmp/calls") == "$expected" ]] || fail "authenticated sudo tears Tailscale down in order" "$(<"$test_tmp/calls")"
grep -qx 'Tailscale has been removed.' "$test_tmp/out" || fail "authenticated sudo reports Tailscale was removed" "$(<"$test_tmp/out")"
pass "authenticated sudo removes Tailscale"

status=0
PLUGIN_FAIL=1 run_remove || status=$?
(( status == 0 )) || fail "plugin disable failure still removes Tailscale" "status=$status"
[[ $(<"$test_tmp/calls") == "$expected" ]] || fail "plugin disable failure does not stop the teardown" "$(<"$test_tmp/calls")"
pass "plugin disable failure does not strand a half-removed Tailscale"

status=0
UNIT_MISSING=1 run_remove || status=$?
(( status == 0 )) || fail "missing daemon unit must not block removal" "status=$status"
if grep -q 'sudo systemctl disable' "$test_tmp/calls"; then
  fail "missing daemon unit must not be disabled"
fi
grep -qx 'pkg-drop tailscale' "$test_tmp/calls" || fail "missing daemon unit must still remove the package"
pass "a missing daemon unit still permits full removal"

status=0
DAEMON_DISABLE_FAIL=1 run_remove || status=$?
(( status == 2 )) || fail "daemon disable failure keeps its error status" "status=$status"
grep -qx 'sudo systemctl disable --now tailscaled.service' "$test_tmp/calls" || fail "daemon failure case must reach disable after authentication"
if grep -q 'pkg-drop\|plugin-disable' "$test_tmp/calls"; then
  fail "daemon disable failure must stop before further cleanup"
fi
pass "daemon disable failure is exercised after successful authentication"

status=0
UNIT_QUERY_FAIL=1 run_remove || status=$?
(( status == 2 )) || fail "unit lookup failure keeps its error status" "status=$status"
[[ $(<"$test_tmp/calls") == $'sudo true\nsystemctl list-unit-files --no-legend tailscaled.service' ]] || fail "lookup failure must stop before teardown"
pass "unit lookup errors stop before teardown"
