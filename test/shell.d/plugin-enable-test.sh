#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR/home" "$TMPDIR/bin"
calls="$TMPDIR/calls"

cat >"$TMPDIR/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_CALLS"
printf 'ipc-timeout %s\n' "${OMARCHY_SHELL_IPC_TIMEOUT-unset}" >>"$OMARCHY_TEST_CALLS"
printf 'ok\n'
SH
chmod +x "$TMPDIR/bin/omarchy-shell"

run_enable() {
  HOME="$TMPDIR/home" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_CALLS="$calls" \
    PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
    omarchy-plugin-enable "$@"
}

unset OMARCHY_SHELL_IPC_TIMEOUT

run_enable omarchy.active-window --section right >/dev/null
grep -Fqx 'shell enablePlugin omarchy.active-window {"section":"right"}' "$calls" ||
  fail "plugin enable did not combine activation and placement"
pass "plugin enable combines activation and placement in one shell mutation"

run_enable omarchy.clock --before omarchy.weather >/dev/null
grep -Fqx 'shell enablePlugin omarchy.clock {"before":"omarchy.weather"}' "$calls" ||
  fail "plugin enable did not preserve relative placement"
pass "plugin enable forwards relative placement"

run_enable omarchy.dropbox >/dev/null
grep -Fqx 'shell enablePlugin omarchy.dropbox {}' "$calls" ||
  fail "plugin enable did not use manifest-default placement"
pass "plugin enable leaves default placement to the registry"

if run_enable omarchy.bar --section right >/dev/null 2>&1; then
  fail "plugin enable accepted placement for a full bar"
fi
pass "plugin enable rejects placement for full bars"

grep -Fqx 'ipc-timeout 10s' "$calls" ||
  fail "plugin enable does not widen the default enablePlugin IPC timeout"
pass "plugin enable widens the default IPC timeout for enablePlugin"

OMARCHY_SHELL_IPC_TIMEOUT=0.5s run_enable omarchy.clock >/dev/null
grep -Fqx 'ipc-timeout 0.5s' "$calls" ||
  fail "plugin enable does not respect an explicit IPC timeout"
pass "plugin enable respects an explicit IPC timeout"
