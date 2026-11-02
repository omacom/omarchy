#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
adding=""
cleanup() {
  if [[ -n $adding ]]; then
    if [[ -f $case_home/adding.pid ]]; then
      kill -TERM "$(cat "$case_home/adding.pid")" 2>/dev/null || true
    else
      kill -TERM "$adding" 2>/dev/null || true
    fi
    wait "$adding" 2>/dev/null || true
  fi
  rm -rf "$test_tmp"
}
trap cleanup EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/real"
cat >"$test_tmp/bin/mise" <<'STUB'
#!/bin/bash
case "$1" in
  which)
    [[ ${OMARCHY_TEST_RESOLVE_FAIL:-0} == 0 ]] || exit 1
    if [[ -f $HOME/installed ]]; then
      printf '%s\n' "$OMARCHY_TEST_REAL_CLI"
    elif [[ -n ${OMARCHY_TEST_LAUNCHER:-} ]]; then
      printf '%s\n' "$OMARCHY_TEST_LAUNCHER"
    else
      exit 1
    fi
    ;;
  use)
    [[ ! -e $HOME/install-started ]] || exit 90
    [[ ${MISE_MINIMUM_RELEASE_AGE:-} == 0 ]] || exit 91
    echo $$ >"$HOME/install-started"
    [[ ${OMARCHY_TEST_INSTALL_FAIL:-0} == 0 ]] || exit 1
    read -r release <"$HOME/release"
    touch "$HOME/installed"
    ;;
  *) exit 92 ;;
esac
STUB

cat >"$test_tmp/real/grok" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$HOME/login-args"
touch "$HOME/signed-in"
echo 'https://auth.x.ai/oauth/authorize'
STUB

cat >"$test_tmp/bin/omarchy-agent-account-state" <<'STUB'
#!/bin/bash
case "$1" in
  list)
    signed=false
    [[ ! -f $HOME/signed-in ]] || signed=true
    printf '[{"accounts":[{"primary":true,"signedIn":%s}]}]\n' "$signed"
    ;;
esac
STUB

for helper in omarchy-agent-usage-update omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/$helper"
done
printf '#!/bin/bash\necho claude\n' >"$test_tmp/bin/omarchy-default-agent"
chmod +x "$test_tmp/bin/"* "$test_tmp/real/grok"

run_isolated() {
  env -i HOME="$case_home" XDG_RUNTIME_DIR="$case_home" \
    OMARCHY_PATH="$ROOT" PATH="$case_home/.local/bin:$test_tmp/bin:$ROOT/bin:/usr/bin" \
    OMARCHY_TEST_REAL_CLI="$test_tmp/real/grok" \
    "$@"
}

start_case() {
  case_home="$test_tmp/$1"
  mkdir -p "$case_home/.local/bin"
  mkfifo "$case_home/release"
}

start_add() {
  run_isolated bash -c 'echo $$ >"$HOME/adding.pid"; exec "$@"' bash "$@" >"$case_home/output" 2>&1 &
  adding=$!
}

wait_for_install() {
  for _ in {1..100}; do
    [[ ! -s $case_home/install-started ]] || return 0
    sleep 0.02
  done
  fail "installer starts" "$(cat "$case_home/output")"
}

assert_preparing() {
  grep -Fxq '@@omarchy status Preparing Grok… Waiting for its download or update to finish.' "$case_home/output" ||
    fail "download wait is visible before the installer finishes" "$(cat "$case_home/output")"
  if grep -q 'browser window' "$case_home/output" || [[ -e $case_home/login-args ]]; then
    fail "browser instruction and login wait for installation"
  fi
}

# Exercise the actual first-run launcher, a native mise dispatcher that
# resolves to that launcher, and a dispatcher with no CLI installed yet.
for route in launcher dispatcher missing absent; do
  start_case "$route"
  extra_env=()
  if [[ $route == launcher || $route == dispatcher ]]; then
    run_isolated omarchy-mise-install grok
    if [[ $route == dispatcher ]]; then
      mv "$case_home/.local/bin/grok" "$case_home/launcher"
      ln -s "$test_tmp/bin/mise" "$case_home/.local/bin/grok"
      extra_env=(OMARCHY_TEST_LAUNCHER="$case_home/launcher")
    fi
  elif [[ $route == missing ]]; then
    ln -s "$test_tmp/bin/mise" "$case_home/.local/bin/grok"
  fi
  start_add env "${extra_env[@]}" omarchy-agent-account-add --events grok
  wait_for_install
  assert_preparing
  echo ready >"$case_home/release"
  wait "$adding" || fail "$route completes after installation" "$(cat "$case_home/output")"
  adding=""
  [[ $(cat "$case_home/login-args") == login ]] || fail "$route runs Grok login"
  grep -q '^@@omarchy done Signed in to Grok.' "$case_home/output" || fail "$route finishes signing in"
  pass "$route shows preparation until installation finishes, then logs in without a second install"
