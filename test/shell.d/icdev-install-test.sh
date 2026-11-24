#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mock_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$mock_bin" "$test_home"

# Run the real omarchy-mise-install in a throwaway home. Only mise itself and
# the ICDEV it would fetch are stubbed: each records how it was called.
cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
echo "mise $*" >>"$OMARCHY_TEST_CALLS"
if [[ $1 == "x" ]]; then
  # mise x <package> -- <bin> <args...>
  echo "icdev ${*:5}" >>"$OMARCHY_TEST_CALLS"
  [[ ${OMARCHY_TEST_SETUP_FAIL:-0} == "1" ]] && { echo "setup: postgres failed"; exit 1; }
fi
exit 0
SH
chmod +x "$mock_bin/mise"

run_installer() {
  : >"$calls"
  rm -f "$test_home/.local/bin/icdev"
  HOME="$test_home" OMARCHY_PATH="$ROOT" OMARCHY_TEST_CALLS="$calls" \
    PATH="$mock_bin:$ROOT/bin:/usr/bin:/bin" \
    "$ROOT/bin/omarchy-install-ai-icdev" >"$test_tmp/output" 2>&1
}

run_installer || fail "installing ICDEV succeeds" "$(cat "$test_tmp/output")"
[[ -x $test_home/.local/bin/icdev ]] || fail "the icdev wrapper is written to ~/.local/bin"
grep -q 'pipx:icdev\[extras=postgresql\]' "$test_home/.local/bin/icdev" || fail "the wrapper installs ICDEV with its PostgreSQL driver"
grep -qx 'icdev omarchy setup' "$calls" || fail "setup runs through the new wrapper" "$(cat "$calls")"
grep -q 'ICDEV has been installed.' "$test_tmp/output" || fail "a finished install says so"
pass "a fresh install writes the wrapper and runs icdev omarchy setup"

if PATH="$mock_bin:$ROOT/bin:/usr/bin:/bin" command -v uv >/dev/null 2>&1; then
  skip "uv is installed first when it is missing (a system uv is on this host)"
else
  grep -qx 'mise use -g --quiet uv@latest' "$calls" || fail "uv is installed for the pipx backend" "$(cat "$calls")"
  grep -q 'global mise config' "$test_tmp/output" || fail "installing uv says it changes the global mise config" "$(cat "$test_tmp/output")"
  pass "uv is installed first when it is missing, and the output says it goes into the global mise config"
fi

printf '#!/bin/bash\nexit 0\n' >"$mock_bin/uv"
chmod +x "$mock_bin/uv"
run_installer || fail "installing with uv present succeeds" "$(cat "$test_tmp/output")"
if grep -q 'uv@latest' "$calls"; then
  fail "an installed uv is left alone" "$(cat "$calls")"
fi
rm -f "$mock_bin/uv"
pass "an installed uv is left alone"

if OMARCHY_TEST_SETUP_FAIL=1 run_installer; then
  fail "a failed setup fails the installer"
fi
grep -q 'setup: postgres failed' "$test_tmp/output" || fail "the setup failure is visible"
if grep -q 'ICDEV has been installed.' "$test_tmp/output"; then
  fail "a failed setup does not report a finished install"
fi
pass "a setup failure stays visible and is not reported as installed"
