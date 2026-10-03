#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
hermes="$test_home/.local/bin/hermes"
ran="$test_tmp/ran"
mise_log="$test_tmp/mise-log"
pkg_log="$test_tmp/pkg-log"
mkdir -p "$mock_bin" "$test_home/.local/bin"
: >"$mise_log"

cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_DESKTOP_INSTALLED:-0} == 1 ]]
SH

# Installing the package is the first thing the runtime setup does, so a mock
# that fails there proves the installer would have installed without running
# the rest of the setup, which hermes-desktop-install-test.sh covers.
cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_PKG_LOG"
exit 1
SH

# Hermes never comes from mise any more; the only thing the installer asks
# mise is to remove what the retired wrapper built. `where` finds that
# environment and `ls -g` lists it as requested when a test says it was built,
# until uninstalled and unrequested respectively. Every call is logged.
cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf 'mise %s\n' "$*" >>"$OMARCHY_TEST_MISE_LOG"
case "$1" in
  where)
    [[ ${OMARCHY_TEST_MISE_BUILT:-0} == 1 && ! -e $OMARCHY_TEST_MISE_LOG.removed ]]
    ;;
  ls)
    if [[ ${OMARCHY_TEST_MISE_BUILT:-0} == 1 && ! -e $OMARCHY_TEST_MISE_LOG.unrequested ]]; then
      echo '{"pipx:hermes-agent[extras=all]": [{"version": "latest"}]}'
    elif [[ ${OMARCHY_TEST_MISE_SIBLING:-0} == 1 ]]; then
      echo '{"pipx:hermes-agent-tools": [{"version": "latest"}]}'
    else
      echo '{}'
    fi
    ;;
  rm)
    touch "$OMARCHY_TEST_MISE_LOG.unrequested"
    ;;
  uninstall)
    touch "$OMARCHY_TEST_MISE_LOG.removed"
    rm -f "${OMARCHY_TEST_SHIM:-}"
    ;;
esac
SH

