#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_path="$test_tmp/pkg-add-bin"
mkdir -p "$mock_path"

cat >"$mock_path/omarchy-pkg-missing" <<'EOF'
#!/bin/bash
exit 0
EOF

cat >"$mock_path/pacman" <<'EOF'
#!/bin/bash
if [[ $1 == "-S" && ${TEST_INSTALL_STATUS:-0} != "0" ]]; then
  echo "error: failed to commit transaction (invalid or corrupted package (checksum))" >&2
  exit "$TEST_INSTALL_STATUS"
fi
exit 0
EOF

cat >"$mock_path/sudo" <<'EOF'
#!/bin/bash
exec "$@"
EOF

chmod +x "$mock_path"/*

run_pkg_add() {
  PATH="$mock_path:$ROOT/bin:$PATH" XDG_RUNTIME_DIR="$test_tmp" "$@" >"$test_tmp/output" 2>&1
}

hint="Your package database may be out of date. Run 'omarchy update' and try again."

if TEST_INSTALL_STATUS=1 run_pkg_add "$ROOT/bin/omarchy-pkg-add" some-package; then
  fail "a failed install fails omarchy-pkg-add"
fi
grep -qF "$hint" "$test_tmp/output" || fail "a failed install points at omarchy update" "$(cat "$test_tmp/output")"
pass "a failed install suggests updating the package database"

if TEST_INSTALL_STATUS=1 run_pkg_add "$ROOT/bin/omarchy-update-lock" run "$ROOT/bin/omarchy-pkg-add" some-package; then
  fail "a failed install during an update fails omarchy-pkg-add"
fi
if grep -qF "$hint" "$test_tmp/output"; then
  fail "a failed install during an update does not suggest running an update" "$(cat "$test_tmp/output")"
fi
pass "a failed install during an update skips the hint"

run_pkg_add "$ROOT/bin/omarchy-pkg-add" some-package || fail "a successful install succeeds" "$(cat "$test_tmp/output")"
if grep -qF "$hint" "$test_tmp/output"; then
  fail "a successful install shows no hint"
fi
pass "a successful install shows no hint"
