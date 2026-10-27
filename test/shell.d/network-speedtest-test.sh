#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The measurement is tested with the client, which is packaged on its own. This
# covers the launcher: the client must replace it, so closing the panel ends
# the test, and must be told which process launched it.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
printf '#!/bin/bash\necho "args=$* ppid=$PPID parent=$OMARCHY_SPEEDTEST_PARENT_PID"\n' > "$tmp/speedtest"
chmod +x "$tmp/speedtest"
export OMARCHY_SPEEDTEST_BINARY=$tmp/speedtest
launcher=$ROOT/bin/omarchy-network-speedtest

out=$(bash -c '"$1" up; echo "caller=$$"' bash "$launcher")
caller=${out##*caller=}
[[ $out == "args=up ppid=$caller parent=$caller"$'\n'* ]] ||
  fail "the client replaces the launcher and knows the panel launched it" "$out"
pass "the client replaces the launcher and knows the panel launched it"

for args in sideways "down extra"; do
  status=0
  # shellcheck disable=SC2086
  out=$("$launcher" $args 2>&1) || status=$?
  (( status == 2 )) && [[ $out == Usage:* ]] || fail "rejects '$args' without starting a test" "status $status: $out"
  pass "rejects '$args' without starting a test"
done

status=0
out=$(OMARCHY_SPEEDTEST_BINARY=$tmp/missing "$launcher" down 2>&1) || status=$?
(( status == 1 )) && [[ $out == *omarchy-speedtest* ]] || fail "names the package when the client is missing" "status $status: $out"
pass "names the package when the client is missing"
