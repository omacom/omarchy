#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

for command in git jq python3; do require_command "$command"; done

test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT
export OMARCHY_TEST_ROOT="$test_tmp"
mkdir -p "$test_tmp/bin" "$test_tmp/package/resources" "$test_tmp/share" "$test_tmp/seed"

# Real Git exercises patch checks and preservation; all package, desktop and
# service commands are mocks. No command reaches the live user installation.
git -C "$test_tmp/seed" init -q -b main
printf 'venv/\n.hermes-bootstrap-complete\napps/desktop/release/\n__pycache__/\n' >"$test_tmp/seed/.gitignore"
printf 'before\n' >"$test_tmp/seed/runtime.txt"
mkdir -p "$test_tmp/seed/apps/desktop/src"
printf 'desktop source\n' >"$test_tmp/seed/apps/desktop/src/main.js"
mkdir -p "$test_tmp/seed/hermes_cli"
cat >"$test_tmp/seed/hermes_cli/main.py" <<'PY'
import os
from pathlib import Path

def _write_desktop_build_stamp(project_root, *, source_mode):
    home = Path(os.environ['HERMES_HOME'])
    assert project_root == home / 'hermes-agent'
    assert source_mode is False
    assert (project_root / 'apps/desktop/release/linux-unpacked/resources/app.asar').is_file()
    (home / 'desktop-build-stamp.json').write_text('upstream build stamp')
    with (Path(os.environ['OMARCHY_TEST_ROOT']) / 'events').open('a') as log:
        log.write('build-stamp\n')
PY
git -C "$test_tmp/seed" add .
git -C "$test_tmp/seed" -c user.name=Test -c user.email=test@example.invalid commit -qm fixture
release_commit=$(git -C "$test_tmp/seed" rev-parse HEAD)
printf 'after\n' >"$test_tmp/seed/runtime.txt"
git -C "$test_tmp/seed" diff >"$test_tmp/share/runtime.patch"
printf 'before\n' >"$test_tmp/seed/runtime.txt"
printf 'newer desktop source\n' >"$test_tmp/seed/apps/desktop/src/main.js"
git -C "$test_tmp/seed" add apps/desktop/src/main.js
git -C "$test_tmp/seed" -c user.name=Test -c user.email=test@example.invalid commit -qm newer-main
origin_commit=$(git -C "$test_tmp/seed" rev-parse HEAD)
export OMARCHY_TEST_RELEASE_COMMIT="$release_commit"
printf '{"branch":"main","commit":"%s"}\n' "$release_commit" >"$test_tmp/package/resources/install-stamp.json"
printf 'packaged app\n' >"$test_tmp/package/resources/app.asar"
printf '#!/bin/bash\nexit 0\n' >"$test_tmp/package/Hermes"
touch "$test_tmp/package/chrome-sandbox"
chmod 755 "$test_tmp/package/Hermes"
chmod 4755 "$test_tmp/package/chrome-sandbox"

cat >"$test_tmp/share/install.sh" <<'MOCK'
#!/bin/bash
set -e
printf '%s\n' "$@" >"$OMARCHY_TEST_ROOT/install-args"
printf '%s\n' "${npm_config_yes:-unset}" >"$OMARCHY_TEST_ROOT/install-npx-answer"
[[ ${OMARCHY_TEST_INSTALL_FAIL:-0} != 1 ]] || exit 7
commit=$OMARCHY_TEST_RELEASE_COMMIT
force=false
stage=""
while (( $# )); do
  case "$1" in
    --dir) runtime=$2; shift ;;
    --commit) commit=$2; shift ;;
    --force-commit) force=true ;;
    --stage) stage=$2; shift ;;
    --hermes-home) [[ $2 == "$HERMES_HOME" ]] ;;
  esac
  shift
done
# The commands upstream writes last: shims for the two side commands and, for
# hermes, a launcher into the runtime's venv the way the real one is written.
write_commands() {
  mkdir -p "$HOME/.local/bin"
  for command in hermes hermes-agent hermes-acp; do
    rm -f "$HOME/.local/bin/$command"
    printf 'native runtime shim\n' >"$HOME/.local/bin/$command"
  done
  printf '#!/bin/bash\nexec "%s/venv/bin/hermes" "$@"\n' "$runtime" >"$HOME/.local/bin/hermes"
  chmod +x "$HOME/.local/bin/hermes"
}
# The path stage writes the commands alone, without touching the checkout.
if [[ $stage == "path" ]]; then
  printf 'path\n' >>"$OMARCHY_TEST_ROOT/events"
  write_commands
  exit 0
fi
printf 'bootstrap\n' >>"$OMARCHY_TEST_ROOT/events"
mkdir -p -- "${runtime%/*}"
if [[ ! -d $runtime ]]; then
  git clone -q --depth 1 "file://$OMARCHY_TEST_ROOT/seed" "$runtime"
else
  git -C "$runtime" checkout -q main
  git -C "$runtime" pull -q --ff-only origin main
fi
git -C "$runtime" fetch -q origin "$commit"
if [[ $force == true ]] || ! git -C "$runtime" merge-base --is-ancestor "$commit" HEAD; then
  git -C "$runtime" checkout -q --detach "$commit"
fi
mkdir -p "$runtime/venv/bin"
git -C "$runtime" rev-parse HEAD >"$runtime/venv/dependency-commit"
# The venv command answers the readiness probes the way the real one does: the
# installer runs the command it leaves on PATH before calling Hermes ready.
cat >"$runtime/venv/bin/hermes" <<'SH'
#!/bin/bash
if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
  echo "[-q QUERY, --query QUERY] [--tui]"
else
  echo "hermes-agent 0.0.0-test"
