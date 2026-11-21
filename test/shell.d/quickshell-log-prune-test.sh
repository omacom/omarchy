#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

prune="$ROOT/bin/omarchy-quickshell-prune-logs"
[[ -x $prune ]] || fail "quickshell prune helper is executable"
pass "quickshell prune helper is executable"

grep -q 'omarchy-quickshell-prune-logs' "$ROOT/bin/omarchy-launch-shell" ||
  fail "shell launch prunes stale quickshell logs"
pass "shell launch prunes stale quickshell logs"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
runtime=$tmp/run
mkdir -p "$runtime/quickshell/by-id" "$runtime/quickshell/by-pid"

# Live instance: a real sleep process and a by-pid symlink into by-id.
sleep 120 &
live_pid=$!
mkdir -p "$runtime/quickshell/by-id/live-instance"
echo big >"$runtime/quickshell/by-id/live-instance/log.log"
ln -s "$runtime/quickshell/by-id/live-instance" "$runtime/quickshell/by-pid/$live_pid"

# Stale instance with a dead pid symlink.
mkdir -p "$runtime/quickshell/by-id/stale-instance"
echo huge >"$runtime/quickshell/by-id/stale-instance/log.log"
ln -s "$runtime/quickshell/by-id/stale-instance" "$runtime/quickshell/by-pid/999999"

# Orphan by-id with no by-pid entry at all.
mkdir -p "$runtime/quickshell/by-id/orphan-instance"
echo orphan >"$runtime/quickshell/by-id/orphan-instance/log.log"

# A trailing slash must not make the live instance's path look unreferenced.
XDG_RUNTIME_DIR="$runtime/" "$prune"

[[ -d $runtime/quickshell/by-id/live-instance ]] || fail "prune keeps the live instance"
[[ ! -d $runtime/quickshell/by-id/stale-instance ]] || fail "prune removes stale instance dirs"
[[ ! -d $runtime/quickshell/by-id/orphan-instance ]] || fail "prune removes orphan instance dirs"
[[ ! -L $runtime/quickshell/by-pid/999999 ]] || fail "prune drops dead by-pid symlinks"
pass "prune keeps live dirs and removes stale quickshell instance logs"

kill "$live_pid" 2>/dev/null || true
