#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
applications="$test_home/.local/share/applications"
mkdir -p "$mock_bin" "$applications"

launch_log="$test_tmp/launch"
notify_log="$test_tmp/notify"

echo "Exec=chromium %U" >"$applications/chromium.desktop"
echo "Exec=brave %U" >"$applications/brave-browser.desktop"
echo "Exec=firefox %u" >"$applications/firefox.desktop"
echo "Exec=$mock_bin/browseros %U" >"$applications/browseros.desktop"

cat >"$mock_bin/browseros" <<'SH'
#!/bin/bash
exec /usr/lib/chromium/chromium --user-data-dir="$HOME/.config/browser-os" "$@"
SH
cat >"$mock_bin/firefox" <<'SH'
#!/bin/bash
exec /usr/lib/firefox/firefox "$@"
SH
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
printf '%s\n' "$*" >"$OMARCHY_TEST_LAUNCH"
SH
cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_NOTIFY"
SH
printf '#!/bin/bash\n' | tee "$mock_bin/chromium" "$mock_bin/brave" >/dev/null
chmod +x "$mock_bin"/*

launch_webapp() {
  rm -f "$launch_log" "$notify_log"
  HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_TEST_DEFAULT_BROWSER="$1" \
    OMARCHY_TEST_LAUNCH="$launch_log" OMARCHY_TEST_NOTIFY="$notify_log" \
    bash "$ROOT/bin/omarchy-launch-webapp" "https://example.test/"
}

launch_webapp brave-browser.desktop
[[ $(<"$launch_log") == "uwsm-app -- brave --app=https://example.test/" ]] ||
  fail "web app opens in an allowlisted default browser" "$(<"$launch_log")"
[[ ! -e $notify_log ]] || fail "an allowlisted default browser sends no notification"
pass "web app opens in an allowlisted default browser"

launch_webapp browseros.desktop
[[ $(<"$launch_log") == "uwsm-app -- $mock_bin/browseros --app=https://example.test/" ]] ||
  fail "web app opens in a default launcher wrapping Chromium" "$(<"$launch_log")"
[[ ! -e $notify_log ]] || fail "a default launcher wrapping Chromium sends no notification"
pass "web app keeps a default launcher whose wrapper runs Chromium"

launch_webapp firefox.desktop
[[ $(<"$launch_log") == "uwsm-app -- chromium --app=https://example.test/" ]] ||
  fail "web app falls back to Chromium when the default can't open web apps" "$(<"$launch_log")"
grep -F "firefox can't open web apps" "$notify_log" >/dev/null ||
  fail "falling back to Chromium tells the user why"
pass "web app falls back to Chromium and notifies when the default can't open web apps"

launch_webapp ""
[[ $(<"$launch_log") == "uwsm-app -- chromium --app=https://example.test/" ]] ||
  fail "web app opens in Chromium with no default browser" "$(<"$launch_log")"
[[ ! -e $notify_log ]] || fail "no default browser sends no notification"
pass "web app opens in Chromium quietly when there is no default browser"
