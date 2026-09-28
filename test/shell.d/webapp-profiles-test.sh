#!/bin/bash

set -euo pipefail

# Webapps pick the browser profile they open in. The profile list is read from
# a Chromium Local State written here, selections are kept by the store, and
# the launcher runs against stubs for the menu and the browser so that what it
# asked and what it launched can be read back.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
launch_log="$test_tmp/launch"
menu_log="$test_tmp/menu"
xdg_state="$test_tmp/default-browser"
local_state="$test_home/.config/chromium/Local State"
mkdir -p "$mock_bin" "$test_home/.local/share/applications" "$test_home/.config/chromium"

cat >"$test_home/.local/share/applications/chromium.desktop" <<'EOF2'
[Desktop Entry]
Exec=chromium %U
EOF2

cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
if [[ $1 == "set" ]]; then
  printf '%s\n' "$3" >"$OMARCHY_TEST_XDG_STATE"
else
  cat "$OMARCHY_TEST_XDG_STATE"
fi
SH
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_LAUNCH_LOG"
SH
cat >"$mock_bin/omarchy-menu-select" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_MENU_LOG"
printf '%s\n' "${OMARCHY_TEST_MENU_PICK:-}"
SH
cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*

echo chromium.desktop >"$xdg_state"

run() {
  HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_XDG_STATE="$xdg_state" OMARCHY_TEST_LAUNCH_LOG="$launch_log" \
    OMARCHY_TEST_MENU_LOG="$menu_log" OMARCHY_TEST_MENU_PICK="${OMARCHY_TEST_MENU_PICK:-}" \
    "$@"
}

write_profiles() {
  printf '{"profile":{"info_cache":%s}}\n' "$1" >"$local_state"
}

reset() {
  rm -f "$launch_log" "$menu_log"
  rm -rf "$test_home/.local/state"
}

# -- listing profiles ---------------------------------------------------------

rm -f "$local_state"
[[ -z $(run omarchy-webapp-profiles) ]] || fail "a browser that has never run lists no profiles"
pass "no profiles are listed before the browser has run"

write_profiles '{"Profile 1":{"name":"Work"},"Default":{"name":"Personal"},"Profile 2":{}}'
[[ $(run omarchy-webapp-profiles) == $'Default\tPersonal\nProfile 1\tWork\nProfile 2\tProfile 2' ]] ||
  fail "profiles are listed sorted as dirname<TAB>name, the directory standing in for a missing name" "$(run omarchy-webapp-profiles)"
pass "profiles come from the browser's Local State"

echo firefox.desktop >"$xdg_state"
[[ $(run omarchy-webapp-profiles --browser) == "chromium.desktop" ]] ||
  fail "a default browser that cannot run webapps falls back to Chromium's profiles"
echo brave-origin.desktop >"$xdg_state"
[[ $(run omarchy-webapp-profiles --browser) == "brave-origin.desktop" ]] ||
  fail "a Chromium-based default browser is the one whose profiles are offered"
[[ -z $(run omarchy-webapp-profiles) ]] || fail "profiles are read from the effective browser's own Local State"
echo chromium.desktop >"$xdg_state"
pass "the profiles offered are those of the browser webapps launch in"

# -- remembering a choice -----------------------------------------------------

reset
run omarchy-webapp-profile-store set "https://example.test" "Profile 1"
[[ $(run omarchy-webapp-profile-store get "https://example.test") == "Profile 1" ]] || fail "a stored profile is read back"
[[ -z $(run omarchy-webapp-profile-store get "https://other.test") ]] || fail "each URL remembers its own profile"
[[ -d $test_home/.local/state/omarchy/webapps ]] || fail "selections live under ~/.local/state/omarchy"
[[ ! -e $test_home/.config/omarchy ]] || fail "selections do not land in ~/.config/omarchy"
pass "the store keeps one profile per webapp URL as local state"

echo brave.desktop >"$xdg_state"
[[ -z $(run omarchy-webapp-profile-store get "https://example.test") ]] ||
  fail "a profile remembered for one browser is not offered for another"
echo chromium.desktop >"$xdg_state"
[[ $(run omarchy-webapp-profile-store get "https://example.test") == "Profile 1" ]] ||
  fail "the selection is back once the browser it was made for is"
pass "a remembered profile only applies to the browser it was chosen in"

run omarchy-webapp-profile-store clear-all
[[ -z $(run omarchy-webapp-profile-store get "https://example.test") ]] || fail "clear-all forgets every selection"
pass "clear-all forgets every selection"

# -- launching ----------------------------------------------------------------

