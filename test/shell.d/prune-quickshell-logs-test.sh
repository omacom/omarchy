#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

prune="$ROOT/bin/omarchy-prune-quickshell-logs"
[[ -x $prune ]] || fail "omarchy-prune-quickshell-logs is executable"
grep -q 'quickshell/by-id' "$prune" || fail "prune targets Quickshell by-id instance dirs"
grep -q 'omarchy-prune-quickshell-logs' "$ROOT/bin/omarchy-launch-shell" ||
  fail "omarchy-launch-shell prunes stale Quickshell logs before each start"
pass "launch-shell prunes stale Quickshell instance logs before start"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
runtime="$tmpdir/run"
by_id="$runtime/quickshell/by-id"
by_pid="$runtime/quickshell/by-pid"
mkdir -p "$by_id" "$by_pid"

live_id=live-instance
stale_id=stale-instance
mkdir -p "$by_id/$live_id" "$by_id/$stale_id"
printf 'stale\n' >"$by_id/$stale_id/log.log"
printf 'live\n' >"$by_id/$live_id/log.log"

# A live by-pid symlink whose pid is this test shell keeps its instance.
ln -s "$by_id/$live_id" "$by_pid/$$"
# A dead pid leaves a dangling symlink that must be removed with its dir.
ln -s "$by_id/$stale_id" "$by_pid/1"

XDG_RUNTIME_DIR="$runtime" "$prune"

[[ -d $by_id/$live_id ]] || fail "prune keeps the instance for a live by-pid symlink"
[[ ! -e $by_id/$stale_id ]] || fail "prune removes instance dirs for dead pids"
[[ -L $by_pid/$$ ]] || fail "prune keeps the live by-pid symlink"
[[ ! -e $by_pid/1 && ! -L $by_pid/1 ]] || fail "prune removes by-pid links for dead pids"
pass "prune keeps live Quickshell instance dirs and drops stale ones"

# No by-pid dir: everything under by-id is stale.
rm -rf "$by_pid"
mkdir -p "$by_id/orphan"
XDG_RUNTIME_DIR="$runtime" "$prune"
[[ ! -e $by_id/orphan ]] || fail "prune removes by-id dirs when no by-pid map exists"
[[ -d $by_id/$live_id ]] && fail "without by-pid, former live dir is also removed" || true
# Recreate and confirm empty by-id is fine
XDG_RUNTIME_DIR="$runtime" "$prune"
pass "prune clears unreferenced by-id dirs when by-pid is absent"
