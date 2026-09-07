#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home"
ln -s "$ROOT/bin/omarchy-cmd-hermes-home" "$test_tmp/bin/omarchy-cmd-hermes-home"
ln -s "$ROOT/bin/omarchy-install-hermes-cli" "$test_tmp/bin/omarchy-install-hermes-cli"

cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
echo "package $*" >>"$OMARCHY_TEST_LOG"
exit "${OMARCHY_TEST_PACKAGE_STATUS:-0}"
SH
cat >"$test_tmp/bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == "hermes-desktop" ]]
SH
cat >"$test_tmp/bin/pacman" <<'SH'
#!/bin/bash
[[ $* == "-Qlq hermes-desktop" ]] || exit 2
echo "package-check" >>"$OMARCHY_TEST_LOG"
if [[ ${OMARCHY_TEST_NATIVE_PACKAGE:-1} == 1 ]]; then
  echo '/usr/share/hermes-desktop/install.sh'
  if [[ ${OMARCHY_TEST_DESKTOP_SEED:-1} == 1 ]]; then
    echo '/usr/share/hermes-desktop/seed/.git/config'
  fi
  if [[ ${OMARCHY_TEST_LARGE_PACKAGE:-0} == 1 ]]; then
    printf '/usr/share/hermes-desktop/seed/file-%s\n' {1..10000}
  fi
fi
SH
cat >"$test_tmp/bin/hermes-desktop" <<'SH'
#!/bin/bash
echo "unexpected-desktop $*" >>"$OMARCHY_TEST_LOG"
exit 42
SH
cat >"$test_tmp/bin/mise" <<'SH'
#!/bin/bash
echo "unexpected-mise $*" >>"$OMARCHY_TEST_LOG"
exit 42
SH
cat >"$test_tmp/bin/setsid" <<'SH'
#!/bin/bash
echo "launch $*" >>"$OMARCHY_TEST_LOG"
printf '%s\n' "$HERMES_HOME" >>"$OMARCHY_TEST_HOME_LOG"
SH
cat >"$test_tmp/bin/systemd-run" <<'SH'
#!/bin/bash
echo "theme $*" >>"$OMARCHY_TEST_LOG"
SH
cat >"$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$test_tmp/bin/"*

run_install() {
  HOME="$test_tmp/home" HERMES_HOME="${OMARCHY_TEST_HERMES_HOME:-$test_tmp/home/custom hermes}" \
    PATH="$test_tmp/bin:$PATH" OMARCHY_TEST_LOG="$test_tmp/log" \
    OMARCHY_TEST_HOME_LOG="$test_tmp/home-log" \
    OMARCHY_TEST_PACKAGE_STATUS="$1" \
    bash "$ROOT/bin/omarchy-install-ai-hermes" >"$test_tmp/output" 2>&1
}

: >"$test_tmp/log"
run_install 42 && fail "package failure must fail the desktop installation"
[[ $(cat "$test_tmp/log") == "package hermes-desktop" ]] || fail "failed package installation must stop before checking or launching"
grep -q 'has been installed' "$test_tmp/output" && fail "failed package installation must not announce success"
pass "desktop install reports package failure before launching"

: >"$test_tmp/log"
OMARCHY_TEST_NATIVE_PACKAGE=0 run_install 0 && fail "legacy package must be upgraded before launch"
[[ $(cat "$test_tmp/log") == $'package hermes-desktop\npackage-check' ]] || fail "legacy package must not receive flags, launch or schedule the theme"
grep -q 'update the hermes-desktop package' "$test_tmp/output" || fail "legacy package failure explains the required update"
grep -q 'has been installed' "$test_tmp/output" && fail "legacy package must not announce successful setup"
pass "desktop install rejects legacy packages without executing their launcher"

: >"$test_tmp/log"
run_install 0 || fail "a cold native runtime can launch the desktop"
[[ $(head -2 "$test_tmp/log") == $'package hermes-desktop\npackage-check' ]] || fail "package installation and compatibility check finish before launch"
# The launch is deliberately detached; wait only for our logging fixture.
for attempt in {1..20}; do
  if grep -q '^launch ' "$test_tmp/log"; then break; fi
  sleep 0.01
done
grep -qxF 'launch uwsm-app -- /usr/bin/hermes-desktop' "$test_tmp/log" || fail "cold installation launches the package desktop entry point"
grep -q '^unexpected-' "$test_tmp/log" && fail "the menu must not run native setup, readiness checks or mise"
[[ ! -e "$test_tmp/home/custom hermes/hermes-agent" && ! -e $test_tmp/home/.local/bin/hermes ]] || fail "native setup remains inside the desktop"
grep -qF -- "--setenv=HERMES_HOME=$test_tmp/home/custom hermes" "$test_tmp/log" || fail "theme handoff follows a custom Hermes home"
grep -qF 'installs Hermes inside the app' "$test_tmp/output" || fail "the menu explains that Hermes setup continues inside the app"
grep -qF 'hermes update' "$test_tmp/output" || fail "installation describes native CLI updates"
pass "desktop installation launches the app before native setup and follows its data home"

for root in "$test_tmp/home/.hermes" "$test_tmp/home/custom hermes"; do
  : >"$test_tmp/log"
  : >"$test_tmp/home-log"
  OMARCHY_TEST_HERMES_HOME="$root/profiles/coder/" run_install 0 || fail "profile install succeeds"
  for attempt in {1..20}; do
    if [[ $(wc -l <"$test_tmp/home-log") == 1 ]]; then break; fi
    sleep 0.01
  done
  [[ $(cat "$test_tmp/home-log") == "$root" ]] || fail "the app receives the shared home"
  grep -qF -- "--setenv=HERMES_HOME=$root omarchy-theme-set-hermes" "$test_tmp/log" || fail "theme unit receives the shared home"
done
pass "profile installation hands the shared default or custom home to the app and theme"