fi
SH
chmod +x "$runtime/venv/bin/hermes"
printf '#!/bin/bash\nexec /usr/bin/python3 "$@"\n' >"$runtime/venv/bin/python"
chmod +x "$runtime/venv/bin/python"
[[ ${OMARCHY_TEST_NO_MARKER:-0} == 1 ]] || touch "$runtime/.hermes-bootstrap-complete"
write_commands
MOCK

cat >"$test_tmp/bin/omarchy-pkg-add" <<'MOCK'
#!/bin/bash
printf 'package %s\n' "$*" >>"$OMARCHY_TEST_ROOT/events"
[[ ${OMARCHY_TEST_PACKAGE_FAIL:-0} != 1 ]] || exit 1
touch "$OMARCHY_TEST_ROOT/package-installed"
MOCK
cat >"$test_tmp/bin/omarchy-pkg-present" <<'MOCK'
#!/bin/bash
[[ -e $OMARCHY_TEST_ROOT/package-installed ]]
MOCK
cat >"$test_tmp/bin/git" <<'MOCK'
#!/bin/bash
if [[ ${OMARCHY_TEST_FETCH_FAIL:-0} == 1 && " $* " == *" --unshallow "* ]]; then exit 8; fi
exec /usr/bin/git "$@"
MOCK
cat >"$test_tmp/bin/setsid" <<'MOCK'
#!/bin/bash
exec "$@"
MOCK
cat >"$test_tmp/bin/cp" <<'MOCK'
#!/bin/bash
if [[ ${OMARCHY_TEST_COPY_FAIL:-0} == 1 ]]; then
  touch "${@: -1}/partial-copy"
  exit 9
fi
exec /usr/bin/cp "$@"
MOCK
cat >"$test_tmp/bin/mv" <<'MOCK'
#!/bin/bash
if [[ ${OMARCHY_TEST_COPY_RACE:-0} == 1 && $1 == -T ]]; then
  mkdir -p "${@: -1}"
fi
exec /usr/bin/mv "$@"
MOCK
cat >"$test_tmp/bin/uwsm-app" <<'MOCK'
#!/bin/bash
[[ $1 == -- ]] || exit 1
shift
exec "$@"
MOCK
cat >"$test_tmp/bin/hermes-desktop" <<'MOCK'
#!/bin/bash
sleep 0.05
native="$HERMES_HOME/hermes-agent/apps/desktop/release/linux-unpacked"
if [[ -x $native/Hermes && -f $native/resources/app.asar ]]; then
  printf 'launch\n' >>"$OMARCHY_TEST_ROOT/events"
else
  printf 'launch-before-copy\n' >>"$OMARCHY_TEST_ROOT/events"
fi
MOCK
cat >"$test_tmp/bin/systemctl" <<'MOCK'
#!/bin/bash
printf 'theme-stop\n' >>"$OMARCHY_TEST_ROOT/events"
MOCK
cat >"$test_tmp/bin/systemd-run" <<'MOCK'
#!/bin/bash
printf 'theme-start\n' >>"$OMARCHY_TEST_ROOT/events"
MOCK
# The only thing the installer asks mise is to remove what the retired wrapper
# built. `where` finds that environment and `ls -g` lists it while a test says
# it was built and it has not been uninstalled and unrequested; uninstalling
# also takes the shim stand-in named in OMARCHY_TEST_SHIM, as mise's does.
cat >"$test_tmp/bin/mise" <<'MOCK'
#!/bin/bash
printf 'mise %s\n' "$*" >>"$OMARCHY_TEST_ROOT/mise-log"
case "$1" in
  where) [[ ${OMARCHY_TEST_MISE_BUILT:-0} == 1 && ! -e $OMARCHY_TEST_ROOT/mise-removed ]] ;;
  ls)
    if [[ ${OMARCHY_TEST_MISE_BUILT:-0} == 1 && ! -e $OMARCHY_TEST_ROOT/mise-unrequested ]]; then
      echo '{"pipx:hermes-agent[extras=all]": [{"version": "latest"}]}'
    else
      echo '{}'
    fi
    ;;
  rm) touch "$OMARCHY_TEST_ROOT/mise-unrequested" ;;
  uninstall) touch "$OMARCHY_TEST_ROOT/mise-removed"; rm -f "${OMARCHY_TEST_SHIM:-}" ;;
esac
MOCK
chmod +x "$test_tmp/bin/"*

# Substitute only system package paths in scratch copies of the actual scripts.
# The runtime setup lives in omarchy-install-hermes-cli, which the desktop
# installer finds on PATH under its own name.
python3 - "$ROOT/bin" "$test_tmp" <<'PY'
from pathlib import Path
import sys
source, scratch = Path(sys.argv[1]), Path(sys.argv[2])
substitutions = {
    '/opt/hermes-desktop': str(scratch / 'package'),
    '/usr/share/hermes-desktop': str(scratch / 'share'),
    '/usr/bin/hermes-desktop': str(scratch / 'bin/hermes-desktop'),
}
for name, target in (('omarchy-install-ai-hermes', scratch / 'installer'),
                     ('omarchy-install-hermes-cli', scratch / 'bin/omarchy-install-hermes-cli')):
    script = (source / name).read_text()
    for original, replacement in substitutions.items():
        script = script.replace(original, replacement)
    target.write_text(script)
    target.chmod(0o755)
PY