reset
write_profiles '{"Default":{"name":"Personal"}}'
run omarchy-launch-webapp "https://example.test" --some-flag
[[ ! -e $menu_log ]] || fail "one profile is used without asking"
[[ $(cat "$launch_log") == 'uwsm-app -- chromium --app=https://example.test --some-flag' ]] ||
  fail "a single profile launches as before, flags passed through" "$(cat "$launch_log")"
pass "a browser with one profile launches without a prompt"

reset
write_profiles '{"Default":{"name":"Personal"},"Profile 1":{"name":"Work"}}'
OMARCHY_TEST_MENU_PICK="Work" run omarchy-launch-webapp "https://example.test"
[[ $(head -1 "$menu_log") == "Choose profile" ]] || fail "two profiles are offered in a menu" "$(cat "$menu_log")"
grep -Fxq 'Always use Work' "$menu_log" || fail "each profile can also be chosen for good" "$(cat "$menu_log")"
[[ $(cat "$launch_log") == 'uwsm-app -- chromium --profile-directory=Profile 1 --app=https://example.test' ]] ||
  fail "the picked profile is passed to the browser" "$(cat "$launch_log")"
[[ -z $(run omarchy-webapp-profile-store get "https://example.test") ]] || fail "a one-off pick is not remembered"
pass "with several profiles the launcher asks, and a plain pick is for this launch only"

reset
write_profiles '{"Default":{"name":"Personal"},"Profile 1":{"name":"Work"}}'
OMARCHY_TEST_MENU_PICK="Always use Work" run omarchy-launch-webapp "https://example.test"
[[ $(run omarchy-webapp-profile-store get "https://example.test") == "Profile 1" ]] || fail "an 'Always use' pick is remembered"
rm -f "$menu_log" "$launch_log"
run omarchy-launch-webapp "https://example.test"
[[ ! -e $menu_log ]] || fail "a remembered profile is not asked about again"
[[ $(cat "$launch_log") == 'uwsm-app -- chromium --profile-directory=Profile 1 --app=https://example.test' ]] ||
  fail "the remembered profile is used" "$(cat "$launch_log")"
pass "an 'Always use' pick is remembered and used on the next launch"

reset
write_profiles '{"Default":{"name":"Personal"},"Profile 1":{"name":"Work"}}'
OMARCHY_TEST_MENU_PICK="" run omarchy-launch-webapp "https://example.test"
[[ ! -e $launch_log ]] || fail "dismissing the menu launches nothing"
pass "dismissing the profile menu cancels the launch"

reset
write_profiles '{"Default":{"name":"Personal"},"Profile 1":{"name":"Work"}}'
run omarchy-webapp-profile-store set "https://app.hey.com" "Profile 1"
OMARCHY_WEBAPP_REMEMBER_KEY="https://app.hey.com" run omarchy-launch-webapp "https://app.hey.com/messages/new?to=a@b.test"
[[ ! -e $menu_log ]] || fail "a handler's stable key finds the remembered profile for a dynamic URL"
grep -q -- '--profile-directory=Profile 1' "$launch_log" || fail "the profile remembered under the stable key is used" "$(cat "$launch_log")"
pass "handlers keep one remembered profile across their dynamic URLs"

reset
write_profiles '{"Default":{"name":"Personal"},"Profile 1":{"name":"Work"}}'
run omarchy-webapp-profile-store set "https://example.test" "Default"
write_profiles '{"Profile 1":{"name":"Work"},"Profile 2":{"name":"Home"}}'
OMARCHY_TEST_MENU_PICK="Home" run omarchy-launch-webapp "https://example.test"
[[ -e $menu_log ]] || fail "a remembered profile that no longer exists is asked about again"
grep -q -- '--profile-directory=Profile 2' "$launch_log" || fail "the new pick is launched" "$(cat "$launch_log")"
pass "a remembered profile that was deleted falls back to asking"

# -- changing the default browser ---------------------------------------------

reset
write_profiles '{"Default":{"name":"Personal"},"Profile 1":{"name":"Work"}}'
run omarchy-webapp-profile-store set "https://example.test" "Default"
run omarchy-default-browser chromium >/dev/null
[[ $(run omarchy-webapp-profile-store get "https://example.test") == "Default" ]] ||
  fail "re-choosing the same default browser keeps the selections"
run omarchy-default-browser brave >/dev/null
echo chromium.desktop >"$xdg_state"
[[ -z $(run omarchy-webapp-profile-store get "https://example.test") ]] ||
  fail "changing the default browser drops the selections"
pass "a new default browser starts with no remembered profiles"
