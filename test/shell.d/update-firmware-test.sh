#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-update-firmware must treat fwupdmgr's "nothing to do" exit code (2)
# as success, preserve all other exit codes (including 130 for Ctrl-C), and
# always refresh metadata before updating.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"

cat >"$test_tmp/bin/fwupdmgr" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$FWUPD_TEST_LOG"
if [[ $1 == "update" ]]; then
  exit "${FWUPD_MOCK_STATUS:-0}"
fi
exit 0
EOF

cat >"$test_tmp/bin/sudo" <<'EOF'
#!/bin/bash
if [[ $1 == "install" ]]; then
  exit 0
fi
if [[ $1 == "fwupdmgr" ]]; then
  exec "$@"
fi
exit 1
EOF

chmod +x "$test_tmp/bin/fwupdmgr" "$test_tmp/bin/sudo"

run_case() {
  local mock_status=$1 expected_status=$2 label=$3
  local actual_status=0 calls

  : >"$test_tmp/calls.log"
  FWUPD_MOCK_STATUS=$mock_status \
    FWUPD_TEST_LOG="$test_tmp/calls.log" \
    PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-update-firmware" >"$test_tmp/out" 2>&1 || actual_status=$?

  (( actual_status == expected_status )) ||
    fail "$label (exit code)" "expected $expected_status, got $actual_status; output: $(cat "$test_tmp/out")"

  calls=$(<"$test_tmp/calls.log")
  [[ $calls == $'refresh --force\nupdate' ]] ||
    fail "$label (call order)" "expected refresh --force then update, got: $calls"

  pass "$label"
}

run_case 0 0 "exits 0 when fwupdmgr update succeeds"
run_case 2 0 "exits 0 when fwupdmgr update returns 2 (nothing to update)"
run_case 1 1 "preserves exit code 1 when fwupdmgr update fails"
run_case 3 3 "preserves exit code 3 on other non-zero failures"
run_case 130 130 "preserves exit code 130 when interrupted with Ctrl-C"
