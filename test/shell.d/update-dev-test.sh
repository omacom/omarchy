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
        [[ ${TEST_GIT_UPSTREAM:-origin/quattro} != "none" ]] || exit 1
        echo "${TEST_GIT_UPSTREAM:-origin/quattro}"
        ;;
      --verify)
        [[ ${TEST_GIT_QUATTRO_REMOTE:-yes} == "yes" ]] || exit 1
        ;;
      *)
        exit 1
        ;;
    esac
    ;;
  branch)
    [[ $2 == --set-upstream-to=* ]]
    ;;
  symbolic-ref)
    echo refs/heads/quattro
    ;;
  for-each-ref)
    echo origin
    ;;
  config)
    case "$2" in
      remote.origin.url) echo https://github.com/omacom/omarchy.git ;;
      remote.origin.promisor) [[ ${TEST_GIT_PROMISOR:-no} == "yes" ]] && echo true ;;
      *) exit 1 ;;
    esac
    ;;
  fetch)
    [[ $2 == "--filter=blob:none" && $3 == "origin" ]]
    ;;
  pull)
    [[ $2 == "--ff-only" ]]
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
TEST_GIT_UPSTREAM=none run_dev_update "$checkout"
if grep -q ' pull ' "$git_log"; then
  fail "dev checkout without an upstream is not pulled" "$(cat "$git_log")"
fi
pass "dev checkout without an upstream is skipped safely"

: >"$git_log"
if TEST_GIT_CHECKOUT=no run_dev_update "$checkout" >"$test_tmp/invalid.out" 2>"$test_tmp/invalid.err"; then
  fail "invalid dev checkout fails the update"
fi
grep -F "OMARCHY_PATH is not a git checkout: $checkout" "$test_tmp/invalid.err" >/dev/null ||
  fail "invalid dev checkout reports the configured path" "$(cat "$test_tmp/invalid.err")"
pass "invalid dev checkout fails with a useful error"

# The master retargeting runs against real scratch repositories: the decision
# depends on fetch --prune, @{upstream} resolution and ancestry, which a stub
# cannot model faithfully.
real_git() { git -c user.email=t@t -c user.name=t -c init.defaultBranch=master -c advice.detachedHead=false "$@"; }
real_update() { # dir -> runs the real script with the system git
  PATH="/usr/bin:$PATH" OMARCHY_PATH="$1" "$ROOT/bin/omarchy-update-dev" >"$1.out" 2>"$1.err"
}
# The configured tracking branch, which still names master after a prune.
upstream_of() {
  local branch
  branch=$(git -C "$1" branch --show-current)
  echo "$(git -C "$1" config "branch.$branch.remote")/$(git -C "$1" config "branch.$branch.merge" | sed 's|^refs/heads/||')"
}
commit_to() { echo "$2" >>"$1/readme"; real_git -C "$1" add readme; real_git -C "$1" commit -q -m "$2"; }

# new_scenario name: a bare remote whose master and quattro start at the same
# commit, plus a checkout tracking origin/master. Leaves $remote_git, $work and
# $checkout pointing at them.
new_scenario() {
  local dir="$test_tmp/real-$1"
  mkdir -p "$dir"
  remote_git="$dir/remote.git" work="$dir/work" checkout="$dir/checkout"
  real_git init -q --bare "$remote_git"
  real_git clone -q "$remote_git" "$work" 2>/dev/null
  commit_to "$work" base
  real_git -C "$work" push -q origin master
  real_git -C "$work" push -q origin master:quattro
  real_git clone -q -b master "$remote_git" "$checkout"
}
delete_remote_master() { real_git --git-dir="$remote_git" branch -q -D master; }

new_scenario pruned
delete_remote_master
real_git -C "$checkout" fetch -q --prune origin
real_update "$checkout" || fail "a pruned master upstream is retargeted to quattro" "$(cat "$checkout.err")"
[[ $(upstream_of "$checkout") == origin/quattro ]] ||
  fail "a pruned master upstream tracks origin/quattro after update" "$(upstream_of "$checkout")"
pass "a pruned master upstream is retargeted to quattro"

new_scenario stale
commit_to "$work" quattro-only
real_git -C "$work" push -q origin master:quattro
delete_remote_master
# The checkout still has refs/remotes/origin/master, so @{upstream} resolves.
real_update "$checkout" || fail "a stale origin/master ref is pruned and retargeted" "$(cat "$checkout.err")"
[[ $(upstream_of "$checkout") == origin/quattro ]] ||
  fail "a stale origin/master ref ends up tracking origin/quattro" "$(upstream_of "$checkout")"
