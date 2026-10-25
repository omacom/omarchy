#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
git_log="$test_tmp/git.log"
checkout="$test_tmp/checkout"
mkdir -p "$stub_bin" "$checkout"

cat >"$stub_bin/git" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$TEST_GIT_LOG"

[[ $1 == "-C" ]] || exit 1
shift 2

case "$1" in
  rev-parse)
    case "$2" in
      --is-inside-work-tree)
        [[ ${TEST_GIT_CHECKOUT:-yes} == "yes" ]] || exit 1
        echo true
        ;;
      --abbrev-ref)
        [[ $4 == "quattro@{upstream}" ]] || exit 1
        [[ ${TEST_GIT_UPSTREAM:-origin/quattro} != "none" ]] || exit 1
        echo "${TEST_GIT_UPSTREAM:-origin/quattro}"
        ;;
      *)
        exit 1
        ;;
    esac
    ;;
  symbolic-ref)
    echo "${TEST_GIT_BRANCH:-refs/heads/quattro}"
    ;;
  for-each-ref)
    [[ $3 == "refs/heads/quattro" ]] || exit 1
    echo "${TEST_GIT_REMOTE:-origin}"
    ;;
  config)
    case "$2" in
      remote.*.url) echo https://github.com/omacom/omarchy.git ;;
      remote.*.promisor) [[ ${TEST_GIT_PROMISOR:-no} == "yes" ]] && echo true ;;
      *) exit 1 ;;
    esac
    ;;
  fetch)
    if [[ $2 == "--filter=blob:none" ]]; then
      [[ $3 == "${TEST_GIT_REMOTE:-origin}" ]]
    else
      [[ $2 == "${TEST_GIT_REMOTE:-origin}" && $3 == "${TEST_GIT_FETCH_REFSPEC:-quattro:quattro}" ]]
    fi
    ;;
  pull)
    [[ $2 == "--ff-only" ]]
    ;;
  worktree)
    if [[ $2 == "list" && $3 == "--porcelain" ]]; then
      if [[ -n ${TEST_GIT_QUATTRO_WORKTREE:-} ]]; then
        printf 'worktree %s\nHEAD 1234\nbranch refs/heads/quattro\n\n' "$TEST_GIT_QUATTRO_WORKTREE"
      fi
    fi
    ;;
  *)
    exit 1
    ;;
esac
SH
chmod +x "$stub_bin/git"

run_dev_update() {
  OMARCHY_PATH="$1" \
    TEST_GIT_LOG="$git_log" \
    PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-update-dev"
}

: >"$git_log"
run_dev_update /usr/share/omarchy
[[ ! -s $git_log ]] || fail "package-backed updates do not invoke git" "$(cat "$git_log")"
pass "package-backed updates skip the dev checkout step"

: >"$git_log"
run_dev_update "$checkout"
grep -Fx -- "-C $checkout pull --ff-only" "$git_log" >/dev/null ||
  fail "dev checkout update pulls its upstream with fast-forward only" "$(cat "$git_log")"
grep -Fx -- "-C $checkout fetch --filter=blob:none origin" "$git_log" >/dev/null ||
  fail "dev checkout update makes a full clone blobless before pulling" "$(cat "$git_log")"
pass "dev checkout update pulls its configured upstream"

: >"$git_log"
TEST_GIT_PROMISOR=yes run_dev_update "$checkout"
if grep -q ' fetch ' "$git_log"; then
  fail "blobless dev checkout is not fetched again before pulling" "$(cat "$git_log")"
fi
pass "blobless dev checkout only pulls"

: >"$git_log"
TEST_GIT_BRANCH=refs/heads/feature run_dev_update "$checkout"
! grep -q ' pull ' "$git_log" ||
  fail "dev checkout on another branch does not pull into the active branch" "$(cat "$git_log")"
! grep -q ' checkout ' "$git_log" ||
  fail "dev checkout on another branch does not switch branches" "$(cat "$git_log")"
grep -Fx -- "-C $checkout fetch origin quattro:quattro" "$git_log" >/dev/null ||
  fail "dev checkout on another branch updates quattro in-place via fetch" "$(cat "$git_log")"
pass "dev checkout on another branch updates quattro in-place"

: >"$git_log"
TEST_GIT_BRANCH=refs/heads/feature TEST_GIT_REMOTE=upstream TEST_GIT_UPSTREAM=upstream/quattro run_dev_update "$checkout"
grep -Fx -- "-C $checkout fetch upstream quattro:quattro" "$git_log" >/dev/null ||
  fail "dev checkout on another branch uses quattro's configured remote" "$(cat "$git_log")"
