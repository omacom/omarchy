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
if [[ ${3:-} == "does.not.exist" ]]; then
  printf 'unknown\n'
else
  printf 'ok\n'
fi
SH
chmod +x "$TMPDIR/bin/omarchy-shell"

run_disable() {
  HOME="$TMPDIR/home" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_CALLS="$calls" \
    PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
    omarchy-plugin-disable "$@"
}

output=$(run_disable acme.weather)
[[ $output == "Disabled acme.weather" ]] || fail "plugin disable did not report success" "$output"
grep -Fqx 'shell setPluginEnabled acme.weather false' "$calls" ||
  fail "plugin disable did not call setPluginEnabled with false"
pass "plugin disable forwards disable mutation to shell"

if output=$(run_disable does.not.exist 2>&1); then
  fail "plugin disable should fail for unknown plugin id" "$output"
fi
[[ $output == *"plugin 'does.not.exist' is not known"* ]] ||
  fail "plugin disable did not report unknown plugin error" "$output"
pass "plugin disable fails when plugin is not known"

if output=$(run_disable 2>&1); then
  fail "plugin disable should fail when plugin id is omitted" "$output"
fi
[[ $output == *"plugin id is required"* ]] ||
  fail "plugin disable did not report missing id error" "$output"
pass "plugin disable requires a plugin id"

output=$(run_disable --help)
[[ $output == *"Usage: omarchy plugin disable <id>"* ]] ||
  fail "plugin disable --help did not print usage" "$output"
pass "plugin disable --help prints usage"
