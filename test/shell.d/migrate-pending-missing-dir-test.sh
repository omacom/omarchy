#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

export OMARCHY_PATH="$tmp_dir/missing-omarchy"
export OMARCHY_MIGRATION_STATE="$tmp_dir/state"
mkdir -p "$OMARCHY_MIGRATION_STATE"

for mode in pending normal; do
  args=()
  if [[ $mode == "pending" ]]; then
    args=(--pending)
  fi

  set +e
  out=$("$ROOT/bin/omarchy-migrate" "${args[@]}" 2>&1)
  status=$?
  set -e

  (( status == 2 )) || fail "migrate $mode exits 2 when migrations dir is missing" "status=$status out=$out"
  [[ $out == *"migrations directory missing"* ]] || fail "migrate $mode mentions the missing directory" "$out"
  pass "migrate $mode fails closed when OMARCHY_PATH has no migrations"
done
