#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home" "$test_tmp/home/.hermes/profiles/james"

for command in xdg-user-dirs-update xdg-mime brave-origin; do
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$command"
done
cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
[[ -z ${BROWSER:-} ]] || exit 1
printf '%s\n' "$*" >>"$OMARCHY_TEST_BROWSER_LOG"
SH
chmod +x "$mock_bin"/*

# Provisioning prepends $OMARCHY_PATH/bin, which shadows a mock for anything
# Omarchy ships, so the install suite is stubbed out at its path instead. The
# real one rethemes the session it runs in: hyprctl reload against the live
# compositor, gsettings against the live desktop, and a global Node install.
mkdir -p "$test_tmp/install/user"
: >"$test_tmp/install/user/all.sh"

HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  BROWSER=omarchy-launch-browser OMARCHY_TEST_BROWSER_LOG="$test_tmp/browser-log" \
  OMARCHY_INSTALL="$test_tmp/install" bash "$ROOT/bin/omarchy-provision-user" >/dev/null ||
  fail "omarchy-provision-user finishes"

grep -Fxq 'set default-web-browser brave-origin.desktop' "$test_tmp/browser-log" ||
  fail "user finalization selects Brave Origin with BROWSER unset"
pass "user finalization selects Brave Origin with BROWSER unset"

: >"$test_tmp/browser-log"
HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_TEST_BROWSER_LOG="$test_tmp/browser-log" OMARCHY_INSTALL="$test_tmp/install" \
  bash "$ROOT/bin/omarchy-provision-user" >/dev/null
[[ ! -s $test_tmp/browser-log ]] || fail "repeated finalization preserves the user's browser choice"
pass "repeated finalization preserves the user's browser choice"

rm "$mock_bin/brave-origin"
: >"$test_tmp/browser-log"
HOME="$test_tmp/legacy-home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_TEST_BROWSER_LOG="$test_tmp/browser-log" OMARCHY_INSTALL="$test_tmp/install" \
  bash "$ROOT/bin/omarchy-provision-user" >/dev/null
grep -Fxq 'set default-web-browser chromium.desktop' "$test_tmp/browser-log" ||
  fail "new users on existing installations fall back to Chromium"
pass "new users on existing installations fall back to Chromium"

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
