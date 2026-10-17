#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home" "$test_tmp/home/.hermes/profiles/james"

for command in xdg-user-dirs-update xdg-settings xdg-mime; do
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$command"
done
chmod +x "$mock_bin"/*

# Provisioning prepends $OMARCHY_PATH/bin, which shadows a mock for anything
# Omarchy ships, so the install suite is stubbed out at its path instead. The
# real one rethemes the session it runs in: hyprctl reload against the live
# compositor, gsettings against the live desktop, and a global Node install.
mkdir -p "$test_tmp/install/user"
: >"$test_tmp/install/user/all.sh"

HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_INSTALL="$test_tmp/install" bash "$ROOT/bin/omarchy-provision-user" >/dev/null ||
  fail "omarchy-provision-user finishes"

for skill in omarchy diagnose-crash; do
  link="$test_tmp/home/.gemini/config/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$ROOT/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for Antigravity"

  link="$test_tmp/home/.hermes/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$ROOT/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for Hermes"

  link="$test_tmp/home/.hermes/profiles/james/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$ROOT/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for a Hermes profile"
done

pass "omarchy-provision-user provisions Antigravity and Hermes skills"

bookmarks="$test_tmp/home/.config/gtk-3.0/bookmarks"
required=(Downloads Projects Pictures Videos)

for dir in "${required[@]}"; do
  [[ $(grep -Fxc "file://$test_tmp/home/$dir $dir" "$bookmarks") == 1 ]] ||
    fail "bookmarks hold $dir exactly once"
done
pass "bookmarks hold each required folder exactly once"

# A bookmark added by hand survives, and the file keeps the mode it already had:
# a plain write would reset that to the umask default. Start from a file the
# helper must add to, so the write actually happens and the mode survives it
# rather than being preserved only because no write was needed.
printf 'file:///srv/shared Books Books\n' >"$bookmarks"
chmod 600 "$bookmarks"
HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash "$ROOT/bin/omarchy-gtk-bookmarks" >/dev/null
[[ $(grep -Fxc "file:///srv/shared Books Books" "$bookmarks") == 1 ]] ||
  fail "bookmarks preserve a user-added entry"
[[ $(stat -c '%a' "$bookmarks") == 600 ]] || fail "bookmarks preserve their mode"
[[ $(grep -Fxc "file://$test_tmp/home/Downloads Downloads" "$bookmarks") == 1 ]] ||
  fail "bookmarks seed the defaults while preserving the user entry"
pass "bookmarks preserve a user-added entry and their mode"

# The check-then-act loop is what produced duplicates, and the atomic write
# advertises cleaning up ones a user already has. Duplicate defaults collapse to
# one, other entries survive, and a file that is already correct is left alone
# rather than rewritten (the old loop did not touch it either).
printf 'file://%s/Downloads Downloads\nfile://%s/Downloads Downloads\nfile:///srv/shared Books Books\n' \
  "$test_tmp/home" "$test_tmp/home" >"$bookmarks"

HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash "$ROOT/bin/omarchy-gtk-bookmarks" >/dev/null

[[ $(grep -Fxc "file://$test_tmp/home/Downloads Downloads" "$bookmarks") == 1 ]] ||
  fail "pre-existing duplicate bookmarks collapse to one" "$(cat "$bookmarks")"
[[ $(grep -Fxc "file:///srv/shared Books Books" "$bookmarks") == 1 ]] ||
  fail "collapsing duplicates keeps the user's other entries" "$(cat "$bookmarks")"

stable_inode=$(stat -c '%i' "$bookmarks")
HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash "$ROOT/bin/omarchy-gtk-bookmarks" >/dev/null
[[ $(stat -c '%i' "$bookmarks") == "$stable_inode" ]] ||
  fail "an already-correct bookmarks file is not rewritten"
pass "bookmarks are deduplicated and an unchanged file is left alone"

# Seeding used to check each line and append separately, so two runs both saw a
# bookmark as missing and both wrote it. A bare `wait` returns success even if
# a worker failed while the others still produced a correct file, so each PID
# is awaited individually: the test proves every writer succeeded and the
# final state is right, not just the final state.
printf 'file://%s/Books Books\n' "$test_tmp/home" >"$bookmarks"
pids=()
for _ in {1..8}; do
  HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-gtk-bookmarks" >/dev/null &
  pids+=("$!")
done
for pid in "${pids[@]}"; do
  wait "$pid" || fail "concurrent bookmark writer failed"
done

[[ $(wc -l <"$bookmarks") == 5 ]] ||
  fail "concurrent seeding adds no duplicate bookmarks" "$(cat "$bookmarks")"
[[ $(sort "$bookmarks" | uniq -d | wc -l) == 0 ]] ||
  fail "concurrent seeding adds no duplicate bookmarks" "$(cat "$bookmarks")"
pass "concurrent seeding adds no duplicate bookmarks"

# Renaming onto a symlink replaces the link itself with a regular file, so a
# dotfile-managed bookmarks file would silently stop being managed. The helper
# follows the link and rewrites the target instead.
shared="$test_tmp/shared-bookmarks"
printf 'file:///srv/shared Books Books\n' >"$shared"
rm -f "$bookmarks"
ln -s "$shared" "$bookmarks"

HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash "$ROOT/bin/omarchy-gtk-bookmarks" >/dev/null

[[ -L $bookmarks ]] || fail "a symlinked bookmarks file stays a symlink" "$(ls -l "$bookmarks")"
[[ $(grep -Fxc "file://$test_tmp/home/Downloads Downloads" "$shared") == 1 ]] ||
  fail "a symlinked bookmarks file is written through to its target" "$(cat "$shared")"
pass "a symlinked bookmarks file keeps its link and is written through"

# A symlink may point at a file its manager has not created yet; the link must
# stay and the target be created, not the link replaced with a regular file.
missing_target="$test_tmp/shared-missing/bookmarks"
mkdir -p "$test_tmp/shared-missing"
rm -f "$bookmarks"
ln -s "$missing_target" "$bookmarks"

HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash "$ROOT/bin/omarchy-gtk-bookmarks" >/dev/null

[[ -L $bookmarks ]] || fail "a symlink to a missing target stays a symlink" "$(ls -l "$bookmarks")"
[[ $(grep -Fxc "file://$test_tmp/home/Downloads Downloads" "$missing_target") == 1 ]] ||
  fail "a symlink to a missing target is created and written through"
pass "a symlink to a missing target is created and keeps its link"

# A file whose last line has no trailing newline used to have that last bookmark
# joined onto the first default line by the read-and-rewrite, changing its label
# and dropping the Downloads entry. Normalize the existing content first.
rm -f "$bookmarks"
printf 'file:///srv/shared Books Books' >"$bookmarks"

HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash "$ROOT/bin/omarchy-gtk-bookmarks" >/dev/null

[[ $(grep -Fxc "file:///srv/shared Books Books" "$bookmarks") == 1 ]] ||
  fail "a file without a trailing newline keeps its last bookmark intact" "$(cat "$bookmarks")"
[[ $(grep -Fxc "file://$test_tmp/home/Downloads Downloads" "$bookmarks") == 1 ]] ||
  fail "a file without a trailing newline still seeds Downloads" "$(cat "$bookmarks")"
pass "a file without a trailing newline is not merged with the defaults"

# readlink -f fails when the link's target parent is missing. The append this
# replaces would have failed through the link; a rename would replace the link
# with a regular file. Stop and leave the link alone instead.
dangling="$test_tmp/no-such-dir/bookmarks"
rm -f "$bookmarks"
ln -s "$dangling" "$bookmarks"

if HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash "$ROOT/bin/omarchy-gtk-bookmarks" >/dev/null 2>&1; then
  fail "an unresolvable bookmarks symlink is reported as a failure"
fi
[[ -L $bookmarks ]] || fail "an unresolvable bookmarks symlink is left in place" "$(ls -l "$bookmarks")"
[[ ! -e $bookmarks ]] || fail "an unresolvable bookmarks symlink is not replaced with a file"
pass "an unresolvable bookmarks symlink is left in place and reported"

# Renaming the temporary over a directory (or another non-regular path) moves it
# into the directory and leaves the bookmarks unseeded, while exiting 0. Refuse
# the path instead, and leave no temporary behind.
rm -f "$bookmarks"
mkdir -p "$bookmarks"
if HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash "$ROOT/bin/omarchy-gtk-bookmarks" >/dev/null 2>&1; then
  fail "a non-regular bookmarks path is reported as a failure"
fi
[[ -d $bookmarks ]] || fail "a non-regular bookmarks path is left in place"
[[ -z $(ls -A "$bookmarks") ]] || fail "a non-regular bookmarks path collects no stray temporary"
rmdir "$bookmarks"
pass "a non-regular bookmarks path is reported and left alone"

# Exiting successfully when the bookmarks cannot be written is what let
# omarchy-provision-user finalize a user whose bookmarks were never seeded, and
# it is indistinguishable from success for any caller that does not read stderr.
# The helper creates the directory itself now, so a missing one no longer
# fails: an existing-but-unwritable directory is what exercises the failure.
rm -f "$bookmarks"
chmod 500 "$test_tmp/home/.config/gtk-3.0"

if HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash "$ROOT/bin/omarchy-gtk-bookmarks" >/dev/null 2>&1; then
  fail "an unwritable bookmarks directory is reported as a failure" "the helper exited successfully"
fi
pass "an unwritable bookmarks directory is reported as a failure"
