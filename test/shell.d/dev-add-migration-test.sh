#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# A checkout whose HEAD was committed at 1789095456, the id #13516 saw reused.
checkout="$test_tmp/omarchy"
mkdir -p "$checkout/migrations"
git -C "$checkout" init -q
GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.invalid \
GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.invalid \
GIT_AUTHOR_DATE=@1789095456 GIT_COMMITTER_DATE=@1789095456 \
  git -C "$checkout" commit --allow-empty -q -m base

# Pin the clock so the expected ids are exact.
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/date" <<'SH'
#!/bin/bash
[[ ${1:-} == "+%s" ]] || exit 1
echo 1790700000
SH
chmod +x "$stub_bin/date"

add_migration() {
  PATH="$stub_bin:$PATH" OMARCHY_PATH="$checkout" "$ROOT/bin/omarchy-dev-add-migration" --no-edit
}

created=$(add_migration)
[[ $created == "$checkout/migrations/1790700000.sh" && -f $created ]] ||
  fail "a new migration is named after the current time, not HEAD's commit time" "created: $created"
pass "a new migration is named after the current time, not HEAD's commit time"

created=$(add_migration)
[[ $created == "$checkout/migrations/1790700001.sh" && -f $created ]] ||
  fail "a second migration in the same second takes the next free id" "created: $created"
pass "a second migration in the same second takes the next free id"

# Two runs started together in the same second must each claim their own file.
for trial in {1..10}; do
  checkout="$test_tmp/race-$trial"
  mkdir -p "$checkout/migrations"

  add_migration >"$test_tmp/$trial.a" &
  first=$!
  add_migration >"$test_tmp/$trial.b" &
  second=$!
  wait "$first" || fail "two concurrent runs in one checkout create distinct migrations" "trial $trial: first run failed"
  wait "$second" || fail "two concurrent runs in one checkout create distinct migrations" "trial $trial: second run failed"

  a=$(<"$test_tmp/$trial.a")
  b=$(<"$test_tmp/$trial.b")
  [[ -f $a && -f $b && $a != "$b" ]] ||
    fail "two concurrent runs in one checkout create distinct migrations" "trial $trial: printed '$a' and '$b'"
done
pass "two concurrent runs in one checkout create distinct migrations"
