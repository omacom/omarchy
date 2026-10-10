#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
applications="$test_tmp/data/applications"
mkdir -p "$mock_bin" "$applications" "$test_tmp/config" "$test_tmp/system/applications"

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_CONFIG_DIRS="$test_tmp/etc"
export XDG_DATA_HOME="$test_tmp/data"
export XDG_DATA_DIRS="$test_tmp/system"
export XDG_CURRENT_DESKTOP=Hyprland
export PATH="$mock_bin:$ROOT/bin:$PATH"

for command in testium firefox update-desktop-database; do
  printf '#!/bin/bash\n' >"$mock_bin/$command"
done
printf '#!/bin/bash\necho fallback.desktop\n' >"$mock_bin/xdg-settings"
cat >"$mock_bin/omarchy-cmd-browser-handoff" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_HANDOFF"
SH
cat >"$mock_bin/omarchy-hyprland-focus-app" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >"$OMARCHY_TEST_FOCUS"
SH
chmod +x "$mock_bin"/*

cat >"$test_tmp/system/applications/chromium.desktop" <<'EOF2'
[Desktop Entry]
Name=Chromium
Exec=testium %U
DBusActivatable=true
Actions=new-private-window;

[Desktop Action new-private-window]
Exec=testium --incognito
EOF2
cat >"$test_tmp/system/applications/firefox.desktop" <<'EOF2'
[Desktop Entry]
Name=Firefox
Exec=firefox %u
EOF2

default_browser() {
  printf '[Default Applications]\nx-scheme-handler/http=%s\nx-scheme-handler/https=%s\n' "$1" "$1" \
    >"$XDG_CONFIG_HOME/mimeapps.list"
}

default_browser chromium.desktop
omarchy-refresh-browser-handoff

shadow="$applications/chromium.desktop"
[[ -f $shadow ]] || fail "handoff shadows the default browser's desktop entry"
[[ $(sed -n 2p "$shadow") == "X-Omarchy-Browser-Handoff=true" ]] ||
  fail "handoff marks its entry in the Desktop Entry group"
grep -qxF "Exec=omarchy-cmd-browser-open testium %U" "$shadow" ||
  fail "handoff routes the browser's links through the opener"
grep -qxF "Exec=omarchy-cmd-browser-open testium --incognito" "$shadow" ||
  fail "handoff routes the browser's actions through the opener"
! grep -q "^DBusActivatable=" "$shadow" || fail "handoff drops D-Bus activation, which would bypass Exec"
pass "handoff shadows the default browser with an entry that goes through the opener"

[[ $(omarchy-cmd-default-browser) == "chromium.desktop" ]] ||
  fail "default browser keeps its desktop ID behind the shadow"
pass "default browser keeps its desktop ID behind the shadow"

rm -f "$mock_bin/testium"
[[ $(omarchy-cmd-default-browser) == "fallback.desktop" ]] ||
  fail "a shadow does not keep a removed browser installed"
printf '#!/bin/bash\n' >"$mock_bin/testium"
chmod +x "$mock_bin/testium"
pass "a shadow does not keep a removed browser installed"

default_browser firefox.desktop
omarchy-refresh-browser-handoff
[[ ! -e $shadow ]] || fail "handoff removes the shadow of the previous default browser"
grep -qxF "Exec=omarchy-cmd-browser-open firefox %u" "$applications/firefox.desktop" ||
  fail "handoff shadows the new default browser"
pass "handoff follows a change of default browser"

rm "$applications/firefox.desktop"
printf '[Desktop Entry]\nExec=firefox --my-profile %%u\n' >"$applications/firefox.desktop"
omarchy-refresh-browser-handoff
grep -qxF "Exec=firefox --my-profile %u" "$applications/firefox.desktop" ||
  fail "handoff leaves a user's own browser entry alone"
pass "handoff leaves a user's own browser entry alone"

handoff_log="$test_tmp/handoff"
focus_log="$test_tmp/focus"
OMARCHY_TEST_HANDOFF="$handoff_log" OMARCHY_TEST_FOCUS="$focus_log" HYPRLAND_INSTANCE_SIGNATURE=test \
  omarchy-cmd-browser-open testium "https://example.test/link"
[[ $(<"$handoff_log") == "testium https://example.test/link" ]] ||
  fail "opener hands the link to the running browser" "actual: $(<"$handoff_log")"
[[ $(<"$focus_log") == '^testium.*$' ]] || fail "opener focuses the browser that took the link"
pass "opener hands links to the running browser and focuses it"

rm -f "$focus_log"
OMARCHY_TEST_HANDOFF="$handoff_log" OMARCHY_TEST_FOCUS="$focus_log" HYPRLAND_INSTANCE_SIGNATURE=test \
  omarchy-cmd-browser-open testium --incognito
[[ ! -e $focus_log ]] || fail "opener leaves focus alone for a window without a link"
pass "opener leaves focus alone for a window without a link"
