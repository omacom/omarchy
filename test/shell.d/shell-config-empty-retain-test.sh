#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Pins applyShellConfig so a truncated/empty or unparseable user shell.json
# after a prior valid load retains the last in-memory user config instead of
# replacing it with builtin defaults (#12990). Without this, the next
# mutateShellConfig/persistShellConfig permanently writes stock config.

shell_qml="$ROOT/shell/shell.qml"

[[ -f $shell_qml ]] || fail "shell.qml exists"

grep -F 'property bool hasAppliedUserShellConfig: false' "$shell_qml" >/dev/null ||
  fail "hasAppliedUserShellConfig tracks a prior successful user shell.json load"

# Extract applyShellConfig so unrelated shellConfig = defaults assignments cannot
# satisfy the pin.
apply_fn=$(awk '
  /^  function applyShellConfig\(\) \{/ {grab=1}
  grab {print}
  grab && /^  \}$/ {exit}
' "$shell_qml")

[[ -n $apply_fn ]] || fail "applyShellConfig function exists"

grep -F 'hasAppliedUserShellConfig = true' <<<"$apply_fn" >/dev/null ||
  fail "a successful versioned user parse marks hasAppliedUserShellConfig"

grep -F 'retaining last valid config' <<<"$apply_fn" >/dev/null ||
  fail "empty/invalid reload after a prior valid load warns and retains"

# The retain path must return without assigning defaults/builtins.
if ! grep -Pzo 'if \(hasAppliedUserShellConfig\) \{\n\s*console\.warn\("shell\.json empty or invalid after a prior valid load; retaining last valid config"\)\n\s*return\n\s*\}' <<<"$apply_fn" >/dev/null; then
  fail "empty/invalid reload returns without clobbering shellConfig" "$apply_fn"
fi

# Guard the pre-fix amplifier: empty user text must not unconditionally
# assign shellConfig = user || defaults once a valid user config was applied.
if grep -E 'shellConfig = user \|\| defaults' <<<"$apply_fn" >/dev/null; then
  fail "applyShellConfig must not fall back with shellConfig = user || defaults"
fi

# First load with nothing valid still falls through to defaults.
grep -E 'shellConfig = defaults' <<<"$apply_fn" >/dev/null ||
  fail "first load with no valid user config still falls back to defaults"

pass "applyShellConfig retains last valid user config when shell.json truncates"
