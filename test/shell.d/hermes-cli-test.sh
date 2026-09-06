#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mise_log="$test_tmp/mise-log"
mkdir -p "$mock_bin" "$test_home/.local/bin"
export OMARCHY_TEST_DESKTOP_LOG="$test_tmp/desktop-log"

cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_DESKTOP_INSTALLED:-0} == 1 ]]
SH

# The package's own runtime/build validation is tested in omarchy-pkgs. This
# fixture exposes its public install/check contract to the Omarchy caller.
cat >"$mock_bin/hermes-desktop" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_DESKTOP_LOG"
root="${HERMES_HOME:-$HOME/.hermes}/hermes-agent"
if [[ $1 == "--install" ]]; then
  [[ ${OMARCHY_TEST_DESKTOP_FAIL:-0} == 0 ]] || exit 1
  mkdir -p "$root/venv/bin" "$HOME/.local/bin"
  cat >"$root/venv/bin/hermes" <<'HERMES'
#!/bin/bash
if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
  [[ ${OMARCHY_TEST_HERMES_CAPABLE:-1} == 1 ]] && echo "[--query QUERY] [--tui]"
else
  echo "hermes-agent fixture"
fi
HERMES
  chmod +x "$root/venv/bin/hermes"
  printf '#!/bin/bash\nexec "%s/venv/bin/hermes" "$@"\n' "$root" >"$HOME/.local/bin/hermes"
  chmod +x "$HOME/.local/bin/hermes"
  echo ready >"$root/.omarchy-hermes-desktop"
fi
[[ ${OMARCHY_TEST_DESKTOP_CHECK_FAIL:-0} == 0 ]] || exit 1
[[ -f $root/.omarchy-hermes-desktop || -f $root/.hermes-bootstrap-complete ]] &&
  [[ -f $HOME/.local/bin/hermes && ! -L $HOME/.local/bin/hermes ]] &&
  grep -qF "$root/" "$HOME/.local/bin/hermes"
SH

cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash
[[ $* == '-Qlq hermes-desktop' ]] || exit 1
[[ ${OMARCHY_TEST_DESKTOP_NATIVE:-1} == 1 ]] && echo '/usr/share/hermes-desktop/install.sh'
SH

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
! command -v "$1" >/dev/null 2>&1
SH

# `mise where` must fail so the installer sees no Hermes behind the stub.
#
# With OMARCHY_TEST_MISE_X_HERMES=1, `mise x -- hermes ...` emulates the Hermes
# the Omarchy stub runs, so the readiness probe can be exercised through a
# mise-installed hermes and not only the foreign and desktop wrappers. Off by
# default, so `mise x` stays silent for every test that does not opt in.
cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_MISE_LOG"
if [[ ${OMARCHY_TEST_MISE_TRACK_REMOVAL:-0} == 1 ]]; then
  if [[ $1 == "uninstall" ]]; then touch "$OMARCHY_TEST_MISE_ROOT/removed"; fi
  if [[ $1 == "where" && -f $OMARCHY_TEST_MISE_ROOT/removed ]]; then exit 1; fi
fi
if [[ $1 == "where" && ${OMARCHY_TEST_MISE_WHERE_OK:-0} == 1 ]]; then
  printf '%s\n' "$OMARCHY_TEST_MISE_ROOT"
  exit 0
