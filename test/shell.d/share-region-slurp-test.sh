#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

picker="$ROOT/config/hyprland-preview-share-picker/config.yaml"
migration="$ROOT/migrations/1789805100.sh"

grep -Fq "slurp -f '%o@%X,%Y,%W,%H'" "$picker" ||
  fail "region share uses output-relative slurp coordinates"
if grep -Fq "slurp -f '%o@%x,%y,%w,%h'" "$picker"; then
  fail "region share does not use global slurp coordinates"
fi
pass "shipped share-picker region command is output-relative"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
home="$test_dir/home"
config="$home/.config/hyprland-preview-share-picker/config.yaml"

run_migration() {
  HOME="$home" bash -euo pipefail "$migration" >/dev/null
}

mkdir -p "$(dirname "$config")"
printf 'region:\n  command: slurp -f '"'"'%%o@%%x,%%y,%%w,%%h'"'"'\n' >"$config"
run_migration
grep -Fq "slurp -f '%o@%X,%Y,%W,%H'" "$config" ||
  fail "migration rewrites a stock global slurp format" "$(cat "$config")"
pass "migration rewrites a stock global slurp format"

printf 'region:\n  command: slurp -f '"'"'%%o@%%X,%%Y,%%W,%%H'"'"'\ncustom: 1\n' >"$config"
run_migration
grep -Fq "custom: 1" "$config" || fail "migration leaves an already-fixed config alone"
grep -Fq "slurp -f '%o@%X,%Y,%W,%H'" "$config" || fail "migration keeps output-relative coordinates"
pass "migration is a no-op when the region command is already correct"

rm -f "$config"
run_migration
[[ ! -e $config ]] || fail "migration does not create a missing share-picker config"
pass "migration skips a missing share-picker config"
