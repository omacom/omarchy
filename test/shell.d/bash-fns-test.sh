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
mise() { :; }
gum() { return 0; }

# 1. ga aborts without cd/mise when git worktree add fails
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
  before="$PWD"
  if ga taken >/dev/null 2>&1; then
    exit 1
  fi
  [[ $PWD == "$before" ]] || exit 1
) || fail "ga returns non-zero and stays in cwd when git worktree add fails"
pass "ga returns non-zero and stays in cwd when git worktree add fails"

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

# 3. gd aborts when ../$root does not exist instead of removing cwd
mkdir -p "$work/orphan--branch"
(
  cd "$work/orphan--branch"
  git() { echo "unexpected git $*" >&2; return 99; }
  if gd >/dev/null 2>&1; then
    exit 1
  fi
) || fail "gd aborts when parent root directory is missing"
pass "gd aborts when parent root directory is missing"

# 4. lsw preserves source and destination paths containing spaces
bash -c 'sleep 30; :' rsw-watch "$work/my src dir" "host:/tmp/my dest dir" &
watch_pid=$!
# Give the subshell a moment to exec sleep or settle argv
sleep 0.05
lsw_out=$(lsw)
grep -Fq "$watch_pid: $work/my src dir -> host:/tmp/my dest dir" <<<"$lsw_out" ||
  fail "lsw parses paths with spaces accurately" "$lsw_out"
pass "lsw parses paths with spaces accurately"
