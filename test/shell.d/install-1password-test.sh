#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

for command in omarchy-pkg-add sudo; do
  printf '#!/bin/bash\n' >"$mock_bin/$command"
done

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ $1 == "chromium" ]]
SH

cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
printf 'launch:%s\n' "$*" >"$OMARCHY_TEST_LOG"
SH

chmod +x "$mock_bin"/*

launch_log="$test_tmp/launch-log"
PATH="$mock_bin:$PATH" OMARCHY_TEST_LOG="$launch_log" \
  bash "$ROOT/bin/omarchy-install-service-1password" >/dev/null

# The installer backgrounds the launch, so give it a moment to land.
for _ in {1..50}; do
  [[ -s $launch_log ]] && break
  sleep 0.1
done

grep -Fxq 'launch:uwsm-app -- 1password --force-device-scale-factor=1' "$launch_log" ||
  fail "1Password installer starts the app at a fixed scale factor" "$(cat "$launch_log" 2>/dev/null)"
pass "1Password installer starts the app at a fixed scale factor"
