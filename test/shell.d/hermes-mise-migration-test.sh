#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1790017600.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
hermes="$test_home/.local/bin/hermes"
marker="# Written by omarchy-install-hermes-cli."
tool='pipx:hermes-agent[extras=all]'
mise_log="$test_tmp/mise-log"
mkdir -p "$mock_bin" "$test_home/.local/bin"

cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_DESKTOP_INSTALLED:-0} == 1 ]]
SH

cat >"$mock_bin/omarchy-default-agent" <<'SH'
#!/bin/bash
printf '%s\n' "${OMARCHY_TEST_DEFAULT_AGENT:-}"
SH

# `where` finds the environment mise built when a test says it did, and `ls -g`
# lists it as requested, until uninstalled and unrequested respectively; a test
# can make either removal stick. Every call is logged, so a test can tell
# being asked from being told to remove.
cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_MISE_LOG"
case "$1" in
  where)
    [[ ${OMARCHY_TEST_MISE_STUCK:-0} == 1 ]] && exit 0
    [[ ${OMARCHY_TEST_MISE_BUILT:-0} == 1 && ! -e $OMARCHY_TEST_MISE_LOG.removed ]]
    ;;
  ls)
    [[ ${OMARCHY_TEST_MISE_LS_FAIL:-0} == 1 ]] && exit 1
    if [[ ${OMARCHY_TEST_MISE_BUILT:-0} == 1 && ! -e $OMARCHY_TEST_MISE_LOG.unrequested ]]; then
      echo '{"pipx:hermes-agent[extras=all]": [{"version": "latest"}]}'
    else
      echo '{}'
    fi
    ;;
  rm)
    [[ ${OMARCHY_TEST_MISE_RM_STUCK:-0} == 1 ]] || touch "$OMARCHY_TEST_MISE_LOG.unrequested"
    ;;
  uninstall)
    touch "$OMARCHY_TEST_MISE_LOG.removed"
    ;;
esac
SH

