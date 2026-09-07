#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
test_home="$test_tmp/home"
mkdir -p "$test_home/real home"
ln -s "$test_home/real home" "$test_home/linked home"

check_home() {
  local configured="$1" expected="$2" actual
  actual=$(HOME="$test_home" HERMES_HOME="$configured" "$ROOT/bin/omarchy-cmd-hermes-home") || fail "valid Hermes home resolves"
  [[ $actual == "$expected" ]] || fail "Hermes home resolves to its shared root" "configured: $configured; expected: $expected; actual: $actual"
}

check_home '' "$test_home/.hermes"
for root in "$test_home/.hermes" "$test_home/custom hermes" "$test_home/linked home"; do
  check_home "$root" "$root"
  check_home "$root/profiles/coder" "$root"
  check_home "$root//profiles/./coder///" "$root"
done
check_home "$test_home/profiles/archive/custom" "$test_home/profiles/archive/custom"
check_home "$test_home/custom/profiles/outer/profiles/inner" "$test_home/custom/profiles/outer"
pass "Hermes home resolves default and custom profile sessions once while preserving symlink spelling"

for invalid in relative '/profiles/coder' / '//./' "$test_home/../../../../../../../../.."; do
  HOME="$test_home" HERMES_HOME="$invalid" "$ROOT/bin/omarchy-cmd-hermes-home" >"$test_tmp/output" 2>"$test_tmp/error" && fail "invalid Hermes home must be rejected: $invalid"
  [[ ! -s $test_tmp/output ]] || fail "invalid Hermes home must not return a path"
done
pass "Hermes home rejects relative paths and a shared root of /"
