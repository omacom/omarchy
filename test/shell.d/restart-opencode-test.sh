#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'pkill -P $$ 2>/dev/null; rm -rf "$test_tmp"' EXIT

# Stand-ins laid out like a mise install, argv[0] opencode.exe and the
# subcommand in argv[1]: a TUI whose prompt mentions a server, and the
# background server, which SIGUSR2 would terminate.
cp "$(command -v bash)" "$test_tmp/opencode.exe"
for subcommand in tui serve; do
  printf '%s\n' 'trap '"'"'touch "$0.usr2"; exit 0'"'"' USR2' 'while :; do sleep 0.05; done' >"$test_tmp/$subcommand"
done
(cd "$test_tmp" && exec ./opencode.exe tui "Review this server") &
(cd "$test_tmp" && exec ./opencode.exe serve --service) &
sleep 0.2

"$ROOT/bin/omarchy-restart-opencode"

for _ in {1..40}; do [[ -f $test_tmp/tui.usr2 ]] && break; sleep 0.05; done
[[ -f $test_tmp/tui.usr2 ]] || fail "theme refresh reaches the opencode.exe TUI"
[[ ! -f $test_tmp/serve.usr2 ]] || fail "theme refresh leaves the opencode server alone"
pass "theme refresh signals the opencode TUI but not its server"