grep -q quattro-only "$checkout/readme" || fail "a stale origin/master checkout is fast-forwarded to quattro"
pass "a stale origin/master ref is pruned, then retargeted and pulled"

new_scenario prequattro
real_git --git-dir="$remote_git" branch -q -D quattro
rm -rf "$checkout"
real_git clone -q -b master "$remote_git" "$checkout"
# quattro appears and master is deleted after this checkout last fetched.
real_git -C "$work" push -q origin master:quattro
delete_remote_master
real_update "$checkout" ||
  fail "a checkout that never fetched quattro fetches before deciding" "$(cat "$checkout.err")"
[[ $(upstream_of "$checkout") == origin/quattro ]] ||
  fail "a checkout that never fetched quattro tracks it after update" "$(upstream_of "$checkout")"
pass "a pre-quattro checkout fetches before deciding and is retargeted"

new_scenario fetchfail
delete_remote_master
mv "$remote_git" "$remote_git.offline"
if real_update "$checkout"; then
  fail "a failed fetch stops the update"
fi
[[ $(upstream_of "$checkout") == origin/master ]] ||
  fail "a failed fetch leaves the master upstream untouched" "$(upstream_of "$checkout")"
grep -F "could not fetch origin" "$checkout.err" >/dev/null ||
  fail "a failed fetch reports why it stopped" "$(cat "$checkout.err")"
pass "a failed fetch stops without changing the upstream"

new_scenario diverged
commit_to "$checkout" local-only
delete_remote_master
if real_update "$checkout"; then
  fail "local commits that are not on quattro stop the update"
fi
[[ $(upstream_of "$checkout") == origin/master ]] ||
  fail "local commits not on quattro keep the old upstream so the hint repeats" "$(upstream_of "$checkout")"
if ! grep -F "not on origin/quattro" "$checkout.err" >/dev/null ||
  ! grep -F "checkout -b quattro --track origin/quattro" "$checkout.err" >/dev/null; then
  fail "local commits not on quattro print the checkout hint" "$(cat "$checkout.err")"
fi
pass "local commits not on quattro stop with a checkout hint"

new_scenario noquattro
real_git --git-dir="$remote_git" branch -q -D quattro
real_git -C "$checkout" fetch -q --prune origin
delete_remote_master
if real_update "$checkout"; then
  fail "a deleted master with no quattro fails the update"
fi
grep -F "upstream origin/master no longer exists" "$checkout.err" >/dev/null ||
  fail "a deleted master with no quattro reports an actionable error" "$(cat "$checkout.err")"
pass "a deleted master with no quattro fails with an actionable error"

new_scenario fork
commit_to "$work" master-only
real_git -C "$work" push -q origin master
real_update "$checkout" || fail "a master that still exists keeps updating" "$(cat "$checkout.err")"
[[ $(upstream_of "$checkout") == origin/master ]] ||
  fail "a master that still exists keeps its upstream" "$(upstream_of "$checkout")"
grep -q master-only "$checkout/readme" || fail "a master that still exists is pulled"
pass "a master that still exists on its remote is left alone"

new_scenario localmaster
real_git -C "$checkout" checkout -q -b feature
real_git -C "$checkout" branch -q --set-upstream-to=master
real_git -C "$checkout" checkout -q master
commit_to "$checkout" master-ahead
real_git -C "$checkout" checkout -q feature
real_update "$checkout" || fail "a branch tracking a local master keeps updating" "$(cat "$checkout.err")"
[[ $(upstream_of "$checkout") == ./master ]] ||
  fail "a branch tracking a local master keeps its upstream" "$(upstream_of "$checkout")"
pass "a branch tracking a local master (remote = .) is left alone"

# A URL remote has no remote-tracking refs, so @{upstream} never resolves even
# while master still exists there.
new_scenario urlremote
real_git -C "$checkout" config branch.master.remote "file://$remote_git"
real_update "$checkout" || fail "a branch tracking master by URL is not taken for a deleted master" "$(cat "$checkout.err")"
[[ $(upstream_of "$checkout") == "file://$remote_git/master" ]] ||
  fail "a branch tracking master by URL keeps its upstream" "$(upstream_of "$checkout")"
pass "a branch tracking master by URL is left alone"

grep -qE '^ *omarchy-update-dev$' "$ROOT/bin/omarchy-update" ||
  fail "top-level update includes the dev checkout step"
pass "top-level update includes the dev checkout step"
