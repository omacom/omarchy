#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT
custom_path="$test_tmp/custom installation"
mkdir -p "$test_tmp/bin" "$custom_path/bin" "$custom_path/install/helpers"

# Exercise both sides of the real command's elevation without changing uid.
# Only the root/non-root probe is replaced; sudo arguments and helper lookup
# remain the shipped code. The custom helper stops before any system writes.
sed 's/if (( EUID != 0 )); then/if [[ ${TEST_ELEVATED:-0} != "1" ]]; then/' \
  "$ROOT/bin/omarchy-parent" >"$custom_path/bin/omarchy-parent"
cat >"$custom_path/install/helpers/parent.sh" <<'SH'
printf '%s\n' "$OMARCHY_PATH" "$GUM_INPUT_HEADER_FOREGROUND" "$@" >"$TEST_RESULT"
exit 0
SH

# Model sudo's env_reset: only explicit env arguments survive. Validate the
# selected checkout before allowing the command to source any helper, so a
# regression cannot reach files from an installed Omarchy on the test host.
cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
set -euo pipefail
[[ $1 == "env" ]] || exit 1
shift
assignments=()
while [[ ${1:-} == *=* ]]; do
  assignments+=("$1")
  shift
done
exec env -i PATH="$PATH" TEST_ELEVATED=1 TEST_RESULT="$TEST_RESULT" \
  TEST_EXPECTED_PATH="$TEST_EXPECTED_PATH" "${assignments[@]}" \
  "$TEST_BASH" -c '
    [[ ${OMARCHY_PATH:-} == "$TEST_EXPECTED_PATH" ]] || exit 70
    exec "$@"
  ' _ "$TEST_BASH" "$@"
SH
chmod +x "$test_tmp/bin/sudo"

export TEST_BASH="$BASH" TEST_RESULT="$test_tmp/result" TEST_EXPECTED_PATH="$custom_path"
PATH="$test_tmp/bin:$PATH" OMARCHY_PATH="$custom_path" GUM_INPUT_HEADER_FOREGROUND='#ff77aa' \
  bash "$custom_path/bin/omarchy-parent" wifi kid --user kid ||
  fail "parent elevation preserves a custom installation path through env_reset"

expected=$(printf '%s\n' "$custom_path" '#ff77aa' wifi kid --user kid)
[[ $(<"$TEST_RESULT") == "$expected" ]] ||
  fail "the elevated command loads the correct helper with its theme and arguments intact" "$(<"$TEST_RESULT")"
pass "parent elevation preserves the installation path, gum theme and arguments through env_reset"