chmod +x "$mock_bin"/*

# A PATH with no mise on it at all, for a machine that has none: the mocks
# minus theirs, and links to every system command but the real one, so the
# ambient PATH cannot supply what the test says is missing.
no_mise_path="$test_tmp/bin-without-mise:$test_home/.local/bin:$ROOT/bin:$test_tmp/usr-bin-without-mise"
mkdir -p "$test_tmp/bin-without-mise"
for mock in "$mock_bin"/*; do
  [[ $(basename "$mock") == mise ]] || ln -s "$mock" "$test_tmp/bin-without-mise/"
done
# A directory of links made here, never a copy of /usr/bin that could itself be
# a link to it: the rm below must only ever remove a link of this test's own.
mkdir "$test_tmp/usr-bin-without-mise"
ln -s "$(realpath /usr/bin)"/* "$test_tmp/usr-bin-without-mise/"
rm -f "$test_tmp/usr-bin-without-mise/mise"
! PATH="$no_mise_path" command -v mise >/dev/null 2>&1 || fail "the PATH built for a machine without mise still finds one"

# The real installer is on PATH: the migration asks it what to retire and
# whether a Hermes still answers before telling the user how to get one back.
# ~/.local/bin is on PATH the way Omarchy puts it there, after the mocks.
run_migration() {
  : >"$mise_log"
  rm -f "$mise_log.removed" "$mise_log.unrequested"
  OMARCHY_TEST_MISE_LOG="$mise_log" \
    HOME="$test_home" \
    PATH="${OMARCHY_TEST_PATH:-$mock_bin:$test_home/.local/bin:$ROOT/bin:$PATH}" \
    bash -euo pipefail "$migration" >"$test_tmp/output" 2>&1
}

write_stub() {
  printf '%s\n' "#!/bin/bash" "$marker" "exec mise x '$tool' -- hermes \"\$@\"" >"$hermes"
  chmod +x "$hermes"
}

write_stub
OMARCHY_TEST_MISE_BUILT=1 run_migration || fail "the migration succeeds over the Omarchy wrapper" "$(cat "$test_tmp/output")"
[[ ! -e $hermes ]] || fail "the migration removes the wrapper Omarchy wrote"
grep -qxF "rm -g $tool" "$mise_log" || fail "the migration removes the global mise Hermes" "$(cat "$mise_log")"
grep -qxF "uninstall --all $tool" "$mise_log" || fail "the migration uninstalls the mise Hermes" "$(cat "$mise_log")"
pass "the migration retires the wrapper and the Hermes mise built"

write_stub
run_migration || fail "the migration succeeds over a wrapper nobody ran"
[[ ! -e $hermes ]] || fail "the migration removes a wrapper nobody ran"
! grep -q '^rm -g' "$mise_log" || fail "nothing built means nothing to uninstall"
pass "a wrapper nobody ran goes without an uninstall"

run_migration || fail "the migration succeeds with nothing to do"
[[ ! -s $mise_log ]] || fail "with nothing of Omarchy's left, mise is not asked" "$(cat "$mise_log")"
pass "the migration is a no-op once the wrapper is gone"

# Anyone else's hermes stays exactly where it is, is not run, and does not vouch
# for a mise environment being Omarchy's.
foreign_ran="$test_tmp/foreign-ran"
foreign_body="#!/bin/bash
touch $foreign_ran
exec $test_home/.hermes/hermes-agent/venv/bin/hermes \"\$@\""
printf '%s\n' "$foreign_body" >"$hermes"
chmod +x "$hermes"
OMARCHY_TEST_MISE_BUILT=1 run_migration || fail "the migration succeeds over a foreign hermes"
[[ -x $hermes && $(cat "$hermes") == "$foreign_body" ]] || fail "a hermes the user set up stays as it is"
[[ ! -e $foreign_ran ]] || fail "the migration runs a foreign hermes"
! grep -q '^rm -g' "$mise_log" || fail "a user's mise environment is removed on the strength of their wrapper"
pass "the migration leaves a hermes the user set up alone"

printf '%s\n' "#!/bin/bash" "# Replaces the stub omarchy-install-hermes-cli used to write." >"$hermes"
chmod +x "$hermes"
run_migration || fail "the migration succeeds over a wrapper that mentions the installer"
[[ -x $hermes ]] || fail "a wrapper that merely mentions the installer is removed"
pass "a wrapper that merely mentions the installer stays"

# The wrapper was written as a regular file, so a link is someone else's
# arrangement even when it lands on the marked file.
rm -f "$hermes"
printf '%s\n' "#!/bin/bash" "$marker" >"$test_tmp/stub"
ln -s "$test_tmp/stub" "$hermes"
run_migration || fail "the migration succeeds over a link to the wrapper"
[[ -L $hermes ]] || fail "a link to the wrapper is removed"
rm -f "$hermes"
ln -s "$test_home/nowhere" "$hermes"
run_migration || fail "the migration succeeds over a dangling link"
[[ -L $hermes ]] || fail "a dangling link is removed"
rm -f "$hermes"
mkdir "$hermes"
run_migration || fail "the migration succeeds over a directory at the command's path"
[[ -d $hermes ]] || fail "a directory at the command's path is removed"
rmdir "$hermes"
pass "the migration leaves links and directories at the command's path alone"

# Without the wrapper nothing proves a mise environment is Omarchy's, the app
# being installed included: a user who built the same spec keeps it.
rm -f "$hermes"
OMARCHY_TEST_DESKTOP_INSTALLED=1 OMARCHY_TEST_MISE_BUILT=1 run_migration || fail "the migration succeeds with the app installed and no wrapper"
! grep -q '^rm -g' "$mise_log" || fail "a mise environment without the wrapper is removed" "$(cat "$mise_log")"
pass "a mise environment without the wrapper is nobody's to remove"

# The environment goes before the wrapper does, because the wrapper is the
# only proof a rerun would have. A removal that leaves the environment behind
# keeps the wrapper, says how to finish by hand, and leaves the migration
# pending; once it can finish, it does.
write_stub
OMARCHY_TEST_MISE_BUILT=1 OMARCHY_TEST_MISE_STUCK=1 run_migration && fail "a removal that left the environment behind counts as done"
[[ -x $hermes ]] || fail "a failed removal takes the wrapper anyway"
grep -qF "mise uninstall --all '$tool'" "$test_tmp/output" || fail "a failed removal says how to finish by hand" "$(cat "$test_tmp/output")"
OMARCHY_TEST_MISE_BUILT=1 run_migration || fail "the migration finishes once the environment can go" "$(cat "$test_tmp/output")"
[[ ! -e $hermes ]] || fail "the retry takes the wrapper once the environment is gone"
pass "a removal that cannot finish leaves the wrapper and the migration pending"

# `mise rm -g` exits 0 whether or not it removed anything, so an environment
# uninstalled but still requested in the global config -- where `mise up` would
# build it again -- is judged by the listing, not the exit code.
write_stub
OMARCHY_TEST_MISE_BUILT=1 OMARCHY_TEST_MISE_RM_STUCK=1 run_migration && fail "an environment still requested counts as removed"
[[ -x $hermes ]] || fail "a still-requested environment takes the wrapper anyway"
grep -qF "mise rm -g '$tool'" "$test_tmp/output" || fail "a still-requested environment says how to finish by hand" "$(cat "$test_tmp/output")"
pass "an environment mise still requests is not counted as gone"

# A listing that cannot be read is not an answer: the wrapper stays and the
# migration stays pending rather than deleting the proof on a guess.
write_stub
OMARCHY_TEST_MISE_BUILT=1 OMARCHY_TEST_MISE_LS_FAIL=1 run_migration && fail "an unreadable listing counts as retired"
[[ -x $hermes ]] || fail "an unreadable listing takes the wrapper anyway"
OMARCHY_TEST_MISE_BUILT=1 run_migration || fail "the migration finishes once the listing can be read" "$(cat "$test_tmp/output")"
[[ ! -e $hermes ]] || fail "the retry takes the wrapper once the listing answers"
pass "a mise listing that cannot be read leaves the migration pending"

# Without mise the listing cannot be read either, and a request it may still
# hold would build Hermes again the day mise is back; the wrapper stays, the
# migration stays pending, and the way out names mise first.
write_stub
OMARCHY_TEST_PATH="$no_mise_path" run_migration && fail "a machine without mise counts the environment as retired"
[[ -x $hermes ]] || fail "without mise the wrapper is taken anyway"
grep -qF "omarchy pkg add mise" "$test_tmp/output" || fail "without mise the way out names mise first" "$(cat "$test_tmp/output")"
pass "without mise the migration stays pending rather than guessing"

# The runtime installer saves whatever held the command aside before upstream's
# installer takes the name, so a user who chose Hermes before this ran has the
# wrapper in that backup and the environment still requested. The copy is proof
# enough, and goes once it has served: left behind it would keep --check
# saying no for a finished install.
saved_dir="$test_home/.local/bin/.hermes-before-desktop.abc123"
mkdir -p "$saved_dir"
write_stub
mv "$hermes" "$saved_dir/hermes"
printf '%s\n' "#!/bin/bash" "exec $test_home/.hermes/hermes-agent/venv/bin/python $test_home/.hermes/hermes-agent/hermes \"\$@\"" >"$hermes"
chmod +x "$hermes"
runtime_command=$(cat "$hermes")
OMARCHY_TEST_MISE_BUILT=1 run_migration || fail "the migration succeeds over a saved wrapper" "$(cat "$test_tmp/output")"
grep -qxF "rm -g $tool" "$mise_log" || fail "a saved wrapper proves the environment Omarchy's" "$(cat "$mise_log")"
[[ ! -e $saved_dir/hermes && ! -d $saved_dir ]] || fail "the saved copy and its empty directory go once the environment is gone"
[[ $(cat "$hermes") == "$runtime_command" ]] || fail "the runtime's command is left alone"
pass "a wrapper saved aside by the runtime installer still retires the environment"
rm -rf "$saved_dir" "$hermes"

# The installer makes real backup directories, so one that is a link is
# somebody else's arrangement: what it points at is neither proof nor ours to
# remove, marker or no marker.
mkdir -p "$test_home/archive"
write_stub
mv "$hermes" "$test_home/archive/hermes"
ln -s "$test_home/archive" "$test_home/.local/bin/.hermes-before-desktop.linked"
OMARCHY_TEST_MISE_BUILT=1 run_migration || fail "the migration succeeds over a linked backup directory"
! grep -q '^rm -g' "$mise_log" || fail "a marked file behind a linked backup directory counts as proof"
[[ -f $test_home/archive/hermes ]] || fail "a file behind a linked backup directory is removed"
rm -f "$test_home/.local/bin/.hermes-before-desktop.linked"; rm -rf "$test_home/archive"
pass "a linked backup directory is neither proof nor touched"

# Choosing Hermes again is what installs the runtime, so a default agent whose
# command just went is told so; one that still answers, or another agent, is not.
write_stub
OMARCHY_TEST_DEFAULT_AGENT=hermes OMARCHY_TEST_MISE_BUILT=1 run_migration || fail "the migration succeeds for a Hermes default agent"
grep -q 'omarchy default agent hermes' "$test_tmp/output" || fail "a default agent that just went is told how to come back" "$(cat "$test_tmp/output")"
# A working Hermes is the app's: the package, its runtime finished and seeded,
# and the command upstream's installer wrote for it.
app_runtime="$test_home/.hermes/hermes-agent"
mkdir -p "$app_runtime/apps/desktop/release/linux-unpacked/resources"
touch "$app_runtime/.hermes-bootstrap-complete" "$app_runtime/apps/desktop/release/linux-unpacked/resources/app.asar" "$app_runtime/apps/desktop/release/linux-unpacked/resources/install-stamp.json"
printf '#!/bin/bash\nexit 0\n' >"$app_runtime/apps/desktop/release/linux-unpacked/Hermes"
chmod +x "$app_runtime/apps/desktop/release/linux-unpacked/Hermes"
cat >"$hermes" <<SH
#!/bin/bash
# stands in for: exec "$app_runtime/venv/bin/python" "$app_runtime/hermes" "\$@"
if [[ \${1:-} == "chat" && \${2:-} == "--help" ]]; then
  echo "[-q QUERY, --query QUERY] [--tui]"
else
  echo "hermes-agent 0.0.0-test"
fi
SH
chmod +x "$hermes"
OMARCHY_TEST_DESKTOP_INSTALLED=1 OMARCHY_TEST_DEFAULT_AGENT=hermes run_migration || fail "the migration succeeds with the app's Hermes in place"
! grep -q 'default agent' "$test_tmp/output" || fail "the app's own Hermes gets reinstall guidance" "$(cat "$test_tmp/output")"
rm -rf "$hermes" "$test_home/.hermes"
OMARCHY_TEST_DEFAULT_AGENT=codex run_migration || fail "the migration succeeds for another default agent"
! grep -q 'default agent' "$test_tmp/output" || fail "another default agent gets Hermes guidance"
pass "the migration says how to reinstall a Hermes that was the default agent"