done

start_case installed
ln -s "$test_tmp/bin/mise" "$case_home/.local/bin/grok"
touch "$case_home/installed"
run_isolated omarchy-agent-account-add --events --reauth :primary grok >"$case_home/output"
[[ ! -f $case_home/install-started && -f $case_home/login-args ]] || fail "an installed CLI signs in without installation"
pass "an installed mise CLI can reauthenticate without installation"

start_case failure
run_isolated omarchy-mise-install grok
if run_isolated env OMARCHY_TEST_INSTALL_FAIL=1 omarchy-agent-account-add --events grok >"$case_home/output" 2>&1; then
  fail "installation failure stops sign-in"
fi
assert_preparing
grep -q '^@@omarchy error Installing the Grok CLI' "$case_home/output" || fail "installation failure has an actionable error"
pass "installation failure reports an error without promising a browser"

# A dispatcher can fall through to a CLI installed outside mise.
start_case native
ln -s "$test_tmp/bin/mise" "$case_home/.local/bin/grok"
ln -s "$test_tmp/real/grok" "$test_tmp/bin/grok"
run_isolated omarchy-agent-account-add --events grok >"$case_home/output"
rm "$test_tmp/bin/grok"
[[ ! -f $case_home/install-started && -f $case_home/login-args ]] || fail "a native CLI behind the dispatcher needs no installation"
pass "a native CLI behind the dispatcher signs in directly"

# New keys fall back to English until translation sync; existing sign-in
# and failure messages must still use the selected language.
start_case localized
mkdir -p "$case_home/.config/omarchy"
echo da >"$case_home/.config/omarchy/language"
run_isolated omarchy-mise-install grok
start_add omarchy-agent-account-add --events grok
wait_for_install
assert_preparing
echo ready >"$case_home/release"
wait "$adding" || fail "localized sign-in completes" "$(cat "$case_home/output")"
adding=""
expected=$(run_isolated omarchy-i18n agents.signInBrowser Grok)
[[ $expected != 'Sign in to Grok in the browser window that opens.' ]] || fail "the fixture uses a translated browser instruction"
grep -Fxq "@@omarchy status $expected" "$case_home/output" || fail "browser instructions keep their translation"
pass "preparation falls back to English and browser instructions remain localized"

start_case localized-failure
mkdir -p "$case_home/.config/omarchy"
echo da >"$case_home/.config/omarchy/language"
run_isolated omarchy-mise-install grok
if run_isolated env OMARCHY_TEST_INSTALL_FAIL=1 omarchy-agent-account-add --events grok >"$case_home/output" 2>&1; then
  fail "localized installation failure stops sign-in"
fi
assert_preparing
expected=$(run_isolated omarchy-i18n agents.installCliFailed Grok)
grep -Fxq "@@omarchy error $expected" "$case_home/output" || fail "installation errors keep their translation"
pass "installation failure remains localized"

start_case unresolved
run_isolated omarchy-mise-install grok
start_add env OMARCHY_TEST_RESOLVE_FAIL=1 omarchy-agent-account-add --events grok
wait_for_install
echo ready >"$case_home/release"
if wait "$adding"; then
  fail "failed CLI resolution stops sign-in"
fi
adding=""
assert_preparing
grep -Fxq "@@omarchy error Couldn't find the installed Grok CLI." "$case_home/output" || fail "resolution failure reports the catalog error"
pass "failed resolution never promises a browser or starts login"

start_case cancel
run_isolated omarchy-mise-install grok
start_add omarchy-agent-account-add --events grok
wait_for_install
installer=$(cat "$case_home/install-started")
kill -TERM "$(cat "$case_home/adding.pid")"
wait "$adding" || true
adding=""
for _ in {1..100}; do
  kill -0 "$installer" 2>/dev/null || break
  sleep 0.02
done
if kill -0 "$installer" 2>/dev/null; then
  kill -TERM "$installer"
  fail "cancel stops the installer"
fi
assert_preparing
pass "cancel stops an installer waiting for a download or lock"
