#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

unit="app-dev.lizardbyte.app.Sunshine.service"
entry='o.launch_on_start("sunshine")'

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/systemctl" <<'MOCK'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$OMARCHY_TEST_LOG"
case $2 in
  enable) exit "$OMARCHY_TEST_ENABLE_STATUS" ;;
  disable) exit "$OMARCHY_TEST_DISABLE_STATUS" ;;
esac
MOCK

cat >"$mock_bin/external" <<'MOCK'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$OMARCHY_TEST_LOG"
case ${0##*/} in
  omarchy-cmd-missing|ip) exit 1 ;;
esac
MOCK
chmod +x "$mock_bin/systemctl" "$mock_bin/external"
for command in omarchy-pkg-add omarchy-pkg-drop omarchy-webapp-install omarchy-webapp-remove omarchy-launch-webapp omarchy-cmd-missing sudo ip; do
  ln -s external "$mock_bin/$command"
done

export PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_ENABLE_STATUS=0 OMARCHY_TEST_DISABLE_STATUS=0

home="$test_tmp/home"
autostart="$home/.config/hypr/autostart.lua"

reset_home() {
  rm -rf "$home"
  mkdir -p "$home/.config/hypr"
  cat >"$autostart" <<'LUA'
-- Extra autostart processes.
o.launch_on_start("my-service")
LUA
  export OMARCHY_TEST_LOG=$(mktemp -p "$test_tmp" commands.XXXXXX)
}

uses_alias() {
  grep -Eq '^systemctl --user (enable|disable) --now sunshine(\.service)?$' "$OMARCHY_TEST_LOG"
}

reset_home
HOME="$home" bash "$ROOT/bin/omarchy-install-service-sunshine" >/dev/null

# The installer backgrounds the web app launch; wait for the mock to run, or cleanup could let it find the real one.
for _ in {1..50}; do
  grep -q '^omarchy-launch-webapp ' "$OMARCHY_TEST_LOG" && break
  sleep 0.1
done
grep -q '^omarchy-launch-webapp ' "$OMARCHY_TEST_LOG" || fail "Sunshine installer opens the admin web app"

grep -Fxq "systemctl --user enable --now $unit" "$OMARCHY_TEST_LOG" || fail "Sunshine installer enables the canonical user unit"
if uses_alias; then
  fail "Sunshine installer does not enable the sunshine alias"
fi
pass "Sunshine installer enables the canonical user unit"
grep -Fq 'o.launch_on_start("my-service")' "$autostart" || fail "Sunshine installer leaves other autostart entries"
if grep -Fq "$entry" "$autostart"; then
  fail "Sunshine installer does not add a Hyprland autostart copy"
fi
pass "Sunshine installer does not add a Hyprland autostart copy"

reset_home
OMARCHY_TEST_ENABLE_STATUS=1
if HOME="$home" bash "$ROOT/bin/omarchy-install-service-sunshine" >"$test_tmp/output" 2>&1; then
  fail "Sunshine installer fails when the unit cannot be enabled"
fi
grep -Fxq "systemctl --user enable --now $unit" "$OMARCHY_TEST_LOG" || fail "Sunshine installer tries to enable the canonical user unit"
if grep -Eq '^(sudo|omarchy-cmd-missing|omarchy-webapp-install|omarchy-launch-webapp) ' "$OMARCHY_TEST_LOG"; then
  fail "Sunshine installer skips firewall and web-app setup when enable fails"
fi
if grep -Fq 'Sunshine has been installed' "$test_tmp/output"; then
  fail "Sunshine installer does not report success when enable fails"
fi
pass "Sunshine installer stops before firewall and web-app setup when enable fails"
OMARCHY_TEST_ENABLE_STATUS=0

reset_home
printf '%s\n' "$entry" >>"$autostart"
HOME="$home" bash "$ROOT/bin/omarchy-remove-service-sunshine" >/dev/null
awk -v expected="systemctl --user disable --now $unit" '
  $0 == expected { disabled = 1 }
  $0 == "omarchy-pkg-drop sunshine" { removed = disabled }
  END { exit !removed }
' "$OMARCHY_TEST_LOG" || fail "Sunshine removal disables the canonical user unit before removing the package"
if uses_alias; then
  fail "Sunshine removal does not disable the sunshine alias"
fi
pass "Sunshine removal disables the canonical user unit before removing the package"
grep -Fq 'o.launch_on_start("my-service")' "$autostart" || fail "Sunshine removal leaves other autostart entries"
if grep -Fq "$entry" "$autostart"; then
  fail "Sunshine removal strips a leftover Hyprland autostart line"
fi
pass "Sunshine removal strips a leftover Hyprland autostart line"

reset_home
OMARCHY_TEST_DISABLE_STATUS=1
HOME="$home" bash "$ROOT/bin/omarchy-remove-service-sunshine" >/dev/null
grep -Fxq "systemctl --user disable --now $unit" "$OMARCHY_TEST_LOG" || fail "Sunshine removal tries to disable the canonical user unit"
grep -Fxq 'omarchy-pkg-drop sunshine' "$OMARCHY_TEST_LOG" || fail "Sunshine removal still removes the package when disable fails"
pass "Sunshine removal still removes the package when disable fails"
OMARCHY_TEST_DISABLE_STATUS=0

reset_home
printf '%s\n' "$entry" >>"$autostart"
HOME="$home" bash -euo pipefail "$ROOT/migrations/1789703649.sh" >/dev/null
grep -Fq 'o.launch_on_start("my-service")' "$autostart" ||
  fail "Sunshine migration leaves other autostart entries"
if grep -Fq "$entry" "$autostart"; then
  fail "Sunshine migration removes the duplicate autostart line"
fi
pass "Sunshine migration removes the duplicate autostart line"

HOME="$home" bash -euo pipefail "$ROOT/migrations/1789703649.sh" >/dev/null
grep -Fq 'o.launch_on_start("my-service")' "$autostart" ||
  fail "Sunshine migration is idempotent"
pass "Sunshine migration is idempotent"
