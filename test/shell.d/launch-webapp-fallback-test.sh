#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

mock_bin="$scratch/bin"
test_home="$scratch/home"
system_apps="$scratch/usr/share/applications"
export TEST_LOG="$scratch/calls"
mkdir -p "$mock_bin" "$test_home/.local/share/applications" "$system_apps"

# Read desktop entries from the scratch tree instead of the host's /usr/share.
sed "s|,/usr}|,$scratch/usr}|" "$ROOT/bin/omarchy-launch-webapp" >"$mock_bin/omarchy-launch-webapp"

cat >"$mock_bin/omarchy-cmd-default-browser" <<'STUB'
#!/bin/bash
printf '%s\n' "$TEST_DEFAULT_BROWSER"
STUB

cat >"$mock_bin/omarchy-cmd-browser-handoff" <<'STUB'
#!/bin/bash
exit 1
STUB

cat >"$mock_bin/setsid" <<'STUB'
#!/bin/bash
printf 'launch:%s\n' "$*" >>"$TEST_LOG"
STUB

cat >"$mock_bin/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf 'notify:%s\n' "$*" >>"$TEST_LOG"
STUB

for browser in zen helium brave; do
  printf '#!/bin/bash\n' >"$mock_bin/$browser"
done
chmod +x "$mock_bin/"*

desktop_entry() {
  printf '[Desktop Entry]\nExec=%s %%U\n' "$2" >"$1"
}

launch_webapp() {
  : >"$TEST_LOG"
  TEST_DEFAULT_BROWSER="$1" HOME="$test_home" PATH="$mock_bin:$PATH" \
    "$mock_bin/omarchy-launch-webapp" https://example.test/app --flag >/dev/null 2>"$scratch/err"
}

desktop_entry "$system_apps/zen.desktop" zen
if launch_webapp zen.desktop; then
  fail "web app launch fails without a Chromium-based browser" "$(cat "$TEST_LOG")"
fi
grep -q '^notify:' "$TEST_LOG" || fail "missing Chromium-based browser is reported" "$(cat "$TEST_LOG")"
if grep -q '^launch:' "$TEST_LOG"; then
  fail "nothing is launched without a Chromium-based browser" "$(cat "$TEST_LOG")"
fi
pass "web app launch fails clearly without a Chromium-based browser"

# An entry whose command is gone is not an installed browser.
desktop_entry "$test_home/.local/share/applications/chromium.desktop" chromium-removed
desktop_entry "$system_apps/helium.desktop" helium
launch_webapp zen.desktop || fail "web app launch uses an installed Chromium-based browser" "$(cat "$scratch/err")"
grep -Fxq 'launch:uwsm-app -- helium --app=https://example.test/app --flag' "$TEST_LOG" ||
  fail "web app falls back to the installed Chromium-based browser" "$(cat "$TEST_LOG")"
pass "web app falls back to the installed Chromium-based browser"

desktop_entry "$system_apps/brave-browser.desktop" brave
launch_webapp brave-browser.desktop || fail "web app launch uses the default browser" "$(cat "$scratch/err")"
grep -Fxq 'launch:uwsm-app -- brave --app=https://example.test/app --flag' "$TEST_LOG" ||
  fail "web app prefers a Chromium-based default browser" "$(cat "$TEST_LOG")"
pass "web app prefers a Chromium-based default browser"