new_home() {
  test_home="$test_tmp/$1"
  hermes_home="$test_home/.hermes"
  runtime="$hermes_home/hermes-agent"
  native="$runtime/apps/desktop/release/linux-unpacked"
  mkdir -p "$test_home"
  rm -f "$test_tmp/package-installed"
  : >"$test_tmp/events"
}
# The app opens in the background, so a run that got that far is joined to it
# before anything is asserted; one that stopped earlier started nothing.
run_installer() {
  HOME="$test_home" HERMES_HOME="${OMARCHY_TEST_HOME:-$hermes_home}" PATH="$test_tmp/bin:$test_home/.local/bin:$PATH" npm_config_yes= \
    bash "$test_tmp/installer" >"$test_tmp/output" 2>&1 || return
  for (( attempt=0; attempt<200; attempt++ )); do
    if grep -q '^launch' "$test_tmp/events"; then return 0; fi
    sleep 0.01
  done
  return 1
}
# ~/.local/bin is on PATH the way Omarchy puts it there, after the mocks.
run_cli() {
  HOME="$test_home" HERMES_HOME="${OMARCHY_TEST_HOME:-$hermes_home}" PATH="$test_tmp/bin:$test_home/.local/bin:$PATH" npm_config_yes= \
    bash "$test_tmp/bin/omarchy-install-hermes-cli" "$@" >"$test_tmp/output" 2>&1
}
assert_stopped() {
  if grep -Eq '^(launch|theme-|build-stamp)' "$test_tmp/events"; then fail "$1"; fi
}

new_home fresh
run_installer || fail "fresh setup succeeds" "$(cat "$test_tmp/output")"
expected=$(printf '%s\n' --skip-setup --branch main --commit "$release_commit" --force-commit --dir "$runtime" --hermes-home "$hermes_home")
[[ $(cat "$test_tmp/install-args") == "$expected" ]] || fail "upstream installer receives the pinned main arguments"
# npx asks before fetching a package it does not have, Playwright's included,
# and the floating terminal the menu opens has nobody to answer. The runners
# clear the variable, so only the installer can have set it.
[[ $(cat "$test_tmp/install-npx-answer") == "true" ]] || fail "upstream installer runs with npx's question answered" "$(cat "$test_tmp/install-npx-answer")"
[[ $(head -2 "$test_tmp/events") == $'package hermes-desktop\nbootstrap' ]] || fail "the package precedes runtime bootstrap" "$(cat "$test_tmp/events")"
[[ $(sed -n '3p' "$test_tmp/events") == build-stamp ]] || fail "upstream build stamp follows the app copy" "$(cat "$test_tmp/events")"
[[ $(tail -1 "$test_tmp/events") == launch ]] || fail "the app opens only once setup and the theme hand-over are in place" "$(cat "$test_tmp/events")"
grep -qx theme-start "$test_tmp/events" || fail "setup hands Hermes the theme"
[[ $(cat "$hermes_home/desktop-build-stamp.json") == 'upstream build stamp' ]] || fail "the upstream helper records the completed packaged build"
[[ $(cat "$runtime/runtime.txt") == after ]] || fail "the release runtime receives its patch"
[[ $(stat -c %a "$native/chrome-sandbox") == 755 ]] || fail "the user sandbox is not setuid"
[[ $(stat -c %a "$test_tmp/package/chrome-sandbox") == 4755 ]] || fail "package sandbox permissions remain unchanged"
[[ $(git -C "$runtime" symbolic-ref --short HEAD) == main && $(git -C "$runtime" rev-parse main) == "$release_commit" ]] || fail "main starts at the release rather than the clone tip"
[[ $(cat "$runtime/venv/dependency-commit") == "$release_commit" ]] || fail "dependencies are installed for the release"
[[ $(git -C "$runtime" rev-parse --is-shallow-repository) == false ]] || fail "first update has connected history"
# Reproduce the updater's checkout/count/pull sequence while origin stays put.
git clone -q "$runtime" "$test_tmp/first-update"
git -C "$test_tmp/first-update" remote set-url origin "file://$test_tmp/seed"
git -C "$test_tmp/first-update" fetch -q origin main
git -C "$test_tmp/first-update" checkout -q main
[[ $(git -C "$test_tmp/first-update" rev-list HEAD..origin/main --count) == 1 ]] || fail "first update detects work even when origin has not moved since install"
git -C "$test_tmp/first-update" pull -q --ff-only origin main
[[ $(git -C "$test_tmp/first-update" rev-parse HEAD) == "$origin_commit" ]] || fail "first update fast-forwards to origin"
pass "fresh setup pins main, patches the matching runtime and copies the complete app before launch"

printf 'user app\n' >"$native/resources/app.asar"
printf 'user build stamp\n' >"$hermes_home/desktop-build-stamp.json"
: >"$test_tmp/events"
run_installer || fail "repeat setup succeeds" "$(cat "$test_tmp/output")"
! grep -qx bootstrap "$test_tmp/events" || fail "repeat setup does not bootstrap again"
! grep -qx build-stamp "$test_tmp/events" || fail "existing app never reruns the build stamp writer"
[[ $(cat "$hermes_home/desktop-build-stamp.json") == 'user build stamp' ]] || fail "existing native build stamp remains unchanged"
[[ $(cat "$native/resources/app.asar") == 'user app' ]] || fail "existing native app remains unchanged"
pass "repeat setup accepts the applied patch and preserves the existing native app"

