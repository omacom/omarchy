#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Pin the clock so both runs start from the same second.
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/date" <<'SH'
#!/bin/bash
[[ ${1:-} == "+%s" ]] || exit 1
echo 1790700000
SH
chmod +x "$stub_bin/date"

for trial in $(seq 1 20); do
  checkout="$test_tmp/omarchy-$trial"
  mkdir -p "$checkout/migrations"

  PATH="$stub_bin:$PATH" OMARCHY_PATH="$checkout" "$ROOT/bin/omarchy-dev-add-migration" --no-edit >"$test_tmp/$trial.a" &
  first=$!
  PATH="$stub_bin:$PATH" OMARCHY_PATH="$checkout" "$ROOT/bin/omarchy-dev-add-migration" --no-edit >"$test_tmp/$trial.b" &
  second=$!
  # wait on both pids returns only the last status, so a failed first run would pass.
  wait "$first" || fail "two concurrent runs in one checkout create distinct migrations" "trial $trial: first run failed"
  wait "$second" || fail "two concurrent runs in one checkout create distinct migrations" "trial $trial: second run failed"

  a=$(<"$test_tmp/$trial.a")
  b=$(<"$test_tmp/$trial.b")
  [[ -f $a && -f $b && $a != "$b" ]] ||
    fail "two concurrent runs in one checkout create distinct migrations" "trial $trial: printed '$a' and '$b'"
done
pass "two concurrent runs in one checkout create distinct migrations"
