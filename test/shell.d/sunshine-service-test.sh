#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/systemctl" <<'MOCK'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$OMARCHY_TEST_LOG"
case $2 in
  list-unit-files)
    printf '%s\n' "$OMARCHY_TEST_UNITS"
    ;;
  enable)
    if [[ $4 == "sunshine.service" && $OMARCHY_TEST_UNITS == *"sunshine.service alias "* ]]; then
      exit 1
    fi
    exit "$OMARCHY_TEST_ENABLE_STATUS"
    ;;
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
export OMARCHY_TEST_LOG="$test_tmp/commands"
export OMARCHY_TEST_ENABLE_STATUS=0 OMARCHY_TEST_DISABLE_STATUS=0

reset_home() {
  export HOME="$test_tmp/home"
  rm -rf "$HOME"
  mkdir -p "$HOME"
  : >"$OMARCHY_TEST_LOG"
}

for scenario in short canonical alias; do
  case $scenario in
    short)
      unit="sunshine.service"
      export OMARCHY_TEST_UNITS='sunshine.service disabled enabled'
      ;;
    canonical)
      unit="app-dev.lizardbyte.app.Sunshine.service"
      export OMARCHY_TEST_UNITS='app-dev.lizardbyte.app.Sunshine.service disabled enabled
other-sunshine.service enabled enabled'
      ;;
    alias)
      unit="app-dev.lizardbyte.app.Sunshine.service"
      export OMARCHY_TEST_UNITS='sunshine.service alias -
app-dev.lizardbyte.app.Sunshine.service enabled enabled'
      ;;
  esac
  reset_home
  bash "$ROOT/bin/omarchy-install-service-sunshine" >/dev/null
  grep -Fxq "systemctl --user enable --now $unit" "$OMARCHY_TEST_LOG" || fail "installer enables $unit"
  [[ -f $HOME/.config/hypr/autostart.lua ]] || fail "successful install configures autostart"
  pass "installer enables $unit ($scenario)"

  : >"$OMARCHY_TEST_LOG"
  bash "$ROOT/bin/omarchy-remove-service-sunshine" >/dev/null
  grep -Fxq "systemctl --user disable --now $unit" "$OMARCHY_TEST_LOG" || fail "remover disables $unit"
  awk -v expected="systemctl --user disable --now $unit" '
    $0 == expected { disabled = 1 }
    $0 == "omarchy-pkg-drop sunshine" { removed = disabled }
    END { exit !removed }
  ' "$OMARCHY_TEST_LOG" || fail "remover disables $unit before removing package"
  pass "remover disables $unit before removing package ($scenario)"
done

reset_home
export OMARCHY_TEST_ENABLE_STATUS=1
export OMARCHY_TEST_UNITS='sunshine.service disabled enabled'
if bash "$ROOT/bin/omarchy-install-service-sunshine" >"$test_tmp/output" 2>&1; then
  fail "enable failure aborts installation"
fi
if grep -Eq '^(sudo|omarchy-cmd-missing|omarchy-webapp-install|omarchy-launch-webapp) ' "$OMARCHY_TEST_LOG"; then
  fail "enable failure skips firewall and web-app setup"
fi
[[ ! -e $HOME/.config/hypr/autostart.lua ]] || fail "enable failure skips autostart setup"
grep -Fq 'Sunshine has been installed' "$test_tmp/output" && fail "enable failure does not report success"
pass "enable failure aborts before firewall, web-app, and autostart setup"

reset_home
export OMARCHY_TEST_DISABLE_STATUS=1
bash "$ROOT/bin/omarchy-remove-service-sunshine" >/dev/null
grep -Fxq 'omarchy-pkg-drop sunshine' "$OMARCHY_TEST_LOG" || fail "disable failure still removes package"
pass "remover preserves best-effort disable handling"