# Advancing the runtime must never reinstall the release or reapply its patch.
printf 'new main\n' >"$runtime/runtime.txt"
git -C "$runtime" add runtime.txt
git -C "$runtime" -c user.name=Test -c user.email=test@example.invalid commit -qm update
: >"$test_tmp/events"
run_installer || fail "a complete updated runtime and native app are reused"
[[ $(cat "$runtime/runtime.txt") == 'new main' ]] || fail "updated runtime is not release-patched"
mv "$native" "$test_tmp/saved-native"
: >"$test_tmp/events"
run_installer && fail "a newer runtime cannot receive an older native app"
[[ ! -e $native ]] || fail "no mismatched native app was copied"
grep -q 'hermes desktop --build-only' "$test_tmp/output" || fail "missing newer native app has actionable guidance"
assert_stopped "a missing updated app prevents launch and theme setup"
# The refusal comes before anything is touched: a launcher of the user's own
# beside that newer runtime is neither saved aside nor replaced by a run that
# is going to stop anyway.
own_launcher="#!/bin/bash
exec \"$test_home/tools/hermes\" \"\$@\""
printf '%s\n' "$own_launcher" >"$test_home/.local/bin/hermes"
: >"$test_tmp/events"
run_cli --now && fail "a newer runtime with a launcher of its own still stops"
grep -q 'hermes desktop --build-only' "$test_tmp/output" || fail "the stop still carries the build-only guidance" "$(cat "$test_tmp/output")"
[[ $(cat "$test_home/.local/bin/hermes") == "$own_launcher" ]] || fail "a run that stops leaves the user's launcher as it was"
[[ -z $(find "$test_home/.local/bin" -maxdepth 1 -name '.hermes-before-desktop.*' -print) ]] || fail "a run that stops saves nothing aside"
[[ ! -s $test_tmp/events ]] || fail "a run that stops writes no commands" "$(cat "$test_tmp/events")"
# A git state that cannot be read is a refusal too, not a clean tree: back at
# the release with the index unreadable, the launcher is still left alone.
git -C "$runtime" checkout -q --detach "$release_commit"
chmod 000 "$runtime/.git/index"
: >"$test_tmp/events"
run_cli --now && { chmod 644 "$runtime/.git/index"; fail "an unreadable git state is not a clean tree"; }
chmod 644 "$runtime/.git/index"
grep -q 'Could not read' "$test_tmp/output" || fail "an unreadable git state is named" "$(cat "$test_tmp/output")"
[[ $(cat "$test_home/.local/bin/hermes") == "$own_launcher" ]] || fail "an unreadable git state leaves the user's launcher as it was"
[[ ! -s $test_tmp/events ]] || fail "an unreadable git state writes no commands" "$(cat "$test_tmp/events")"
pass "updated runtimes are preserved and never seeded with the old packaged app"

new_home dirty-desktop
HOME="$test_home" HERMES_HOME="$hermes_home" bash "$test_tmp/share/install.sh" --dir "$runtime" --hermes-home "$hermes_home"
printf 'local desktop edit\n' >"$runtime/apps/desktop/src/main.js"
: >"$test_tmp/events"
run_installer && fail "modified desktop sources cannot be certified as the packaged build"
[[ ! -e $native && ! -e $hermes_home/desktop-build-stamp.json ]] || fail "modified desktop sources receive neither packaged app nor build stamp"
[[ $(cat "$runtime/apps/desktop/src/main.js") == 'local desktop edit' ]] || fail "desktop source edits are preserved"
grep -q 'hermes desktop --build-only' "$test_tmp/output" || fail "modified desktop sources have build guidance"
assert_stopped "modified desktop sources prevent stamping, launch and theme setup"
pass "a matching commit with modified desktop sources is preserved without seeding or stamping"

for failure in package install marker; do
  new_home "$failure-failure"
  case "$failure" in
    package) OMARCHY_TEST_PACKAGE_FAIL=1 run_installer && fail "package failure stops setup" ;;
    install) OMARCHY_TEST_INSTALL_FAIL=1 run_installer && fail "installer failure stops setup" ;;
    marker) OMARCHY_TEST_NO_MARKER=1 run_installer && fail "missing marker stops setup" ;;
  esac
  [[ ! -e $native ]] || fail "failed setup does not seed the app"
  assert_stopped "failed setup prevents launch and theme setup"
done
pass "package, upstream installer and readiness failures stop before launch"

for failure in copy race; do
  new_home "$failure-failure"
  if [[ $failure == "copy" ]]; then
    OMARCHY_TEST_COPY_FAIL=1 run_installer && fail "copy failure stops setup"
    [[ ! -e $native ]] || fail "partial copy is never published"
  else
    OMARCHY_TEST_COPY_RACE=1 run_installer && fail "concurrent native app stops publication"
    [[ -d $native && -z $(ls -A "$native") ]] || fail "concurrent empty app directory is preserved"
  fi
  [[ -z $(find "${native%/*}" -maxdepth 1 -name '.linux-unpacked.*' -print) ]] || fail "owned staging directory is cleaned up"
  assert_stopped "publication failure prevents launch"
done
pass "failed copies and concurrent app creation preserve existing work and clean only staging"

new_home incomplete-native
run_installer || fail "incomplete native fixture sets up"
rm "$native/resources/app.asar"
: >"$test_tmp/events"
run_installer && fail "incomplete existing app requires repair"
[[ ! -e $native/resources/app.asar ]] || fail "incomplete existing app is not overwritten"
assert_stopped "incomplete native app prevents launch"
pass "an incomplete existing native app is preserved"

# A runtime already at the release, edited where the patch lands, before Omarchy
# has prepared it: the conflict is reported and nothing is touched.
new_home patch-conflict
HOME="$test_home" HERMES_HOME="$hermes_home" bash "$test_tmp/share/install.sh" --dir "$runtime" --hermes-home "$hermes_home"
printf 'local edit\n' >"$runtime/runtime.txt"
: >"$test_tmp/events"
run_installer && fail "unexpected patch conflict stops setup"
[[ $(cat "$runtime/runtime.txt") == 'local edit' ]] || fail "conflicting runtime changes are preserved"
assert_stopped "patch conflict prevents launch"
rm "$runtime/.hermes-bootstrap-complete"
: >"$test_tmp/events"
run_installer && fail "incomplete modified runtime cannot be reset by upstream installer"
! grep -qx bootstrap "$test_tmp/events" || fail "modified runtime never reaches upstream installer"
pass "patch conflicts and incomplete modified runtimes retain local changes and stop safely"

