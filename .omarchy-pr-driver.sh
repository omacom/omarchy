#!/bin/bash
# Driver to implement and open 5 security PRs. Run with: bash .omarchy-pr-driver.sh
set -euo pipefail
export PATH="/usr/bin:/bin:/usr/local/bin:/opt/homebrew/bin:$HOME/.local/bin:$PATH"

REPO="/Users/takshkothari/Downloads/Taksh/Pull_Requests/repos/omarchy"
HOOK_SRC="/Users/takshkothari/Downloads/Taksh/Pull_Requests/scripts/git-hooks/commit-msg"
LOG="/tmp/omarchy-5pr-driver.log"
exec > >(tee -a "$LOG") 2>&1

cd "$REPO"
git fetch upstream
git fetch origin
BASE=$(git rev-parse upstream/quattro)
echo "BASE=$BASE"

install_hook() {
  local gitdir
  gitdir=$(git -C "$1" rev-parse --git-common-dir)
  mkdir -p "$gitdir/hooks"
  cp "$HOOK_SRC" "$gitdir/hooks/commit-msg"
  chmod +x "$gitdir/hooks/commit-msg"
}

ensure_clean_commit() {
  git log -1 --format=%B | grep -viE 'Co-authored-by:.*(Cursor|cursoragent|Claude|Anthropic)' >/tmp/msgcheck || true
  if git log -1 --format=%B | grep -qiE 'Co-authored-by:.*(Cursor|cursoragent|Claude|Anthropic)'; then
    echo "FATAL: AI co-author present" >&2
    git log -1 --format=%B >&2
    exit 1
  fi
}

make_wt() {
  local name="$1" branch="$2"
  local wt="$REPO/worktrees/$name"
  if [[ -d $wt ]]; then
    git -C "$wt" checkout -B "$branch" "$BASE"
  else
    git worktree add -B "$branch" "$wt" "$BASE"
  fi
  install_hook "$wt"
  echo "$wt"
}

echo "driver ready BASE=$BASE"
