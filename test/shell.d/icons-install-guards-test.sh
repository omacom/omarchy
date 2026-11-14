#!/bin/bash

set -euo pipefail

# omarchy-icons-install feeds a pasted URL to git and a name derived from it to
# rm, as omarchy-theme-install does, and shares its guards. They are exercised
# here with git stubbed, so a guard that stopped working shows up as a clone
# that should never have been reached.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/git" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_GIT_CALLS"
[[ $* == *" status --porcelain" ]] && { printf '%s' "${OMARCHY_TEST_GIT_STATUS:-}"; exit 0; }
[[ $* == *" log HEAD --branches --not --remotes --oneline" ]] && { printf '%s' "${OMARCHY_TEST_GIT_UNPUSHED:-}"; exit 0; }
[[ -z ${OMARCHY_TEST_GIT_FAILS:-} ]] || exit 1
[[ $1 == "clone" ]] && mkdir -p "${*: -1}/.git" && printf 'cloned\n' >"${*: -1}/mpv.svg"
exit 0
SH

cat >"$mock_bin/gum" <<'SH'
#!/bin/bash
exit 1
SH

printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"$OMARCHY_TEST_SET_CALLS"\nexit 0\n' >"$mock_bin/omarchy-icons-set"
chmod +x "$mock_bin"/*

sets="$test_tmp/home/.config/omarchy/icons"
git_calls="$test_tmp/git-calls"
set_calls="$test_tmp/set-calls"

install_icons() {
  : >"$git_calls"
  : >"$set_calls"

  HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_GIT_CALLS="$git_calls" OMARCHY_TEST_SET_CALLS="$set_calls" \
    bash "$ROOT/bin/omarchy-icons-install" "$1" >"$test_tmp/out" 2>&1 || return $?
}

for url in "-x" "--upload-pack=touch /tmp/pwned" "ext::sh -c id" "ext://sh -c id"; do
  if install_icons "$url"; then
    fail "omarchy-icons-install refuses the URL '$url'"
  fi

  [[ ! -s $git_calls ]] || fail "omarchy-icons-install refuses '$url' before running git" "$(cat "$git_calls")"
done

pass "a URL that names a git option or a transport helper never reaches git"

# The derived name is joined into the path that is removed before the clone,
# and Original always means no icon set at all.
for url in \
  "https://example.com/..git" \
  "https://example.com/.git" \
  "https://example.com/omarchy-a';id;'b-icons.git" \
  'https://example.com/a$(id).git' \
  "https://example.com/a b.git" \
  "https://example.com/-a.git" \
  "https://example.com/omarchy-original-icons.git"; do
  if install_icons "$url"; then
    fail "omarchy-icons-install refuses the derived name from '$url'"
  fi

  [[ ! -s $git_calls ]] || fail "omarchy-icons-install refuses '$url' before running git" "$(cat "$git_calls")"
done

pass "a URL whose name would climb out, be shell syntax or shadow Original never reaches git"

install_icons "https://github.com/example/omarchy-cool-icons.git" || fail "omarchy-icons-install clones a normal URL"
grep -Fq -- "-- https://github.com/example/omarchy-cool-icons.git" "$git_calls" || fail "omarchy-icons-install passes the URL after --" "$(cat "$git_calls")"
[[ $(<"$sets/cool/mpv.svg") == "cloned" ]] || fail "omarchy-icons-install puts the set under the name derived from the URL" "$(cat "$git_calls")"
grep -Fxq "cool" "$set_calls" || fail "omarchy-icons-install applies the icon set it installed" "$(cat "$set_calls")"

install_icons "git@example.com:omarchy-blue-icons.git" || fail "omarchy-icons-install accepts a home-relative scp-style URL"
[[ -d $sets/blue ]] || fail "omarchy-icons-install names the set after the repo, not the whole URL" "$(cat "$git_calls")"

pass "an ordinary icon set URL still clones and applies"

# The set that is there outlives a clone that fails, and is only replaced once
# its successor is whole.
printf 'mine\n' >"$sets/cool/mpv.svg"
if OMARCHY_TEST_GIT_FAILS=1 install_icons "https://github.com/example/omarchy-cool-icons.git"; then
  fail "omarchy-icons-install reports a clone that failed"
fi
[[ $(<"$sets/cool/mpv.svg") == "mine" ]] || fail "a failed clone leaves the installed icon set as it was"
[[ ! -s $set_calls ]] || fail "a failed clone applies nothing" "$(cat "$set_calls")"
[[ -z $(find "$test_tmp/home/.config/omarchy" -maxdepth 1 -name '.icons-install.*') ]] || fail "a failed clone leaves no staging dir behind"
install_icons "https://github.com/example/omarchy-cool-icons.git" || fail "omarchy-icons-install replaces a set it cloned before"
[[ $(<"$sets/cool/mpv.svg") == "cloned" ]] || fail "reinstalling replaces the cloned icon set"

pass "a failed clone leaves the installed icon set in place"

# A cloned set the user has since edited is not replaced either: neither with
# files changed in place nor with commits its remote never saw.
printf 'edited\n' >"$sets/cool/mpv.svg"
if OMARCHY_TEST_GIT_STATUS=" M mpv.svg" install_icons "https://github.com/example/omarchy-cool-icons.git"; then
  fail "omarchy-icons-install refuses to replace a cloned set with uncommitted changes"
fi
if OMARCHY_TEST_GIT_UNPUSHED="abc1234 my icon" install_icons "https://github.com/example/omarchy-cool-icons.git"; then
  fail "omarchy-icons-install refuses to replace a cloned set with commits of the user's own"
fi
! grep -q '^clone' "$git_calls" || fail "a cloned set with local changes is refused before cloning" "$(cat "$git_calls")"
[[ $(<"$sets/cool/mpv.svg") == "edited" ]] || fail "a cloned icon set's local changes are left as they were"

pass "installing never replaces a cloned icon set that has local changes"

# With git itself: a clone is replaced while it is as it was cloned, and kept
# once it holds work of the user's own that no remote has, wherever git keeps
# it: a commit on a branch, a commit on a detached HEAD, or a stash.
real_home="$test_tmp/real-home"
real_sets="$real_home/.config/omarchy/icons"
upstream="$test_tmp/omarchy-real-icons"
real_git() { git -c user.name=test -c user.email=test@example.com -c init.defaultBranch=main "$@"; }
real_git init -q "$upstream"
printf '<svg/>\n' >"$upstream/mpv.svg"
real_git -C "$upstream" add mpv.svg
real_git -C "$upstream" commit -q -m "An icon"
install_real() {
  : >"$set_calls"
  HOME="$real_home" PATH="$test_tmp/set-only:$ROOT/bin:$PATH" OMARCHY_TEST_SET_CALLS="$set_calls" \
    bash "$ROOT/bin/omarchy-icons-install" "$upstream" >"$test_tmp/out" 2>&1 || return $?
}
mkdir -p "$test_tmp/set-only"
cp "$mock_bin/omarchy-icons-set" "$test_tmp/set-only/"
install_real || fail "omarchy-icons-install clones with git itself" "$(cat "$test_tmp/out")"
install_real || fail "omarchy-icons-install replaces a clone that is as it was cloned" "$(cat "$test_tmp/out")"

real_git -C "$real_sets/real" commit -q --allow-empty -m "On a branch"
! install_real || fail "omarchy-icons-install keeps a clone with a commit on a branch"
real_git -C "$real_sets/real" reset -q --hard origin/HEAD

real_git -C "$real_sets/real" checkout -q --detach
real_git -C "$real_sets/real" commit -q --allow-empty -m "On a detached HEAD"
! install_real || fail "omarchy-icons-install keeps a clone with a commit on a detached HEAD"
real_git -C "$real_sets/real" checkout -q -

printf 'stashed\n' >"$real_sets/real/mpv.svg"
real_git -C "$real_sets/real" stash -q
! install_real || fail "omarchy-icons-install keeps a clone with stashed changes"
real_git -C "$real_sets/real" stash drop -q

install_real || fail "omarchy-icons-install replaces the clone again once that work is gone" "$(cat "$test_tmp/out")"

pass "a clone holding commits or a stash no remote has is kept, on a branch or a detached HEAD"

# A set the user wrote, or a working copy they linked in, is never replaced.
mkdir -p "$sets/handmade" "$test_tmp/working/.git"
printf 'drawn by hand\n' >"$sets/handmade/mpv.svg"
ln -s "$test_tmp/working" "$sets/linked"
for name in handmade linked; do
  if install_icons "https://github.com/example/omarchy-$name-icons.git"; then
    fail "omarchy-icons-install refuses to replace the user's own set '$name'"
  fi
  [[ ! -s $git_calls ]] || fail "omarchy-icons-install refuses '$name' before running git" "$(cat "$git_calls")"
done
[[ $(<"$sets/handmade/mpv.svg") == "drawn by hand" && -L $sets/linked ]] || fail "the user's own icon sets are left as they were"

pass "installing never replaces an icon set the user wrote or linked in"
