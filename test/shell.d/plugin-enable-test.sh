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
printf '%s\n' "${OMARCHY_SHELL_IPC_TIMEOUT:-}" >>"$OMARCHY_TEST_CALLS.timeout"
printf 'ok\n'
SH
chmod +x "$TMPDIR/bin/omarchy-shell"

run_enable() {
  HOME="$TMPDIR/home" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_CALLS="$calls" \
    OMARCHY_SHELL_IPC_TIMEOUT="${IPC_TIMEOUT:-}" \
    PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
    omarchy-plugin-enable "$@"
}

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

[[ $(tail -n1 "$calls.timeout") == "10s" ]] ||
  fail "plugin enable gave the shell only the default IPC timeout"
IPC_TIMEOUT=3s run_enable omarchy.dropbox >/dev/null
[[ $(tail -n1 "$calls.timeout") == "3s" ]] ||
  fail "plugin enable overrode an explicit IPC timeout"
pass "plugin enable gives the shell 10s unless told otherwise"

if run_enable omarchy.bar --section right >/dev/null 2>&1; then
  fail "plugin enable accepted placement for a full bar"
fi
pass "plugin enable rejects placement for full bars"
