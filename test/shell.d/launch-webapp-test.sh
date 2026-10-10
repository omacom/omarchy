#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" "$test_home/.local/share/applications"
export XDG_CONFIG_HOME="$test_home/.config" XDG_DATA_HOME="$test_home/.local/share"

for browser in chromium opera; do
  printf '[Desktop Entry]\nExec=%s %%U\n' "$browser" >"$test_home/.local/share/applications/$browser.desktop"
done

cat >"$mock_bin/omarchy-cmd-default-browser" <<'SH'
#!/bin/bash
echo "$OMARCHY_TEST_DEFAULT_BROWSER"
SH
cat >"$mock_bin/omarchy-cmd-browser-handoff" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_WEBAPP_LAUNCH"
SH
chmod +x "$mock_bin"/*

launch_log="$test_tmp/launch"

launch_webapp() {
  HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_DEFAULT_BROWSER="$1" \
    OMARCHY_TEST_WEBAPP_LAUNCH="$launch_log" bash "$ROOT/bin/omarchy-launch-webapp" "${@:2}"
}

launch_webapp chromium.desktop https://example.test/app
[[ $(<"$launch_log") == $'uwsm-app\n--\nchromium\n--app=https://example.test/app' ]] ||
  fail "web app launcher opens Chromium in app mode" "$(cat "$launch_log")"
pass "web app launcher opens Chromium in app mode"

launch_webapp opera.desktop https://example.test/app "--user-data-dir=$test_tmp/my profile"
[[ $(<"$launch_log") == $'uwsm-app\n--\nopera\n--new-window\nhttps://example.test/app\n'"--user-data-dir=$test_tmp/my profile" ]] ||
  fail "web app launcher opens the URL in a new Opera window, which ignores --app=" "$(cat "$launch_log")"
pass "web app launcher opens the URL in a new Opera window, which ignores --app="
