#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
events="$test_tmp/events"
mkdir -p "$mock_bin"

# Mock omarchy-cmd-present: zeroclaw is "present" when a marker file exists.
cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ -e $OMARCHY_TEST_ROOT/zeroclaw-installed ]]
SH

# Mock the zeroclaw command: it "runs" when a marker file exists.
cat >"$mock_bin/zeroclaw" <<'SH'
#!/bin/bash
if [[ -e $OMARCHY_TEST_ROOT/zeroclaw-runs ]]; then
  echo "zeroclaw 1.0.0"
  exit 0
fi
exit 1
SH
chmod +x "$mock_bin/zeroclaw"

# Mock curl to record the install call instead of actually downloading.
cat >"$mock_bin/curl" <<'SH'
#!/bin/bash
printf 'curl %s\n' "$*" >>"$OMARCHY_TEST_ROOT/events"
# Simulate the installer writing the binary by creating the runs marker.
touch "$OMARCHY_TEST_ROOT/zeroclaw-runs"
SH
chmod +x "$mock_bin/curl"

# Mock bash to pass through (curl|bash needs bash to exist).
cat >"$mock_bin/bash" <<'SH'
#!/bin/bash
exec "$@"
SH
chmod +x "$mock_bin/bash"

export PATH="$mock_bin:$PATH"
export OMARCHY_TEST_ROOT="$test_tmp"

# --- Tests ---

# No mode is a usage error.
run omarchy-install-zeroclaw-cli && fail "no mode is a usage error"
[[ ! -s $events ]] || fail "no mode installs nothing" "$(cat "$events")"
pass "every mode is named outright"

# --check fails when zeroclaw is not installed.
run omarchy-install-zeroclaw-cli --check && fail "--check calls a machine without ZeroClaw installed"
pass "--check fails when ZeroClaw is not installed"

# --now installs when zeroclaw is not installed.
run omarchy-install-zeroclaw-cli --now || fail "--now sets ZeroClaw up" "$(cat "$test_tmp/output")"
grep -Fxq "curl -fsSL https://zeroclaw.com/install.sh" "$events" || fail "--now runs the canonical installer" "$(cat "$events")"
pass "--now runs the canonical installer when ZeroClaw is missing"

# --check succeeds after a finished install.
touch "$test_tmp/zeroclaw-installed"
run omarchy-install-zeroclaw-cli --check || fail "--check follows a finished install"
pass "--check succeeds after a finished install"

# --now does not reinstall when already installed and running.
: >"$events"
run omarchy-install-zeroclaw-cli --now || fail "--now accepts a finished install" "$(cat "$test_tmp/output")"
! grep -q '^curl' "$events" || fail "a running install is never reinstalled" "$(cat "$events")"
pass "a running install is never reinstalled"

# --check fails when the binary exists but does not run (dangling install).
rm -f "$test_tmp/zeroclaw-runs"
run omarchy-install-zeroclaw-cli --check && fail "--check calls a binary that does not run"
pass "--check fails when the binary exists but does not run"

# --now reinstalls when the binary does not run.
: >"$events"
run omarchy-install-zeroclaw-cli --now || fail "--now reinstalls behind a broken binary" "$(cat "$test_tmp/output")"
grep -Fxq "curl -fsSL https://zeroclaw.com/install.sh" "$events" || fail "--now reinstalls when the binary does not run" "$(cat "$events")"
pass "--now reinstalls when the binary does not run"