# Every refusal comes before anything of the user's is touched, whatever state
# the runtime is in: a launcher of their own is neither saved aside nor
# replaced, and no bootstrap runs, by a run that is going to stop anyway.
own_launcher="#!/bin/bash
exec \"$test_home/tools/hermes\" \"\$@\""
assert_untouched() {
  [[ $(cat "$test_home/.local/bin/hermes") == "$own_launcher" ]] || fail "$1: the user's launcher is not as it was"
  [[ -z $(find "$test_home/.local/bin" -maxdepth 1 -name '.hermes-before-desktop.*' -print) ]] || fail "$1: something was saved aside"
  [[ ! -s $test_tmp/events ]] || fail "$1: setup ran" "$(cat "$test_tmp/events")"
}
# A finished runtime at the release whose edit the runtime patch cannot land on.
new_home patch-conflict-own-launcher
touch "$test_tmp/package-installed"
HOME="$test_home" HERMES_HOME="$hermes_home" bash "$test_tmp/share/install.sh" --dir "$runtime" --hermes-home "$hermes_home"
printf 'local edit\n' >"$runtime/runtime.txt"
printf '%s\n' "$own_launcher" >"$test_home/.local/bin/hermes"
: >"$test_tmp/events"
run_cli --now && fail "a conflicting edit still stops setup"
grep -q 'patch conflicts' "$test_tmp/output" || fail "a conflicting edit is named" "$(cat "$test_tmp/output")"
assert_untouched "a patch conflict"
# An unfinished runtime beside a half-built app.
new_home incomplete-app
touch "$test_tmp/package-installed"
OMARCHY_TEST_NO_MARKER=1 HOME="$test_home" HERMES_HOME="$hermes_home" bash "$test_tmp/share/install.sh" --dir "$runtime" --hermes-home "$hermes_home"
mkdir -p "$native/resources"
printf 'half\n' >"$native/resources/app.asar"
printf '%s\n' "$own_launcher" >"$test_home/.local/bin/hermes"
: >"$test_tmp/events"
run_cli --now && fail "a half-built app beside an unfinished runtime still stops setup"
grep -q 'is incomplete' "$test_tmp/output" || fail "a half-built app is named" "$(cat "$test_tmp/output")"
assert_untouched "a half-built app"
# An unfinished runtime whose git state cannot be read is not a clean one.
new_home unreadable-incomplete
touch "$test_tmp/package-installed"
OMARCHY_TEST_NO_MARKER=1 HOME="$test_home" HERMES_HOME="$hermes_home" bash "$test_tmp/share/install.sh" --dir "$runtime" --hermes-home "$hermes_home"
printf '%s\n' "$own_launcher" >"$test_home/.local/bin/hermes"
chmod 000 "$runtime/.git/index"
: >"$test_tmp/events"
run_cli --now && { chmod 644 "$runtime/.git/index"; fail "an unreadable git state beside an unfinished runtime is not a clean tree"; }
chmod 644 "$runtime/.git/index"
grep -q 'incomplete at' "$test_tmp/output" || fail "an unreadable git state is refused as incomplete" "$(cat "$test_tmp/output")"
assert_untouched "an unreadable git state"
pass "a refusal leaves the user's launcher and runtime as they were, whatever state the runtime is in"

# Once set up, a runtime is the user's to edit; a finished install is not
# re-patched or re-verified, only opened.
new_home finished-edit
run_installer || fail "finished-edit fixture sets up" "$(cat "$test_tmp/output")"
printf 'local edit\n' >"$runtime/runtime.txt"
: >"$test_tmp/events"
run_installer || fail "a finished install with local edits is accepted" "$(cat "$test_tmp/output")"
[[ $(cat "$runtime/runtime.txt") == 'local edit' ]] || fail "local edits to a finished runtime are preserved"
[[ $(cat "$test_tmp/events") == launch ]] || fail "a finished install is only opened" "$(cat "$test_tmp/events")"
pass "a finished install is left as the user has it"

new_home full-history-retry
git clone -q "$test_tmp/seed" "$runtime"
git -C "$runtime" checkout -q --detach "$release_commit"
run_installer || fail "clean incomplete full-history release checkout is repaired" "$(cat "$test_tmp/output")"
[[ $(cat "$runtime/venv/dependency-commit") == "$release_commit" ]] || fail "full-history retry pins before installing dependencies"
[[ $(git -C "$runtime" rev-parse HEAD) == "$release_commit" && -f $native/resources/app.asar ]] || fail "full-history retry seeds the matching release"
pass "full-history retries force the guarded release pin before dependency setup"

# A main that is neither the release nor origin/main is kept under another name
# and main still starts at the release: a user's own commits stay reachable,
# and a clone whose main is off origin/main only because upstream rewrote its
# history is not refused for work it never did.
new_home local-main
git clone -q "$test_tmp/seed" "$runtime"
printf 'local branch work\n' >"$runtime/keep"
git -C "$runtime" add keep
git -C "$runtime" -c user.name=Test -c user.email=test@example.invalid commit -qm local-work
local_main=$(git -C "$runtime" rev-parse main)
git -C "$runtime" checkout -q --detach "$release_commit"
run_installer || fail "a runtime whose main carries other work still sets up" "$(cat "$test_tmp/output")"
[[ $(git -C "$runtime" rev-parse main) == "$release_commit" ]] || fail "main starts at the release"
kept=$(git -C "$runtime" for-each-ref --format='%(objectname)' 'refs/heads/main-before-omarchy-*')
[[ $kept == "$local_main" ]] || fail "what main pointed at is kept under another name" "$kept"
grep -q 'main-before-omarchy-' "$test_tmp/output" || fail "the kept branch is named in the output"
[[ -f $native/resources/app.asar ]] || fail "setup carries on to seed the app"
pass "work on main is kept under another name rather than refused"

