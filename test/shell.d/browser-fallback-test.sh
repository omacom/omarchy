#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" "$test_home/.local/share/applications" "$test_home/.config"

for browser in brave-origin chromium google-chrome; do
  printf '[Desktop Entry]\nExec=%s %%U\n' "$browser" >"$test_home/.local/share/applications/$browser.desktop"
done

cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
[[ -z ${BROWSER:-} ]] || exit 1
case $1 in
get) cat "$OMARCHY_TEST_BROWSER_FILE" ;;
set)
  [[ ${OMARCHY_TEST_DEFAULT_FAIL:-0} != "1" ]] || exit 1
  printf '%s\n' "$3" >"$OMARCHY_TEST_BROWSER_FILE"
  ;;
esac
SH
cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ " $OMARCHY_TEST_INSTALLED_BROWSERS " == *" $1 "* ]]
SH
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_LAUNCH_LOG"
SH
cat >"$mock_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_DROP_LOG"
SH
cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*

export HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" BROWSER=omarchy-launch-browser
export OMARCHY_TEST_BROWSER_FILE="$test_tmp/default-browser"
export OMARCHY_TEST_LAUNCH_LOG="$test_tmp/launch-log"
export OMARCHY_TEST_DROP_LOG="$test_tmp/drop-log"
export OMARCHY_TEST_INSTALLED_BROWSERS="brave-origin chromium"

assert_webapp_browser() {
  local default_browser=$1 expected=$2
  printf '%s\n' "$default_browser" >"$OMARCHY_TEST_BROWSER_FILE"
  bash "$ROOT/bin/omarchy-launch-webapp" 'https://example.test/path?q=one&name=two words' '--name=Example App'
  mapfile -t args <"$OMARCHY_TEST_LAUNCH_LOG"
  [[ ${args[0]} == "uwsm-app" && ${args[1]} == "--" && ${args[2]} == "$expected" ]] ||
    fail "web apps resolve $default_browser to $expected" "${args[*]}"
  [[ ${args[3]} == "--app=https://example.test/path?q=one&name=two words" && ${args[4]} == "--name=Example App" ]] ||
    fail "web apps preserve URL and extra argument boundaries"
}

for browser in brave-origin chromium google-chrome; do
  assert_webapp_browser "$browser.desktop" "$browser"
done
pass "web apps honor supported browser choices with BROWSER unset"

for browser in firefox.desktop zen.desktop ''; do
  assert_webapp_browser "$browser" brave-origin
done
pass "web apps fall back to Brave Origin for unsupported or unset defaults"

OMARCHY_TEST_INSTALLED_BROWSERS=chromium assert_webapp_browser firefox.desktop chromium
pass "web apps keep working on existing installations without Brave Origin"

for browser in firefox chromium; do
  printf '%s.desktop\n' "$browser" >"$OMARCHY_TEST_BROWSER_FILE"
  bash "$ROOT/bin/omarchy-remove-browser" "$browser" >/dev/null
  [[ $(<"$OMARCHY_TEST_BROWSER_FILE") == "brave-origin.desktop" ]] ||
    fail "removing the default $browser selects Brave Origin"
  [[ $(<"$OMARCHY_TEST_DROP_LOG") == "$browser" ]] || fail "removes the selected $browser package"
done
pass "removing an optional default browser restores Brave Origin"

printf 'firefox.desktop\n' >"$OMARCHY_TEST_BROWSER_FILE"
bash "$ROOT/bin/omarchy-remove-browser" chrome >/dev/null
[[ $(<"$OMARCHY_TEST_BROWSER_FILE") == "firefox.desktop" ]] || fail "removing another browser preserves the user's default"
pass "removing another browser preserves the user's default"

OMARCHY_TEST_INSTALLED_BROWSERS=chromium bash "$ROOT/bin/omarchy-remove-browser" firefox >/dev/null
[[ $(<"$OMARCHY_TEST_BROWSER_FILE") == "chromium.desktop" ]] || fail "legacy installs fall back to Chromium on removal"
pass "legacy installs fall back to Chromium on removal"

: >"$OMARCHY_TEST_DROP_LOG"
if OMARCHY_TEST_INSTALLED_BROWSERS=chromium bash "$ROOT/bin/omarchy-remove-browser" chromium >/dev/null 2>&1; then
  fail "removal refuses to leave the default pointing at an uninstalled browser"
fi
[[ ! -s $OMARCHY_TEST_DROP_LOG && $(<"$OMARCHY_TEST_BROWSER_FILE") == "chromium.desktop" ]] ||
  fail "refusing removal preserves the browser package and default"
pass "removal keeps the last default browser installed"

if OMARCHY_TEST_DEFAULT_FAIL=1 bash "$ROOT/bin/omarchy-remove-browser" chromium >/dev/null 2>&1; then
  fail "removal fails when XDG cannot switch the default"
fi
[[ ! -s $OMARCHY_TEST_DROP_LOG ]] || fail "a failed default switch keeps the browser installed"
pass "a failed default switch keeps the browser installed"
