#!/bin/bash
# omarchy:exclusive
# A full shell on llvmpipe beside a busy pool can miss its IPC deadline or be the OOM killer's pick.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "bar fallback test"

setup_scratch_shell

broken_bar_id="acme.broken-bar"
broken_bar_dir="$SCRATCH_HOME/.config/omarchy/plugins/$broken_bar_id"
mkdir -p "$broken_bar_dir"
cat >"$broken_bar_dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$broken_bar_id",
  "name": "Broken Bar",
  "version": "1.0.0",
  "kinds": ["bar"],
  "entryPoints": {"bar": "Bar.qml"}
}
JSON
cat >"$broken_bar_dir/Bar.qml" <<'QML'
import QtQuick

Item {
  this is not valid qml
}
QML

# Selected at login, as a user who picked the plugin last session has it.
jq --arg id "$broken_bar_id" '.bar.id = $id' "$ROOT/config/omarchy/shell.json" \
  >"$SCRATCH_HOME/.config/omarchy/shell.json"

start_scratch_shell
wait_scratch_shell

for _ in {1..100}; do
  grep -q "bar option $broken_bar_id failed to load" "$SCRATCH_LOG" && break
  sleep 0.1
done
grep -q "bar option $broken_bar_id failed to load" "$SCRATCH_LOG" || {
  sed -n '1,120p' "$SCRATCH_LOG" >&2
  fail "the broken bar fixture never failed to load"
}

wait_scratch_layer omarchy-bar mapped || {
  sed -n '1,120p' "$SCRATCH_LOG" >&2
  fail "the default bar returns when a bar plugin fails to load"
}
pass "the default bar returns when a bar plugin fails to load"

# Any shell.json write clears the failure so a fixed plugin gets another try.
# This one still fails to compile, and the default bar must stay up through it.
failures_before=$(grep -c "failed to load" "$SCRATCH_LOG" || true)
jq '.bar.size = ((.bar.size // 0) + 1)' "$SCRATCH_HOME/.config/omarchy/shell.json" \
  >"$SCRATCH_HOME/.config/omarchy/shell.json.tmp"
mv "$SCRATCH_HOME/.config/omarchy/shell.json.tmp" "$SCRATCH_HOME/.config/omarchy/shell.json"

for _ in {1..100}; do
  (( $(grep -c "failed to load" "$SCRATCH_LOG" || true) > failures_before )) && break
  sleep 0.1
done
(( $(grep -c "failed to load" "$SCRATCH_LOG" || true) > failures_before )) || {
  sed -n '1,160p' "$SCRATCH_LOG" >&2
  fail "the broken bar is tried again after shell.json changes"
}
sleep 1

if grep -q "Binding loop detected" "$SCRATCH_LOG"; then
  sed -n '1,160p' "$SCRATCH_LOG" >&2
  fail "retrying a broken bar plugin leaves no binding loop"
fi
pass "retrying a broken bar plugin leaves no binding loop"

wait_scratch_layer omarchy-bar mapped || {
  sed -n '1,160p' "$SCRATCH_LOG" >&2
  fail "the default bar stays up when a broken bar plugin is retried"
}
pass "the default bar stays up when a broken bar plugin is retried"
