#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

for command in git jq; do require_command "$command"; done

# The installer runs upstream's install.sh from the hermes-agent package and
# starts the checkout on main at the packaged release. Real git exercises the
# branch, history and patch work; the package, install.sh, mise and the default
# agent are mocks, so nothing reaches a live Hermes or the real mise. Every
# mock appends to one events file, so the order things happen in is provable.

test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT
export OMARCHY_TEST_ROOT="$test_tmp"
mkdir -p "$test_tmp/bin" "$test_tmp/share" "$test_tmp/seed"

git -C "$test_tmp/seed" init -q -b main
printf 'venv/\n.hermes-bootstrap-complete\n' >"$test_tmp/seed/.gitignore"
printf 'before\n' >"$test_tmp/seed/runtime.txt"
printf '#!/bin/bash\n' >"$test_tmp/seed/hermes"
git -C "$test_tmp/seed" add .
git -C "$test_tmp/seed" -c user.name=Test -c user.email=test@example.invalid commit -qm fixture
release_commit=$(git -C "$test_tmp/seed" rev-parse HEAD)
printf 'after\n' >"$test_tmp/seed/runtime.txt"
git -C "$test_tmp/seed" diff >"$test_tmp/share/runtime.patch"
printf 'before\n' >"$test_tmp/seed/runtime.txt"
printf 'newer\n' >"$test_tmp/seed/newer.txt"
git -C "$test_tmp/seed" add newer.txt
git -C "$test_tmp/seed" -c user.name=Test -c user.email=test@example.invalid commit -qm newer-main
origin_commit=$(git -C "$test_tmp/seed" rev-parse HEAD)
export OMARCHY_TEST_RELEASE_COMMIT="$release_commit"
printf '{"branch":"main","commit":"%s"}\n' "$release_commit" >"$test_tmp/share/release.json"

# Upstream's installer, reduced to what the real one leaves behind: a clone
# pinned at the requested commit, a venv whose hermes answers the probes, the
# bootstrap marker, and the commands it writes over ~/.local/bin. Its path
# stage writes only those commands.
cat >"$test_tmp/share/install.sh" <<'MOCK'
#!/bin/bash
set -e
commit=$OMARCHY_TEST_RELEASE_COMMIT
force=false
stage=""
args=("$@")
while (( $# )); do
  case "$1" in
    --dir) runtime=$2; shift ;;
    --commit) commit=$2; shift ;;
    --force-commit) force=true ;;
    --hermes-home) [[ $2 == "$HERMES_HOME" ]]; shift ;;
    --stage) stage=$2; shift ;;
  esac
  shift
done
write_commands() {
  mkdir -p "$HOME/.local/bin"
  for command in hermes hermes-agent hermes-acp; do
    rm -f "$HOME/.local/bin/$command"
    printf '#!/bin/bash\nexec "%s/venv/bin/hermes" "$@"\n' "$runtime" >"$HOME/.local/bin/$command"
    chmod +x "$HOME/.local/bin/$command"
  done
}
if [[ $stage == "path" ]]; then
  printf 'commands\n' >>"$OMARCHY_TEST_ROOT/events"
  [[ -d $runtime ]] || exit 1
  # Upstream warns and returns success without writing when the checked-in
  # entrypoint is missing; the flag stages that answer directly.
  [[ -f $runtime/hermes && ${OMARCHY_TEST_STAGE_WRITES_NOTHING:-0} != 1 ]] || exit 0
  write_commands
  exit 0
fi
printf 'bootstrap\n' >>"$OMARCHY_TEST_ROOT/events"
printf '%s\n' "${args[@]}" >"$OMARCHY_TEST_ROOT/install-args"
[[ ${OMARCHY_TEST_INSTALL_FAIL:-0} != 1 ]] || exit 7
mkdir -p -- "${runtime%/*}"
if [[ -d $runtime/.git ]] && ! git -C "$runtime" rev-parse --verify HEAD >/dev/null 2>&1; then
  mv "$runtime" "$runtime.broken"
fi
if [[ ! -d $runtime ]]; then
  git clone -q --depth 1 "file://$OMARCHY_TEST_ROOT/seed" "$runtime"
fi
git -C "$runtime" fetch -q origin "$commit"
if [[ $force == true ]] || ! git -C "$runtime" merge-base --is-ancestor "$commit" HEAD; then
  git -C "$runtime" checkout -q --detach "$commit"
fi
mkdir -p "$runtime/venv/bin"
cat >"$runtime/venv/bin/hermes" <<'SH'
#!/bin/bash
if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
  [[ ${OMARCHY_TEST_HERMES_CAPABLE:-1} == 1 ]] && echo "[-q QUERY, --query QUERY] [--tui]"
else
  echo "hermes-agent 0.0.0-test"
fi
SH
chmod +x "$runtime/venv/bin/hermes"
printf '#!/bin/bash\nexec /usr/bin/python3 "$@"\n' >"$runtime/venv/bin/python"
chmod +x "$runtime/venv/bin/python"
[[ ${OMARCHY_TEST_NO_MARKER:-0} == 1 ]] || touch "$runtime/.hermes-bootstrap-complete"
write_commands
printf 'installed\n' >>"$OMARCHY_TEST_ROOT/events"
MOCK
cat >"$test_tmp/bin/omarchy-pkg-add" <<'MOCK'
#!/bin/bash
printf 'package %s\n' "$*" >>"$OMARCHY_TEST_ROOT/events"
[[ ${OMARCHY_TEST_PACKAGE_FAIL:-0} != 1 ]]
MOCK

