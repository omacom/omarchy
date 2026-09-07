#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home"
ln -s "$ROOT/bin/omarchy-cmd-hermes-home" "$test_tmp/bin/omarchy-cmd-hermes-home"

cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
echo "package $*" >>"$OMARCHY_TEST_LOG"
SH
cat >"$test_tmp/bin/omarchy-install-hermes-cli" <<'SH'
#!/bin/bash
echo "setup $*" >>"$OMARCHY_TEST_LOG"
printf '%s\n' "$HERMES_HOME" >>"$OMARCHY_TEST_HOME_LOG"
[[ $1 == "--now" ]] || exit 2
exit "${OMARCHY_TEST_SETUP_STATUS:-0}"
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
    OMARCHY_TEST_SETUP_STATUS="$1" \
    bash "$ROOT/bin/omarchy-install-ai-hermes" >"$test_tmp/output" 2>&1
}

: >"$test_tmp/log"
run_install 42 && fail "native setup failure must fail the desktop installation"
grep -q '^launch\|^theme' "$test_tmp/log" && fail "failed setup must not launch or schedule the theme"
grep -q 'has been installed' "$test_tmp/output" && fail "failed setup must not announce success"
pass "desktop install reports native setup failure before launching"

: >"$test_tmp/log"
run_install 0 || fail "completed native setup succeeds"
[[ $(head -2 "$test_tmp/log") == $'package hermes-desktop\nsetup --now' ]] || fail "package and native setup finish in order"
# The launch is deliberately detached; wait only for our logging fixture.
for attempt in {1..20}; do
  if grep -q '^launch ' "$test_tmp/log"; then break; fi
  sleep 0.01
done
grep -qxF 'launch uwsm-app -- /usr/bin/hermes-desktop' "$test_tmp/log" || fail "completed setup launches the package entry point"
grep -qF -- "--setenv=HERMES_HOME=$test_tmp/home/custom hermes" "$test_tmp/log" || fail "theme handoff follows a custom Hermes home"
grep -qF 'hermes update' "$test_tmp/output" || fail "completed setup describes native CLI updates"
pass "desktop install waits for native setup before launch and follows its data home"

for root in "$test_tmp/home/.hermes" "$test_tmp/home/custom hermes"; do
  : >"$test_tmp/log"
  : >"$test_tmp/home-log"
  OMARCHY_TEST_HERMES_HOME="$root/profiles/coder/" run_install 0 || fail "profile install succeeds"
  for attempt in {1..20}; do
    if [[ $(wc -l <"$test_tmp/home-log") == 2 ]]; then break; fi
    sleep 0.01
  done
  [[ $(cat "$test_tmp/home-log") == "$root"$'\n'"$root" ]] || fail "setup and app receive the shared home"
  grep -qF -- "--setenv=HERMES_HOME=$root omarchy-theme-set-hermes" "$test_tmp/log" || fail "theme unit receives the shared home"
done
pass "profile installation hands the shared default or custom home to setup, app and theme"