pass "dev checkout on another branch uses quattro's configured remote"

: >"$git_log"
TEST_GIT_BRANCH=refs/heads/feature TEST_GIT_QUATTRO_WORKTREE="$test_tmp/main-checkout" run_dev_update "$checkout"
grep -Fx -- "-C $test_tmp/main-checkout pull --ff-only" "$git_log" >/dev/null ||
  fail "dev checkout on another branch pulls quattro in its worktree when checked out" "$(cat "$git_log")"
! grep -q -- "-C $checkout fetch origin quattro:quattro" "$git_log" ||
  fail "dev checkout does not fetch in-place when quattro is checked out in a worktree" "$(cat "$git_log")"
pass "dev checkout on another branch pulls quattro in its worktree"

: >"$git_log"
TEST_GIT_UPSTREAM=none run_dev_update "$checkout" >"$test_tmp/no-upstream.out"
if grep -q ' pull ' "$git_log"; then
  fail "dev checkout without an upstream is not pulled" "$(cat "$git_log")"
fi
grep -F "quattro branch has no upstream" "$test_tmp/no-upstream.out" >/dev/null ||
  fail "dev checkout without an upstream names the quattro branch" "$(cat "$test_tmp/no-upstream.out")"
pass "dev checkout without an upstream is skipped safely"

: >"$git_log"
if TEST_GIT_CHECKOUT=no run_dev_update "$checkout" >"$test_tmp/invalid.out" 2>"$test_tmp/invalid.err"; then
  fail "invalid dev checkout fails the update"
fi
grep -F "OMARCHY_PATH is not a git checkout: $checkout" "$test_tmp/invalid.err" >/dev/null ||
  fail "invalid dev checkout reports the configured path" "$(cat "$test_tmp/invalid.err")"
pass "invalid dev checkout fails with a useful error"

real_git=$(which git)
real_tmp="$test_tmp/real"
mkdir -p "$real_tmp"

upstream_repo="$real_tmp/upstream"
"$real_git" init -b quattro "$upstream_repo" >/dev/null
"$real_git" -C "$upstream_repo" config user.name "Tester"
"$real_git" -C "$upstream_repo" config user.email "test@example.com"
"$real_git" -C "$upstream_repo" commit --allow-empty -m "initial" >/dev/null

local_repo="$real_tmp/local"
"$real_git" clone "$upstream_repo" "$local_repo" >/dev/null 2>&1
"$real_git" -C "$local_repo" config user.name "Tester"
"$real_git" -C "$local_repo" config user.email "test@example.com"

feature_wt="$real_tmp/feature-wt"
"$real_git" -C "$local_repo" worktree add -b feature "$feature_wt" >/dev/null 2>&1

"$real_git" -C "$upstream_repo" commit --allow-empty -m "upstream update 1" >/dev/null

OMARCHY_PATH="$feature_wt" "$ROOT/bin/omarchy-update-dev" >/dev/null 2>&1

upstream_head=$("$real_git" -C "$upstream_repo" rev-parse HEAD)
local_quattro_head=$("$real_git" -C "$local_repo" rev-parse refs/heads/quattro)
[[ $upstream_head == "$local_quattro_head" ]] ||
  fail "real git worktree update did not fast-forward quattro" "expected $upstream_head, got $local_quattro_head"

wt_branch=$("$real_git" -C "$feature_wt" symbolic-ref --short HEAD)
[[ $wt_branch == "feature" ]] ||
  fail "real git worktree update changed active feature branch" "$wt_branch"
pass "real git worktree update pulls quattro in its worktree cleanly"

"$real_git" -C "$local_repo" checkout -b other >/dev/null 2>&1
"$real_git" -C "$upstream_repo" commit --allow-empty -m "upstream update 2" >/dev/null
OMARCHY_PATH="$feature_wt" "$ROOT/bin/omarchy-update-dev" >/dev/null 2>&1

upstream_head_2=$("$real_git" -C "$upstream_repo" rev-parse HEAD)
local_quattro_head_2=$("$real_git" -C "$local_repo" rev-parse refs/heads/quattro)
[[ $upstream_head_2 == "$local_quattro_head_2" ]] ||
  fail "real git in-place fetch did not fast-forward quattro" "expected $upstream_head_2, got $local_quattro_head_2"
pass "real git in-place fetch fast-forwards quattro when not checked out in any worktree"

grep -qE '^ *omarchy-update-dev$' "$ROOT/bin/omarchy-update" ||
  fail "top-level update includes the dev checkout step"
pass "top-level update includes the dev checkout step"