fi
if [[ $1 == "x" && ${OMARCHY_TEST_MISE_X_HERMES:-0} == 1 ]]; then
  # Args are `x <tool> -- hermes <hermes-args...>`; skip to what follows hermes.
  shift
  while (( $# )) && [[ $1 != "--" ]]; do shift; done
  shift 2
  if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
    [[ ${OMARCHY_TEST_HERMES_CAPABLE:-1} == 1 ]] && echo "[-q QUERY, --query QUERY] [--tui]"
  else
    echo "hermes-agent 0.0.0-test"
  fi
  exit 0
fi
[[ $1 != "where" ]]
SH

chmod +x "$mock_bin"/*

run_installer() {
  OMARCHY_TEST_DESKTOP_INSTALLED="$1" \
    OMARCHY_TEST_MISE_WHERE_OK="${OMARCHY_TEST_MISE_WHERE_OK:-0}" \
    OMARCHY_TEST_MISE_ROOT="$test_tmp/mise" \
    OMARCHY_TEST_MISE_LOG="$mise_log" \
    HERMES_HOME="${OMARCHY_TEST_HERMES_HOME:-$test_home/.hermes}" \
    HOME="$test_home" \
    PATH="$mock_bin:$PATH" \
    bash "$ROOT/bin/omarchy-install-hermes-cli" ${2:+"$2"} >/dev/null 2>&1
}

stub_marker="# Written by omarchy-install-hermes-cli."
python_pin="3.13"
app_stub_body='#!/bin/bash
exec /home/x/.hermes/hermes-agent/venv/bin/hermes "$@"'

# Writing the stub must not provision anything: user setup calls this on every
# machine, including the ones that never run Hermes.
: >"$mise_log"
rm -f "$test_home/.local/bin/hermes"
run_installer 0 || fail "installer failed with no desktop installed"
[[ -x $test_home/.local/bin/hermes ]] || fail "installer writes a hermes stub when the desktop is absent"
grep -qxF "$stub_marker" "$test_home/.local/bin/hermes" || fail "the stub records which command wrote it"
tr '\0' ' ' <"$mise_log" | grep -q "use -g --quiet uv" &&
  fail "writing the stub does not install uv"
pass "writing the Hermes stub provisions nothing"

# Merely installing the package must not remove a working terminal install.
printf '%s\n' "#!/bin/bash" "$stub_marker" >"$test_home/.local/bin/hermes"
chmod +x "$test_home/.local/bin/hermes"
: >"$mise_log"
run_installer 1 && fail "a cold desktop is not ready"
grep -qxF "$stub_marker" "$test_home/.local/bin/hermes" || fail "cold desktop preserves the marked wrapper"
tr '\0' '\n' <"$mise_log" | grep -Eq '^(rm|uninstall)$' && fail "cold desktop removes no mise environment"
pass "a cold desktop preserves the existing CLI"

# A failed setup keeps the old CLI and its environment available for retry.
OMARCHY_TEST_DESKTOP_FAIL=1 run_installer 1 --now && fail "failed native setup reaches the caller"
grep -qxF "$stub_marker" "$test_home/.local/bin/hermes" || fail "failed setup preserves the old wrapper"
tr '\0' '\n' <"$mise_log" | grep -Eq '^(rm|uninstall)$' && fail "failed setup removes no mise environment"
pass "failed native setup preserves the old CLI"

# --now records provenance before the package replaces the wrapper, then drops
# the superseded environment only after the replacement answers both probes.
mkdir -p "$test_tmp/mise"
: >"$mise_log"
: >"$OMARCHY_TEST_DESKTOP_LOG"
OMARCHY_TEST_MISE_TRACK_REMOVAL=1 OMARCHY_TEST_MISE_WHERE_OK=1 run_installer 1 --now || fail "native takeover succeeds"
[[ -f $test_tmp/mise/removed ]] || fail "takeover removes the owned mise environment"
grep -qx -- '--install' "$OMARCHY_TEST_DESKTOP_LOG" || fail "takeover installs the native package synchronously"
[[ -x $test_home/.local/bin/hermes ]] || fail "the native replacement remains on PATH"
grep -qxF "$stub_marker" "$test_home/.local/bin/hermes" && fail "takeover actually replaced the wrapper"
pass "native takeover removes mise only after the replacement is ready"

# Without an owned wrapper, the same mise spec might be the user's own setup.
: >"$mise_log"
OMARCHY_TEST_MISE_WHERE_OK=1 run_installer 1 --now || fail "existing native install remains ready"
tr '\0' '\n' <"$mise_log" | grep -Eq '^(rm|uninstall)$' && fail "unowned mise environment was removed"
pass "native setup preserves an unowned mise environment"

OMARCHY_TEST_DESKTOP_CHECK_FAIL=1 run_installer 1 --check && fail "CLI readiness must respect the package's desktop check"
pass "a working CLI alone does not make an incomplete native desktop ready"

: >"$OMARCHY_TEST_DESKTOP_LOG"
OMARCHY_TEST_DESKTOP_NATIVE=0 run_installer 1 --check && fail "legacy package is not native-ready"
OMARCHY_TEST_DESKTOP_NATIVE=0 run_installer 1 --now && fail "legacy package must be upgraded before native setup"
[[ ! -s $OMARCHY_TEST_DESKTOP_LOG ]] || fail "unsupported flags must not reach the legacy desktop launcher"
pass "mixed versions never invoke unsupported legacy desktop flags"

OMARCHY_TEST_HERMES_HOME="$test_home/custom hermes" run_installer 1 --now || fail "native setup supports a custom data home"
[[ -f "$test_home/custom hermes/hermes-agent/.omarchy-hermes-desktop" ]] || fail "native setup uses HERMES_HOME"
OMARCHY_TEST_HERMES_HOME="$test_home/custom hermes" run_installer 1 --check || fail "readiness follows the custom data home"
pass "native setup and readiness follow HERMES_HOME"

# A package-only setup can replace the wrapper before this helper ever runs.
# Its exact receipt carries the predecessor ownership through a retry.
run_installer 1 --now || fail "the default native installation is ready for receipt checks"
receipt_dir="$test_home/.hermes/hermes-agent/.git"
receipt="$receipt_dir/omarchy-mise-predecessor"
mkdir -p "$receipt_dir"
printf '%s\n' 'pipx:hermes-agent[extras=all]' >"$receipt"
: >"$mise_log"
run_installer 1 --check || fail "readiness accepts a ready native install with pending cleanup"
[[ -f $receipt && ! -s $mise_log ]] || fail "--check must not consume ownership or remove mise"
pass "readiness leaves a pending predecessor receipt untouched"

OMARCHY_TEST_DESKTOP_CHECK_FAIL=1 run_installer 1 && fail "an incomplete desktop is not ready for cleanup"
OMARCHY_TEST_HERMES_CAPABLE=0 run_installer 1 && fail "an incapable CLI is not ready for cleanup"
[[ -f $receipt && ! -s $mise_log ]] || fail "failed readiness must retain receipt and mise"
pass "predecessor cleanup waits for both native readiness probes"

OMARCHY_TEST_MISE_WHERE_OK=1 run_installer 1 && fail "failed predecessor removal reaches the caller"
[[ -f $receipt ]] || fail "failed cleanup must retain its ownership receipt"
pass "failed predecessor cleanup retains proof for retry"

rm -f "$test_tmp/mise/removed"
: >"$mise_log"
OMARCHY_TEST_MISE_TRACK_REMOVAL=1 OMARCHY_TEST_MISE_WHERE_OK=1 run_installer 1 || fail "warm native setup retries predecessor cleanup"
[[ ! -e $receipt && -f $test_tmp/mise/removed && -x $test_home/.local/bin/hermes ]] || fail "successful cleanup consumes the receipt and preserves the native wrapper"
pass "warm native setup completes package-only predecessor cleanup"

printf '%s\n' 'pipx:hermes-agent[extras=all]' >"$receipt"
rm -f "$test_tmp/mise/removed"
OMARCHY_TEST_MISE_TRACK_REMOVAL=1 OMARCHY_TEST_MISE_WHERE_OK=1 run_installer 1 --now || fail "explicit setup consumes predecessor ownership"
[[ ! -e $receipt && -f $test_tmp/mise/removed ]] || fail "explicit setup finishes receipt cleanup"
pass "explicit setup also consumes a predecessor receipt"

printf '%s\n\n' 'pipx:hermes-agent[extras=all]' >"$receipt"
: >"$mise_log"
run_installer 1 || fail "an invalid receipt does not prevent using a ready native install"
[[ -f $receipt && ! -s $mise_log ]] || fail "a receipt must match exact bytes before cleanup"
pass "a similar receipt cannot authorize mise cleanup"

rm -f "$receipt"
printf '%s\n' 'pipx:hermes-agent[extras=all]' >"$test_tmp/foreign-receipt"
ln -s "$test_tmp/foreign-receipt" "$receipt"
run_installer 1 || fail "a symlink receipt does not prevent using native Hermes"
[[ -L $receipt && ! -s $mise_log ]] || fail "a receipt symlink cannot authorize cleanup"
rm -f "$receipt"
rmdir "$receipt_dir"
mkdir "$test_tmp/foreign-git"
printf '%s\n' 'pipx:hermes-agent[extras=all]' >"$test_tmp/foreign-git/omarchy-mise-predecessor"
ln -s "$test_tmp/foreign-git" "$receipt_dir"
run_installer 1 || fail "a symlink Git directory does not prevent using native Hermes"
[[ -L $receipt_dir && ! -s $mise_log ]] || fail "a symlink Git directory cannot authorize cleanup"
pass "receipt ownership excludes symlinks"

# Uninstall is explicit removal, so receipt ownership is sufficient even with
# the package gone. Failed cleanup must leave that proof available for retry.
rm -f "$receipt_dir"
mkdir "$receipt_dir"
printf '%s\n' 'pipx:hermes-agent[extras=all]' >"$receipt"
OMARCHY_TEST_MISE_WHERE_OK=1 run_installer 0 --remove && fail "failed uninstall reports the retained predecessor"
[[ -f $receipt && -x $test_home/.local/bin/hermes ]] || fail "failed uninstall retains receipt and native wrapper"
rm -f "$test_tmp/mise/removed"
OMARCHY_TEST_MISE_TRACK_REMOVAL=1 OMARCHY_TEST_MISE_WHERE_OK=1 run_installer 0 --remove || fail "uninstall can finish receipt cleanup without the package"
[[ ! -e $receipt && -f $test_tmp/mise/removed && -x $test_home/.local/bin/hermes ]] || fail "explicit predecessor removal consumes receipt and preserves native wrapper"
pass "explicit uninstall uses predecessor ownership and retains proof on failure"

# --check answers about Hermes being usable, not about the venv appearing. The
# venv exists from the python-deps stage, several stages before the command.
rm -rf "$test_home/.hermes"
rm -f "$test_home/.local/bin/hermes"
run_installer 1 --check && fail "--check reports Hermes missing before the app installs it"
# The venv command answers the readiness probes, as the real one does: foreign
# wrappers below exec it, and the installer runs both before trusting them.
mkdir -p "$test_home/.hermes/hermes-agent/venv/bin"
cat >"$test_home/.hermes/hermes-agent/venv/bin/hermes" <<'SH'
#!/bin/bash
if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
  [[ ${OMARCHY_TEST_HERMES_CAPABLE:-1} == 1 ]] && echo "[-q QUERY, --query QUERY] [--tui]"
else
  echo "hermes-agent 0.0.0-test"
fi
SH
chmod +x "$test_home/.hermes/hermes-agent/venv/bin/hermes"
run_installer 1 --check && fail "--check waits for the install to finish, not just the venv"
touch "$test_home/.hermes/hermes-agent/.hermes-bootstrap-complete"
printf '%s\n' "#!/bin/bash" "exec $test_home/.hermes/hermes-agent/venv/bin/hermes \"\$@\"" >"$test_home/.local/bin/hermes"
chmod +x "$test_home/.local/bin/hermes"
run_installer 1 --check || fail "--check reports Hermes present once the app has finished"
pass "--check follows the app's completed install"

# An executable called hermes that belongs to something else is not this
# install being ready.
printf '%s\n' "#!/bin/bash" "exec /usr/local/bin/somebody-elses-hermes \"\$@\"" >"$test_home/.local/bin/hermes"
chmod +x "$test_home/.local/bin/hermes"
run_installer 1 --check && fail "--check rejects a hermes command belonging to something else"
pass "--check rejects a foreign hermes command"

# A hermes the user installed themselves -- the official installer, a wrapper of
# their own -- is not ours to replace. --check follows whether it runs, and
# installing steps aside so the default agent uses it.
official_body="#!/bin/bash
unset PYTHONPATH
unset PYTHONHOME
exec $test_home/.hermes/hermes-agent/venv/bin/hermes \"\$@\""
printf '%s\n' "$official_body" >"$test_home/.local/bin/hermes"
chmod +x "$test_home/.local/bin/hermes"
run_installer 0 --check || fail "--check accepts a working foreign hermes command"
run_installer 0 || fail "installing over a foreign hermes command returns success"
run_installer 0 --now || fail "--now over a foreign hermes command returns success"
[[ $(cat "$test_home/.local/bin/hermes") == "$official_body" ]] ||
  fail "a foreign hermes command is left untouched"
pass "a foreign hermes command is preserved and satisfies --check"

OMARCHY_TEST_HERMES_CAPABLE=0 run_installer 0 --check &&
  fail "--check rejects a foreign Hermes without native prompted sessions"
OMARCHY_TEST_HERMES_CAPABLE=0 run_installer 0 &&
  fail "installing refuses a foreign Hermes without native prompted sessions"
[[ $(cat "$test_home/.local/bin/hermes") == "$official_body" ]] ||
  fail "an older foreign Hermes command is left untouched"
pass "a foreign Hermes must support native prompted sessions"

# Broken foreign paths are still foreign. They cannot be used, so --check says
# so and the installer refuses rather than replacing them.
printf '%s\n' "$official_body" >"$test_home/.local/bin/hermes"
chmod -x "$test_home/.local/bin/hermes"
run_installer 0 --check && fail "--check rejects a non-executable foreign hermes"
run_installer 0 && fail "the installer does not succeed over a non-executable foreign hermes"
[[ -f $test_home/.local/bin/hermes && ! -x $test_home/.local/bin/hermes ]] ||
  fail "a non-executable foreign hermes is left untouched"
pass "a non-executable foreign hermes is preserved"

# The executable bit is not enough: a wrapper whose interpreter is gone passes
# -x and still cannot run. The probe has to run it to find out, and finding
# out never touches the file.
broken_interp_body="#!$test_home/nowhere/python3
print('hermes')"
printf '%s\n' "$broken_interp_body" >"$test_home/.local/bin/hermes"
chmod +x "$test_home/.local/bin/hermes"
run_installer 0 --check && fail "--check rejects a foreign hermes whose interpreter is missing"
run_installer 0 && fail "the installer does not succeed over a foreign hermes whose interpreter is missing"
run_installer 0 --now && fail "--now does not succeed over a foreign hermes whose interpreter is missing"
[[ -x $test_home/.local/bin/hermes && $(cat "$test_home/.local/bin/hermes") == "$broken_interp_body" ]] ||
  fail "a foreign hermes whose interpreter is missing is left untouched"
pass "a foreign hermes with a missing interpreter is preserved and rejected"

# Likewise a wrapper that execs a target that is no longer there.
broken_target_body="#!/bin/bash
exec $test_home/nowhere/hermes \"\$@\""
printf '%s\n' "$broken_target_body" >"$test_home/.local/bin/hermes"
chmod +x "$test_home/.local/bin/hermes"
run_installer 0 --check && fail "--check rejects a foreign hermes whose target is missing"
run_installer 0 && fail "the installer does not succeed over a foreign hermes whose target is missing"
run_installer 0 --now && fail "--now does not succeed over a foreign hermes whose target is missing"
[[ -x $test_home/.local/bin/hermes && $(cat "$test_home/.local/bin/hermes") == "$broken_target_body" ]] ||
  fail "a foreign hermes whose target is missing is left untouched"
pass "a foreign hermes with a missing target is preserved and rejected"

foreign_target="$test_home/foreign/hermes"
mkdir -p "$(dirname "$foreign_target")"
printf '%s\n' "$official_body" >"$foreign_target"
chmod +x "$foreign_target"
rm -f "$test_home/.local/bin/hermes"
ln -s "$foreign_target" "$test_home/.local/bin/hermes"
run_installer 0 --check || fail "--check accepts a foreign link to a working hermes command"
run_installer 0 || fail "the installer succeeds over a foreign link to a working hermes command"
run_installer 0 --now || fail "--now succeeds over a foreign link to a working hermes command"
[[ -L $test_home/.local/bin/hermes && $(readlink "$test_home/.local/bin/hermes") == "$foreign_target" ]] ||
  fail "a foreign link to a working hermes command is left untouched"
pass "a foreign link to a working hermes command is preserved"

rm -f "$test_home/.local/bin/hermes"
ln -s "$test_home/nowhere/hermes" "$test_home/.local/bin/hermes"
run_installer 0 --check && fail "--check rejects a dangling hermes link"
run_installer 0 && fail "the installer does not succeed over a dangling hermes link"
[[ -L $test_home/.local/bin/hermes && $(readlink "$test_home/.local/bin/hermes") == "$test_home/nowhere/hermes" ]] ||
  fail "a dangling hermes link is left untouched"
pass "a dangling hermes link is preserved"

# A directory passes -x on search permission alone. It is still not a command.
rm -f "$test_home/.local/bin/hermes"
mkdir "$test_home/.local/bin/hermes"
run_installer 0 --check && fail "--check rejects a directory at the hermes path"
run_installer 0 && fail "the installer does not succeed over a directory at the hermes path"
[[ -d $test_home/.local/bin/hermes ]] || fail "a directory at the hermes path is left untouched"
pass "a directory at the hermes path is preserved and rejected"

# Mentioning the installer is not the same as being written by it.
rmdir "$test_home/.local/bin/hermes"
mentions_body="#!/bin/bash
# Replaces the stub omarchy-install-hermes-cli used to write.
exec $test_home/.hermes/hermes-agent/venv/bin/hermes \"\$@\""
printf '%s\n' "$mentions_body" >"$test_home/.local/bin/hermes"
chmod +x "$test_home/.local/bin/hermes"
run_installer 0 || fail "installing over a wrapper that mentions the installer returns success"
[[ $(cat "$test_home/.local/bin/hermes") == "$mentions_body" ]] ||
  fail "a wrapper that merely mentions the installer is left untouched"
pass "ownership needs the exact marker line, not a mention"

# Our own stub is ours to rewrite, so reinstalling refreshes it to the current
# template.
rm -f "$test_home/.local/bin/hermes"
printf '%s\n' "#!/bin/bash" "$stub_marker" "# stale template" >"$test_home/.local/bin/hermes"
chmod +x "$test_home/.local/bin/hermes"
run_installer 0 || fail "reinstalling over our own stub succeeds"
grep -qxF "$stub_marker" "$test_home/.local/bin/hermes" || fail "the refreshed stub still carries the marker"
grep -q "stale template" "$test_home/.local/bin/hermes" && fail "reinstalling rewrites our own stub"
grep -q "exec env -u UV_PYTHON mise x" "$test_home/.local/bin/hermes" || fail "the refreshed stub is the current template"
pass "reinstalling refreshes the Omarchy stub"

mkdir -p "$test_tmp/mise/hermes-agent/lib/python$python_pin"
: >"$mise_log"
OMARCHY_TEST_MISE_WHERE_OK=1 run_installer 0 || fail "reinstalling replaces an older owned Hermes environment"
tr '\0' '\n' <"$mise_log" | grep -q '^rm$' || fail "an older owned Hermes environment is removed from mise config"
tr '\0' '\n' <"$mise_log" | grep -q '^uninstall$' || fail "an older owned Hermes environment is uninstalled"
pass "reinstalling replaces an older owned Hermes environment"

# The mise-installed path is what a machine without the desktop app runs, and
# --check gates the default agent there too. The stub is present and its mise
# environment resolves, so readiness turns on the hermes mise runs -- exercised
# here in both directions, since the desktop and foreign cases cover only their
# own wrappers.
run_mise_check() {
  OMARCHY_TEST_DESKTOP_INSTALLED=0 \
    OMARCHY_TEST_MISE_WHERE_OK=1 \
    OMARCHY_TEST_MISE_ROOT="$test_tmp/mise" \
    OMARCHY_TEST_MISE_LOG="$mise_log" \
    OMARCHY_TEST_MISE_X_HERMES=1 \
    OMARCHY_TEST_HERMES_CAPABLE="$1" \
    HERMES_HOME="${OMARCHY_TEST_HERMES_HOME:-$test_home/.hermes}" \
    HOME="$test_home" \
    PATH="$mock_bin:$PATH" \
    bash "$ROOT/bin/omarchy-install-hermes-cli" --check >/dev/null 2>&1
}
run_mise_check 1 || fail "--check accepts a mise-installed hermes that runs the seeded session"
run_mise_check 0 && fail "--check rejects a mise-installed hermes without the flags omarchy-agent passes"
pass "--check follows the mise-installed hermes it would actually run"

rm -f "$test_home/.local/bin/hermes"
: >"$mise_log"
OMARCHY_TEST_MISE_WHERE_OK=1 run_installer 0 &&
  fail "installing refuses to claim an unmarked Hermes mise environment"
tr '\0' '\n' <"$mise_log" | grep -Eq '^(rm|uninstall)$' &&
  fail "an unmarked Hermes mise environment is never removed"
[[ ! -e $test_home/.local/bin/hermes ]] ||
  fail "an unmarked Hermes mise environment is not given an Omarchy wrapper"
pass "a Hermes mise environment needs wrapper ownership before replacement"

# install/user/mise.sh is sourced by install/user/all.sh through run_logged,
# which runs it under `bash -eE` and hands its exit code back to
# omarchy-provision-user's `set -euo pipefail`. Everything that finalizes a user
# -- the default browser, the mailto handler, the first-install migration
# markers, the finalize-user marker -- runs after that source, so this leaf
# returning non-zero costs the user all of it. The Hermes installer is the only
# line in it that can fail, and it does exactly that whenever hermes-desktop is
# installed but the app has not been launched yet: the case a second user on a
# shared machine hits on their first login.
mise_sh_home="$test_tmp/mise-sh-home"
mkdir -p "$mise_sh_home/.local/bin"

cat >"$mock_bin/omarchy-mise-install" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin/omarchy-mise-install"

# Desktop installed, nothing bootstrapped: omarchy-install-hermes-cli exits 1.
OMARCHY_TEST_DESKTOP_INSTALLED=1 \
  OMARCHY_TEST_MISE_LOG="$mise_log" \
  HOME="$mise_sh_home" \
  PATH="$mock_bin:$ROOT/bin:$PATH" \
  bash "$ROOT/bin/omarchy-install-hermes-cli" >/dev/null 2>&1 &&
  fail "the Hermes installer exits non-zero when the desktop app has not set Hermes up"

# Sourced exactly as run_logged does it.
OMARCHY_TEST_DESKTOP_INSTALLED=1 \
  OMARCHY_TEST_MISE_LOG="$mise_log" \
  HOME="$mise_sh_home" \
  PATH="$mock_bin:$ROOT/bin:$PATH" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/user/mise.sh" >/dev/null 2>&1 ||
  fail "user setup survives a Hermes install that cannot finish"
pass "user setup survives a Hermes install that cannot finish"

# UV_PYTHON pins the interpreter Hermes is built against. Left in the
# environment it reaches Hermes itself and every command the agent shells out
# to, so a `uv` run in the user's own project resolves 3.13 there as well --
# uv only warns that this contradicts the project's requires-python, then
# builds the venv anyway. The stub drops it before handing over.
leak_home="$test_tmp/leak-home"
leak_bin="$test_tmp/leak-bin"
leak_log="$test_tmp/leak-log"
leak_prefix="$test_tmp/leak-prefix"
mkdir -p "$leak_home/.local/bin" "$leak_bin" "$leak_prefix/hermes-agent/lib/python$python_pin"

# A mise whose `where` satisfies the stub's probe, so the stub goes straight to
# handing over, and whose `x` records the UV_PYTHON it was handed.
cat >"$leak_bin/mise" <<SH
#!/bin/bash
case \$1 in
  where) echo "$leak_prefix" ;;
  x) printf '%s' "\${UV_PYTHON-}" >"$leak_log" ;;
esac
SH
chmod +x "$leak_bin/mise"

OMARCHY_TEST_DESKTOP_INSTALLED=0 \
  OMARCHY_TEST_MISE_LOG="$mise_log" \
  HOME="$leak_home" \
  PATH="$mock_bin:$PATH" \
  bash "$ROOT/bin/omarchy-install-hermes-cli" >/dev/null 2>&1 ||
  fail "the installer writes a stub for the leak check"

HOME="$leak_home" PATH="$leak_bin:$mock_bin:$PATH" \
  "$leak_home/.local/bin/hermes" --version >/dev/null 2>&1

[[ -f $leak_log ]] || fail "the stub reaches the command it wraps"
[[ -z $(cat "$leak_log") ]] ||
  fail "the interpreter pin does not follow Hermes into the commands it runs"
pass "the interpreter pin does not follow Hermes into the commands it runs"

# --owns is the one answer to whether the wrapper on PATH is this installer's.
# Remove Preinstalls and the migration both ask it rather than carrying their
# own copy of the marker, so a change to what ownership means reaches them.
owns_home="$test_tmp/owns-home"
mkdir -p "$owns_home/.local/bin"

run_owns() {
  OMARCHY_TEST_DESKTOP_INSTALLED=0 \
    OMARCHY_TEST_MISE_LOG="$mise_log" \
    HOME="$owns_home" \
    PATH="$mock_bin:$PATH" \
    bash "$ROOT/bin/omarchy-install-hermes-cli" --owns
}

rm -f "$owns_home/.local/bin/hermes"
run_owns && fail "--owns says no when there is no wrapper at all"

printf '%s\n' "#!/bin/bash" "$stub_marker" >"$owns_home/.local/bin/hermes"
chmod +x "$owns_home/.local/bin/hermes"
run_owns || fail "--owns recognises the stub this installer wrote"

printf '%s\n' "#!/bin/bash" "# Replaces the stub omarchy-install-hermes-cli used to write." \
  >"$owns_home/.local/bin/hermes"
run_owns && fail "--owns needs the exact marker line, not a mention"

# Quoting the marker inside a longer line is not the same as carrying it: the
# match is whole-line, so a wrapper describing what it replaced stays the
# user's.
printf '%s\n' "#!/bin/bash" "# Replaced '$stub_marker' with my own." \
  >"$owns_home/.local/bin/hermes"
run_owns && fail "--owns needs the marker to be the whole line, not part of one"

rm -f "$owns_home/.local/bin/hermes"
ln -s "$test_home/.local/bin/hermes" "$owns_home/.local/bin/hermes"
run_owns && fail "--owns disclaims a symlink, whatever it resolves to"
rm -f "$owns_home/.local/bin/hermes"
pass "--owns answers for the wrapper this installer wrote and nothing else"

# The marker lives in exactly one place. Every other caller asks --owns, so a
# second copy is drift waiting to happen.
marker_copies=$(grep -rl "Written by omarchy-install-hermes-cli" \
  "$ROOT/bin" "$ROOT/install" "$ROOT/migrations" 2>/dev/null | wc -l)
(( marker_copies == 1 )) ||
  fail "only omarchy-install-hermes-cli spells out the ownership marker"
pass "the ownership marker is written down once"

# --remove tears down a Hermes CLI this installer owns, so Remove Hermes can
# clear one the desktop app never superseded. It turns on the same ownership as
# the rest of the file, so its cases mirror that split.
remove_home="$test_tmp/remove-home"
mkdir -p "$remove_home/.local/bin"

run_remove() {
  OMARCHY_TEST_DESKTOP_INSTALLED=0 \
    OMARCHY_TEST_MISE_WHERE_OK="${OMARCHY_TEST_MISE_WHERE_OK:-0}" \
    OMARCHY_TEST_MISE_ROOT="$test_tmp/mise" \
    OMARCHY_TEST_MISE_LOG="$mise_log" \
    HOME="$remove_home" \
    PATH="$mock_bin:$PATH" \
    bash "$ROOT/bin/omarchy-install-hermes-cli" --remove
}

rm -f "$remove_home/.local/bin/hermes"
: >"$mise_log"
run_remove || fail "--remove succeeds when there is nothing to remove"
# No stub means no proof the mise environment -- if one even exists -- is
# Omarchy's, so nothing may reach mise at all.
tr '\0' '\n' <"$mise_log" | grep -Eq '^(rm|uninstall)$' &&
  fail "--remove leaves mise alone when nothing proves ownership"
pass "--remove is idempotent when no Hermes CLI is present"

printf '%s\n' "#!/bin/bash" "$stub_marker" >"$remove_home/.local/bin/hermes"
chmod +x "$remove_home/.local/bin/hermes"
: >"$mise_log"
run_remove || fail "--remove succeeds tearing down an owned CLI"
tr '\0' '\n' <"$mise_log" | grep -q '^rm$' || fail "--remove drops the mise tool from config"
tr '\0' '\n' <"$mise_log" | grep -q '^uninstall$' || fail "--remove uninstalls the mise tool"
[[ ! -e $remove_home/.local/bin/hermes ]] || fail "--remove takes the stub it owns"
pass "--remove tears down the mise CLI and the stub this installer owns"

# When mise still resolves the tool after the teardown, the environment
# survived whatever uninstall claimed, and --remove has to say so.
printf '%s\n' "#!/bin/bash" "$stub_marker" >"$remove_home/.local/bin/hermes"
chmod +x "$remove_home/.local/bin/hermes"
OMARCHY_TEST_MISE_WHERE_OK=1 run_remove && fail "--remove claims success while mise still resolves the tool"
pass "--remove fails when the mise environment survives the teardown"

foreign_remove_body="#!/bin/bash
exec /usr/local/bin/my-own-hermes \"\$@\""
printf '%s\n' "$foreign_remove_body" >"$remove_home/.local/bin/hermes"
chmod +x "$remove_home/.local/bin/hermes"
: >"$mise_log"
OMARCHY_TEST_MISE_WHERE_OK=1 run_remove || fail "--remove succeeds with a foreign hermes present"
[[ -f $remove_home/.local/bin/hermes && $(cat "$remove_home/.local/bin/hermes") == "$foreign_remove_body" ]] ||
  fail "--remove leaves a hermes it does not own untouched"
# The wrapper may front a mise environment the user built against the very same
# spec; without the marker there is no telling, so the environment stays too.
tr '\0' '\n' <"$mise_log" | grep -Eq '^(rm|uninstall)$' &&
  fail "--remove never removes a mise environment it cannot prove is Omarchy's"
pass "--remove leaves a Hermes the user installed themselves"

# Judged by what is left, not by what rm claimed: a stub that survives the
# teardown is a CLI still installed, and --remove has to say so.
printf '%s\n' "#!/bin/bash" "$stub_marker" >"$remove_home/.local/bin/hermes"
chmod +x "$remove_home/.local/bin/hermes"
chmod 555 "$remove_home/.local/bin"
run_remove && fail "--remove claims success while the stub survives"
chmod 755 "$remove_home/.local/bin"
rm -f "$remove_home/.local/bin/hermes"
pass "--remove fails when the stub cannot be removed"

# The app's marker says its install once landed, not that it is still there. A
# wrapper whose runtime has since gone answers for nothing, so readiness runs
# the command, exactly as it does for a hermes the user installed themselves.
ready_home="$test_tmp/ready-home"
mkdir -p "$ready_home/.hermes/hermes-agent/venv/bin" "$ready_home/.local/bin"
touch "$ready_home/.hermes/hermes-agent/.hermes-bootstrap-complete"
printf '%s\n' "#!/bin/bash" "exec $ready_home/.hermes/hermes-agent/venv/bin/hermes \"\$@\"" \
  >"$ready_home/.local/bin/hermes"
chmod +x "$ready_home/.local/bin/hermes"

run_ready_check() {
  OMARCHY_TEST_DESKTOP_INSTALLED=1 \
    OMARCHY_TEST_MISE_LOG="$mise_log" \
    HOME="$ready_home" \
    PATH="$mock_bin:$PATH" \
    bash "$ROOT/bin/omarchy-install-hermes-cli" --check >/dev/null 2>&1
}

run_ready_check && fail "--check rejects the app's wrapper when its runtime is gone"

cat >"$ready_home/.hermes/hermes-agent/venv/bin/hermes" <<'SH'
#!/bin/bash
if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
  echo "[-q QUERY, --query QUERY] [--tui]"
else
  echo "hermes-agent 0.0.0-test"
fi
SH
chmod +x "$ready_home/.hermes/hermes-agent/venv/bin/hermes"
run_ready_check || fail "--check accepts the app's wrapper once it runs"
pass "readiness runs the app's command rather than trusting its marker"

# A release whose help lists only the old probe's --oneshot marker cannot run
# the seeded --tui --query session omarchy-agent starts, so it is not ready.
cat >"$ready_home/.hermes/hermes-agent/venv/bin/hermes" <<'SH'
#!/bin/bash
if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
  echo "--oneshot"
else
  echo "hermes-agent 0.0.0-test"
fi
SH
chmod +x "$ready_home/.hermes/hermes-agent/venv/bin/hermes"
run_ready_check && fail "--check accepts a release without the flags omarchy-agent passes"
pass "a release listing only --oneshot is not prompt-ready"

# A release that lists --tui-theme and --query-log but has dropped the bare
# --tui/--query omarchy-agent passes must not read as ready on the substring
# alone. The probe matches at a flag boundary for exactly this case.
cat >"$ready_home/.hermes/hermes-agent/venv/bin/hermes" <<'SH'
#!/bin/bash
if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
  echo "[--tui-theme THEME] [--query-log FILE]"
else
  echo "hermes-agent 0.0.0-test"
fi
SH
chmod +x "$ready_home/.hermes/hermes-agent/venv/bin/hermes"
run_ready_check && fail "--check accepts a release whose flags only contain --tui/--query as a substring"
pass "a flag that merely contains --tui or --query is not prompt-ready"

# Each flag answers for itself: a release that kept --tui but dropped --query,
# or the reverse, cannot run the seeded session either, so neither grep may
# ride on the other's match.
for kept in '--tui' '-q QUERY, --query QUERY'; do
  cat >"$ready_home/.hermes/hermes-agent/venv/bin/hermes" <<SH
#!/bin/bash
if [[ \${1:-} == "chat" && \${2:-} == "--help" ]]; then
  echo "[$kept]"
else
  echo "hermes-agent 0.0.0-test"
fi
SH
  chmod +x "$ready_home/.hermes/hermes-agent/venv/bin/hermes"
  run_ready_check && fail "--check accepts a release listing only $kept"
done
pass "either flag alone is not prompt-ready"

# An underscore continues a flag name just as a dash does: --tui_mode is not
# --tui.
cat >"$ready_home/.hermes/hermes-agent/venv/bin/hermes" <<'SH'
#!/bin/bash
if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
  echo "[--tui_mode MODE] [--query_log FILE]"
else
  echo "hermes-agent 0.0.0-test"
fi
SH
chmod +x "$ready_home/.hermes/hermes-agent/venv/bin/hermes"
run_ready_check && fail "--check accepts flags that extend --tui/--query with an underscore"
pass "an underscore continuation is not the bare flag"

# A flag mentioned in another option's help text is not that option. Hermes
# already writes "With --tui:" into --dev's description, so prose has to stay
# prose even when both names appear in it.
cat >"$ready_home/.hermes/hermes-agent/venv/bin/hermes" <<'SH'
#!/bin/bash
if [[ ${1:-} == "chat" && ${2:-} == "--help" ]]; then
  echo "  --dev                 With --tui: run sources via tsx"
  echo "  --log FILE            Where --query output lands"
else
  echo "hermes-agent 0.0.0-test"
fi
SH
chmod +x "$ready_home/.hermes/hermes-agent/venv/bin/hermes"
run_ready_check && fail "--check accepts flags that appear only in option descriptions"
pass "a flag mentioned in prose is not a defined option"
