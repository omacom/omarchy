#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

install_script="$ROOT/bin/omarchy-install-gaming-battlenet"

[[ ! -f $ROOT/applications/battlenet.desktop ]] || fail "Battle.net launcher is not part of default application refresh"
[[ -f $ROOT/default/applications/battlenet.desktop ]] || fail "Battle.net launcher template is available to the installer"
grep -F '$OMARCHY_PATH/default/applications/battlenet.desktop' "$install_script" >/dev/null ||
  fail "Battle.net installer installs the launcher from the installer-only template"

pass "Battle.net launcher is only installed by the Battle.net installer"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
launch_log="$test_tmp/launch-log"
launcher="$test_home/Games/battlenet/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"
mkdir -p "$mock_bin" "$(dirname "$launcher")"
touch "$launcher"

cat >"$mock_bin/umu-run" <<'SH'
#!/bin/bash
printf 'env:<%s><%s><%s><%s><%s>\n' "$WINEPREFIX" "$PROTONPATH" "$GAMEID" "$PROTON_VERB" "${MANGOHUD:-}" >"$OMARCHY_TEST_LOG"
printf 'args:' >>"$OMARCHY_TEST_LOG"
for arg in "$@"; do
  printf '<%s>' "$arg" >>"$OMARCHY_TEST_LOG"
done
printf '\n' >>"$OMARCHY_TEST_LOG"
exit "${OMARCHY_TEST_UMU_STATUS:-0}"
SH
chmod +x "$mock_bin/umu-run"

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_NOTIFICATIONS"
SH
chmod +x "$mock_bin/omarchy-notification-send"

HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" PATH="$mock_bin:$PATH" OMARCHY_TEST_LOG="$launch_log" \
  "$ROOT/bin/omarchy-launch-battlenet" --with-mangohud

grep -Fxq "env:<$test_home/Games/battlenet><GE-Proton><umu-battlenet><run><1>" "$launch_log" ||
  fail "Battle.net launcher passes its umu environment" "$(cat "$launch_log")"
grep -Fxq "args:<$launcher>" "$launch_log" ||
  fail "Battle.net launcher passes the Battle.net executable to umu" "$(cat "$launch_log")"
pass "Battle.net launcher passes its umu environment"

mkdir -p "$test_home/.config/omarchy/launchers"
printf '%s\n' 'LAUNCH_ARGS="--force-device-scale-factor=1.75 --some-other-option"' >"$test_home/.config/omarchy/launchers/battlenet.conf"
HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" PATH="$mock_bin:$PATH" OMARCHY_TEST_LOG="$launch_log" \
  "$ROOT/bin/omarchy-launch-battlenet"

grep -Fxq "args:<$launcher><--force-device-scale-factor=1.75><--some-other-option>" "$launch_log" ||
  fail "Battle.net launcher appends launch arguments from config" "$(cat "$launch_log")"
pass "Battle.net launcher appends launch arguments from config"

notifications="$test_tmp/notifications"
rm -f "$launch_log" "$notifications"
printf '%s\n' 'LAUNCH_ARGS="--some-option"' 'false' >"$test_home/.config/omarchy/launchers/battlenet.conf"
if HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" PATH="$mock_bin:$PATH" OMARCHY_TEST_LOG="$launch_log" OMARCHY_TEST_NOTIFICATIONS="$notifications" \
  "$ROOT/bin/omarchy-launch-battlenet" 2>/dev/null; then
  fail "Battle.net launcher fails when config sourcing returns an error"
fi
[[ ! -s $launch_log ]] || fail "Battle.net is not launched after a config error" "$(cat "$launch_log")"
grep -Fq -- "-u critical Battle.net launch failed Could not load $test_home/.config/omarchy/launchers/battlenet.conf" "$notifications" ||
  fail "Battle.net config error is reported as a desktop notification" "$(cat "$notifications")"
pass "Battle.net launcher fails and notifies when config sourcing fails"

rm -f "$notifications"
if HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" PATH="$mock_bin:$PATH" OMARCHY_TEST_NOTIFICATIONS="$notifications" \
  "$ROOT/bin/omarchy-launch-battlenet" --invalid-option; then
  fail "Battle.net launcher rejects an unknown argument"
fi
grep -Fq -- "Unknown argument: --invalid-option" "$notifications" ||
  fail "unknown arguments are reported as desktop notifications" "$(cat "$notifications")"
pass "Battle.net launcher reports argument errors as desktop notifications"

rm -f "$notifications" "$test_home/.config/omarchy/launchers/battlenet.conf"
if HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" PATH="$mock_bin:$PATH" OMARCHY_TEST_LOG="$launch_log" OMARCHY_TEST_NOTIFICATIONS="$notifications" OMARCHY_TEST_UMU_STATUS=23 \
  "$ROOT/bin/omarchy-launch-battlenet"; then
  fail "Battle.net launcher preserves umu-run failure status"
else
  status=$?
fi
(( status == 23 )) || fail "Battle.net launcher preserves umu-run failure status" "$status"
grep -Fq -- "umu-run exited with status 23" "$notifications" ||
  fail "umu-run failures are reported as desktop notifications" "$(cat "$notifications")"
pass "Battle.net launcher reports umu-run failures as desktop notifications"

rm -f "$launcher" "$notifications"
if HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" PATH="$mock_bin:$PATH" OMARCHY_TEST_NOTIFICATIONS="$notifications" \
  "$ROOT/bin/omarchy-launch-battlenet"; then
  fail "Battle.net launcher fails when the client is not installed"
fi
grep -Fq -- "Battle.net is not installed" "$notifications" ||
  fail "missing installation is reported as a desktop notification" "$(cat "$notifications")"
pass "Battle.net launcher reports a missing installation as a desktop notification"
