#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"
calls="$test_tmp/calls"

cat >"$test_tmp/bin/omarchy-shell" <<'SCRIPT'
#!/bin/bash
case "$2" in
listScreensavers)
  printf '%s\n' '[{"id":"omarchy.screensaver","name":"Omarchy","selected":true},{"id":"com.example.aquarium","name":"ASCII Aquarium","selected":false}]'
  ;;
setScreensaver)
  printf 'set:%s\n' "$3" >>"$CALLS"
  printf 'ok\n'
  ;;
screensaverLauncher)
  printf '%s\n' "$TEST_LAUNCHER"
  ;;
*) exit 1 ;;
esac
SCRIPT

cat >"$test_tmp/launcher" <<'SCRIPT'
#!/bin/bash
printf 'launch:%s\n' "$*" >>"$CALLS"
SCRIPT
chmod +x "$test_tmp/bin/omarchy-shell" "$test_tmp/launcher"

CALLS="$calls" TEST_LAUNCHER="$test_tmp/launcher" PATH="$test_tmp/bin:$PATH" \
  "$ROOT/bin/omarchy-screensaver-select" com.example.aquarium --test >/dev/null

grep -qx 'set:com.example.aquarium' "$calls" || fail "screensaver selector persists the selected id"
grep -qx 'launch:force' "$calls" || fail "screensaver selector launches the selected plugin for testing"
pass "screensaver selector chooses and tests a discovered plugin"