# A shallow.lock nothing has touched for a minute is what a probe that killed
# Hermes mid-fetch leaves behind; it must not stop the history fetch for good.
new_home stale-lock
HOME="$test_home" HERMES_HOME="$hermes_home" bash "$test_tmp/share/install.sh" --dir "$runtime" --hermes-home "$hermes_home"
printf 'stale\n' >"$runtime/.git/shallow.lock"
touch -d '5 minutes ago' "$runtime/.git/shallow.lock"
run_installer || fail "a stale shallow.lock does not stop setup" "$(cat "$test_tmp/output")"
[[ ! -e $runtime/.git/shallow.lock ]] || fail "the stale lock is cleared"
[[ $(git -C "$runtime" rev-parse --is-shallow-repository) == false ]] || fail "the history fetch went ahead after the stale lock"
pass "a stale shallow.lock is cleared rather than left to block every history fetch"

# The same old lock with a git still working in the runtime is somebody's: it
# is waited for, not taken. Each way a live git is found gets its own run: a
# stand-in git that lives until this test releases it, only after setup has
# said it is waiting, and that says if its lock was stolen while it lived; it
# then leaves the lock behind orphaned the way a killed fetch would.
live_lock_case() {
  local name=$1 where=$2 output_line='Waiting for Hermes' attempt
  shift 2
  new_home "$name"
  ln -s "$test_home" "$test_tmp/$name-link"
  HOME="$test_home" HERMES_HOME="$hermes_home" bash "$test_tmp/share/install.sh" --dir "$runtime" --hermes-home "$hermes_home"
  printf 'live\n' >"$runtime/.git/shallow.lock"
  touch -d '5 minutes ago' "$runtime/.git/shallow.lock"
  rm -f "$test_tmp/lock-stolen" "$test_tmp/release-git"
  (cd "$where" && { if (( $# )); then export "$@"; fi; } && export LOCK="$runtime/.git/shallow.lock" && exec -a "${OMARCHY_TEST_GIT_ARGV0:-git}" bash -c 'for (( i = 0; i < 900; i++ )); do [[ -e "$1" ]] && exit; [[ -e $LOCK ]] || { touch "$2"; exit; }; sleep 0.1; done' _ "$test_tmp/release-git" "$test_tmp/lock-stolen") &
  fake_git=$!
  : >"$test_tmp/output"
  # The runtime is reached through a link, as a symlinked home would, since
  # /proc reports canonical paths and the runtime path keeps links.
  OMARCHY_TEST_HOME="$test_tmp/$name-link/.hermes" run_installer &
  installer=$!
  for (( attempt = 0; attempt < 300; attempt++ )); do
    grep -q "$output_line" "$test_tmp/output" 2>/dev/null && break
    sleep 0.1
  done
  if ! grep -q "$output_line" "$test_tmp/output"; then
    touch "$test_tmp/release-git"; wait "$installer" || true
    fail "setup says it is waiting for the live git ($name)" "$(cat "$test_tmp/output")"
  fi
  [[ ! -e $test_tmp/lock-stolen ]] || fail "the lock was cleared while a git still worked in the runtime ($name)"
  touch "$test_tmp/release-git"
  wait "$installer" || fail "setup goes ahead once the git is gone ($name)" "$(cat "$test_tmp/output")"
  wait "$fake_git" 2>/dev/null || true
  [[ ! -e $test_tmp/lock-stolen ]] || fail "the lock was cleared while a git still worked in the runtime ($name)"
  [[ ! -e $runtime/.git/shallow.lock ]] || fail "the orphaned lock is cleared once nothing holds it ($name)"
  [[ $(git -C "$runtime" rev-parse --is-shallow-repository) == false ]] || fail "the history fetch went ahead after the wait ($name)"
}
# Found by its working directory.
live_lock_case live-lock-cwd "$test_tmp/live-lock-cwd/.hermes/hermes-agent"
pass "a lock a live git holds is waited for, not taken, through a linked runtime path"
# Found by GIT_DIR alone, with a trailing slash, from elsewhere, with a large
# environment: read whole and NUL-delimited, or it would go unseen.
big_env=$(head -c 120000 /dev/zero | tr '\0' 'x')
live_lock_case live-lock-env "$test_tmp" BIG_ENV="$big_env" GIT_DIR="$test_tmp/live-lock-env/.hermes/hermes-agent/.git/"
pass "a git working from elsewhere with GIT_DIR naming the runtime is found by its environment"
# Named by its path, as a git run as /usr/bin/git is.
live_lock_case live-lock-path "$test_tmp/live-lock-path/.hermes/hermes-agent" OMARCHY_TEST_GIT_ARGV0=/usr/bin/git
pass "a git that names itself by its path is found too"
# A process that only names git on its command line, an editor opened on
# /usr/bin/git from inside the runtime say, is not a git at work there: the
# stale lock goes and setup carries on without waiting.
new_home bystander
HOME="$test_home" HERMES_HOME="$hermes_home" bash "$test_tmp/share/install.sh" --dir "$runtime" --hermes-home "$hermes_home"
printf 'stale\n' >"$runtime/.git/shallow.lock"
touch -d '5 minutes ago' "$runtime/.git/shallow.lock"
rm -f "$test_tmp/release-bystander"
(cd "$runtime" && exec -a nvim bash -c 'for (( i = 0; i < 900; i++ )); do [[ -e "$1" ]] && exit; sleep 0.1; done' _ "$test_tmp/release-bystander" /usr/bin/git) &
bystander=$!
run_installer || { touch "$test_tmp/release-bystander"; fail "setup goes ahead beside a process that only names git" "$(cat "$test_tmp/output")"; }
touch "$test_tmp/release-bystander"
wait "$bystander" 2>/dev/null || true
! grep -q 'Waiting for Hermes' "$test_tmp/output" || fail "a process that only names git is waited for"
[[ ! -e $runtime/.git/shallow.lock ]] || fail "the stale lock is cleared beside a process that only names git"
pass "a process that only names git on its command line is not waited for"

new_home deepen-retry
OMARCHY_TEST_FETCH_FAIL=1 run_installer && fail "history fetch failure stops setup"
[[ ! -e $native ]] || fail "failed history fetch does not seed the app"
assert_stopped "failed history fetch prevents launch"
: >"$test_tmp/events"
run_installer || fail "history fetch can be retried after runtime setup" "$(cat "$test_tmp/output")"
! grep -qx bootstrap "$test_tmp/events" || fail "history retry does not repeat upstream installation"
pass "a history fetch failure can be retried without reinstalling the ready runtime"

new_home existing-commands
mkdir -p "$test_home/.local/bin"
printf 'foreign wrapper\n' >"$test_home/.local/bin/hermes"
printf 'symlink target\n' >"$test_home/target"
ln -s "$test_home/target" "$test_home/.local/bin/hermes-agent"
ln -s "$test_home/missing" "$test_home/.local/bin/hermes-acp"
run_installer || fail "existing commands are preserved before upstream replaces them" "$(cat "$test_tmp/output")"
backups=("$test_home/.local/bin/".hermes-before-desktop.*)
[[ ${#backups[@]} == 1 && -d ${backups[0]} ]] || fail "one backup directory preserves existing command names"
[[ $(cat "${backups[0]}/hermes") == 'foreign wrapper' ]] || fail "foreign wrapper bytes are saved"
[[ $(readlink "${backups[0]}/hermes-agent") == "$test_home/target" && $(readlink "${backups[0]}/hermes-acp") == "$test_home/missing" ]] || fail "working and broken symlinks are saved as links"
[[ $(cat "$test_home/target") == 'symlink target' ]] || fail "upstream does not overwrite the original symlink target"
grep -qF "${backups[0]}" "$test_tmp/output" || fail "backup location is reported"
pass "pre-existing command files and symlinks are backed up before replacement"

new_home old-package
mv "$test_tmp/package/resources/install-stamp.json" "$test_tmp/saved-install-stamp.json"
run_installer && fail "an old installed package cannot bootstrap"
grep -q 'omarchy update' "$test_tmp/output" || fail "old package has actionable upgrade guidance"
! grep -qx bootstrap "$test_tmp/events" || fail "old package never reaches upstream installer"
mv "$test_tmp/saved-install-stamp.json" "$test_tmp/package/resources/install-stamp.json"
pass "old package fails with upgrade guidance before changing the runtime"

# Choosing Hermes as the default agent runs the same setup, short of opening
# the app: the package, the runtime, the seeded app and the theme hand-over.
new_home terminal-agent
run_cli --now || fail "the default agent path sets Hermes up" "$(cat "$test_tmp/output")"
[[ $(cat "$test_tmp/events") == $'package hermes-desktop\nbootstrap\nbuild-stamp\ntheme-stop\ntheme-start' ]] ||
  fail "the default agent path installs the app's runtime without opening the app" "$(cat "$test_tmp/events")"
[[ -x $test_home/.local/bin/hermes && -f $native/resources/app.asar ]] || fail "the default agent path leaves the command and the seeded app in place"
: >"$test_tmp/events"
run_cli --now || fail "a finished install is accepted by the default agent path" "$(cat "$test_tmp/output")"
[[ ! -s $test_tmp/events ]] || fail "a finished install is set up again" "$(cat "$test_tmp/events")"
run_cli --check || fail "--check follows the installed runtime"
pass "choosing Hermes as the default agent installs the app's runtime without opening the app"

# A Hermes from elsewhere is not the app's: choosing Hermes installs the app
# over it, with the previous command saved aside.
new_home own-hermes
mkdir -p "$test_home/.local/bin"
cat >"$test_home/.local/bin/hermes" <<'SH'
#!/bin/bash
if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
  echo "[-q QUERY, --query QUERY] [--tui]"
else
  echo "hermes-agent 0.0.0-user"
fi
SH
chmod +x "$test_home/.local/bin/hermes"
own_hermes=$(cat "$test_home/.local/bin/hermes")
run_cli --check && fail "--check calls a Hermes from elsewhere the app's"
run_cli --now || fail "choosing Hermes installs the app over a Hermes from elsewhere" "$(cat "$test_tmp/output")"
[[ $(head -2 "$test_tmp/events") == $'package hermes-desktop\nbootstrap' ]] || fail "the app and its runtime are installed over a Hermes from elsewhere" "$(cat "$test_tmp/events")"
backups=("$test_home/.local/bin/".hermes-before-desktop.*)
[[ ${#backups[@]} == 1 && $(cat "${backups[0]}/hermes") == "$own_hermes" ]] || fail "the previous hermes command is saved aside"
grep -qF "$hermes_home/" "$test_home/.local/bin/hermes" || fail "the command is now the app's"
run_cli --check || fail "--check follows the app's Hermes"
pass "Hermes is only installed through the app: a Hermes from elsewhere is superseded, its command saved aside"

# A finished runtime whose command is gone, or not its own, gets its command
# back from upstream's path stage alone: no bootstrap, the runtime untouched,
# and what held the name saved aside. Until then --check says no, so the menu
# opens a terminal for the repair rather than running the agent on the wrong
# Hermes.
new_home command-repair
run_cli --now || fail "command-repair fixture sets up" "$(cat "$test_tmp/output")"
rm "$test_home/.local/bin/hermes"
run_cli --check && fail "--check calls a runtime installed without its command"
: >"$test_tmp/events"
run_cli --now || fail "a missing command is restored" "$(cat "$test_tmp/output")"
[[ $(cat "$test_tmp/events") == path ]] || fail "a missing command is restored without bootstrapping again" "$(cat "$test_tmp/events")"
run_cli --check || fail "--check follows the restored command"
printf '%s\n' "#!/bin/bash" "exec /usr/local/bin/somebody-elses-hermes \"\$@\"" >"$test_home/.local/bin/hermes"
chmod +x "$test_home/.local/bin/hermes"
run_cli --check && fail "--check calls the app installed while the terminal is on another Hermes"
: >"$test_tmp/events"
run_cli --now || fail "a foreign command beside the app's runtime is replaced" "$(cat "$test_tmp/output")"
[[ $(cat "$test_tmp/events") == path ]] || fail "a foreign command is replaced without bootstrapping again" "$(cat "$test_tmp/events")"
grep -lF somebody-elses-hermes "$test_home/.local/bin/".hermes-before-desktop.*/hermes >/dev/null 2>&1 || fail "the foreign command is saved aside"
grep -qF "$hermes_home/" "$test_home/.local/bin/hermes" || fail "the runtime's own command is back"
run_cli --check || fail "--check follows the runtime's own command"
chmod -x "$test_home/.local/bin/hermes"
run_cli --check && fail "--check calls the runtime's own command installed when it cannot run"
: >"$test_tmp/events"
run_cli --now || fail "the runtime's own command is rewritten when it cannot run" "$(cat "$test_tmp/output")"
[[ $(cat "$test_tmp/events") == path && -x $test_home/.local/bin/hermes ]] || fail "a command that cannot run is rewritten by the path stage alone" "$(cat "$test_tmp/events")"
pass "a finished runtime gets its own command back without bootstrapping again"

# A hermes ahead of ~/.local/bin on PATH is what the default agent would run,
# so a finished install behind it is not installed, and --now names it rather
# than setting anything up again.
cp "$test_home/.local/bin/hermes" "$test_tmp/bin/hermes"
run_cli --check && fail "--check calls a shadowed install installed"
: >"$test_tmp/events"
run_cli --now && fail "--now reports a shadowed install as ready"
grep -qF "$test_tmp/bin/hermes" "$test_tmp/output" || fail "--now names the command in the way" "$(cat "$test_tmp/output")"
[[ ! -s $test_tmp/events ]] || fail "a shadowed install is set up again" "$(cat "$test_tmp/events")"
rm -f "$test_tmp/bin/hermes"
run_cli --check || fail "--check follows the install once nothing shadows it"
pass "a hermes ahead of ~/.local/bin on PATH is reported, not set up over"

# A machine that chose Hermes before its migration ran: the wrapper's copy the
# runtime setup saved aside proves the mise environment Omarchy's, and mise's
# shim for it sits ahead of ~/.local/bin. Choosing Hermes again finishes the
# handover: the environment goes, the shim and the saved copy with it, and
# only then is the command the one PATH finds.
new_home handover
run_cli --now || fail "handover fixture sets up" "$(cat "$test_tmp/output")"
saved="$test_home/.local/bin/.hermes-before-desktop.mise01"
mkdir -p "$saved"
printf '%s\n' "#!/bin/bash" "# Written by omarchy-install-hermes-cli." >"$saved/hermes"
cp "$test_home/.local/bin/hermes" "$test_tmp/bin/hermes"
: >"$test_tmp/mise-log"; rm -f "$test_tmp/mise-removed" "$test_tmp/mise-unrequested"
OMARCHY_TEST_MISE_BUILT=1 run_cli --check && fail "--check calls a handover with the mise environment still there finished"
: >"$test_tmp/events"
OMARCHY_TEST_MISE_BUILT=1 OMARCHY_TEST_SHIM="$test_tmp/bin/hermes" run_cli --now || fail "--now finishes the handover" "$(cat "$test_tmp/output")"
grep -q 'mise uninstall --all' "$test_tmp/mise-log" || fail "the environment the saved wrapper proves Omarchy's is removed" "$(cat "$test_tmp/mise-log")"
[[ ! -e $test_tmp/bin/hermes ]] || fail "the shim is gone with the environment"
[[ ! -e $saved/hermes && ! -d $saved ]] || fail "the saved wrapper and its directory go once the environment is gone"
[[ ! -s $test_tmp/events ]] || fail "the handover sets nothing up again" "$(cat "$test_tmp/events")"
run_cli --check || fail "--check follows the finished handover"
pass "choosing Hermes again before the migration finishes the handover: the mise Hermes and its shim go"

new_home custom-profile
hermes_home="$test_home/custom home"
runtime="$hermes_home/hermes-agent"
OMARCHY_TEST_HOME="$hermes_home/PrOfIlEs/coder/../coder/" run_installer || fail "profile setup succeeds"
[[ -x $runtime/apps/desktop/release/linux-unpacked/Hermes ]] || fail "profile uses the canonical root runtime"
grep -qxF "$hermes_home" "$test_tmp/install-args" || fail "canonical custom home reaches upstream installer"
pass "custom profile paths normalize to the shared Hermes home"

# New releases moved the stamp writer out of main. Keep the earlier cases on
# the old layout and exercise a fresh installation with the relocated helper.
git -C "$test_tmp/seed" mv hermes_cli/main.py hermes_cli/main_desktop.py
printf 'raise AssertionError("legacy module imported after desktop split")\n' >"$test_tmp/seed/hermes_cli/main.py"
git -C "$test_tmp/seed" add hermes_cli/main.py
git -C "$test_tmp/seed" -c user.name=Test -c user.email=test@example.invalid commit -qm split-desktop
release_commit=$(git -C "$test_tmp/seed" rev-parse HEAD)
export OMARCHY_TEST_RELEASE_COMMIT="$release_commit"
printf '{"branch":"main","commit":"%s"}\n' "$release_commit" >"$test_tmp/package/resources/install-stamp.json"
new_home split-desktop
run_installer || fail "setup supports the relocated desktop helper" "$(cat "$test_tmp/output")"
[[ $(cat "$hermes_home/desktop-build-stamp.json") == 'upstream build stamp' ]] || fail "relocated helper writes the build stamp"
grep -qx launch "$test_tmp/events" || fail "setup launches after the relocated helper writes the stamp"
pass "new releases use the relocated desktop stamp writer"
