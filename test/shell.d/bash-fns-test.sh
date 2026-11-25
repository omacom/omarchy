#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$ROOT/default/bash/fns/worktrees"
source "$ROOT/default/bash/fns/rsyncing"

work=$(mktemp -d)
watch_pid=""
cleanup() {
  [[ -n $watch_pid ]] && kill "$watch_pid" 2>/dev/null || true
  rm -rf -- "$work"
}
trap cleanup EXIT

# Stub mise and gum so worktree tests stay self-contained
mise_log="$work/mise.log"
mise() { printf '%s\n' "$*" >>"$mise_log"; }
gum() { return 0; }

# 1. ga aborts without running mise trust or changing cwd when git worktree add fails
mkdir -p "$work/repo"
(
  cd "$work/repo"
  git init -q
  git config user.email test@example.com
  git config user.name Test
  git commit -q --allow-empty -m init

  if ga "" >/dev/null 2>&1; then
    exit 1
  fi

  # Create a branch first so `ga` fails on duplicate branch
  git branch taken
  : >"$mise_log"
  before="$PWD"
  if ga taken >/dev/null 2>&1; then
    exit 1
  fi
  [[ $PWD == $before ]] || exit 1
  [[ ! -s $mise_log ]] || exit 1
) || fail "ga returns non-zero without calling mise trust or changing cwd when git worktree add fails"
pass "ga returns non-zero without calling mise trust or changing cwd when git worktree add fails"

# 2. ga + gd support branch names containing `/`
(
  cd "$work/repo"
  ga "feat/sub" >/dev/null 2>&1
  [[ $PWD == "$work/repo--feat-sub" ]] || exit 1
  [[ $(git branch --show-current) == "feat/sub" ]] || exit 1
  gd >/dev/null 2>&1
  [[ $PWD == "$work/repo" ]] || exit 1
  [[ ! -d "$work/repo--feat-sub" ]] || exit 1
  ! git show-ref --verify --quiet refs/heads/feat/sub
) || fail "ga and gd create and cleanly remove worktrees for branches containing /"
pass "ga and gd create and cleanly remove worktrees for branches containing /"

# 3. gd on detached HEAD removes worktree without deleting an unrelated slug-matching branch
(
  cd "$work/repo"
  git branch "feat-sub"
  ga "feat/sub" >/dev/null 2>&1
  git switch --detach -q
  gd >/dev/null 2>&1
  [[ $PWD == "$work/repo" ]] || exit 1
  [[ ! -d "$work/repo--feat-sub" ]] || exit 1
  git show-ref --verify --quiet refs/heads/feat-sub
  git show-ref --verify --quiet refs/heads/feat/sub
) || fail "gd on detached HEAD removes worktree without deleting an unrelated branch"
pass "gd on detached HEAD removes worktree without deleting an unrelated branch"

# 4. gd aborts when ../$root does not exist without invoking git worktree remove
mkdir -p "$work/orphan--branch"
git_log="$work/git.log"
(
  cd "$work/orphan--branch"
  : >"$git_log"
  git() {
    printf '%s\n' "$*" >>"$git_log"
    [[ $1 == "branch" ]] && return 0
    return 99
  }
  if gd >/dev/null 2>&1; then
    exit 1
  fi
  ! grep -q '^worktree remove' "$git_log"
) || fail "gd aborts when parent root directory is missing without invoking git worktree remove"
pass "gd aborts when parent root directory is missing without invoking git worktree remove"

# 5. lsw preserves source and destination paths containing spaces
bash -c 'sleep 30; :' rsw-watch "$work/my src dir" "host:/tmp/my dest dir" &
watch_pid=$!
sleep 0.05
lsw_out=$(lsw)
grep -Fq "$watch_pid: $work/my src dir -> host:/tmp/my dest dir" <<<"$lsw_out" ||
  fail "lsw parses paths with spaces accurately" "$lsw_out"
pass "lsw parses paths with spaces accurately"
