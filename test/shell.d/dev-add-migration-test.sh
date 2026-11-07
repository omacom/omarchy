#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-dev-add-migration"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/migrations"
git -C "$tmpdir" init -q
git -C "$tmpdir" config user.email "test@example.com"
git -C "$tmpdir" config user.name "test"
# Old committer time must not become the migration id.
GIT_AUTHOR_DATE="2020-01-01T00:00:00Z" GIT_COMMITTER_DATE="2020-01-01T00:00:00Z" \
  git -C "$tmpdir" commit --allow-empty -q -m "base"
touch "$tmpdir/migrations/1577836800.sh"

before=$(date +%s)
created=$(OMARCHY_PATH="$tmpdir" "$helper" --no-edit)
after=$(date +%s)

[[ -f $created ]] || fail "dev-add-migration did not create a file" "path: $created"
pass "dev-add-migration creates a migration file"

base=$(basename "$created" .sh)
[[ $base =~ ^[0-9]+$ ]] || fail "migration id is not a unix timestamp" "id: $base"
(( base >= before && base <= after + 1 )) ||
  fail "migration id should be wall-clock time, not HEAD committer date" "id: $base before: $before after: $after"
pass "dev-add-migration stamps wall-clock time"

[[ $base != "1577836800" ]] ||
  fail "migration id reused HEAD committer date" "id: $base"
pass "dev-add-migration does not reuse HEAD committer date"

# Occupy the next minute of ids, so only advancing past them finds a free one.
now=$(date +%s)
for (( id = now; id <= now + 60; id++ )); do
  touch "$tmpdir/migrations/$id.sh"
done
created2=$(OMARCHY_PATH="$tmpdir" "$helper" --no-edit)
base2=$(basename "$created2" .sh)
(( base2 == now + 61 )) ||
  fail "dev-add-migration should advance past colliding ids to the first free one" "id: $base2 expected: $(( now + 61 ))"
pass "dev-add-migration advances past a colliding migration id"
