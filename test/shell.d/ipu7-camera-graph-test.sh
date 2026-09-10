#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

checker="$ROOT/test/hardware/ipu7-camera-graph"
fixtures="$ROOT/test/shell.d/fixtures/ipu7-camera-graph"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

check_result() {
  local expected=$1 message=$2 pending=$3 media=$4 status=0
  bash "$checker" "$pending" "$media" > "$test_tmp/result" 2>&1 || status=$?
  [[ $status == "$expected" ]] || fail "$message" "$(cat "$test_tmp/result")"
  pass "$message"
}

check_result 1 "observed CVS wait fails the graph check" "$fixtures/observed-pending.txt" "$fixtures/observed-media.txt"
grep -q 'unregistered Panther Lake CVS endpoint' "$test_tmp/result" || fail "the observed failure identifies the CVS boundary"
pass "the observed failure identifies the CVS boundary"

# This expectation is synthetic. Passing it verifies the checker, not a kernel fix.
check_result 0 "expected registered graph passes the limited topology check" "$fixtures/expected-pending.txt" "$fixtures/expected-media.txt"
check_result 1 "a registered sensor cannot conceal a pending CVS endpoint" "$fixtures/observed-pending.txt" "$fixtures/expected-media.txt"
check_result 1 "an empty notifier cannot conceal a missing sensor" "$fixtures/expected-pending.txt" "$fixtures/observed-media.txt"

sed 's/INTC10E1/INTC10E2/' "$fixtures/observed-pending.txt" > "$test_tmp/ptl-h.txt"
check_result 1 "Panther Lake H CVS also fails while pending" "$test_tmp/ptl-h.txt" "$fixtures/expected-media.txt"
grep -q 'unregistered Panther Lake CVS endpoint' "$test_tmp/result" || fail "Panther Lake H identifies the CVS boundary"

printf 'ipu7:\n [devname] other-sensor\n' > "$test_tmp/other-pending.txt"
check_result 1 "other pending IPU7 subdevices also fail" "$test_tmp/other-pending.txt" "$fixtures/expected-media.txt"
printf 'other-camera:\n [fwnode] dev=nil, node=INTC10E1-0/port@1/endpoint@0\nipu7:\n' > "$test_tmp/other-notifier.txt"
check_result 0 "another notifier cannot create an IPU7 failure" "$test_tmp/other-notifier.txt" "$fixtures/expected-media.txt"
printf 'ipu7:\nother-camera:\n [fwnode] dev=nil, node=INTC10E1-0/port@1/endpoint@0\n' > "$test_tmp/following-notifier.txt"
check_result 0 "IPU7 parsing ends at the following notifier" "$test_tmp/following-notifier.txt" "$fixtures/expected-media.txt"

sed '/device node name/d' "$fixtures/expected-media.txt" > "$test_tmp/no-nodes.txt"
check_result 1 "an entity without a subdevice node fails" "$fixtures/expected-pending.txt" "$test_tmp/no-nodes.txt"
sed '/^- entity 169:/,$d' "$fixtures/expected-media.txt" > "$test_tmp/link-only.txt"
check_result 1 "a sensor name in a link cannot substitute for a registered sensor" "$fixtures/expected-pending.txt" "$test_tmp/link-only.txt"

: > "$test_tmp/empty.txt"
check_result 2 "missing diagnostics are inconclusive" "$test_tmp/missing.txt" "$fixtures/expected-media.txt"
check_result 2 "an empty pending file is inconclusive" "$test_tmp/empty.txt" "$fixtures/expected-media.txt"
check_result 2 "an empty topology is inconclusive" "$fixtures/expected-pending.txt" "$test_tmp/empty.txt"
sed 's/model           ipu7/model           unrelated/' "$fixtures/expected-media.txt" > "$test_tmp/unrelated.txt"
check_result 2 "another media device is inconclusive" "$fixtures/expected-pending.txt" "$test_tmp/unrelated.txt"
