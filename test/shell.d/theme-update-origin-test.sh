#!/bin/bash

set -euo pipefail

# Theme update reads the stored Git origin rather than the install argument, so
# existing clones need the same transport policy immediately before pull.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

theme="$test_tmp/home/.config/omarchy/themes/transport"
mock_bin="$test_tmp/bin"
pull_marker="$test_tmp/pull-reached"
mkdir -p "$theme" "$mock_bin"

real_git=$(command -v git)
"$real_git" -C "$theme" init -q
"$real_git" -C "$theme" remote add origin https://example.com/acme/theme.git

cat >"$mock_bin/git" <<'SH'
#!/bin/bash
for arg in "$@"; do
  if [[ $arg == "pull" ]]; then
    printf '%s\n' "$*" >"$OMARCHY_TEST_PULL_MARKER"
    exit 70
  fi
done
exec "$OMARCHY_TEST_REAL_GIT" "$@"
SH

cat >"$mock_bin/omarchy-theme-extras" <<'SH'
#!/bin/bash
printf '%s\n' "$OMARCHY_TEST_THEME"
SH

chmod +x "$mock_bin"/*

update_theme() {
  HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_THEME="$theme" \
    OMARCHY_TEST_PULL_MARKER="$pull_marker" OMARCHY_TEST_REAL_GIT="$real_git" \
    bash "$ROOT/bin/omarchy-theme-update" >"$test_tmp/out" 2>&1
}

for url in \
  "git://example.com/acme/theme.git" \
  "http://example.com/acme/theme.git" \
  "ftp://example.com/acme/theme.git"; do
  "$real_git" -C "$theme" remote set-url origin "$url"
  rm -f "$pull_marker"

  if update_theme; then
    fail "theme update refuses the stored unauthenticated origin '$url'"
  fi
  [[ ! -e $pull_marker ]] ||
    fail "theme update refuses '$url' before git pull"
  grep -qF "remote set-url origin URL" "$test_tmp/out" ||
    fail "theme update gives an origin migration command for '$url'" "$(cat "$test_tmp/out")"
done

pass "theme update blocks every stored unauthenticated network origin before pull"

for url in \
  "https://example.com/acme/theme.git" \
  "ssh://git@example.com/acme/theme.git" \
  "git+ssh://git@example.com/acme/theme.git" \
  "ssh+git://git@example.com/acme/theme.git" \
  "ftps://example.com/acme/theme.git" \
  "file://$test_tmp/theme.git" \
  "git@example.com:acme/theme.git" \
  "$test_tmp/theme.git"; do
  "$real_git" -C "$theme" remote set-url origin "$url"
  rm -f "$pull_marker"

  update_theme && fail "the pull stub makes the update fail after accepting '$url'"
  [[ -e $pull_marker ]] ||
    fail "theme update lets the authenticated or local origin reach pull: $url" "$(cat "$test_tmp/out")"
done

pass "theme update preserves authenticated network and local origins"

# A bare `git pull` reads the current branch's configured remote, which need not
# be named origin. Check and pass that exact remote so a secure origin cannot
# hide a plaintext upstream, and a securely renamed remote keeps working.
branch=$("$real_git" -C "$theme" symbolic-ref --quiet --short HEAD)
"$real_git" -C "$theme" remote add upstream http://example.com/acme/theme.git
"$real_git" -C "$theme" config "branch.$branch.remote" upstream
"$real_git" -C "$theme" remote set-url origin https://example.com/acme/theme.git
rm -f "$pull_marker"

if update_theme; then
  fail "theme update refuses the branch's plaintext upstream remote"
fi
[[ ! -e $pull_marker ]] ||
  fail "theme update checks the branch remote before pull" "$(cat "$pull_marker")"
grep -qF "'upstream' remote" "$test_tmp/out" ||
  fail "theme update identifies the refused branch remote" "$(cat "$test_tmp/out")"
grep -qF "remote set-url upstream URL" "$test_tmp/out" ||
  fail "theme update gives a migration command for the branch remote" "$(cat "$test_tmp/out")"

"$real_git" -C "$theme" remote set-url upstream https://example.com/acme/theme.git
"$real_git" -C "$theme" remote remove origin
rm -f "$pull_marker"
update_theme && fail "the pull stub fails after accepting the renamed secure remote"
[[ $(<"$pull_marker") == "-C $theme pull -- upstream" ]] ||
  fail "theme update pulls explicitly from the checked branch remote" "$(cat "$pull_marker")"

"$real_git" -C "$theme" config "branch.$branch.remote" http://example.com/acme/theme.git
rm -f "$pull_marker"
if update_theme; then
  fail "theme update refuses a plaintext URL used directly as the branch remote"
fi
[[ ! -e $pull_marker ]] ||
  fail "theme update checks a direct branch URL before pull" "$(cat "$pull_marker")"
grep -qF "config branch.$branch.remote URL" "$test_tmp/out" ||
  fail "theme update gives a migration command for a direct branch URL" "$(cat "$test_tmp/out")"

"$real_git" -C "$theme" config "branch.$branch.remote" https://example.com/acme/theme.git
rm -f "$pull_marker"
update_theme && fail "the pull stub fails after accepting the direct secure branch URL"
[[ $(<"$pull_marker") == "-C $theme pull -- https://example.com/acme/theme.git" ]] ||
  fail "theme update pulls explicitly from the checked direct branch URL" "$(cat "$pull_marker")"

"$real_git" -C "$theme" config --unset "branch.$branch.remote"
"$real_git" -C "$theme" remote add origin https://example.com/acme/theme.git

pass "theme update checks and pulls from the current branch remote or URL"

"$real_git" -C "$theme" remote set-url origin shorthand:acme/theme.git
"$real_git" config --file "$test_tmp/home/.gitconfig" url.git://example.com/.insteadOf shorthand:
rm -f "$pull_marker"

if update_theme; then
  fail "theme update refuses an origin rewritten to an unauthenticated URL"
fi
[[ ! -e $pull_marker ]] ||
  fail "theme update checks the expanded origin before pull"

pass "theme update checks the effective URL after Git origin rewriting"