cat >"$test_tmp/bin/omarchy-pkg-present" <<'MOCK'
#!/bin/bash
[[ $1 == "hermes-desktop" && ${OMARCHY_TEST_DESKTOP_INSTALLED:-0} == 1 ]]
MOCK

# `where` answers while the built marker exists; `uninstall` clears it unless
# told to be stubborn, which is how a teardown that did not take is staged.
cat >"$test_tmp/bin/mise" <<'MOCK'
#!/bin/bash
printf 'mise %s\n' "$1" >>"$OMARCHY_TEST_ROOT/events"
case $1 in
  where) [[ -e $OMARCHY_TEST_ROOT/mise-built ]] ;;
  uninstall) [[ ${OMARCHY_TEST_MISE_STUBBORN:-0} == 1 ]] || rm -f "$OMARCHY_TEST_ROOT/mise-built" ;;
  *) exit 0 ;;
esac
MOCK

cat >"$test_tmp/bin/omarchy-default-agent" <<'MOCK'
#!/bin/bash
printf '%s\n' "${OMARCHY_TEST_DEFAULT_AGENT:-}"
MOCK

cat >"$test_tmp/bin/git" <<'MOCK'
#!/bin/bash
if [[ ${OMARCHY_TEST_FETCH_FAIL:-0} == 1 && " $* " == *" --unshallow "* ]]; then exit 8; fi
exec /usr/bin/git "$@"
MOCK
chmod +x "$test_tmp/bin/"*

# Substitute only the package paths in a scratch copy of the actual script.
mkdir -p "$test_tmp/opt/resources"
printf '{"branch":"main","commit":"%s","packaged":true}\n' "$release_commit" >"$test_tmp/opt/resources/install-stamp.json"
python3 - "$ROOT/bin/omarchy-install-hermes-cli" "$test_tmp" <<'PYEOF'
from pathlib import Path
import sys
source, scratch = Path(sys.argv[1]), Path(sys.argv[2])
script = source.read_text().replace('/usr/share/hermes-agent', str(scratch / 'share')).replace('/opt/hermes-desktop', str(scratch / 'opt'))
(scratch / 'installer').write_text(script)
PYEOF

legacy_marker="# Written by omarchy-install-hermes-cli."

new_home() {
  test_home="$test_tmp/$1"
  hermes_home="$test_home/.hermes"
  runtime="$hermes_home/hermes-agent"
  command_path="$test_home/.local/bin/hermes"
  ownership="$test_home/.local/state/omarchy/hermes-runtime"
  pending="$test_home/.local/state/omarchy/hermes-runtime-migration"
  mkdir -p "$test_home/.local/bin"
  : >"$test_tmp/events"
  rm -f "$test_tmp/mise-built" "$test_tmp/install-args" "$test_tmp/stub-ran"
}
run_installer() {
  HOME="$test_home" HERMES_HOME="${OMARCHY_TEST_HOME:-$hermes_home}" PATH="$test_tmp/bin:$PATH" \
    bash "$test_tmp/installer" "$@" >"$test_tmp/output" 2>&1
}
events() {
  tr '\n' ',' <"$test_tmp/events"
}
# The stub the mise-backed installer used to write, with a tell-tale for
# whether anything ran it.
write_legacy_stub() {
  printf '%s\n' '#!/bin/bash' "$legacy_marker" 'touch "$OMARCHY_TEST_ROOT/stub-ran"' 'echo hermes-agent 0.0.0-mise' >"$command_path"
  chmod +x "$command_path"
}
# Whether one event precedes another in the log.
before() {
  local first second
  first=$(grep -nx -- "$1" "$test_tmp/events" | head -1 | cut -d: -f1)
  second=$(grep -nx -- "$2" "$test_tmp/events" | head -1 | cut -d: -f1)
  [[ -n $first && -n $second ]] && (( first < second ))
}

new_home fresh
run_installer --check && fail "--check reports Hermes missing on a fresh machine"
[[ ! -s $test_tmp/events ]] || fail "--check changes nothing"
pass "--check reports Hermes missing without touching anything"

run_installer --now || fail "fresh setup succeeds" "$(cat "$test_tmp/output")"
expected=$(printf '%s\n' --skip-setup --branch main --commit "$release_commit" --force-commit --dir "$runtime" --hermes-home "$hermes_home")
[[ $(cat "$test_tmp/install-args") == "$expected" ]] || fail "upstream installer receives the pinned main arguments"
[[ $(events) == "package hermes-agent,bootstrap,installed,mise where," ]] || fail "the package lands before upstream's installer runs" "$(events)"
[[ $(git -C "$runtime" symbolic-ref --short HEAD) == main && $(git -C "$runtime" rev-parse main) == "$release_commit" ]] || fail "main starts at the release rather than the clone tip"
[[ $(git -C "$runtime" rev-parse --is-shallow-repository) == false ]] || fail "first update has connected history"
[[ $(cat "$runtime/runtime.txt") == after ]] || fail "the release runtime receives its patch"
[[ -f $runtime/.hermes-bootstrap-complete ]] || fail "the runtime is marked complete"
[[ $(cat "$ownership") == "$runtime" ]] || fail "the runtime Omarchy installed is recorded by path"
run_installer --check || fail "--check reports Hermes present once set up"
# Reproduce the updater's fetch/pull while origin stays put.
git clone -q "$runtime" "$test_tmp/first-update"
git -C "$test_tmp/first-update" remote set-url origin "file://$test_tmp/seed"
git -C "$test_tmp/first-update" fetch -q origin main
git -C "$test_tmp/first-update" checkout -q main
[[ $(git -C "$test_tmp/first-update" rev-list HEAD..origin/main --count) == 1 ]] || fail "first update detects work even when origin has not moved since install"
git -C "$test_tmp/first-update" pull -q --ff-only origin main
[[ $(git -C "$test_tmp/first-update" rev-parse HEAD) == "$origin_commit" ]] || fail "first update fast-forwards to origin"
pass "fresh setup pins main at the release, patches it and leaves hermes update a path forward"

