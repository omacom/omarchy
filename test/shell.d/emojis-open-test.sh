#!/bin/bash

# The emoji picker opens in a real shell: summoning it maps its surface,
# favorites and the skin tone saved from an earlier session load, and the
# picker logs no QML errors while building its grid.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "emoji picker opens"

setup_scratch_shell
mkdir -p "$SCRATCH_HOME/.local/state/omarchy"
printf '{"recent":["\\ud83e\\udee0"],"favorites":["\\ud83d\\udc4d"],"tone":3}\n' \
  >"$SCRATCH_HOME/.local/state/omarchy/emojis.json"
start_scratch_shell
wait_scratch_shell

summoned=""
for _ in {1..80}; do
  [[ $(scratch_ipc shell summon omarchy.emojis '{}' 2>/dev/null || true) == "ok" ]] && { summoned=1; break; }
  kill -0 "$SCRATCH_PID" 2>/dev/null || break
  sleep 0.1
done
[[ -n $summoned ]] || { sed -n '1,120p' "$SCRATCH_LOG" >&2; fail "emoji picker summons in a scratch shell"; }
wait_scratch_layer omarchy-emojis mapped || fail "emoji picker maps when summoned"
pass "emoji picker maps when summoned"

sleep 0.5
if grep -E "plugins/emojis/.*(Error|TypeError|ReferenceError|is not a function|Cannot read)" "$SCRATCH_LOG" >&2; then
  fail "emoji picker builds its grid without QML errors"
fi
pass "emoji picker builds its grid without QML errors"

scratch_ipc_quiet shell hide omarchy.emojis >/dev/null 2>&1 || true
wait_scratch_layer omarchy-emojis absent || fail "emoji picker hides"
pass "emoji picker hides"

# Saved preferences survive the open and close untouched.
[[ $(jq -r '.tone' "$SCRATCH_HOME/.local/state/omarchy/emojis.json") == 3 ]] || fail "emoji picker keeps saved preferences"
pass "emoji picker keeps saved preferences"
