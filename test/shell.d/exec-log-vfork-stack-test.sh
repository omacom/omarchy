#!/bin/bash

# #15390: the exec-log preload's logging path runs in a vfork child, on the 8 KB stack glibc
# allocates for that helper. 8 KB of locals overflows it into the parent's frames and the parent
# crashes in clone() once the child execs. Pin the frame here rather than the crash, because the
# corruption depends on the caller's layout and the report's reproducer (quickshell) is not part
# of a checkout.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

fixture="$ROOT/test/shell.d/fixtures/idle-shell/exec-log.c"
cc -c -fstack-usage -O2 -o "$tmpdir/exec-log.o" "$fixture" ||
  fail "the exec-log fixture compiles with -fstack-usage"
usage=$(ls "$tmpdir"/*.su 2>/dev/null | head -1)
[[ -n $usage ]] || fail "the compiler wrote a stack-usage report" "$(ls -A "$tmpdir")"

# glibc's inline exec wrappers are reported too; only this fixture's own frames matter.
largest=$(awk -F'\t' -v f="$fixture" '$1 ~ "^" f ":" { if ($2 + 0 > m) { m = $2 + 0; who = $1 } } END { if (who) printf "%d %s", m, who }' "$usage")
[[ -n $largest ]] || fail "the stack-usage report covers the fixture's own functions" "$(cat "$usage")"
frame=${largest%% *}
function_name=${largest#* }
(( frame < 512 )) ||
  fail "no exec-log frame fills a vfork child's stack (${frame} bytes in $function_name)" "$(cat "$usage")"

pass "exec-log's logging path fits the stack a vfork child gets"