: >"$test_tmp/events"
run_installer --now || fail "repeat setup succeeds" "$(cat "$test_tmp/output")"
[[ $(events) == "mise where," ]] || fail "--now on a usable Hermes only asks mise whether a copy remains" "$(events)"
[[ -z $(ls -A "$test_home/.local/bin" | grep '^\.hermes-before-install') ]] || fail "a usable Hermes is not backed up again"
: >"$test_tmp/events"
run_installer --now --replace || fail "--replace with the runtime in place succeeds"
[[ $(events) == "mise where," ]] || fail "--replace changes nothing when the runtime is already ours" "$(events)"
pass "a usable Hermes is left alone by --now, with or without --replace"

# Advancing the runtime must never reinstall the release or reapply its patch.
printf 'new main\n' >"$runtime/runtime.txt"
git -C "$runtime" add runtime.txt
git -C "$runtime" -c user.name=Test -c user.email=test@example.invalid commit -qm update
: >"$test_tmp/events"
run_installer --now || fail "an updated runtime is reused" "$(cat "$test_tmp/output")"
! grep -qx bootstrap "$test_tmp/events" || fail "an updated runtime is not reinstalled"
[[ $(cat "$runtime/runtime.txt") == 'new main' ]] || fail "an updated runtime is not release-patched"
pass "a runtime that updated itself is preserved"

for failure in package install marker; do
  new_home "$failure-failure"
  case "$failure" in
    package) OMARCHY_TEST_PACKAGE_FAIL=1 run_installer --now && fail "package failure stops setup" ;;
    install) OMARCHY_TEST_INSTALL_FAIL=1 run_installer --now && fail "installer failure stops setup" ;;
    marker) OMARCHY_TEST_NO_MARKER=1 run_installer --now && fail "missing marker stops setup" ;;
  esac
  run_installer --check && fail "a failed setup is not reported ready" "$failure"
  [[ ! -e $ownership ]] || fail "a failed setup records no runtime" "$failure"
done
new_home package-message
OMARCHY_TEST_PACKAGE_FAIL=1 run_installer --now && fail "an unavailable package stops setup"
grep -q 'omarchy update' "$test_tmp/output" || fail "an unavailable package has actionable guidance"
pass "package, upstream installer and readiness failures fail loudly"

# A package that cannot replace the mise Hermes leaves it exactly as it was.
new_home old-package
write_legacy_stub
touch "$test_tmp/mise-built"
mv "$test_tmp/share/release.json" "$test_tmp/saved-release.json"
run_installer --now && fail "an old package cannot set up the runtime"
grep -q 'omarchy update' "$test_tmp/output" || fail "old package has actionable upgrade guidance"
! grep -qx bootstrap "$test_tmp/events" || fail "old package never reaches upstream installer"
[[ -f $command_path ]] && grep -qxF "$legacy_marker" "$command_path" || fail "the mise Hermes survives a package that cannot replace it"
[[ -e $test_tmp/mise-built ]] || fail "the mise environment survives a package that cannot replace it"
! grep -q '^mise' "$test_tmp/events" || fail "mise is left alone when the package cannot replace its Hermes"
mv "$test_tmp/saved-release.json" "$test_tmp/share/release.json"
pass "an old package fails before touching the mise Hermes"

new_home legacy-check
write_legacy_stub
run_installer --check && fail "--check does not report the mise stub as Hermes"
[[ ! -e $test_tmp/stub-ran ]] || fail "--check never runs the mise stub"
mv "$command_path" "$test_home/stub-elsewhere"
ln -s "$test_home/stub-elsewhere" "$command_path"
run_installer --check && fail "--check does not report a link to the mise stub as Hermes"
[[ ! -e $test_tmp/stub-ran ]] || fail "--check never runs the mise stub through a link"
pass "--check never runs the mise stub, linked or not"

# A stub nobody ran built nothing, so nothing replaces it.
new_home cold-stub
write_legacy_stub
run_installer --migrate || fail "migrating a cold stub succeeds" "$(cat "$test_tmp/output")"
[[ ! -e $command_path ]] || fail "the cold stub is removed"
[[ $(events) == "mise where,mise where," ]] || fail "a cold stub has no mise tool to remove" "$(events)"
[[ ! -e $pending ]] || fail "a cold stub leaves no replacement pending"
[[ ! -e $test_tmp/stub-ran ]] || fail "--migrate never runs the mise stub"
pass "--migrate retires a cold stub without installing anything"

