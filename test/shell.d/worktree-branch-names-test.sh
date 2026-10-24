#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command git

source "$ROOT/default/bash/fns/worktrees"

test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
export GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=test@example.invalid
export GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=test@example.invalid
mkdir -p "$HOME"

# Real git, with the prompt and the toolchain trust step answered by stubs.
mise_calls=0
gum() { return 0; }
mise() { mise_calls=$((mise_calls + 1)); }

has_branch() {
  git show-ref --verify --quiet "refs/heads/$1"
}

repo="$test_tmp/proj"
git init -q -b main "$repo"
git -C "$repo" commit -q --allow-empty -m fixture
cd "$repo"

ga release/toto >/dev/null 2>&1
[[ $PWD == "$test_tmp/proj--release-toto" ]] ||
  fail "ga keeps the worktree of a branch with a slash in one flat directory" "$PWD"
[[ ! -e $test_tmp/proj--release ]] || fail "ga leaves no directory named after the part before the slash"
pass "ga names the worktree directory without the slash"

gd >/dev/null 2>&1 || fail "gd succeeds for a branch with a slash"
[[ $PWD == "$repo" ]] || fail "gd returns to the main checkout" "$PWD"
[[ ! -e $test_tmp/proj--release-toto ]] || fail "gd removes the worktree of a branch with a slash"
! has_branch release/toto || fail "gd deletes the branch with a slash"
pass "gd removes a worktree and its branch when the branch name has a slash"

ga feature-x >/dev/null 2>&1
[[ $PWD == "$test_tmp/proj--feature-x" ]] || fail "ga still names a plain branch as before" "$PWD"
gd >/dev/null 2>&1 || fail "gd succeeds for a plain branch"
[[ ! -e $test_tmp/proj--feature-x ]] || fail "gd removes the worktree of a plain branch"
! has_branch feature-x || fail "gd deletes a plain branch"
pass "gd still removes a worktree and its branch for a plain name"

ga topic-one >/dev/null 2>&1
git switch -q -c unrelated
gd >/dev/null 2>"$test_tmp/gd.err" || fail "gd succeeds after the worktree switched branches"
[[ ! -e $test_tmp/proj--topic-one ]] || fail "gd removes a worktree whose branch was switched"
has_branch unrelated || fail "gd keeps a checked-out branch that does not belong to the directory"
has_branch topic-one || fail "gd does not guess a branch from the directory name once the checkout moved"
grep -q "Kept the branch" "$test_tmp/gd.err" || fail "gd says it kept the branch" "$(cat "$test_tmp/gd.err")"
pass "gd deletes no branch when the checkout is on a branch whose name does not map to the directory"

ga topic-two >/dev/null 2>&1
git switch -q --detach
gd >/dev/null 2>&1 || fail "gd succeeds from a detached HEAD"
[[ ! -e $test_tmp/proj--topic-two ]] || fail "gd removes the worktree of a detached HEAD"
has_branch topic-two || fail "gd keeps the branch when HEAD is detached"
pass "gd removes a worktree with a detached HEAD and keeps the branch"

git branch release-toto
ga release/toto >/dev/null 2>&1
git switch -q release-toto
gd >/dev/null 2>&1 || fail "gd succeeds when the worktree sits on a branch named like its directory"
[[ ! -e $test_tmp/proj--release-toto ]] || fail "gd removes the worktree whose branch is ambiguous"
has_branch release-toto || fail "gd keeps a branch that shares its dashed name with another branch"
has_branch release/toto || fail "gd keeps the slashed branch when it cannot tell which branch belongs to the directory"
pass "gd deletes no branch when two branches map to the directory"

ga dup-one >/dev/null 2>&1
cd "$repo"
if ga dup/one >/dev/null 2>"$test_tmp/ga.err"; then
  fail "ga refuses a directory that another branch already uses"
fi
[[ $PWD == "$repo" ]] || fail "ga stays where it was when the directory exists" "$PWD"
grep -q "already exists" "$test_tmp/ga.err" || fail "ga says the directory exists" "$(cat "$test_tmp/ga.err")"
! has_branch dup/one || fail "ga creates no branch when the directory exists"
pass "ga stops before touching git when the directory exists"

# Another ga can take the directory between the check and git worktree add.
race_dir="$test_tmp/proj--race-one"
git() {
  if [[ $1 == worktree && $2 == add ]]; then
    mkdir -p "$race_dir"
    touch "$race_dir/occupied"
  fi
  command git "$@"
}
mise_calls=0
if ga race/one >/dev/null 2>&1; then
  fail "ga fails when git cannot create the worktree"
fi
unset -f git
[[ $PWD == "$repo" ]] || fail "ga stays where it was when git cannot create the worktree" "$PWD"
(( mise_calls == 0 )) || fail "ga trusts nothing when git cannot create the worktree"
pass "ga stops when git refuses to create the worktree"
