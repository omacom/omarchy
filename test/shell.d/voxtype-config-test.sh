#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

bin_dir="$test_tmp/bin"
mkdir -p "$bin_dir"

cat >"$bin_dir/omarchy-cmd-missing" <<'EOF'
#!/bin/bash
! command -v "$1" >/dev/null 2>&1
EOF
chmod +x "$bin_dir/omarchy-cmd-missing"

cat >"$bin_dir/omarchy-launch-floating-terminal-with-presentation" <<'EOF'
#!/bin/bash
echo "launch:$*" >>"$TEST_LOG"
EOF
chmod +x "$bin_dir/omarchy-launch-floating-terminal-with-presentation"

cat >"$bin_dir/omarchy-restart-shell" <<'EOF'
#!/bin/bash
echo "restart-shell" >>"$TEST_LOG"
EOF
chmod +x "$bin_dir/omarchy-restart-shell"

log="$test_tmp/test.log"

# Test 1: When voxtype is missing, both scripts route to installer
: >"$log"
PATH="$bin_dir:$PATH" TEST_LOG="$log" "$ROOT/bin/omarchy-voxtype-config"
grep -qx "launch:omarchy-voxtype-install" "$log" || fail "missing voxtype routes config to installer"
! grep -q "restart-shell" "$log" || fail "missing voxtype does not restart shell early"
pass "missing voxtype routes config to installer"

: >"$log"
PATH="$bin_dir:$PATH" TEST_LOG="$log" "$ROOT/bin/omarchy-voxtype-model"
grep -qx "launch:omarchy-voxtype-install" "$log" || fail "missing voxtype routes model setup to installer"
pass "missing voxtype routes model setup to installer"

# Test 2: When voxtype is present, run the respective configure/model command
touch "$bin_dir/voxtype"
chmod +x "$bin_dir/voxtype"

: >"$log"
PATH="$bin_dir:$PATH" TEST_LOG="$log" "$ROOT/bin/omarchy-voxtype-config"
grep -qx 'launch:voxtype configure' "$log" || fail "present voxtype runs configure"
grep -qx "restart-shell" "$log" || fail "present voxtype restarts shell after config"
pass "present voxtype runs configure"

: >"$log"
PATH="$bin_dir:$PATH" TEST_LOG="$log" "$ROOT/bin/omarchy-voxtype-model"
grep -qx 'launch:voxtype setup model' "$log" || fail "present voxtype runs model setup"
grep -qx "restart-shell" "$log" || fail "present voxtype restarts shell after model setup"
pass "present voxtype runs model setup"
