#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home"
mkdir -p "$HOME/.config/omarchy/hooks/demo.d"
printf 'exit 7\n' >"$HOME/.config/omarchy/hooks/demo"
printf 'echo continued >"$HOME/continued"\n' >"$HOME/.config/omarchy/hooks/demo.d/second"
OMARCHY_HOOK_REPORT_STATUS=0 bash "$ROOT/bin/omarchy-hook" demo >/dev/null || fail "legacy hook callers keep best-effort status"
[[ -f $HOME/continued ]] || fail "later hooks must run after failure"
if OMARCHY_HOOK_REPORT_STATUS=1 bash "$ROOT/bin/omarchy-hook" demo >/dev/null; then
  fail "opt-in supervisor must see failure"
fi
[[ -f $HOME/continued ]] || fail "status reporting must still run later hooks"
OMARCHY_HOOK_REPORT_STATUS=1 bash "$ROOT/bin/omarchy-hook" absent >/dev/null || fail "absent notification hooks succeed"
pass "hook supervisors can request failure status without changing legacy callers"
