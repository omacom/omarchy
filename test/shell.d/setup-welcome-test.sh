#!/bin/bash

set -euo pipefail

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

bin_dir="$test_tmp/bin"
mkdir -p "$bin_dir"
cp "$BASH_SOURCE" "$test_tmp/test.sh"
cp "$(dirname "$BASH_SOURCE")/../../bin/omarchy-setup-welcome" "$bin_dir/omarchy-setup-welcome"
chmod +x "$bin_dir/omarchy-setup-welcome"

cat >"$bin_dir/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf 'notification\n' >>"$TEST_COUNT"
printf '%s\n' "$*" >>"$TEST_LOG"
STUB
chmod +x "$bin_dir/omarchy-notification-send"

export PATH="$bin_dir:$PATH"
export TEST_LOG="$test_tmp/notifications.log"
export TEST_COUNT="$test_tmp/notification-count.log"

assert_lines() {
  local expected=$1
  local actual
  actual=$(wc -l <"$TEST_COUNT")
  [[ $actual -eq $expected ]] || {
    echo "expected $expected notifications, got $actual" >&2
    cat "$TEST_LOG" >&2
    exit 1
  }
}

"$bin_dir/omarchy-setup-welcome"
assert_lines 1
grep -Fq -- '--exec omarchy-menu-keybindings' "$TEST_LOG"
! grep -Fq -- '--exec omarchy-menu$' "$TEST_LOG"

: >"$TEST_LOG"
: >"$TEST_COUNT"
"$bin_dir/omarchy-setup-welcome" --all
assert_lines 2
grep -Fq -- '--exec omarchy-menu-keybindings' "$TEST_LOG"
grep -Fq -- '--exec omarchy-menu' "$TEST_LOG"

if "$bin_dir/omarchy-setup-welcome" --unexpected >/dev/null 2>&1; then
  echo "unexpected option was accepted" >&2
  exit 1
fi

echo "setup welcome tests passed"