chmod +x "$mock_bin"/*

# ~/.local/bin is on PATH the way Omarchy puts it there, after the mocks, so
# `hermes` resolves to the command under test unless a test shadows it.
run_installer() {
  OMARCHY_TEST_DESKTOP_INSTALLED="${OMARCHY_TEST_DESKTOP_INSTALLED:-0}" \
    OMARCHY_TEST_MISE_LOG="$mise_log" \
    OMARCHY_TEST_PKG_LOG="$pkg_log" \
    OMARCHY_TEST_RAN="$ran" \
    HOME="$test_home" \
    PATH="$mock_bin:$test_home/.local/bin:$PATH" \
    bash "$ROOT/bin/omarchy-install-hermes-cli" "$@" >"$test_tmp/output" 2>&1
}

# A hermes that runs, defines the flags omarchy-agent passes unless a test says
# otherwise, and records that it ran. With "ours" it names the runtime the way
# upstream's launcher does; without, it is a command from somewhere else.
write_hermes() {
  cat >"$hermes" <<'SH'
#!/bin/bash
touch "$OMARCHY_TEST_RAN"
if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
  printf '%s\n' "${OMARCHY_TEST_HERMES_HELP-[-q QUERY, --query QUERY] [--tui]}"
else
  echo "hermes-agent 0.0.0-test"
fi
SH
  if [[ ${1:-} == "ours" ]]; then
    printf '# stands in for: exec "%s/.hermes/hermes-agent/venv/bin/python" "$@"\n' "$test_home" >>"$hermes"
  fi
  chmod +x "$hermes"
}

legacy_marker="# Written by omarchy-install-hermes-cli."

write_legacy_stub() {
  printf '%s\n' "#!/bin/bash" "$legacy_marker" 'touch "$OMARCHY_TEST_RAN"' >"$1"
  chmod +x "$1"
}

# The app's launcher used to call this with no arguments; a default of --now
# would turn every launch into an install.
: >"$pkg_log"
run_installer && fail "the installer runs without a mode"
grep -q 'Usage' "$test_tmp/output" || fail "a missing mode prints usage"
[[ ! -s $pkg_log ]] || fail "a missing mode installs nothing"
pass "the installer needs its mode named"

rm -f "$hermes"
run_installer --check && fail "--check reports a Hermes with nothing at the command's path"
pass "--check is false with no hermes command"

# The retired wrapper built Hermes through mise when run, so it is never run to
# find out whether Hermes is there, whether it is the file or a link to it.
write_legacy_stub "$hermes"
rm -f "$ran"
run_installer --check && fail "--check reports the retired mise wrapper as a Hermes"
[[ ! -e $ran ]] || fail "--check runs the retired mise wrapper"
rm -f "$hermes"
write_legacy_stub "$test_tmp/stub"
ln -s "$test_tmp/stub" "$hermes"
run_installer --check && fail "--check reports a link to the retired wrapper as a Hermes"
[[ ! -e $ran ]] || fail "--check runs the retired wrapper through a link"
rm -f "$hermes"
pass "--check never runs the retired mise wrapper"

# Hermes is only ever installed through the app: a hermes that works but did
# not come from it is not the app's, so --check says no and --now installs the
# app over it, the command saved aside by the runtime setup further on.
write_hermes
run_installer --check && fail "--check calls a hermes without the app installed"
: >"$pkg_log"
run_installer --now && fail "--now carries on past the mocked package failure"
grep -qx 'hermes-desktop' "$pkg_log" || fail "--now installs the app over a hermes from elsewhere" "$(cat "$test_tmp/output")"
pass "a hermes that did not come from the app is not the app's; choosing Hermes installs the app"

rm -f "$hermes"
: >"$pkg_log"
run_installer --now && fail "--now carries on past the mocked package failure"
grep -qx 'hermes-desktop' "$pkg_log" || fail "--now installs the hermes-desktop package" "$(cat "$test_tmp/output")"
pass "--now installs Hermes Desktop when no Hermes answers"

# The retired wrapper is not a Hermes for --now either, and still is not run.
write_legacy_stub "$hermes"
rm -f "$ran"
: >"$pkg_log"
run_installer --now && fail "--now carries on past the mocked package failure"
grep -qx 'hermes-desktop' "$pkg_log" || fail "--now installs over the retired wrapper"
[[ ! -e $ran ]] || fail "--now runs the retired wrapper"
rm -f "$hermes"
pass "--now installs over the retired mise wrapper without running it"

# With the app installed, a command that runs is not the whole answer: until
# the runtime carries the marker upstream writes last and the packaged app has
# been seeded, --now still has minutes of work, so --check says no and the menu
# opens a terminal for it rather than running it where nobody can see.
runtime="$test_home/.hermes/hermes-agent"
native="$runtime/apps/desktop/release/linux-unpacked/resources"
write_hermes ours
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --check && fail "--check calls an app with no runtime installed"
mkdir -p "$runtime" "$native"
touch "$runtime/.hermes-bootstrap-complete"
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --check && fail "--check calls an app whose packaged build is not seeded installed"
touch "$native/app.asar" "$native/install-stamp.json"
printf '#!/bin/bash\nexit 0\n' >"$native/../Hermes"
chmod +x "$native/../Hermes"
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --check || fail "--check follows a finished install"
pass "--check says no while --now still has work to do behind the app"

# With the app installed, the terminal has to be on the app's Hermes: a working
# command from somewhere else beside a finished runtime is not installed, so
# --now gets to put the runtime's own command back.
write_hermes
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --check && fail "--check calls the app installed while the command is somebody else's"
write_hermes ours
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --check || fail "--check follows the runtime's own command"
pass "--check needs the app's own command once the app is installed"

# The flags have to be defined by the help, not merely mentioned in it, and
# both of them: omarchy-agent passes --query to seed the session and --tui to
# keep it interactive.
OMARCHY_TEST_DESKTOP_INSTALLED=1 OMARCHY_TEST_HERMES_HELP='Run with --tui for a terminal session; see --query in the docs.' run_installer --check &&
  fail "--check accepts flags that are only mentioned"
OMARCHY_TEST_DESKTOP_INSTALLED=1 OMARCHY_TEST_HERMES_HELP='[--tui]' run_installer --check && fail "--check accepts a hermes without --query"
OMARCHY_TEST_DESKTOP_INSTALLED=1 OMARCHY_TEST_HERMES_HELP='[-q QUERY, --query QUERY]' run_installer --check && fail "--check accepts a hermes without --tui"
pass "--check needs both flags defined, not mentioned"

chmod -x "$hermes"
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --check && fail "--check accepts a hermes that is not executable"
rm -f "$hermes"
mkdir "$hermes"
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --check && fail "--check accepts a directory at the command's path"
rmdir "$hermes"
ln -s "$test_tmp/nowhere" "$hermes"
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --check && fail "--check accepts a dangling link"
rm -f "$hermes"
write_hermes ours
pass "--check rejects what is not a command that runs"

# Installed and finished: nothing to do, and quickly, because choosing the
# agent from the menu runs this.
: >"$pkg_log"
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --now || fail "--now accepts a finished install" "$(cat "$test_tmp/output")"
[[ ! -s $pkg_log && ! -s $test_tmp/output ]] || fail "a finished install is set up again" "$(cat "$test_tmp/output")"
pass "--now has nothing to do once the app and its runtime are in"

[[ ! -s $mise_log ]] || fail "the installer touched mise" "$(cat "$mise_log")"
pass "Hermes never goes through mise"

# A PATH that finds no hermes at all is not in the way: the theme unit asks
# from a service whose PATH has no ~/.local/bin and runs the command by path.
run_installer_bare_path() {
  OMARCHY_TEST_DESKTOP_INSTALLED="${OMARCHY_TEST_DESKTOP_INSTALLED:-0}" \
    OMARCHY_TEST_MISE_LOG="$mise_log" OMARCHY_TEST_PKG_LOG="$pkg_log" OMARCHY_TEST_RAN="$ran" \
    HOME="$test_home" PATH="$mock_bin:/usr/bin" \
    bash "$ROOT/bin/omarchy-install-hermes-cli" "$@" >"$test_tmp/output" 2>&1
}
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer_bare_path --check || fail "--check from a PATH without ~/.local/bin still follows a finished install" "$(cat "$test_tmp/output")"
pass "--check does not need ~/.local/bin on the caller's PATH"

# What omarchy-agent runs is whichever hermes PATH finds first, and Omarchy
# puts mise's shims ahead of ~/.local/bin. A command ahead of the one the probe
# vets means the agent would run something else, so it is not installed, and
# --now says what is in the way rather than reporting a Hermes that is not the
# one the agent gets.
cp "$hermes" "$mock_bin/hermes"
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --check && fail "--check calls a shadowed command installed"
rm -f "$mock_bin/hermes"
OMARCHY_TEST_DESKTOP_INSTALLED=1 run_installer --check || fail "--check follows the command once nothing shadows it"
pass "a hermes ahead of ~/.local/bin on PATH is not the one the agent gets"

# The retired wrapper's environment goes with the wrapper's proof, wherever
# that is. --retire-mise is the migration's whole job; --now does the same once
# the runtime installer has saved the wrapper aside, so a user who chose Hermes
# before their migration ran is not left with mise's shim answering `hermes`.
write_legacy_stub "$hermes"
: >"$mise_log"; rm -f "$mise_log.removed" "$mise_log.unrequested"
OMARCHY_TEST_MISE_BUILT=1 run_installer --retire-mise || fail "--retire-mise succeeds over the wrapper" "$(cat "$test_tmp/output")"
[[ ! -e $hermes ]] || fail "--retire-mise removes the wrapper"
grep -qF "mise rm -g pipx:hermes-agent[extras=all]" "$mise_log" || fail "--retire-mise removes the global mise Hermes" "$(cat "$mise_log")"
grep -qF "mise uninstall --all pipx:hermes-agent[extras=all]" "$mise_log" || fail "--retire-mise uninstalls the mise Hermes" "$(cat "$mise_log")"
: >"$mise_log"
run_installer --retire-mise || fail "--retire-mise succeeds with nothing of Omarchy's"
[[ ! -s $mise_log ]] || fail "--retire-mise asks mise about an environment nothing proves Omarchy's" "$(cat "$mise_log")"
pass "--retire-mise removes the wrapper and the environment it built, and only with proof"

# A global tool whose name merely starts the same way is not the retired one;
# read as it, it could never be removed and the migration would stay pending.
write_legacy_stub "$hermes"
: >"$mise_log"
OMARCHY_TEST_MISE_SIBLING=1 run_installer --retire-mise || fail "--retire-mise succeeds beside a tool named like the retired one" "$(cat "$test_tmp/output")"
[[ ! -e $hermes ]] || fail "the wrapper goes when only a similarly named tool is requested"
! grep -q '^mise rm' "$mise_log" || fail "a similarly named tool is taken for the retired one" "$(cat "$mise_log")"
pass "a mise tool named like the retired one does not keep the migration pending"

# --now finishing a handover, mise environment and shim included, needs the
# package fixtures and lives in hermes-desktop-install-test.sh.