# One mise had built, or the default agent depends on, is a Hermes in use: it
# is replaced, and the copy mise built goes only once the runtime answers.
new_home built-stub
write_legacy_stub
touch "$test_tmp/mise-built"
run_installer --migrate || fail "migrating a built mise Hermes succeeds" "$(cat "$test_tmp/output")"
grep -qx bootstrap "$test_tmp/events" || fail "a Hermes mise had built is replaced with the runtime"
before installed 'mise rm' || fail "the mise tool goes after the runtime is in" "$(events)"
[[ ! -e $test_tmp/mise-built ]] || fail "the mise environment is uninstalled"
grep -qF "$runtime/" "$command_path" || fail "the command now points into the runtime"
[[ ! -e $test_tmp/stub-ran ]] || fail "--migrate never runs the mise stub"
[[ ! -e $pending ]] || fail "a finished replacement is no longer pending"
backups=("$test_home/.local/bin/".hermes-before-install.*)
[[ ${#backups[@]} == 1 ]] && grep -qxF "$legacy_marker" "${backups[0]}/hermes" || fail "the stub's bytes are saved like any other command"
run_installer --check || fail "the replacement is ready"
pass "--migrate replaces a Hermes mise had built, retiring the mise copy last"

new_home default-stub
write_legacy_stub
OMARCHY_TEST_DEFAULT_AGENT=hermes run_installer --migrate || fail "migrating the default agent's stub succeeds" "$(cat "$test_tmp/output")"
grep -qx bootstrap "$test_tmp/events" || fail "the default agent's cold stub is replaced with the runtime"
run_installer --check || fail "the default agent's replacement is ready"
pass "--migrate installs the runtime where Hermes is the default agent"

new_home no-stub
run_installer --migrate || fail "--migrate succeeds with nothing to migrate"
[[ ! -s $test_tmp/events ]] || fail "--migrate touches nothing without the stub" "$(events)"
pass "--migrate does nothing where the stub never existed"

# A replacement that fails before upstream wrote anything leaves the mise
# Hermes exactly as it was, and is picked up again on the next run.
new_home migrate-resume
write_legacy_stub
touch "$test_tmp/mise-built"
OMARCHY_TEST_INSTALL_FAIL=1 run_installer --migrate && fail "a failed replacement leaves the migration pending"
[[ -e $pending ]] || fail "a failed replacement is marked pending"
[[ -f $command_path ]] && grep -qxF "$legacy_marker" "$command_path" || fail "a replacement that failed before the runtime keeps the stub"
[[ -e $test_tmp/mise-built ]] || fail "a replacement that failed before the runtime keeps the mise Hermes"
[[ ! -e $ownership ]] || fail "a replacement that failed before the runtime records nothing"
: >"$test_tmp/events"
run_installer --migrate || fail "the replacement resumes on the next run" "$(cat "$test_tmp/output")"
grep -qx bootstrap "$test_tmp/events" || fail "the resumed replacement installs the runtime"
[[ ! -e $pending && ! -e $test_tmp/mise-built ]] || fail "the resumed replacement finishes and retires the mise Hermes"
pass "a replacement that fails before the runtime is in resumes rather than reading as done"

# One that fails after upstream wrote the commands has taken the stub's name,
# but the mise Hermes and the pending mark are still there, and the next run
# finishes the job.
new_home migrate-resume-late
write_legacy_stub
touch "$test_tmp/mise-built"
OMARCHY_TEST_NO_MARKER=1 run_installer --migrate && fail "a replacement that failed after the commands leaves the migration pending"
[[ -e $pending && -e $test_tmp/mise-built ]] || fail "a late failure keeps the mise Hermes and the pending mark"
[[ ! -e $test_tmp/stub-ran ]] || fail "a late failure never runs the stub"
: >"$test_tmp/events"
run_installer --migrate || fail "the late-failed replacement resumes" "$(cat "$test_tmp/output")"
[[ ! -e $pending && ! -e $test_tmp/mise-built ]] || fail "the resumed late replacement finishes and retires the mise Hermes"
run_installer --check || fail "the resumed late replacement is ready"
pass "a replacement that fails after the commands are written resumes and finishes"

new_home migrate-resume-without-stub
write_legacy_stub
touch "$test_tmp/mise-built"
OMARCHY_TEST_INSTALL_FAIL=1 run_installer --migrate && fail "fixture: a failed replacement leaves the migration pending"
rm -f "$command_path"
: >"$test_tmp/events"
run_installer --migrate || fail "the replacement resumes without the stub" "$(cat "$test_tmp/output")"
grep -qx bootstrap "$test_tmp/events" || fail "the resumed replacement installs the runtime without the stub"
[[ ! -e $pending ]] || fail "the resumed replacement without the stub finishes"
pass "a pending replacement resumes even after the stub is gone"

# Mentioning the marker, or quoting it inside a longer line, is not carrying it.
new_home mentions
printf '%s\n' '#!/bin/bash' "# Replaced '$legacy_marker' with my own." "exec $test_tmp/elsewhere/hermes \"\$@\"" >"$command_path"
chmod +x "$command_path"
run_installer --migrate || fail "--migrate succeeds over a wrapper that mentions the marker"
[[ -f $command_path && ! -s $test_tmp/events ]] || fail "a wrapper that only mentions the marker is left alone"
pass "ownership needs the exact marker line, not a mention"

# Judged by what is left: a mise that still resolves the tool afterwards is a
# Hermes still installed, so the run fails and stays pending until it goes.
new_home stubborn
write_legacy_stub
touch "$test_tmp/mise-built"
OMARCHY_TEST_MISE_STUBBORN=1 run_installer --migrate && fail "--migrate claims success while mise still resolves the tool"
grep -q 'Finish by hand' "$test_tmp/output" || fail "a stubborn mise environment gets by-hand instructions"
[[ -e $pending ]] || fail "a stubborn mise environment keeps the replacement pending"
: >"$test_tmp/events"
run_installer --migrate || fail "the replacement finishes once the mise environment can go" "$(cat "$test_tmp/output")"
! grep -qx bootstrap "$test_tmp/events" || fail "the finished runtime is not installed twice"
[[ ! -e $pending && ! -e $test_tmp/mise-built ]] || fail "the retry retires the mise environment"
pass "--migrate fails while the mise environment survives, and finishes once it goes"

# A migration is not done until the mise copy is gone: a teardown that keeps
# failing on the fast path keeps it pending rather than marking it complete.
new_home migrate-stubborn-fast-path
write_legacy_stub
touch "$test_tmp/mise-built"
OMARCHY_TEST_MISE_STUBBORN=1 run_installer --migrate && fail "fixture: the first attempt fails on teardown"
[[ -e $pending ]] || fail "fixture: the first attempt leaves the migration pending"
: >"$test_tmp/events"
OMARCHY_TEST_MISE_STUBBORN=1 run_installer --migrate && fail "a retry whose teardown still fails does not read as done"
[[ -e $pending ]] || fail "a retry whose teardown still fails stays pending"
! grep -qx bootstrap "$test_tmp/events" || fail "the retry does not reinstall the ready runtime"
OMARCHY_TEST_MISE_STUBBORN=1 run_installer --now || fail "the default agent can still use the Hermes that runs"
[[ -e $pending ]] || fail "plain --now does not clear a pending migration it did not finish"
run_installer --migrate || fail "the migration finishes once the teardown takes"
[[ ! -e $pending ]] || fail "the finished migration is no longer pending"
pass "a pending migration stays pending while its teardown keeps failing"

# Nor is it done while the runtime cannot be prepared: a fetch that keeps
# failing on the fast path is a failure for the migration and for the app,
# and a warning for the default agent.
new_home migrate-shallow-fast-path
OMARCHY_TEST_FETCH_FAIL=1 run_installer --now && fail "fixture: the history fetch fails on first setup"
mkdir -p "$(dirname "$pending")"
touch "$pending"
OMARCHY_TEST_FETCH_FAIL=1 run_installer --migrate && fail "a migration whose runtime cannot be prepared does not read as done"
[[ -e $pending ]] || fail "a migration whose runtime cannot be prepared stays pending"
OMARCHY_TEST_FETCH_FAIL=1 run_installer --now --replace && fail "the app is not handed a runtime that could not be prepared"
OMARCHY_TEST_FETCH_FAIL=1 run_installer --now || fail "the default agent still gets the Hermes that runs"
[[ -e $pending ]] || fail "plain --now leaves the unprepared runtime's migration pending"
run_installer --migrate || fail "the migration finishes once the fetch works"
[[ ! -e $pending && $(git -C "$runtime" rev-parse --is-shallow-repository) == false ]] || fail "the finished migration has connected history"
touch "$test_tmp/mise-built"
OMARCHY_TEST_MISE_STUBBORN=1 run_installer --now --replace && fail "the app is not handed a runtime with a mise copy that will not go"
pass "a runtime that cannot be prepared or cleared fails the migration and the app, and only warns the default agent"

new_home now-stub
write_legacy_stub
touch "$test_tmp/mise-built"
run_installer --now || fail "--now replaces the mise Hermes" "$(cat "$test_tmp/output")"
before 'package hermes-agent' bootstrap && before installed 'mise rm' || fail "--now installs the package, then the runtime, then retires the mise Hermes" "$(events)"
[[ ! -e $test_tmp/mise-built ]] || fail "--now uninstalls the mise environment"
[[ ! -e $test_tmp/stub-ran ]] || fail "--now never runs the mise stub"
run_installer --check || fail "--now leaves Hermes ready"
pass "--now retires the mise Hermes only after the runtime is in"

# Everything that can refuse does so before the mise Hermes is touched.
new_home legacy-dirty
write_legacy_stub
touch "$test_tmp/mise-built"
git clone -q "$test_tmp/seed" "$runtime"
git -C "$runtime" checkout -q --detach "$release_commit"
printf 'local edit\n' >"$runtime/runtime.txt"
run_installer --now && fail "a dirty incomplete runtime stops setup"
! grep -qx bootstrap "$test_tmp/events" || fail "a dirty runtime never reaches the upstream installer"
[[ -f $command_path ]] && grep -qxF "$legacy_marker" "$command_path" || fail "a refused setup keeps the mise stub"
[[ -e $test_tmp/mise-built ]] || fail "a refused setup keeps the mise environment"
[[ -z $(ls -A "$test_home/.local/bin" | grep '^\.hermes-before-install') ]] || fail "a refused setup takes no backup"
pass "a refused setup leaves the mise Hermes working"

# The marker lives in exactly one place now the stub is history.
marker_copies=$(grep -rl "Written by omarchy-install-hermes-cli" \
  "$ROOT/bin" "$ROOT/install" "$ROOT/migrations" 2>/dev/null | wc -l)
(( marker_copies == 1 )) || fail "only omarchy-install-hermes-cli spells out the legacy marker"
pass "the legacy marker is written down once"

# Existing desktop installs predate the record. The desktop installer copied
# the packaged app in byte for byte, so its stamp is what tells them apart; a
# marker alone is upstream's, and an app the user built has its own stamp.
new_home backfill
mkdir -p "$runtime/apps/desktop/release/linux-unpacked/resources"
touch "$runtime/.hermes-bootstrap-complete"
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --migrate || fail "--migrate succeeds on a marked runtime"
[[ ! -e $ownership ]] || fail "a marker alone does not make the runtime Omarchy's"
printf '{"branch":"main","commit":"%s"}\n' "$release_commit" >"$runtime/apps/desktop/release/linux-unpacked/resources/install-stamp.json"
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --migrate || fail "--migrate succeeds on a user-built app"
[[ ! -e $ownership ]] || fail "an app the user built does not make the runtime Omarchy's"
cp "$test_tmp/opt/resources/install-stamp.json" "$runtime/apps/desktop/release/linux-unpacked/resources/install-stamp.json"
run_installer --migrate || fail "--migrate succeeds on a runtime seeded with the packaged app"
[[ $(cat "$ownership") == "$runtime" ]] || fail "the runtime seeded with the packaged app is recorded"
pass "--migrate records the runtime the desktop installer seeded, by the app it copied in"

# Only a recorded runtime is maintained on the fast path: an official install
# at the same path is left exactly as it is, mise copy and all.
new_home unrecorded
HOME="$test_home" HERMES_HOME="$hermes_home" bash "$test_tmp/share/install.sh" --dir "$runtime" --hermes-home "$hermes_home" >/dev/null
[[ $(git -C "$runtime" rev-parse --is-shallow-repository) == true ]] || fail "unrecorded fixture is a shallow official install"
touch "$test_tmp/mise-built"
: >"$test_tmp/events"
run_installer --now || fail "--now accepts an official install" "$(cat "$test_tmp/output")"
[[ ! -s $test_tmp/events ]] || fail "an unrecorded runtime is neither prepared nor has its mise copy touched" "$(events)"
[[ $(git -C "$runtime" rev-parse --is-shallow-repository) == true && -e $test_tmp/mise-built ]] || fail "an unrecorded runtime is left as it was"
mkdir -p "$(dirname "$ownership")"
printf '%s\n' "$runtime" >"$ownership"
run_installer --now || fail "--now maintains a recorded runtime" "$(cat "$test_tmp/output")"
[[ $(git -C "$runtime" rev-parse --is-shallow-repository) == false && $(git -C "$runtime" symbolic-ref --short HEAD) == main ]] || fail "a recorded runtime is prepared on the fast path"
[[ ! -e $test_tmp/mise-built ]] || fail "a recorded runtime's mise copy is retired on the fast path"
pass "the fast path maintains only the runtime Omarchy recorded"

# A hermes the user installed somewhere else. --check follows whether it runs;
# --now leaves a working one be, and --replace takes the name over for the
# runtime, keeping the bytes it found.
official_target="$test_tmp/elsewhere/hermes"
mkdir -p "$(dirname "$official_target")"
cat >"$official_target" <<'SH'
#!/bin/bash
if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
  [[ ${OMARCHY_TEST_HERMES_CAPABLE:-1} == 1 ]] && echo "[-q QUERY, --query QUERY] [--tui]"
else
  echo "hermes-agent 0.0.0-foreign"
fi
SH
chmod +x "$official_target"
foreign_body="#!/bin/bash
exec $official_target \"\$@\""
broken_body="#!/bin/bash
exec $test_tmp/nowhere/hermes \"\$@\""

new_home foreign
printf '%s\n' "$foreign_body" >"$command_path"
chmod +x "$command_path"
run_installer --check || fail "--check accepts a working foreign hermes"
run_installer --now || fail "--now steps aside for a working foreign hermes"
[[ ! -s $test_tmp/events && $(cat "$command_path") == "$foreign_body" ]] || fail "a working foreign hermes is left untouched by --now"
OMARCHY_TEST_HERMES_CAPABLE=0 run_installer --check && fail "--check rejects a foreign Hermes without native prompted sessions"
chmod -x "$command_path"
run_installer --check && fail "--check rejects a non-executable foreign hermes"
printf '%s\n' "$broken_body" >"$command_path"
chmod +x "$command_path"
run_installer --check && fail "--check rejects a foreign hermes whose target is missing"
rm -f "$command_path"
ln -s "$official_target" "$command_path"
run_installer --check || fail "--check accepts a foreign link to a working hermes"
rm -f "$command_path"
ln -s "$test_tmp/nowhere/hermes" "$command_path"
run_installer --check && fail "--check rejects a dangling hermes link"
rm -f "$command_path"
mkdir "$command_path"
run_installer --check && fail "--check rejects a directory at the hermes path"
rmdir "$command_path"
pass "--check follows whether a hermes the user installed actually runs, and --now leaves a working one be"

printf '%s\n' "$foreign_body" >"$command_path"
chmod +x "$command_path"
run_installer --now --replace || fail "--replace takes over a foreign hermes" "$(cat "$test_tmp/output")"
backups=("$test_home/.local/bin/".hermes-before-install.*)
[[ ${#backups[@]} == 1 && $(cat "${backups[0]}/hermes") == "$foreign_body" ]] || fail "the foreign hermes is saved before replacement"
grep -qF "$runtime/" "$command_path" || fail "the command now points into the runtime"
grep -qF "${backups[0]}" "$test_tmp/output" || fail "backup location is reported"
pass "--replace replaces a foreign hermes after saving it"

# A foreign command that does not run is replaced by --now as well: the user
# asked for Hermes, and what they had is kept in the backup.
new_home broken-foreign
printf '%s\n' "$broken_body" >"$command_path"
chmod +x "$command_path"
run_installer --now || fail "--now replaces a foreign hermes that does not run" "$(cat "$test_tmp/output")"
backups=("$test_home/.local/bin/".hermes-before-install.*)
[[ ${#backups[@]} == 1 && $(cat "${backups[0]}/hermes") == "$broken_body" ]] || fail "the broken foreign hermes is saved before replacement"
run_installer --check || fail "the replacement of a broken foreign hermes is ready"
pass "--now replaces a foreign hermes that does not run, after saving it"

new_home existing-commands
printf 'symlink target\n' >"$test_home/target"
ln -s "$test_home/target" "$test_home/.local/bin/hermes-agent"
ln -s "$test_home/missing" "$test_home/.local/bin/hermes-acp"
run_installer --now || fail "existing commands are preserved before upstream replaces them" "$(cat "$test_tmp/output")"
backups=("$test_home/.local/bin/".hermes-before-install.*)
[[ ${#backups[@]} == 1 && -d ${backups[0]} ]] || fail "one backup directory preserves existing command names"
[[ $(readlink "${backups[0]}/hermes-agent") == "$test_home/target" && $(readlink "${backups[0]}/hermes-acp") == "$test_home/missing" ]] || fail "working and broken symlinks are saved as links"
[[ $(cat "$test_home/target") == 'symlink target' ]] || fail "upstream does not overwrite the original symlink target"
pass "pre-existing command files and symlinks are backed up before replacement"

new_home directory
mkdir "$command_path"
run_installer --now && fail "--now refuses a directory at the hermes path"
! grep -qx bootstrap "$test_tmp/events" || fail "a directory at the hermes path never reaches the installer"
[[ -d $command_path ]] || fail "a directory at the hermes path is left untouched"
[[ -z $(ls -A "$test_home/.local/bin" | grep '^\.hermes-before-install') ]] || fail "a refused name takes no backup"
pass "a directory at the hermes path stops setup before anything is taken"

# A healthy runtime whose commands went missing or broke is repaired through
# upstream's own launcher stage, without touching the checkout.
new_home lost-commands
run_installer --now || fail "lost-commands fixture sets up" "$(cat "$test_tmp/output")"
rm -f "$command_path"
run_installer --check && fail "--check reports a runtime without its command"
: >"$test_tmp/events"
run_installer --now || fail "--now restores a missing command" "$(cat "$test_tmp/output")"
[[ $(events) == "package hermes-agent,commands,mise where," ]] || fail "a missing command is rewritten without reinstalling" "$(events)"
run_installer --check || fail "the restored command is ready"
rm -f "$test_home/.local/bin/hermes-acp"
run_installer --check && fail "--check reports a runtime without one of its other commands"
run_installer --now || fail "--now restores a missing hermes-acp" "$(cat "$test_tmp/output")"
[[ -f $test_home/.local/bin/hermes-acp ]] || fail "hermes-acp is written back"
printf 'not a launcher\n' >"$test_home/.local/bin/hermes-agent"
run_installer --check && fail "--check reports a runtime whose hermes-agent is something else"
run_installer --now || fail "--now restores a broken hermes-agent" "$(cat "$test_tmp/output")"
grep -qF "$runtime/" "$test_home/.local/bin/hermes-agent" || fail "hermes-agent is written back over what held its name"
pass "a runtime that lost a command, or has something else at its name, gets it back without reinstalling"

# Upstream's launcher stage reports success even when it wrote nothing, and
# what is left at the name must never be trusted, least of all the stub.
new_home stage-writes-nothing
run_installer --now || fail "stage fixture sets up" "$(cat "$test_tmp/output")"
write_legacy_stub
touch "$test_tmp/mise-built"
OMARCHY_TEST_STAGE_WRITES_NOTHING=1 run_installer --now && fail "a launcher stage that wrote nothing is not success"
grep -q 'did not write' "$test_tmp/output" || fail "a launcher stage that wrote nothing is named"
[[ ! -e $test_tmp/stub-ran ]] || fail "the stub is never probed in place of upstream's command"
[[ -f $command_path ]] && grep -qxF "$legacy_marker" "$command_path" || fail "the stub is still there to be replaced on the next run"
[[ -e $test_tmp/mise-built ]] || fail "the mise Hermes survives a launcher stage that wrote nothing"
pass "a launcher stage that writes nothing fails without running or retiring the mise Hermes"

new_home dirty-runtime
git clone -q "$test_tmp/seed" "$runtime"
git -C "$runtime" checkout -q --detach "$release_commit"
printf 'local edit\n' >"$runtime/runtime.txt"
run_installer --now && fail "an incomplete modified runtime is not reset by the upstream installer"
! grep -qx bootstrap "$test_tmp/events" || fail "a modified runtime never reaches the upstream installer"
[[ $(cat "$runtime/runtime.txt") == 'local edit' ]] || fail "local runtime changes are preserved"
pass "an incomplete modified runtime is kept and setup stops"

# An interrupted clone has no commits to judge; upstream moves it aside.
new_home interrupted-clone
mkdir -p "$runtime"
git -C "$runtime" init -q -b main
run_installer --now || fail "an interrupted clone is handed to the upstream installer" "$(cat "$test_tmp/output")"
[[ -d $runtime.broken ]] || fail "the interrupted clone is moved aside rather than deleted"
run_installer --check || fail "the reinstalled runtime is ready"
pass "an interrupted clone is repaired by upstream rather than refused"

# A recorded runtime that lost its marker is still ours after a repair fails.
new_home failed-repair
run_installer --now || fail "failed-repair fixture sets up" "$(cat "$test_tmp/output")"
rm -f "$runtime/.hermes-bootstrap-complete"
# The fixture's patch applies, so the release tree has to be clean again for
# the guard to hand the checkout back to upstream at all.
git -C "$runtime" checkout -q -- runtime.txt
: >"$test_tmp/events"
OMARCHY_TEST_INSTALL_FAIL=1 run_installer --now && fail "a failed repair reports failure"
grep -qx bootstrap "$test_tmp/events" || fail "fixture: the repair reaches upstream's installer"
[[ $(cat "$ownership") == "$runtime" ]] || fail "a failed repair keeps the runtime recorded"
pass "a failed repair does not make a recorded runtime someone else's"

new_home full-history-retry
git clone -q "$test_tmp/seed" "$runtime"
git -C "$runtime" checkout -q --detach "$release_commit"
run_installer --now || fail "a clean incomplete release checkout is repaired" "$(cat "$test_tmp/output")"
[[ $(git -C "$runtime" symbolic-ref --short HEAD) == main && $(git -C "$runtime" rev-parse HEAD) == "$release_commit" ]] || fail "the repaired checkout starts main at the release"
pass "a clean incomplete release checkout is repaired in place"

new_home local-main
git clone -q "$test_tmp/seed" "$runtime"
printf 'local branch work\n' >"$runtime/keep"
git -C "$runtime" add keep
git -C "$runtime" -c user.name=Test -c user.email=test@example.invalid commit -qm local-work
local_main=$(git -C "$runtime" rev-parse main)
git -C "$runtime" checkout -q --detach "$release_commit"
run_installer --now && fail "local main commits are not reset by upstream installation"
! grep -qx bootstrap "$test_tmp/events" || fail "local main is checked before the upstream installer"
[[ $(git -C "$runtime" rev-parse main) == "$local_main" ]] || fail "local main commit stays referenced"
pass "local work on main is never discarded"

# A runtime that runs but cannot be prepared is still a Hermes the default
# agent can use, so plain --now says so and succeeds; the app, which asked for
# the runtime itself, is told no.
new_home patch-conflict
run_installer --now || fail "patch conflict fixture sets up" "$(cat "$test_tmp/output")"
printf 'local edit\n' >"$runtime/runtime.txt"
run_installer --now || fail "a patch conflict on a usable Hermes does not fail the default agent"
grep -q 'could not be prepared' "$test_tmp/output" || fail "a patch conflict on a usable Hermes is reported"
run_installer --now --replace && fail "an unexpected patch conflict stops the app's setup"
[[ $(cat "$runtime/runtime.txt") == 'local edit' ]] || fail "conflicting runtime changes are preserved"
pass "a runtime patch conflict keeps local changes, warns the default agent and stops the app"

new_home deepen-retry
OMARCHY_TEST_FETCH_FAIL=1 run_installer --now && fail "a history fetch failure stops setup"
: >"$test_tmp/events"
run_installer --now || fail "history fetch can be retried after runtime setup" "$(cat "$test_tmp/output")"
! grep -qx bootstrap "$test_tmp/events" || fail "history retry does not repeat upstream installation"
[[ $(git -C "$runtime" rev-parse --is-shallow-repository) == false ]] || fail "the retry connects history"
[[ $(git -C "$runtime" symbolic-ref --short HEAD) == main ]] || fail "the retry starts main"
pass "a history fetch failure can be retried without reinstalling the ready runtime"

new_home custom-profile
hermes_home="$test_home/custom home"
runtime="$hermes_home/hermes-agent"
OMARCHY_TEST_HOME="$hermes_home/PrOfIlEs/coder/../coder/" run_installer --now || fail "profile setup succeeds" "$(cat "$test_tmp/output")"
[[ -f $runtime/.hermes-bootstrap-complete ]] || fail "profile uses the canonical root runtime"
grep -qxF "$hermes_home" "$test_tmp/install-args" || fail "canonical custom home reaches upstream installer"
[[ $(cat "$ownership") == "$runtime" ]] || fail "the custom home's runtime is recorded by its own path"
pass "custom profile paths normalize to the shared Hermes home"

# Readiness turns on the flags omarchy-agent passes, defined rather than
# mentioned, and it is the command that has to answer.
new_home probe
run_installer --now || fail "probe fixture sets up" "$(cat "$test_tmp/output")"
probe_help() {
  cat >"$runtime/venv/bin/hermes" <<SH
#!/bin/bash
if [[ \${1:-} == "chat" && \${2:-} == "--help" ]]; then
  printf '%s\n' "$1"
else
  echo "hermes-agent 0.0.0-test"
fi
SH
  chmod +x "$runtime/venv/bin/hermes"
}
probe_help "--oneshot"
run_installer --check && fail "--check accepts a release without the flags omarchy-agent passes"
run_installer --now && fail "--now does not claim success over a Hermes without seeded sessions"
grep -q 'hermes update' "$test_tmp/output" || fail "an installed Hermes without seeded sessions points at hermes update"
probe_help "[--tui-theme THEME] [--query-log FILE]"
run_installer --check && fail "--check accepts flags that only contain --tui/--query as a substring"
probe_help "[--tui]"
run_installer --check && fail "--check accepts --tui alone"
probe_help "[-q QUERY, --query QUERY]"
run_installer --check && fail "--check accepts --query alone"
probe_help "[--tui_mode MODE] [--query_log FILE]"
run_installer --check && fail "--check accepts an underscore continuation as the bare flag"
probe_help $'  --dev                 With --tui: run sources via tsx\n  --log FILE            Where --query output lands'
run_installer --check && fail "--check accepts flags that appear only in option descriptions"
probe_help "[-q QUERY, --query QUERY] [--tui]"
run_installer --check || fail "--check accepts the flags omarchy-agent passes"
rm -f "$runtime/venv/bin/hermes"
run_installer --check && fail "--check trusts the marker after the runtime is gone"
pass "readiness follows the flags omarchy-agent passes and runs the command to find out"

new_home usage
run_installer --owns && fail "an unknown mode is rejected"
grep -q 'Usage' "$test_tmp/output" || fail "an unknown mode prints usage"
pass "unknown modes are rejected"
