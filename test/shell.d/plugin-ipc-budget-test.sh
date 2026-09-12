#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# How long the stub shell takes to answer. Longer than the 2s default these
# commands used to run with, shorter than the budget they ask for now, so the
# same call fails or succeeds purely on the budget.
BUSY_SECONDS=3

stub_dir="$TMPDIR/stubs"
mkdir -p "$stub_dir"

# A stand-in for omarchy-shell that keeps the part under test: the caller's
# budget wraps the call, and expiry becomes "is not responding" on exit 1.
cat >"$stub_dir/omarchy-shell" <<'STUB'
#!/bin/bash

[[ ${1:-} == "-q" ]] && shift

printf '%s\n' "${OMARCHY_SHELL_IPC_TIMEOUT:-unset}" >>"$BUDGET_LOG"

answer=$(timeout "${OMARCHY_SHELL_IPC_TIMEOUT:-2s}" \
  bash -c 'sleep "$1"; printf ok' _ "${SHELL_BUSY_SECONDS:-0}")
status=$?

if (( status == 124 || status == 137 )); then
  echo "omarchy-shell is not responding" >&2
  exit 1
fi

if [[ ${2:-} == "listPlugins" ]]; then
  printf '%s\n' "${STUB_PLUGINS:-[]}"
else
  printf '%s\n' "$answer"
fi
exit 0
STUB
chmod +x "$stub_dir/omarchy-shell"

export BUDGET_LOG="$TMPDIR/budgets"

run_plugin_cmd() {
  local home="$1"
  shift

  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" "$@"
}

home="$TMPDIR/home"
mkdir -p "$home/.config/omarchy/plugins"

# --- enable and disable ride out a busy shell ------------------------------
#
# omarchy-plugin-add and omarchy-plugin-clone call these one step after their
# own rescan, and an editor saving into ~/.config/omarchy/plugins/ starts the
# same reload through inotify. Reporting an unreachable shell there turns work
# in progress into a failure (#9304).

: >"$BUDGET_LOG"
output=$(SHELL_BUSY_SECONDS="$BUSY_SECONDS" run_plugin_cmd "$home" \
  omarchy-plugin-disable acme.busy 2>&1) ||
  fail "plugin disable waits out a shell that is rebuilding plugins" "$output"
grep -qF "Disabled acme.busy" <<<"$output" ||
  fail "plugin disable reports the change it made" "$output"
pass "plugin disable waits for a shell busy with a plugin reload"

: >"$BUDGET_LOG"
output=$(SHELL_BUSY_SECONDS="$BUSY_SECONDS" run_plugin_cmd "$home" \
  omarchy-plugin-enable acme.busy 2>&1) ||
  fail "plugin enable waits out a shell that is rebuilding plugins" "$output"
grep -qF "Enabled acme.busy" <<<"$output" ||
  fail "plugin enable reports the change it made" "$output"
pass "plugin enable waits for a shell busy with a plugin reload"

# --- remove asks for the same budget ---------------------------------------
#
# Its setPluginEnabled call sits between the confirmation and the deletion, so
# an expiry there aborts a removal that was already agreed to.

write_plugin() {
  mkdir -p "$1"
  jq -n --arg id "$2" '{
    schemaVersion: 1, id: $id, name: "Busy", version: "1.0.0",
    kinds: ["bar-widget"], entryPoints: {barWidget: "Widget.qml"},
    barWidget: {displayName: "Busy", category: "Test", allowMultiple: false}
  }' >"$1/manifest.json"
  printf 'import QtQuick\nItem {}\n' >"$1/Widget.qml"
}

write_plugin "$home/.config/omarchy/plugins/acme.removable" "acme.removable"
: >"$BUDGET_LOG"
output=$(STUB_PLUGINS='[{"id":"acme.removable","enabled":true}]' \
  run_plugin_cmd "$home" omarchy-plugin-remove acme.removable --yes 2>&1) ||
  fail "plugin remove runs against the stub shell" "$output"
grep -qFx '15s' "$BUDGET_LOG" ||
  fail "plugin remove asks for the raised budget" "$(cat "$BUDGET_LOG")"
pass "plugin remove asks the shell for a budget that fits a reload"

# --- an explicit budget still wins -----------------------------------------
#
# The commands raise the default; they do not override someone who set one.

: >"$BUDGET_LOG"
output=$(OMARCHY_SHELL_IPC_TIMEOUT=1s SHELL_BUSY_SECONDS="$BUSY_SECONDS" \
  run_plugin_cmd "$home" omarchy-plugin-disable acme.busy 2>&1) &&
  fail "an explicit 1s budget still expires against a busy shell" "$output"
grep -qFx '1s' "$BUDGET_LOG" ||
  fail "plugin disable keeps the caller's budget" "$(cat "$BUDGET_LOG")"
pass "an explicit OMARCHY_SHELL_IPC_TIMEOUT is left alone"
